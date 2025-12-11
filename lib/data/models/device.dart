import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/utils/device_type_helper.dart';

class Device {
  final String id;
  final String name;
  final String code;
  final DeviceType type;
  final String deviceType; // API type: "relay", "sensor", "gateway"
  final String gen; // Generation: "G2", "GBLE", etc.
  final bool isOnline;
  final String? roomName;
  final String? roomId;
  final int? serial;
  final String? icon; // FontAwesome icon from API (e.g., "fat fa-heat")
  final String? relayUsage; // Usage type (e.g., "heating")

  Device({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    this.deviceType = '',
    this.gen = '',
    required this.isOnline,
    this.roomName,
    this.roomId,
    this.serial,
    this.icon,
    this.relayUsage,
  });

  bool get isPowerDevice => type == DeviceType.powerSwitch;
  bool get isWeatherStation => type == DeviceType.weatherStation;
  bool get isGateway => type == DeviceType.gateway;
  bool get canToggle => DeviceTypeHelper.canToggle(type);
  bool get hasStatistics => DeviceTypeHelper.hasStatistics(type);

  /// Check if device is used for heating
  bool get isHeating => relayUsage == 'heating';

  /// Check if device is a plug
  bool get isPlug => icon?.contains('fa-plug') == true || code.contains('PL');

  /// Get the appropriate icon for this device based on type and usage
  IconData get displayIcon {
    if (isWeatherStation) return AppIcons.weatherStation;
    if (isGateway) return AppIcons.gateway;
    if (isHeating) return AppIcons.heating;
    if (isPowerDevice || isPlug) return AppIcons.powerDevice;
    return AppIcons.unknownDevice;
  }

  /// Get the appropriate color for this device based on type and usage
  Color get displayColor {
    if (isWeatherStation) return AppColors.weatherStation;
    if (isGateway) return AppColors.gateway;
    if (isHeating) return AppColors.heating;
    if (isPowerDevice || isPlug) return AppColors.powerDevice;
    return AppColors.textSecondary;
  }

  /// Parse from v2/devices/get API response
  factory Device.fromV2Json(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final code = json['code'] as String? ?? '';
    final deviceType = json['type'] as String? ?? '';
    final gen = json['gen'] as String? ?? '';
    final online = json['online'] as int? ?? 0;

    final settings = json['settings'] as Map<String, dynamic>?;
    final deviceInfo = settings?['DeviceInfo'] as Map<String, dynamic>?;
    final status = json['status'] as Map<String, dynamic>?;

    // Get name from multiple sources (in priority order):
    // 1. settings.DeviceInfo.name (user-set name)
    // 2. settings.sys.device.name (system name)
    // 3. settings.switch:0.name (component name for switches)
    // 4. Friendly name from app type (e.g., "Plug S G3" from "PlugSG3")
    // 5. Fall back to device ID
    String? name = deviceInfo?['name'] as String?;

    if (name == null || name.isEmpty) {
      final sysDevice = settings?['sys']?['device'] as Map<String, dynamic>?;
      name = sysDevice?['name'] as String?;
    }

    if (name == null || name.isEmpty) {
      final switchSettings = settings?['switch:0'] as Map<String, dynamic>?;
      name = switchSettings?['name'] as String?;
    }

    if (name == null || name.isEmpty) {
      // Generate friendly name from app type (e.g., "PlugSG3" -> "Plug S G3")
      final app = deviceInfo?['app'] as String?;
      if (app != null && app.isNotEmpty) {
        name = _formatAppName(app);
      }
    }

    if (name == null || name.isEmpty) {
      // Use model code as last resort (e.g., "S3PL-00112EU" -> "S3PL")
      name = code.split('-').firstOrNull ?? id;
    }

    // Get serial from status
    final serial = status?['serial'] as int?;

    return Device(
      id: id,
      name: name,
      code: code,
      type: DeviceTypeHelper.fromCode(code),
      deviceType: deviceType,
      gen: gen,
      isOnline: online == 1,
      serial: serial,
    );
  }

  /// Format app name to be more readable (e.g., "PlugSG3" -> "Plug S G3")
  static String _formatAppName(String app) {
    // Insert spaces before capital letters and numbers
    final buffer = StringBuffer();
    for (int i = 0; i < app.length; i++) {
      final char = app[i];
      if (i > 0) {
        final prevChar = app[i - 1];
        // Add space before uppercase if previous was lowercase
        if (char.toUpperCase() == char &&
            char.toLowerCase() != char &&
            prevChar.toLowerCase() == prevChar &&
            prevChar.toUpperCase() != prevChar) {
          buffer.write(' ');
        }
        // Add space before number if previous was letter
        else if (RegExp(r'[0-9]').hasMatch(char) &&
                 RegExp(r'[a-zA-Z]').hasMatch(prevChar)) {
          buffer.write(' ');
        }
      }
      buffer.write(char);
    }
    return buffer.toString();
  }

  /// Parse from old interface/device/list API (legacy)
  factory Device.fromJson(Map<String, dynamic> json, String deviceId) {
    // API uses 'type' field for device code (e.g., "S3PL-00112EU", "SBWS-90CM")
    final code = json['type'] as String? ?? json['code'] as String? ?? '';
    return Device(
      id: deviceId,
      name: json['name'] as String? ?? 'Unknown Device',
      code: code,
      type: DeviceTypeHelper.fromCode(code),
      isOnline: json['cloud_online'] as bool? ?? json['online'] as bool? ?? false,
      roomName: json['room_name'] as String?,
      roomId: json['room_id']?.toString(),
      serial: json['serial'] as int?,
    );
  }

  factory Device.fromStatusJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? json['_dev_info']?['id'] as String? ?? '';
    final code = json['code'] as String? ?? json['_dev_info']?['code'] as String? ?? '';
    final devInfo = json['_dev_info'] as Map<String, dynamic>?;

    return Device(
      id: id,
      name: id, // Name will be updated from device list
      code: code,
      type: DeviceTypeHelper.fromCode(code),
      isOnline: devInfo?['online'] as bool? ?? json['cloud']?['connected'] as bool? ?? false,
      serial: (json['serial'] is int) ? json['serial'] as int : null,
    );
  }

  Device copyWith({
    String? id,
    String? name,
    String? code,
    DeviceType? type,
    String? deviceType,
    String? gen,
    bool? isOnline,
    String? roomName,
    String? roomId,
    int? serial,
    String? icon,
    String? relayUsage,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      type: type ?? this.type,
      deviceType: deviceType ?? this.deviceType,
      gen: gen ?? this.gen,
      isOnline: isOnline ?? this.isOnline,
      roomName: roomName ?? this.roomName,
      roomId: roomId ?? this.roomId,
      serial: serial ?? this.serial,
      icon: icon ?? this.icon,
      relayUsage: relayUsage ?? this.relayUsage,
    );
  }

  @override
  String toString() {
    return 'Device(id: $id, name: $name, type: $type, online: $isOnline)';
  }
}
