import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Exception thrown when local API calls fail
class LocalApiException implements Exception {
  final String message;
  final int? errorCode;
  final bool isAuthRequired;

  LocalApiException({
    required this.message,
    this.errorCode,
    this.isAuthRequired = false,
  });

  @override
  String toString() => 'LocalApiException: $message (code: $errorCode)';
}

/// Service for communicating with Shelly devices over local network
/// using the Gen2/Gen3 JSON-RPC API
class LocalDeviceService {
  final http.Client _client;

  /// Timeout for local API requests (3 seconds for fast local network)
  static const Duration timeout = Duration(seconds: 3);

  LocalDeviceService({http.Client? client}) : _client = client ?? http.Client();

  /// Build RPC URL for local device
  String _rpcUrl(String ip, [int port = 80]) => 'http://$ip/rpc';

  /// Send JSON-RPC request to local device
  ///
  /// [ip] - Device IP address
  /// [method] - RPC method name (e.g., 'Shelly.GetStatus', 'Switch.Set')
  /// [params] - Optional parameters for the method
  /// [port] - HTTP port (default: 80)
  Future<Map<String, dynamic>> rpc(
    String ip,
    String method, {
    Map<String, dynamic>? params,
    int port = 80,
  }) async {
    final url = _rpcUrl(ip, port);
    final body = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'method': method,
      if (params != null && params.isNotEmpty) 'params': params,
    };

    if (kDebugMode) {
      debugPrint('[Local] --> $method @ $ip:$port');
      if (params != null && params.isNotEmpty) {
        debugPrint('[Local]     params: $params');
      }
    }

    final stopwatch = Stopwatch()..start();

    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(timeout);

      stopwatch.stop();

      if (kDebugMode) {
        debugPrint('[Local] <-- $method @ $ip (${stopwatch.elapsedMilliseconds}ms, HTTP ${response.statusCode})');
      }

      if (response.statusCode == 401) {
        if (kDebugMode) {
          debugPrint('[Local] !!! Auth required for $ip');
        }
        throw LocalApiException(
          message: 'Authentication required',
          errorCode: 401,
          isAuthRequired: true,
        );
      }

      if (response.statusCode != 200) {
        if (kDebugMode) {
          debugPrint('[Local] !!! HTTP error ${response.statusCode} for $ip');
        }
        throw LocalApiException(
          message: 'HTTP ${response.statusCode}',
          errorCode: response.statusCode,
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      // Check for RPC error
      if (json.containsKey('error')) {
        final error = json['error'] as Map<String, dynamic>;
        if (kDebugMode) {
          debugPrint('[Local] !!! RPC error: ${error['message']} (code: ${error['code']})');
        }
        throw LocalApiException(
          message: error['message'] as String? ?? 'RPC error',
          errorCode: error['code'] as int?,
        );
      }

      // Return the result (or empty map if null)
      return json['result'] as Map<String, dynamic>? ?? {};
    } on TimeoutException {
      stopwatch.stop();
      if (kDebugMode) {
        debugPrint('[Local] !!! Timeout after ${stopwatch.elapsedMilliseconds}ms for $ip');
      }
      throw LocalApiException(message: 'Connection timeout');
    } on SocketException catch (e) {
      stopwatch.stop();
      if (kDebugMode) {
        debugPrint('[Local] !!! Socket error for $ip: ${e.message}');
      }
      throw LocalApiException(message: 'Network error: ${e.message}');
    } on FormatException catch (e) {
      if (kDebugMode) {
        debugPrint('[Local] !!! Invalid JSON from $ip: $e');
      }
      throw LocalApiException(message: 'Invalid response format');
    }
  }

  /// Get full device status (Shelly.GetStatus)
  /// Returns the same format as cloud API status
  Future<Map<String, dynamic>> getStatus(String ip, [int port = 80]) async {
    final result = await rpc(ip, 'Shelly.GetStatus', port: port);

    // Add timestamp for consistency with cloud API
    result['_updated'] = DateTime.now().toIso8601String();

    return result;
  }

  /// Get device info (Shelly.GetDeviceInfo)
  /// Returns device identification and capabilities
  Future<Map<String, dynamic>> getDeviceInfo(String ip, [int port = 80]) async {
    return rpc(ip, 'Shelly.GetDeviceInfo', port: port);
  }

  /// Get device configuration (Shelly.GetConfig)
  Future<Map<String, dynamic>> getConfig(String ip, [int port = 80]) async {
    return rpc(ip, 'Shelly.GetConfig', port: port);
  }

  /// Set switch state (Switch.Set)
  ///
  /// [ip] - Device IP address
  /// [on] - Turn switch on (true) or off (false)
  /// [switchId] - Switch ID (default: 0)
  /// [port] - HTTP port (default: 80)
  ///
  /// Returns: {'was_on': bool} indicating previous state
  Future<Map<String, dynamic>> setSwitch(
    String ip,
    bool on, {
    int switchId = 0,
    int port = 80,
  }) async {
    return rpc(
      ip,
      'Switch.Set',
      params: {
        'id': switchId,
        'on': on,
      },
      port: port,
    );
  }

  /// Toggle switch state (Switch.Toggle)
  ///
  /// Returns: {'was_on': bool} indicating previous state
  Future<Map<String, dynamic>> toggleSwitch(
    String ip, {
    int switchId = 0,
    int port = 80,
  }) async {
    return rpc(
      ip,
      'Switch.Toggle',
      params: {
        'id': switchId,
      },
      port: port,
    );
  }

  /// Get switch status only (Switch.GetStatus)
  Future<Map<String, dynamic>> getSwitchStatus(
    String ip, {
    int switchId = 0,
    int port = 80,
  }) async {
    return rpc(
      ip,
      'Switch.GetStatus',
      params: {
        'id': switchId,
      },
      port: port,
    );
  }

  /// Check if device is reachable on local network
  /// Uses GetDeviceInfo as a lightweight ping
  Future<bool> isReachable(String ip, [int port = 80]) async {
    try {
      await getDeviceInfo(ip, port);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get device ID from local device info
  /// Useful for matching mDNS discovered devices with cloud devices
  Future<String?> getDeviceId(String ip, [int port = 80]) async {
    try {
      final info = await getDeviceInfo(ip, port);
      // Device ID is in 'id' field (e.g., "shellyplugsg3-E4B063FB8A14")
      // Extract the MAC portion after the dash
      final fullId = info['id'] as String?;
      if (fullId != null && fullId.contains('-')) {
        return fullId.split('-').last.toLowerCase();
      }
      return fullId?.toLowerCase();
    } catch (_) {
      return null;
    }
  }

  /// Dispose of HTTP client
  void dispose() {
    _client.close();
  }
}
