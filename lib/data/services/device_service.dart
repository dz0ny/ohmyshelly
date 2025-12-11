import 'package:flutter/foundation.dart';
import '../models/device.dart';
import '../models/device_status.dart';
import '../models/statistics.dart';
import '../../core/utils/device_type_helper.dart';
import 'api_service.dart';

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

  DeviceService(this._apiService);

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
          statuses[device.id] = _parseDeviceStatus(statusJson, device.code);
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

  DeviceStatus _parseDeviceStatus(Map<String, dynamic> json, [String? deviceCode]) {
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
      debugPrint('Weather stats response keys: ${response.keys.toList()}');
    }

    // Statistics API returns data directly (not wrapped in isok/data)
    // Check if it's an error response
    if (response['isok'] == false) {
      final errors = response['errors'] as Map<String, dynamic>?;
      throw ApiException(message: errors?['message'] as String? ?? 'Failed to fetch weather statistics');
    }

    // Response might have data nested or be the data itself
    final data = response['data'] as Map<String, dynamic>? ?? response;
    return WeatherStatistics.fromJson(data);
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
      debugPrint('Power stats response keys: ${response.keys.toList()}');
    }

    // Statistics API returns data directly (not wrapped in isok/data)
    // Check if it's an error response
    if (response['isok'] == false) {
      final errors = response['errors'] as Map<String, dynamic>?;
      throw ApiException(message: errors?['message'] as String? ?? 'Failed to fetch power statistics');
    }

    // Response might have data nested or be the data itself
    final data = response['data'] as Map<String, dynamic>? ?? response;
    return PowerStatistics.fromJson(data);
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
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
