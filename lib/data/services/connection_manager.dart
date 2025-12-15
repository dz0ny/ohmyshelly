import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/local_device_info.dart';
import '../models/device_status.dart';
import 'local_device_service.dart';
import 'mdns_discovery_service.dart';
import 'storage_service.dart';
import 'device_service.dart';
import 'network_monitor_service.dart';

/// Result of a device status fetch, including connection source
class DeviceStatusResult {
  final DeviceStatus? status;
  final ConnectionSource source;

  DeviceStatusResult({
    this.status,
    required this.source,
  });
}

/// Orchestrates local-first connection strategy with cloud fallback
///
/// This manager:
/// 1. Discovers devices via mDNS
/// 2. Extracts IPs from cloud API responses
/// 3. Tries local connections first, falls back to cloud
/// 4. Persists discovered IPs for faster reconnection
/// 5. Monitors network changes and re-evaluates connections
class ConnectionManager {
  final LocalDeviceService _localService;
  final DeviceService _cloudService;
  final MdnsDiscoveryService _mdnsService;
  final StorageService _storageService;
  final NetworkMonitorService _networkMonitor;

  final Map<String, LocalDeviceInfo> _localInfoCache = {};
  StreamSubscription<DiscoveredDevice>? _mdnsSubscription;
  StreamSubscription<NetworkChangeEvent>? _networkSubscription;

  String? _apiUrl;
  String? _token;
  bool _initialized = false;

  /// Current WiFi network name (if known)
  String? _currentWifiName;
  String? get currentWifiName => _currentWifiName;

  /// Whether we're currently on WiFi (local access may be available)
  bool get isOnWifi => _networkMonitor.currentState.isWifi;

  /// Whether local access is disabled due to being off WiFi
  bool _localAccessDisabled = false;
  bool get isLocalAccessDisabled => _localAccessDisabled;

  /// Stream controller for notifying listeners about network changes
  final _networkChangeController = StreamController<NetworkChangeEvent>.broadcast();

  /// Stream of network change events for providers to listen to
  Stream<NetworkChangeEvent> get networkChanges => _networkChangeController.stream;

  ConnectionManager({
    required LocalDeviceService localService,
    required DeviceService cloudService,
    required MdnsDiscoveryService mdnsService,
    required StorageService storageService,
    required NetworkMonitorService networkMonitor,
  })  : _localService = localService,
        _cloudService = cloudService,
        _mdnsService = mdnsService,
        _storageService = storageService,
        _networkMonitor = networkMonitor;

  /// Whether the manager has been initialized
  bool get isInitialized => _initialized;

  /// Whether mDNS discovery is running
  bool get isDiscovering => _mdnsService.isDiscovering;

  /// Initialize with cloud credentials and start discovery
  Future<void> initialize(String apiUrl, String token) async {
    if (kDebugMode) {
      debugPrint('[ConnMgr] Initializing connection manager...');
    }

    _apiUrl = apiUrl;
    _token = token;

    // Load persisted local IPs from storage
    await _loadPersistedLocalInfo();

    // Start network monitoring
    await _startNetworkMonitoring();

    // Subscribe to mDNS discoveries
    _mdnsSubscription?.cancel();
    _mdnsSubscription = _mdnsService.discoveredDevices.listen(
      _onDeviceDiscovered,
    );

    // Start mDNS discovery (non-blocking, failure is non-fatal)
    try {
      await _mdnsService.startDiscovery();
      if (kDebugMode) {
        debugPrint('[ConnMgr] mDNS discovery started successfully');
      }
    } catch (e) {
      // mDNS failure is non-fatal - continue with cloud-only or persisted IPs
      if (kDebugMode) {
        debugPrint('[ConnMgr] mDNS discovery failed (non-fatal): $e');
      }
    }

    _initialized = true;
    if (kDebugMode) {
      debugPrint('[ConnMgr] Initialization complete, ${_localInfoCache.length} cached devices');
    }
  }

  /// Start network monitoring and handle initial state
  Future<void> _startNetworkMonitoring() async {
    // Start network monitor
    await _networkMonitor.startMonitoring();

    // Get initial network state
    _currentWifiName = _networkMonitor.currentState.wifiName;
    _localAccessDisabled = !_networkMonitor.currentState.isWifi;

    if (kDebugMode) {
      debugPrint('[ConnMgr] Network state: wifi=${_networkMonitor.currentState.isWifi}, '
          'name=$_currentWifiName, localDisabled=$_localAccessDisabled');
    }

    // Subscribe to network change events
    _networkSubscription?.cancel();
    _networkSubscription = _networkMonitor.events.listen(_onNetworkChange);
  }

