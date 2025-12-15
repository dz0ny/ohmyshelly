import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';

/// Network state with connectivity and WiFi information
class NetworkState {
  final bool isConnected;
  final bool isWifi;
  final bool isCellular;
  final String? wifiName;

  const NetworkState({
    required this.isConnected,
    required this.isWifi,
    required this.isCellular,
    this.wifiName,
  });

  /// No connection state
  static const disconnected = NetworkState(
    isConnected: false,
    isWifi: false,
    isCellular: false,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NetworkState &&
        other.isConnected == isConnected &&
        other.isWifi == isWifi &&
        other.isCellular == isCellular &&
        other.wifiName == wifiName;
  }

  @override
  int get hashCode => Object.hash(isConnected, isWifi, isCellular, wifiName);

  @override
  String toString() =>
      'NetworkState(connected: $isConnected, wifi: $isWifi, cellular: $isCellular, wifiName: $wifiName)';
}

/// Event emitted when network changes in a way that affects local connections
enum NetworkChangeEvent {
  /// Connected to WiFi (may have local access)
  wifiConnected,

  /// Switched to a different WiFi network
  wifiChanged,

  /// Disconnected from WiFi (lost local access)
  wifiDisconnected,

  /// Network connectivity restored
  connectivityRestored,

  /// Network connectivity lost
  connectivityLost,
}

/// Monitors network connectivity and WiFi changes
///
/// This service:
/// 1. Detects when device switches between WiFi networks
/// 2. Detects when device loses WiFi connection
/// 3. Emits events for ConnectionManager to react to
class NetworkMonitorService {
  final Connectivity _connectivity = Connectivity();
  final NetworkInfo _networkInfo = NetworkInfo();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Current network state
  NetworkState _currentState = NetworkState.disconnected;
  NetworkState get currentState => _currentState;

  /// Last known WiFi name (for detecting network changes)
  String? _lastWifiName;

  /// Stream of network change events
  final _eventController = StreamController<NetworkChangeEvent>.broadcast();
  Stream<NetworkChangeEvent> get events => _eventController.stream;

  /// Stream of network state changes
  final _stateController = StreamController<NetworkState>.broadcast();
  Stream<NetworkState> get stateStream => _stateController.stream;

  bool _isMonitoring = false;
  bool get isMonitoring => _isMonitoring;

  /// Start monitoring network changes
  Future<void> startMonitoring() async {
    if (_isMonitoring) return;
    _isMonitoring = true;

    if (kDebugMode) {
      debugPrint('[NetworkMonitor] Starting network monitoring...');
    }

    // Get initial state
    await _updateNetworkState();

    // Subscribe to connectivity changes
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );

    if (kDebugMode) {
      debugPrint('[NetworkMonitor] Initial state: $_currentState');
    }
  }

  /// Stop monitoring
  void stopMonitoring() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _isMonitoring = false;
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    if (kDebugMode) {
      debugPrint('[NetworkMonitor] Connectivity changed: $results');
    }
    _updateNetworkState();
  }

  /// Update network state and emit events
  Future<void> _updateNetworkState() async {
    final previousState = _currentState;
    final previousWifiName = _lastWifiName;

    // Check current connectivity
    final connectivityResults = await _connectivity.checkConnectivity();
    final hasWifi = connectivityResults.contains(ConnectivityResult.wifi);
    final hasCellular = connectivityResults.contains(ConnectivityResult.mobile);
    final hasConnection = connectivityResults.isNotEmpty &&
        !connectivityResults.contains(ConnectivityResult.none);

    // Try to get WiFi name (may fail due to permissions)
    String? wifiName;
    if (hasWifi) {
      try {
        wifiName = await _networkInfo.getWifiName();
        // Android returns WiFi name in quotes, remove them
        if (wifiName != null) {
          wifiName = wifiName.replaceAll('"', '');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[NetworkMonitor] Could not get WiFi name: $e');
        }
      }
    }

    // Update state
    _currentState = NetworkState(
      isConnected: hasConnection,
      isWifi: hasWifi,
      isCellular: hasCellular,
      wifiName: wifiName,
    );
    _lastWifiName = wifiName;

    if (kDebugMode) {
      debugPrint('[NetworkMonitor] State updated: $_currentState');
    }

    // Emit state change
    _stateController.add(_currentState);

    // Determine what event to emit
    final event = _determineEvent(
      previousState: previousState,
      previousWifiName: previousWifiName,
      currentState: _currentState,
      currentWifiName: wifiName,
    );

    if (event != null) {
      if (kDebugMode) {
        debugPrint('[NetworkMonitor] Emitting event: $event');
      }
      _eventController.add(event);
    }
  }

  /// Determine which event to emit based on state change
  NetworkChangeEvent? _determineEvent({
    required NetworkState previousState,
    required String? previousWifiName,
    required NetworkState currentState,
    required String? currentWifiName,
  }) {
    // Connection lost
    if (previousState.isConnected && !currentState.isConnected) {
      return NetworkChangeEvent.connectivityLost;
    }

    // Connection restored
    if (!previousState.isConnected && currentState.isConnected) {
      if (currentState.isWifi) {
        return NetworkChangeEvent.wifiConnected;
      }
      return NetworkChangeEvent.connectivityRestored;
    }

    // WiFi disconnected (switched to cellular or other)
    if (previousState.isWifi && !currentState.isWifi) {
      return NetworkChangeEvent.wifiDisconnected;
    }

    // WiFi connected (switched from cellular or other)
    if (!previousState.isWifi && currentState.isWifi) {
      return NetworkChangeEvent.wifiConnected;
    }

    // WiFi name changed (switched WiFi networks)
    if (previousState.isWifi &&
        currentState.isWifi &&
        previousWifiName != null &&
        currentWifiName != null &&
        previousWifiName != currentWifiName) {
      return NetworkChangeEvent.wifiChanged;
    }

    // WiFi name became available (first time we could read it)
    if (previousState.isWifi &&
        currentState.isWifi &&
        previousWifiName == null &&
        currentWifiName != null) {
      // This might indicate we just connected to a new network
      // or permissions were just granted
      return null; // No event, state is the same
    }

    return null;
  }

  /// Force a network state check (useful after app resumes)
  Future<void> checkNetwork() async {
    await _updateNetworkState();
  }

  /// Check if local network access is likely available
  ///
  /// Returns true if connected to WiFi (local devices might be reachable)
  bool get hasLocalNetworkAccess => _currentState.isWifi;

  /// Dispose resources
  void dispose() {
    stopMonitoring();
    _eventController.close();
    _stateController.close();
  }
}
