import 'package:flutter/foundation.dart';
import '../models/device.dart';
import '../models/device_status.dart';
import '../models/statistics.dart';
import '../../core/utils/device_type_helper.dart';
import 'api_service.dart';

/// Cache entry with expiration
class _CacheEntry<T> {
  final T data;
  final DateTime expiresAt;

  _CacheEntry(this.data, this.expiresAt);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Result from fetching devices with their statuses
class DevicesWithStatuses {
  final List<Device> devices;
  final Map<String, DeviceStatus> statuses;

  DevicesWithStatuses({
    required this.devices,
    required this.statuses,
  });
}

/// Device metadata from get_all_lists API (names, rooms, etc.)
class DeviceMetadata {
  final String id;
  final String name;
  final String? roomName;
  final int? roomId;
  final String? icon;
  final String? category;
  final String? relayUsage;

  DeviceMetadata({
    required this.id,
    required this.name,
    this.roomName,
    this.roomId,
    this.icon,
    this.category,
    this.relayUsage,
  });
}

class DeviceService {
  final ApiService _apiService;

  // Statistics cache: key -> cached data with expiration
  final Map<String, _CacheEntry<WeatherStatistics>> _weatherStatsCache = {};
  final Map<String, _CacheEntry<PowerStatistics>> _powerStatsCache = {};

  // Cache TTLs
  static const Duration _currentDayTtl = Duration(minutes: 5);
  static const Duration _historicalTtl = Duration(hours: 1);

  DeviceService(this._apiService);

  /// Generate cache key for statistics
  String _statsCacheKey(String deviceId, DateTime from, DateTime to) {
    return '$deviceId:${from.toIso8601String()}:${to.toIso8601String()}';
  }

  /// Determine TTL based on whether date range includes today
  Duration _getTtlForRange(DateTime from, DateTime to) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    // If range includes today, use shorter TTL
    if (to.isAfter(today) && from.isBefore(tomorrow)) {
      return _currentDayTtl;
    }
    return _historicalTtl;
  }

  /// Clear expired cache entries
  void _cleanExpiredCache() {
    _weatherStatsCache.removeWhere((_, entry) => entry.isExpired);
    _powerStatsCache.removeWhere((_, entry) => entry.isExpired);
  }

  /// Clear all statistics cache (call on logout or when needed)
  void clearStatisticsCache() {
    _weatherStatsCache.clear();
    _powerStatsCache.clear();
  }

  /// Fetch device metadata (names, rooms) from get_all_lists API
  Future<Map<String, DeviceMetadata>> fetchDeviceMetadata(
    String apiUrl,
    String token,
  ) async {
    final response = await _apiService.post(
      '$apiUrl/interface/device/get_all_lists',
      {},
      token: token,
    );

    if (response['isok'] != true || response['data'] == null) {
      return {};
    }

    final data = response['data'] as Map<String, dynamic>;
    final devicesData = data['devices'] as Map<String, dynamic>? ?? {};
    final roomsData = data['rooms'] as Map<String, dynamic>? ?? {};

    // Build room name lookup
    final roomNames = <int, String>{};
    roomsData.forEach((roomId, roomJson) {
      if (roomJson is Map<String, dynamic>) {
        final id = int.tryParse(roomId) ?? roomJson['id'] as int?;
        if (id != null) {
          roomNames[id] = roomJson['name'] as String? ?? '';
        }
      }
    });

    // Build device metadata
    final metadata = <String, DeviceMetadata>{};
    devicesData.forEach((deviceId, deviceJson) {
      if (deviceJson is Map<String, dynamic>) {
        final roomId = deviceJson['room_id'] as int?;
        metadata[deviceId] = DeviceMetadata(
          id: deviceId,
          name: deviceJson['name'] as String? ?? deviceId,
          roomId: roomId,
          roomName: roomId != null ? roomNames[roomId] : null,
          icon: deviceJson['icon'] as String?,
          category: deviceJson['category'] as String?,
          relayUsage: deviceJson['relay_usage'] as String?,
        );
      }
    });

    return metadata;
  }

  /// Fetch devices and their statuses using v2/devices/get API
  /// Also fetches user-set names from get_all_lists API
  Future<DevicesWithStatuses> fetchDevicesWithStatuses(
    String apiUrl,
    String token,
  ) async {
    // Fetch metadata (names, rooms) and device status in parallel
    final results = await Future.wait([
      fetchDeviceMetadata(apiUrl, token),
      _fetchDeviceStatuses(apiUrl, token),
    ]);

    final metadata = results[0] as Map<String, DeviceMetadata>;
    final statusResult = results[1] as _DeviceStatusResult;

    // Merge metadata into devices
    final devices = statusResult.devices.map((device) {
      final meta = metadata[device.id];
      if (meta != null) {
        return device.copyWith(
          name: meta.name,
          roomName: meta.roomName,
          roomId: meta.roomId?.toString(),
          icon: meta.icon,
          relayUsage: meta.relayUsage,
        );
      }
      return device;
    }).toList();

    if (kDebugMode) {
      for (final device in devices) {
        debugPrint('Device: ${device.name} | Room: ${device.roomName ?? "none"} | Code: "${device.code}" | Type: ${device.type}');
      }
    }

    return DevicesWithStatuses(devices: devices, statuses: statusResult.statuses);
  }