  /// Handle network change events
  void _onNetworkChange(NetworkChangeEvent event) {
    if (kDebugMode) {
      debugPrint('[ConnMgr] Network change event: $event');
    }

    switch (event) {
      case NetworkChangeEvent.wifiConnected:
        _handleWifiConnected();
      case NetworkChangeEvent.wifiChanged:
        _handleWifiChanged();
      case NetworkChangeEvent.wifiDisconnected:
        _handleWifiDisconnected();
      case NetworkChangeEvent.connectivityLost:
        _handleConnectivityLost();
      case NetworkChangeEvent.connectivityRestored:
        _handleConnectivityRestored();
    }

    // Forward event to listeners (e.g., DeviceProvider)
    _networkChangeController.add(event);
  }

  /// Handle connecting to WiFi
  void _handleWifiConnected() {
    if (kDebugMode) {
      debugPrint('[ConnMgr] WiFi connected, enabling local access');
    }

    _localAccessDisabled = false;
    _currentWifiName = _networkMonitor.currentState.wifiName;

    // Reset all local connection states to allow fresh probing
    _resetLocalConnectionStates();
  }

  /// Handle switching to a different WiFi network
  void _handleWifiChanged() {
    final newWifiName = _networkMonitor.currentState.wifiName;

    if (kDebugMode) {
      debugPrint('[ConnMgr] WiFi changed: $_currentWifiName -> $newWifiName');
    }

    _currentWifiName = newWifiName;

    // Reset all local connection states since we're on a new network
    // Devices from the old network likely have different IPs
    _resetLocalConnectionStates();
  }

  /// Handle disconnecting from WiFi (switched to cellular or other)
  void _handleWifiDisconnected() {
    if (kDebugMode) {
      debugPrint('[ConnMgr] WiFi disconnected, disabling local access');
    }

    _localAccessDisabled = true;
    _currentWifiName = null;

    // Mark all devices as unreachable locally (force cloud fallback)
    _markAllDevicesUnreachable();
  }

  /// Handle losing all connectivity
  void _handleConnectivityLost() {
    if (kDebugMode) {
      debugPrint('[ConnMgr] Connectivity lost');
    }

    _localAccessDisabled = true;
    _currentWifiName = null;
  }

  /// Handle connectivity restored (to non-WiFi)
  void _handleConnectivityRestored() {
    if (kDebugMode) {
      debugPrint('[ConnMgr] Connectivity restored (non-WiFi)');
    }

    // Still disable local access if not on WiFi
    _localAccessDisabled = !_networkMonitor.currentState.isWifi;
  }

  /// Reset all local connection states to allow fresh probing
  void _resetLocalConnectionStates() {
    if (kDebugMode) {
      debugPrint('[ConnMgr] Resetting ${_localInfoCache.length} local connection states');
    }

    for (final key in _localInfoCache.keys.toList()) {
      final info = _localInfoCache[key];
      if (info != null) {
        _localInfoCache[key] = info.copyWith(
          state: LocalConnectionState.unknown,
          lastLocalFailure: null, // Clear backoff
        );
      }
    }
  }

  /// Mark all devices as unreachable locally (force cloud usage)
  void _markAllDevicesUnreachable() {
    if (kDebugMode) {
      debugPrint('[ConnMgr] Marking all ${_localInfoCache.length} devices as unreachable');
    }

    for (final key in _localInfoCache.keys.toList()) {
      final info = _localInfoCache[key];
      if (info != null) {
        _localInfoCache[key] = info.copyWith(
          state: LocalConnectionState.unreachable,
        );
      }
    }
  }

  /// Handle newly discovered device from mDNS
  void _onDeviceDiscovered(DiscoveredDevice discovered) {
    if (discovered.deviceId == null) {
      if (kDebugMode) {
        debugPrint('[ConnMgr] mDNS device without ID: ${discovered.name}');
      }
      return;
    }

    final ip = discovered.primaryIp;
    if (ip != null) {
      if (kDebugMode) {
        debugPrint('[ConnMgr] mDNS discovered: ${discovered.deviceId} @ $ip:${discovered.port}');
      }
      _updateLocalInfo(
        discovered.deviceId!,
        ip,
        discovered.port,
      );
    }
  }

