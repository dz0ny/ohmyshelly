import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/websocket_event.dart';

/// WebSocket connection states.
enum WebSocketState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

/// Exception thrown by WebSocket operations.
class WebSocketException implements Exception {
  final String message;
  final dynamic originalError;

  WebSocketException(this.message, [this.originalError]);

  @override
  String toString() => 'WebSocketException: $message';
}

/// Service for managing WebSocket connection to Shelly Cloud.
///
/// Provides real-time device status updates and JSON-RPC command support.
class WebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  // Connection state
  WebSocketState _state = WebSocketState.disconnected;
  final _stateController = StreamController<WebSocketState>.broadcast();

  // Event stream for incoming events
  final _eventController = StreamController<WebSocketEvent>.broadcast();

  // RPC pending completers
  final Map<int, Completer<Map<String, dynamic>>> _pendingRpcs = {};

  // Reconnection
  final _reconnectionStrategy = _ReconnectionStrategy();
  Timer? _reconnectTimer;
  String? _apiUrl;
  String? _token;
  bool _intentionalDisconnect = false;

  /// Current connection state.
  WebSocketState get state => _state;

  /// Stream of connection state changes.
  Stream<WebSocketState> get stateStream => _stateController.stream;

  /// Stream of incoming WebSocket events.
  Stream<WebSocketEvent> get events => _eventController.stream;

  /// Whether the WebSocket is currently connected.
  bool get isConnected => _state == WebSocketState.connected;

  /// Connect to Shelly Cloud WebSocket.
  ///
  /// [apiUrl] is the user's API URL (e.g., https://shelly-220-eu.shelly.cloud)
  /// [token] is the authentication token
  Future<void> connect(String apiUrl, String token) async {
    if (_state == WebSocketState.connecting ||
        _state == WebSocketState.connected) {
      return;
    }

    _apiUrl = apiUrl;
    _token = token;
    _intentionalDisconnect = false;

    await _connect();
  }

  Future<void> _connect() async {
    if (_apiUrl == null || _token == null) {
      if (kDebugMode) {
        debugPrint('[WebSocket] Cannot connect: apiUrl=$_apiUrl, token=${_token != null ? "present" : "null"}');
      }
      return;
    }

    _setState(WebSocketState.connecting);

    try {
      final wsUrl = _buildWebSocketUrl(_apiUrl!, _token!);
      if (kDebugMode) {
        debugPrint('[WebSocket] Connecting to: ${wsUrl.replaceAll(_token!, '***')}');
        // Show last 10 chars of token for identification
        final tokenSuffix = _token!.length > 10 ? _token!.substring(_token!.length - 10) : _token!;
        debugPrint('[WebSocket] Token suffix: ...$tokenSuffix');
        // Check token expiration
        final payload = _decodeJwtPayload(_token!);
        if (payload != null) {
          final exp = payload['exp'] as int?;
          final iat = payload['iat'] as int?;
          if (exp != null) {
            final expTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
            final remaining = expTime.difference(DateTime.now());
            debugPrint('[WebSocket] Token expires in: ${remaining.inMinutes}m (at $expTime)');
            if (iat != null) {
              final issuedTime = DateTime.fromMillisecondsSinceEpoch(iat * 1000);
              debugPrint('[WebSocket] Token issued at: $issuedTime');
            }
            if (remaining.isNegative) {
              debugPrint('[WebSocket] WARNING: Token is EXPIRED!');
            }
          }
        } else {
          debugPrint('[WebSocket] WARNING: Could not decode token payload');
        }
      }

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Wait for connection to be ready
      await _channel!.ready;

      _setState(WebSocketState.connected);
      _reconnectionStrategy.reset();

      if (kDebugMode) {
        debugPrint('[WebSocket] Connected successfully');
      }

      // Listen for messages
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
        cancelOnError: false,
      );
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[WebSocket] Connection failed: $e');
        debugPrint('[WebSocket] Stack: $stack');
      }
      _setState(WebSocketState.disconnected);
      _scheduleReconnect();
    }
  }

  /// Decode JWT payload for debugging
  Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Disconnect from WebSocket.
  void disconnect() {
    _intentionalDisconnect = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _cleanup();
    _setState(WebSocketState.disconnected);
  }

  /// Dispose of all resources.
  void dispose() {
    disconnect();
    _stateController.close();
    _eventController.close();
    _cancelAllPendingRpcs();
  }

  /// Send a JSON-RPC request to a device.
  ///
  /// Returns the response from the device.
  /// Throws [WebSocketException] on timeout or error.
  Future<Map<String, dynamic>> sendRpc({
    required String deviceId,
    required String method,
    Map<String, dynamic>? params,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (_state != WebSocketState.connected) {
      throw WebSocketException('Not connected');
    }

    final trid = _generateTrid();
    final completer = Completer<Map<String, dynamic>>();
    _pendingRpcs[trid] = completer;

    // Convert hex device ID to decimal for RPC calls
    // Shelly Cloud WebSocket expects decimal device IDs
    final rpcDeviceId = _hexToDecimalDeviceId(deviceId);

    // Send request
    final request = {
      'event': 'Shelly:JrpcRequest',
      'trid': trid,
      'deviceId': rpcDeviceId,
      'method': method,
      'params': params ?? {},
    };

    if (kDebugMode) {
      print('[WebSocket] Sending RPC: $method to $rpcDeviceId (from $deviceId)');
    }

    _channel?.sink.add(jsonEncode(request));

    // Wait with timeout
    try {
      return await completer.future.timeout(timeout);
    } on TimeoutException {
      _pendingRpcs.remove(trid);
      throw WebSocketException('RPC timeout: $method');
    }
  }

  // --- Private methods ---

  void _setState(WebSocketState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(newState);
    }
  }

  String _buildWebSocketUrl(String userApiUrl, String token) {
    final uri = Uri.parse(userApiUrl);
    return 'wss://${uri.host}:6113/shelly/wss/hk_sock?t=$token';
  }

  int _generateTrid() => DateTime.now().millisecondsSinceEpoch;

  void _handleMessage(dynamic message) {
    if (message is! String) return;

    try {
      final json = jsonDecode(message) as Map<String, dynamic>;
      final event = json['event'] as String?;

      if (kDebugMode && event != null) {
        // Don't log status changes (too verbose) or Error events (from keepalive)
        if (event != 'Shelly:StatusOnChange' && event != 'Error') {
          debugPrint('[WebSocket] Received event: $event');
        }
      }

      switch (event) {
        case 'Shelly:StatusOnChange':
          _handleStatusChange(json);
        case 'Shelly:Online':
          _handleOnlineChange(json);
        case 'Shelly:JrpcResponse':
          _handleJrpcResponse(json);
        // Ignore other events: Shelly:JrpcRequest, User:EventLog, etc.
      }
    } catch (e) {
      if (kDebugMode) {
        print('[WebSocket] Error parsing message: $e');
      }
    }
  }

  void _handleStatusChange(Map<String, dynamic> json) {
    try {
      final device = json['device'] as Map<String, dynamic>?;
      final status = json['status'] as Map<String, dynamic>?;

      if (device == null || status == null) return;

      final deviceId = device['id'] as String?;
      final deviceCode = device['code'] as String? ?? '';
      final deviceGen = device['gen'] as String? ?? '';

      if (deviceId == null) return;

      // Get hex ID from status if available, otherwise normalize device.id
      final hexId = status['id'] as String? ?? _normalizeDeviceId(deviceId);

      // Extract metadata if present
      final metadataList = json['metadata'] as List<dynamic>?;
      final metadata =
          metadataList?.isNotEmpty == true
              ? metadataList!.first as Map<String, dynamic>
              : null;

      _eventController.add(
        StatusChangeEvent(
          deviceId: hexId,
          deviceCode: deviceCode,
          deviceGen: deviceGen,
          status: status,
          metadata: metadata,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('[WebSocket] Error handling StatusOnChange: $e');
      }
    }
  }

  void _handleOnlineChange(Map<String, dynamic> json) {
    try {
      final device = json['device'] as Map<String, dynamic>?;
      final online = json['online'];

      if (device == null) return;

      final deviceId = device['id'] as String?;
      final deviceCode = device['code'] as String? ?? '';
      final deviceGen = device['gen'] as String? ?? '';

      if (deviceId == null) return;

      _eventController.add(
        OnlineChangeEvent(
          deviceId: _normalizeDeviceId(deviceId),
          deviceCode: deviceCode,
          deviceGen: deviceGen,
          isOnline: online == 1,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('[WebSocket] Error handling Online: $e');
      }
    }
  }

  void _handleJrpcResponse(Map<String, dynamic> json) {
    final trid = json['trid'] as int?;
    if (trid == null || !_pendingRpcs.containsKey(trid)) return;

    final response = json['response'] as Map<String, dynamic>?;
    if (response != null) {
      _pendingRpcs[trid]!.complete(response);
    } else {
      _pendingRpcs[trid]!.completeError(
        WebSocketException('RPC error: ${json['error']}'),
      );
    }
    _pendingRpcs.remove(trid);
  }

  void _handleError(dynamic error) {
    if (kDebugMode) {
      debugPrint('[WebSocket] Stream error: $error');
      debugPrint('[WebSocket] Error type: ${error.runtimeType}');
    }
    _cleanup();
    _setState(WebSocketState.disconnected);

    if (!_intentionalDisconnect) {
      _scheduleReconnect();
    }
  }

  void _handleDone() {
    if (kDebugMode) {
      final closeCode = _channel?.closeCode;
      final closeReason = _channel?.closeReason;
      debugPrint('[WebSocket] Connection closed - code: $closeCode, reason: $closeReason');
      if (closeCode != null) {
        debugPrint('[WebSocket] Close code meaning: ${_getCloseCodeMeaning(closeCode)}');
      }
    }
    _cleanup();
    _setState(WebSocketState.disconnected);

    if (!_intentionalDisconnect) {
      _scheduleReconnect();
    }
  }

  /// Get human-readable meaning for WebSocket close codes
  String _getCloseCodeMeaning(int code) {
    switch (code) {
      case 1000:
        return 'Normal closure';
      case 1001:
        return 'Going away (server shutdown or browser navigating away)';
      case 1002:
        return 'Protocol error';
      case 1003:
        return 'Unsupported data';
      case 1005:
        return 'No status received';
      case 1006:
        return 'Abnormal closure (connection lost without close frame)';
      case 1007:
        return 'Invalid frame payload data';
      case 1008:
        return 'Policy violation';
      case 1009:
        return 'Message too big';
      case 1010:
        return 'Mandatory extension missing';
      case 1011:
        return 'Internal server error';
      case 1012:
        return 'Service restart';
      case 1013:
        return 'Try again later';
      case 1014:
        return 'Bad gateway';
      case 1015:
        return 'TLS handshake failure';
      case 4000:
        return 'Shelly: Unknown error';
      case 4001:
        return 'Shelly: Invalid token / Authentication failed';
      case 4002:
        return 'Shelly: Token expired';
      case 4003:
        return 'Shelly: Rate limited';
      default:
        return 'Unknown code';
    }
  }

  void _cleanup() {
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
  }

  void _scheduleReconnect() {
    if (_intentionalDisconnect) return;

    final delay = _reconnectionStrategy.getNextDelay();
    if (kDebugMode) {
      print('[WebSocket] Reconnecting in ${delay.inSeconds}s');
    }

    _setState(WebSocketState.reconnecting);
    _reconnectTimer = Timer(delay, () {
      if (!_intentionalDisconnect) {
        _connect();
      }
    });
  }

  void _cancelAllPendingRpcs() {
    for (final completer in _pendingRpcs.values) {
      completer.completeError(WebSocketException('Connection closed'));
    }
    _pendingRpcs.clear();
  }

  /// Convert hex device ID to decimal string for RPC calls.
  ///
  /// Shelly Cloud WebSocket expects decimal device IDs for RPC requests,
  /// but our app stores hex MAC addresses internally.
  String _hexToDecimalDeviceId(String hexId) {
    // BLE devices: X-prefixed IDs stay as-is
    if (hexId.startsWith('X')) {
      return hexId;
    }

    // If it's already a decimal number, return as-is
    if (RegExp(r'^\d+$').hasMatch(hexId)) {
      return hexId;
    }

    // Convert hex to decimal
    try {
      final decimal = BigInt.parse(hexId, radix: 16);
      return decimal.toString();
    } catch (e) {
      // If conversion fails, return original
      if (kDebugMode) {
        debugPrint('[WebSocket] Failed to convert hex ID to decimal: $hexId');
      }
      return hexId;
    }
  }

  /// Normalize device ID to hex format for consistent map lookups.
  ///
  /// Device IDs come in multiple formats:
  /// - Hex (12 chars): "e4b063fb8a14" - keep as-is
  /// - Decimal string: "251446242806292" - convert to hex
  /// - X-prefixed (BLE): "XB9592269562702" - keep as-is
  String _normalizeDeviceId(String id) {
    // BLE devices: X-prefixed IDs stay as-is
    if (id.startsWith('X')) {
      return id;
    }

    // Already hex (6 or 12 chars, all hex characters)
    if (RegExp(r'^[0-9a-fA-F]{6,12}$').hasMatch(id)) {
      return id.toLowerCase();
    }

    // Decimal string -> convert to hex
    try {
      return BigInt.parse(id).toRadixString(16).padLeft(12, '0').toLowerCase();
    } catch (_) {
      return id; // Return as-is if conversion fails
    }
  }
}

/// Reconnection strategy with exponential backoff.
class _ReconnectionStrategy {
  int _attempts = 0;
  static const _maxAttempts = 10;
  static const _initialDelay = Duration(seconds: 1);
  static const _maxDelay = Duration(minutes: 2);

  Duration getNextDelay() {
    final delay = _initialDelay * pow(2, _attempts);
    _attempts = min(_attempts + 1, _maxAttempts);
    return delay > _maxDelay ? _maxDelay : delay;
  }

  void reset() => _attempts = 0;
}
