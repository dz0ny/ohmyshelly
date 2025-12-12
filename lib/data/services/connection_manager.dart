import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/local_device_info.dart';
import '../models/device_status.dart';
import 'local_device_service.dart';
import 'mdns_discovery_service.dart';
import 'storage_service.dart';
import 'device_service.dart';

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
class ConnectionManager {
  final LocalDeviceService _localService;
  final DeviceService _cloudService;
  final MdnsDiscoveryService _mdnsService;
  final StorageService _storageService;

  final Map<String, LocalDeviceInfo> _localInfoCache = {};
  StreamSubscription<DiscoveredDevice>? _mdnsSubscription;

  String? _apiUrl;
  String? _token;
  bool _initialized = false;

  ConnectionManager({
    required LocalDeviceService localService,
    required DeviceService cloudService,
    required MdnsDiscoveryService mdnsService,
    required StorageService storageService,
  })  : _localService = localService,
        _cloudService = cloudService,
        _mdnsService = mdnsService,
        _storageService = storageService;

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
    );

    // Persist for future use
    _persistLocalInfo(normalizedId);

    if (kDebugMode) {
      debugPrint('[ConnectionManager] Updated local info for $normalizedId: $ip:$port');
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
      debugPrint('[ConnMgr] getStatus $deviceId: hasIp=$hasIp, canTry=$canTry, shouldRetry=$shouldRetry, state=${localInfo?.state}');
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
      debugPrint('[ConnMgr] Toggle $deviceId -> $action (ip=${localInfo?.localIp}, state=${localInfo?.state}, canTry=$canTry, shouldRetry=$shouldRetry)');
    }

    // Try local first if we have an IP and should retry (respects backoff after failures)
    if (localInfo != null &&
        localInfo.canTryLocal &&
        localInfo.shouldRetryLocal) {
      try {
        if (kDebugMode) {
          debugPrint('[ConnMgr] Trying local toggle for $deviceId @ ${localInfo.localIp}:${localInfo.localPort}');
        }

        _updateLocalInfoState(
          deviceId,
          LocalConnectionState.connecting,
        );

        await _localService.setSwitch(
          localInfo.localIp!,
          turnOn,
          port: localInfo.localPort,
        );

        // Mark as connected on success
        _updateLocalInfoState(
          deviceId,
          LocalConnectionState.connected,
          success: true,
        );

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
  /// Runs in parallel for speed, returns map of deviceId -> isReachable
  Future<Map<String, bool>> probeLocalDevices() async {
    final devicesToProbe = _localInfoCache.entries
        .where((e) => e.value.canTryLocal && e.value.shouldRetryLocal)
        .toList();

    if (devicesToProbe.isEmpty) {
      if (kDebugMode) {
        debugPrint('[ConnMgr] No devices to probe');
      }
      return {};
    }

    if (kDebugMode) {
      debugPrint('[ConnMgr] Probing ${devicesToProbe.length} devices for local reachability...');
    }

    final results = <String, bool>{};
    final stopwatch = Stopwatch()..start();

    // Probe all devices in parallel
    await Future.wait(
      devicesToProbe.map((entry) async {
        final deviceId = entry.key;
        final info = entry.value;

        try {
          _updateLocalInfoState(deviceId, LocalConnectionState.connecting);

          final reachable = await _localService.isReachable(
            info.localIp!,
            info.localPort,
          );

          results[deviceId] = reachable;
          _updateLocalInfoState(
            deviceId,
            reachable ? LocalConnectionState.connected : LocalConnectionState.unreachable,
            success: reachable,
          );

          if (kDebugMode) {
            final status = reachable ? '✓' : '✗';
            debugPrint('[ConnMgr] $status Probe $deviceId @ ${info.localIp}: ${reachable ? 'reachable' : 'unreachable'}');
          }
        } catch (e) {
          results[deviceId] = false;
          _updateLocalInfoState(
            deviceId,
            LocalConnectionState.unreachable,
            success: false,
          );
          if (kDebugMode) {
            debugPrint('[ConnMgr] ✗ Probe $deviceId failed: $e');
          }
        }
      }),
    );

    stopwatch.stop();
    if (kDebugMode) {
      final reachableCount = results.values.where((r) => r).length;
      debugPrint('[ConnMgr] Probe complete: $reachableCount/${results.length} reachable (${stopwatch.elapsedMilliseconds}ms)');
    }

    return results;
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
  }

  /// Dispose resources
  void dispose() {
    _mdnsSubscription?.cancel();
    _mdnsService.dispose();
    _localService.dispose();
  }
}