  /// Update local info for a device (from mDNS or cloud API)
  void _updateLocalInfo(String deviceId, String ip, [int port = 80]) {
    final normalizedId = deviceId.toLowerCase();
    final existing = _localInfoCache[normalizedId];

    _localInfoCache[normalizedId] = LocalDeviceInfo(
      deviceId: normalizedId,
      localIp: ip,
      localPort: port,
      state: existing?.state ?? LocalConnectionState.unknown,
      lastLocalSuccess: existing?.lastLocalSuccess,
      lastLocalFailure: existing?.lastLocalFailure,
      // Store current WiFi name when device is discovered
      discoveredOnWifi: _currentWifiName ?? existing?.discoveredOnWifi,
    );

    // Persist for future use
    _persistLocalInfo(normalizedId);

    if (kDebugMode) {
      debugPrint('[ConnectionManager] Updated local info for $normalizedId: $ip:$port (wifi: $_currentWifiName)');
    }
  }

  /// Register IP address from cloud API response for a device
  void registerCloudIp(String deviceId, String? ip) {
    if (ip == null || ip.isEmpty) return;
    _updateLocalInfo(deviceId, ip);
  }

  /// Get device status with local-first strategy
  ///
  /// Tries local connection first if available, falls back to cloud on failure
  Future<DeviceStatusResult> getDeviceStatus(
    String deviceId,
    String deviceCode,
  ) async {
    final localInfo = _localInfoCache[deviceId.toLowerCase()];

    if (kDebugMode) {
      final hasIp = localInfo?.localIp != null;
      final canTry = localInfo?.canTryLocal ?? false;
      final shouldRetry = localInfo?.shouldRetryLocal ?? false;
      debugPrint('[ConnMgr] getStatus $deviceId: hasIp=$hasIp, canTry=$canTry, shouldRetry=$shouldRetry, '
          'state=${localInfo?.state}, localDisabled=$_localAccessDisabled');
    }

    // Skip local if local access is disabled (not on WiFi)
    if (_localAccessDisabled) {
      if (kDebugMode) {
        debugPrint('[ConnMgr] → Local access disabled, using cloud for $deviceId');
      }
      return DeviceStatusResult(
        status: null,
        source: ConnectionSource.cloud,
      );
    }

    // Try local first if we have an IP and should retry
    if (localInfo != null &&
        localInfo.canTryLocal &&
        localInfo.shouldRetryLocal) {
      try {
        if (kDebugMode) {
          debugPrint('[ConnMgr] Trying local for $deviceId @ ${localInfo.localIp}:${localInfo.localPort}');
        }

        _updateLocalInfoState(
          deviceId,
          LocalConnectionState.connecting,
        );

        final localStatus = await _localService.getStatus(
          localInfo.localIp!,
          localInfo.localPort,
        );

        // Mark success
        _updateLocalInfoState(
          deviceId,
          LocalConnectionState.connected,
          success: true,
        );

        // Parse status using existing DeviceService parser
        final status = _cloudService.parseDeviceStatus(localStatus, deviceCode);

        if (kDebugMode) {
          debugPrint('[ConnMgr] ✓ Local status success for $deviceId');
        }

        return DeviceStatusResult(
          status: status.copyWithSource(ConnectionSource.local),
          source: ConnectionSource.local,
        );
      } catch (e) {
        // Mark failure and fall through to cloud
        _updateLocalInfoState(
          deviceId,
          LocalConnectionState.unreachable,
          success: false,
        );
        if (kDebugMode) {
          debugPrint('[ConnMgr] ✗ Local status failed for $deviceId: $e');
        }
      }
    }

    // Return cloud source indicator (actual cloud fetch handled by DeviceProvider)
    if (kDebugMode) {
      debugPrint('[ConnMgr] → Using cloud for $deviceId');
    }
    return DeviceStatusResult(
      status: null,
      source: ConnectionSource.cloud,
    );
  }