  /// Internal: fetch device statuses from v2 API
  Future<_DeviceStatusResult> _fetchDeviceStatuses(
    String apiUrl,
    String token,
  ) async {
    final response = await _apiService.postJson(
      '$apiUrl/v2/devices/get',
      {
        'select': ['status', 'settings'],
        'show': ['offline', 'shared'],
      },
      token: token,
    );

    // v2 API returns array directly, or error with isok: false
    if (response['isok'] == false) {
      final errors = response['errors'] as Map<String, dynamic>?;
      throw ApiException(
        message: errors?['message'] as String? ?? 'Failed to fetch devices',
      );
    }

    // Response is a list of devices
    final devicesList = response['data'] as List<dynamic>? ?? [];

    final devices = <Device>[];
    final statuses = <String, DeviceStatus>{};

    for (final deviceJson in devicesList) {
      if (deviceJson is Map<String, dynamic>) {
        final device = Device.fromV2Json(deviceJson);
        devices.add(device);

        // Parse status from embedded 'status' field
        final statusJson = deviceJson['status'] as Map<String, dynamic>?;
        if (statusJson != null) {
          // Add timestamp for API responses (used for WebSocket vs API precedence)
          final statusWithTimestamp = Map<String, dynamic>.from(statusJson);
          statusWithTimestamp['_updated'] = DateTime.now().toIso8601String();
          statuses[device.id] = parseDeviceStatus(statusWithTimestamp, device.code);
        }
      }
    }

    return _DeviceStatusResult(devices: devices, statuses: statuses);
  }

  /// Legacy: Fetch devices only (without status)
  Future<List<Device>> fetchDevices(String apiUrl, String token) async {
    final result = await fetchDevicesWithStatuses(apiUrl, token);
    return result.devices;
  }

  /// Legacy: Fetch all statuses separately
  Future<Map<String, DeviceStatus>> fetchAllStatuses(
    String apiUrl,
    String token,
  ) async {
    final result = await fetchDevicesWithStatuses(apiUrl, token);
    return result.statuses;
  }

  /// Parse device status from JSON.
  /// Made public for reuse in WebSocket event handling.
  DeviceStatus parseDeviceStatus(Map<String, dynamic> json, [String? deviceCode]) {
    // Determine device type from code or status data
    final code = deviceCode ??
        json['code'] as String? ??
        (json['_dev_info'] as Map<String, dynamic>?)?['code'] as String? ??
        '';
    final deviceType = DeviceTypeHelper.fromCode(code);

    PowerDeviceStatus? powerStatus;
    WeatherStationStatus? weatherStatus;
    GatewayStatus? gatewayStatus;

    switch (deviceType) {
      case DeviceType.powerSwitch:
        if (json.containsKey('switch:0')) {
          powerStatus = PowerDeviceStatus.fromJson(json);
        }
        break;
      case DeviceType.weatherStation:
        if (json.containsKey('temperature:0')) {
          weatherStatus = WeatherStationStatus.fromJson(json);
        }
        break;
      case DeviceType.gateway:
        gatewayStatus = GatewayStatus.fromJson(json);
        break;
      case DeviceType.unknown:
        // Try to detect from available data
        if (json.containsKey('switch:0')) {
          powerStatus = PowerDeviceStatus.fromJson(json);
        } else if (json.containsKey('temperature:0') &&
            json.containsKey('humidity:0')) {
          weatherStatus = WeatherStationStatus.fromJson(json);
        } else {
          gatewayStatus = GatewayStatus.fromJson(json);
        }
        break;
    }

    return DeviceStatus(
      powerStatus: powerStatus,
      weatherStatus: weatherStatus,
      gatewayStatus: gatewayStatus,
      rawJson: json,
    );
  }

  Future<void> toggleDevice(
    String apiUrl,
    String token,
    String deviceId,
    bool turnOn,
  ) async {
    final response = await _apiService.post(
      '$apiUrl/device/relay/control',
      {
        'id': deviceId,
        'channel': '0',
        'turn': turnOn ? 'on' : 'off',
      },
      token: token,
    );

    if (response['isok'] != true) {
      throw ApiException(message: 'Failed to toggle device');
    }
  }