  /// Toggle device with local-first strategy
  ///
  /// Returns true if toggle succeeded (via local or cloud)
  Future<bool> toggleDevice(String deviceId, bool turnOn) async {
    final localInfo = _localInfoCache[deviceId.toLowerCase()];
    final action = turnOn ? 'ON' : 'OFF';

    if (kDebugMode) {
      final canTry = localInfo?.canTryLocal ?? false;
      final shouldRetry = localInfo?.shouldRetryLocal ?? false;
      debugPrint('[ConnMgr] Toggle $deviceId -> $action (ip=${localInfo?.localIp}, state=${localInfo?.state}, '
          'canTry=$canTry, shouldRetry=$shouldRetry, localDisabled=$_localAccessDisabled)');
    }

    // Skip local if local access is disabled (not on WiFi)
    final shouldTryLocal = !_localAccessDisabled &&
        localInfo != null &&
        localInfo.canTryLocal &&
        localInfo.shouldRetryLocal;

    // Try local first if we have an IP and should retry (respects backoff after failures)
    if (shouldTryLocal) {
      try {
        if (kDebugMode) {
          debugPrint('[ConnMgr] Trying local toggle for $deviceId @ ${localInfo.localIp}:${localInfo.localPort}');
        }

        // Don't set 'connecting' state here to avoid UI flicker

        await _localService.setSwitch(
          localInfo.localIp!,
          turnOn,
          port: localInfo.localPort,
        );

        // Mark as connected on success (only if not already connected)
        if (localInfo.state != LocalConnectionState.connected) {
          _updateLocalInfoState(
            deviceId,
            LocalConnectionState.connected,
            success: true,
          );
        } else {
          // Just update success timestamp without state change
          _updateLocalInfoTimestamp(deviceId, success: true);
        }

        if (kDebugMode) {
          debugPrint('[ConnMgr] ✓ Local toggle $action succeeded for $deviceId');
        }

        return true;
      } catch (e) {
        // Mark as unreachable and fall through to cloud
        _updateLocalInfoState(
          deviceId,
          LocalConnectionState.unreachable,
          success: false,
        );
        if (kDebugMode) {
          debugPrint('[ConnMgr] ✗ Local toggle failed for $deviceId: $e, falling back to cloud');
        }
      }
    } else if (kDebugMode && localInfo != null) {
      debugPrint('[ConnMgr] Skipping local for $deviceId: canTry=${localInfo.canTryLocal}, shouldRetry=${localInfo.shouldRetryLocal}');
    }

    // Fall back to cloud
    if (_apiUrl == null || _token == null) {
      if (kDebugMode) {
        debugPrint('[ConnMgr] ✗ No cloud credentials for $deviceId');
      }
      return false;
    }

    try {
      if (kDebugMode) {
        debugPrint('[ConnMgr] Trying cloud toggle for $deviceId');
      }
      await _cloudService.toggleDevice(_apiUrl!, _token!, deviceId, turnOn);
      if (kDebugMode) {
        debugPrint('[ConnMgr] ✓ Cloud toggle $action succeeded for $deviceId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ConnMgr] ✗ Cloud toggle failed for $deviceId: $e');
      }
      return false;
    }
  }

  /// Get local connection info for a device
  LocalDeviceInfo? getLocalInfo(String deviceId) {
    return _localInfoCache[deviceId.toLowerCase()];
  }

  /// Get connection source for a device
  ConnectionSource getConnectionSource(String deviceId) {
    final info = _localInfoCache[deviceId.toLowerCase()];
    if (info?.state == LocalConnectionState.connected) {
      return ConnectionSource.local;
    }
    return ConnectionSource.cloud;
  }

  /// Check if device can be reached locally
  Future<bool> isLocalReachable(String deviceId) async {
    final info = _localInfoCache[deviceId.toLowerCase()];
    if (info?.localIp == null) return false;

    return _localService.isReachable(info!.localIp!, info.localPort);
  }

  /// Force refresh local connection status for a device
  Future<void> refreshLocalStatus(String deviceId) async {
    final info = _localInfoCache[deviceId.toLowerCase()];
    if (info?.localIp == null) return;

    final reachable = await isLocalReachable(deviceId);
    _updateLocalInfoState(
      deviceId,
      reachable ? LocalConnectionState.connected : LocalConnectionState.unreachable,
      success: reachable,
    );
  }