  Future<WeatherStatistics> fetchWeatherStatistics(
    String apiUrl,
    String token,
    String deviceId,
    DateRange dateRange,
  ) async {
    final range = dateRange.getDateRange();
    return fetchWeatherStatisticsForRange(apiUrl, token, deviceId, range.from, range.to);
  }

  Future<WeatherStatistics> fetchWeatherStatisticsForRange(
    String apiUrl,
    String token,
    String deviceId,
    DateTime from,
    DateTime to,
  ) async {
    // Check cache first
    _cleanExpiredCache();
    final cacheKey = _statsCacheKey(deviceId, from, to);
    final cached = _weatherStatsCache[cacheKey];
    if (cached != null && !cached.isExpired) {
      if (kDebugMode) {
        debugPrint('[Cache] Weather stats HIT for $deviceId');
      }
      return cached.data;
    }

    final dateFromStr = _formatDateTime(from);
    final dateToStr = _formatDateTime(to);

    final response = await _apiService.get(
      '$apiUrl/v2/statistics/weather-station',
      token: token,
      queryParams: {
        'id': deviceId,
        'channel': '0',
        'date_range': 'custom',
        'date_from': dateFromStr,
        'date_to': dateToStr,
      },
    );

    if (kDebugMode) {
      debugPrint('[Cache] Weather stats MISS for $deviceId');
    }

    // Statistics API returns data directly (not wrapped in isok/data)
    // Check if it's an error response
    if (response['isok'] == false) {
      final errors = response['errors'] as Map<String, dynamic>?;
      throw ApiException(message: errors?['message'] as String? ?? 'Failed to fetch weather statistics');
    }

    // Response might have data nested or be the data itself
    final data = response['data'] as Map<String, dynamic>? ?? response;
    final stats = WeatherStatistics.fromJson(data);

    // Cache the result
    final ttl = _getTtlForRange(from, to);
    _weatherStatsCache[cacheKey] = _CacheEntry(stats, DateTime.now().add(ttl));

    return stats;
  }

  Future<PowerStatistics> fetchPowerStatistics(
    String apiUrl,
    String token,
    String deviceId,
    DateRange dateRange,
  ) async {
    final range = dateRange.getDateRange();
    return fetchPowerStatisticsForRange(apiUrl, token, deviceId, range.from, range.to);
  }

  Future<PowerStatistics> fetchPowerStatisticsForRange(
    String apiUrl,
    String token,
    String deviceId,
    DateTime from,
    DateTime to,
  ) async {
    // Check cache first
    _cleanExpiredCache();
    final cacheKey = _statsCacheKey(deviceId, from, to);
    final cached = _powerStatsCache[cacheKey];
    if (cached != null && !cached.isExpired) {
      if (kDebugMode) {
        debugPrint('[Cache] Power stats HIT for $deviceId');
      }
      return cached.data;
    }

    final dateFromStr = _formatDateTime(from);
    final dateToStr = _formatDateTime(to);

    final response = await _apiService.get(
      '$apiUrl/v2/statistics/power-consumption',
      token: token,
      queryParams: {
        'id': deviceId,
        'channel': '0',
        'date_range': 'custom',
        'date_from': dateFromStr,
        'date_to': dateToStr,
      },
    );

    if (kDebugMode) {
      debugPrint('[Cache] Power stats MISS for $deviceId');
    }

    // Statistics API returns data directly (not wrapped in isok/data)
    // Check if it's an error response
    if (response['isok'] == false) {
      final errors = response['errors'] as Map<String, dynamic>?;
      throw ApiException(message: errors?['message'] as String? ?? 'Failed to fetch power statistics');
    }

    // Response might have data nested or be the data itself
    final data = response['data'] as Map<String, dynamic>? ?? response;
    final stats = PowerStatistics.fromJson(data);

    // Cache the result
    final ttl = _getTtlForRange(from, to);
    _powerStatsCache[cacheKey] = _CacheEntry(stats, DateTime.now().add(ttl));

    return stats;
  }

  /// Format DateTime for API - converts local time to UTC
  String _formatDateTime(DateTime dt) {
    final utc = dt.toUtc();
    return '${utc.year}-${utc.month.toString().padLeft(2, '0')}-${utc.day.toString().padLeft(2, '0')} '
        '${utc.hour.toString().padLeft(2, '0')}:${utc.minute.toString().padLeft(2, '0')}:${utc.second.toString().padLeft(2, '0')}';
  }
}

/// Internal result class for device status fetching
class _DeviceStatusResult {
  final List<Device> devices;
  final Map<String, DeviceStatus> statuses;

  _DeviceStatusResult({
    required this.devices,
    required this.statuses,
  });
}