  /// Probe all known devices to check local reachability
  /// Runs in parallel for speed, returns true if any state changed
  Future<bool> probeLocalDevices() async {
    final devicesToProbe = _localInfoCache.entries
        .where((e) => e.value.canTryLocal && e.value.shouldRetryLocal)
        .toList();

    if (devicesToProbe.isEmpty) {
      if (kDebugMode) {
        debugPrint('[ConnMgr] No devices to probe');
      }
      return false;
    }

    if (kDebugMode) {
      debugPrint('[ConnMgr] Probing ${devicesToProbe.length} devices for local reachability...');
    }

    final results = <String, bool>{};
    var stateChanged = false;
    final stopwatch = Stopwatch()..start();

    // Probe all devices in parallel
    // Don't set intermediate 'connecting' state to avoid UI flicker
    await Future.wait(
      devicesToProbe.map((entry) async {
        final deviceId = entry.key;
        final info = entry.value;
        final previousState = info.state;

        try {
          final reachable = await _localService.isReachable(
            info.localIp!,
            info.localPort,
          );

          results[deviceId] = reachable;
          final newState = reachable ? LocalConnectionState.connected : LocalConnectionState.unreachable;

          // Only update if state actually changed
          if (previousState != newState) {
            _updateLocalInfoState(deviceId, newState, success: reachable);
            stateChanged = true;
          } else {
            // Just update timestamp
            _updateLocalInfoTimestamp(deviceId, success: reachable);
          }

          if (kDebugMode) {
            final status = reachable ? '✓' : '✗';
            debugPrint('[ConnMgr] $status Probe $deviceId @ ${info.localIp}: ${reachable ? 'reachable' : 'unreachable'}');
          }
        } catch (e) {
          results[deviceId] = false;
          // Only update if state changed
          if (previousState != LocalConnectionState.unreachable) {
            _updateLocalInfoState(deviceId, LocalConnectionState.unreachable, success: false);
            stateChanged = true;
          }
          if (kDebugMode) {
            debugPrint('[ConnMgr] ✗ Probe $deviceId failed: $e');
          }
        }
      }),
    );

    stopwatch.stop();
    if (kDebugMode) {
      final reachableCount = results.values.where((r) => r).length;
      debugPrint('[ConnMgr] Probe complete: $reachableCount/${results.length} reachable (${stopwatch.elapsedMilliseconds}ms), stateChanged=$stateChanged');
    }

    return stateChanged;
  }

  void _updateLocalInfoState(
    String deviceId,
    LocalConnectionState state, {
    bool? success,
  }) {
    final normalizedId = deviceId.toLowerCase();
    final existing = _localInfoCache[normalizedId];
    if (existing == null) return;

    _localInfoCache[normalizedId] = existing.copyWith(
      state: state,
      lastLocalSuccess: success == true ? DateTime.now() : null,
      lastLocalFailure: success == false ? DateTime.now() : null,
    );

    _persistLocalInfo(normalizedId);
  }

  /// Update only the timestamp without changing state (to avoid UI flicker)
  void _updateLocalInfoTimestamp(String deviceId, {required bool success}) {
    final normalizedId = deviceId.toLowerCase();
    final existing = _localInfoCache[normalizedId];
    if (existing == null) return;

    _localInfoCache[normalizedId] = existing.copyWith(
      lastLocalSuccess: success ? DateTime.now() : null,
      lastLocalFailure: !success ? DateTime.now() : null,
    );

    // Don't persist on every toggle to reduce I/O
  }

  Future<void> _loadPersistedLocalInfo() async {
    final stored = await _storageService.getLocalDeviceInfo();
    for (final entry in stored.entries) {
      _localInfoCache[entry.key] = entry.value;
    }
    if (kDebugMode && stored.isNotEmpty) {
      debugPrint('[ConnectionManager] Loaded ${stored.length} persisted local devices');
    }
  }

  Future<void> _persistLocalInfo(String deviceId) async {
    final info = _localInfoCache[deviceId];
    if (info != null) {
      await _storageService.saveLocalDeviceInfo(deviceId, info);
    }
  }

  /// Clear all local connection data (call on logout)
  Future<void> clear() async {
    _localInfoCache.clear();
    await _storageService.clearLocalDeviceInfo();
    _apiUrl = null;
    _token = null;
    _initialized = false;
    _currentWifiName = null;
    _localAccessDisabled = false;
  }

  /// Dispose resources
  void dispose() {
    _mdnsSubscription?.cancel();
    _networkSubscription?.cancel();
    _networkChangeController.close();
    _mdnsService.dispose();
    _localService.dispose();
    _networkMonitor.dispose();
  }
}
