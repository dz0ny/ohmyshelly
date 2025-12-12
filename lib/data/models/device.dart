import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/utils/device_type_helper.dart';

/// Input mode for switch devices - describes how the physical input affects the relay
enum SwitchInputMode {
  /// Input state directly controls output (input ON = output ON)
  follow,
  /// Input toggle causes output toggle (flip/edge switch behavior)
  flip,
  /// Momentary button - each press toggles output
  momentary,
  /// Input is detached from output (doesn't affect relay)
  detached,
  /// PIR sensor mode - triggers ON with auto-off timer
  activate,
  /// Unknown or not applicable
  unknown,
}

/// Type of physical input connected to the device
enum InputType {
  /// Push button (momentary switch)
  button,
  /// Toggle switch (maintains position)
  toggleSwitch,
  /// Unknown or not applicable
  unknown,
}

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
  final SwitchInputMode inputMode; // How input affects relay (follow, flip, momentary, detached)
  final InputType inputType; // Type of physical input (button, switch)

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
    this.inputMode = SwitchInputMode.unknown,
    this.inputType = InputType.unknown,
  });

  bool get isPowerDevice => type == DeviceType.powerSwitch;
  bool get isWeatherStation => type == DeviceType.weatherStation;
  bool get isGateway => type == DeviceType.gateway;
  bool get canToggle => DeviceTypeHelper.canToggle(type);
  bool get hasStatistics => DeviceTypeHelper.hasStatistics(type);

  /// Check if device has a push button connected
  bool get isPushButton => inputType == InputType.button;

  /// Check if device has a toggle switch connected
  bool get isToggleSwitch => inputType == InputType.toggleSwitch;

  /// Check if input is detached from relay output
  bool get isDetached => inputMode == SwitchInputMode.detached;

  /// Check if device is used for heating
  bool get isHeating => relayUsage == 'heating';

  /// Check if device is a plug
  bool get isPlug => icon?.contains('fa-plug') == true || code.contains('PL');

  /// Get the appropriate icon for this device based on type and usage
  IconData get displayIcon {
    if (isWeatherStation) return AppIcons.weatherStation;
    if (isGateway) return AppIcons.gateway;

    // Map relay_usage to icons
    if (relayUsage != null) {
      final icon = _getIconForRelayUsage(relayUsage!);
      if (icon != null) return icon;
    }

    if (isPowerDevice || isPlug) return AppIcons.powerDevice;
    return AppIcons.unknownDevice;
  }

  /// Get icon for relay_usage value
  static IconData? _getIconForRelayUsage(String usage) {
    return switch (usage) {
      'heating' => AppIcons.heating,
      'lighting' || 'light' => AppIcons.lighting,
      'garage_door' => AppIcons.garageDoor,
      'gate' => AppIcons.gate,
      'door' => AppIcons.door,
      'socket' || 'plug' => AppIcons.socket,
      'roller' || 'blinds' || 'shutter' => AppIcons.roller,
      'fan' || 'ventilation' => AppIcons.ventilation,
      'pump' => AppIcons.pump,
      'irrigation' || 'garden' => AppIcons.irrigation,
      'pool' || 'pool_and_garden' => AppIcons.poolAndGarden,
      'entertainment' || 'tv' => AppIcons.entertainment,
      'refrigeration' || 'fridge' => AppIcons.refrigeration,
      'laundry' || 'washer' => AppIcons.laundry,
      'dryer' => AppIcons.dryer,
      'cooking' || 'oven' || 'stove' => AppIcons.cooking,
      'electric_vehicle' || 'ev_charger' => AppIcons.electricVehicle,
      'water_heater' || 'boiler' => AppIcons.waterHeater,
      'air_conditioner' || 'ac' || 'hvac' => AppIcons.airConditioner,
      'coffee_maker' || 'coffee' => AppIcons.coffeeMaker,
      'dishwasher' => AppIcons.dishwasher,
      'security' => AppIcons.security,
      'alarm' => AppIcons.alarm,
      'camera' => AppIcons.camera,
      'lock' => AppIcons.lock,
      'other' => AppIcons.other,
      _ => null,
    };
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

    // Parse switch settings for name and input mode
    final switchSettings = settings?['switch:0'] as Map<String, dynamic>?;

    if (name == null || name.isEmpty) {
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

    // Parse input mode from switch:0 settings (in_mode)
    final inModeStr = switchSettings?['in_mode'] as String?;
    final inputMode = _parseInputMode(inModeStr);

    // Parse input type from input:0 settings (type)
    final inputSettings = settings?['input:0'] as Map<String, dynamic>?;
    final inputTypeStr = inputSettings?['type'] as String?;
    final inputType = _parseInputType(inputTypeStr);

    // Debug logging for input detection
    if (kDebugMode && (inModeStr != null || inputTypeStr != null)) {
      debugPrint('[Device] $id: in_mode=$inModeStr, input_type=$inputTypeStr -> inputMode=$inputMode, inputType=$inputType');
    }

    return Device(
      id: id,
      name: name,
      code: code,
      type: DeviceTypeHelper.fromCode(code),
      deviceType: deviceType,
      gen: gen,
      isOnline: online == 1,
      serial: serial,
      inputMode: inputMode,
      inputType: inputType,
    );
  }

  /// Parse input mode string from API to enum
  static SwitchInputMode _parseInputMode(String? mode) {
    if (mode == null) return SwitchInputMode.unknown;
    switch (mode.toLowerCase()) {
      case 'follow':
        return SwitchInputMode.follow;
      case 'flip':
      case 'edge':
        return SwitchInputMode.flip;
      case 'momentary':
        return SwitchInputMode.momentary;
      case 'detached':
        return SwitchInputMode.detached;
      case 'activate':
        return SwitchInputMode.activate;
      default:
        return SwitchInputMode.unknown;
    }
  }

  /// Parse input type string from API to enum
  static InputType _parseInputType(String? type) {
    if (type == null) return InputType.unknown;
    switch (type.toLowerCase()) {
      case 'button':
        return InputType.button;
      case 'switch':
        return InputType.toggleSwitch;
      default:
        return InputType.unknown;
    }
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
    SwitchInputMode? inputMode,
    InputType? inputType,
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
      inputMode: inputMode ?? this.inputMode,
      inputType: inputType ?? this.inputType,
    );
  }

  /// Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'type': type.index,
      'deviceType': deviceType,
      'gen': gen,
      'isOnline': isOnline,
      'roomName': roomName,
      'roomId': roomId,
      'serial': serial,
      'icon': icon,
      'relayUsage': relayUsage,
      'inputMode': inputMode.index,
      'inputType': inputType.index,
    };
  }

  /// Create from cached JSON
  factory Device.fromCacheJson(Map<String, dynamic> json) {
    final code = json['code'] as String? ?? '';
    final inputModeIndex = json['inputMode'] as int?;
    final inputTypeIndex = json['inputType'] as int?;
    return Device(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Device',
      code: code,
      type: DeviceType.values[json['type'] as int? ?? 0],
      deviceType: json['deviceType'] as String? ?? '',
      gen: json['gen'] as String? ?? '',
      isOnline: json['isOnline'] as bool? ?? false,
      roomName: json['roomName'] as String?,
      roomId: json['roomId'] as String?,
      serial: json['serial'] as int?,
      icon: json['icon'] as String?,
      relayUsage: json['relayUsage'] as String?,
      inputMode: inputModeIndex != null && inputModeIndex < SwitchInputMode.values.length
          ? SwitchInputMode.values[inputModeIndex]
          : SwitchInputMode.unknown,
      inputType: inputTypeIndex != null && inputTypeIndex < InputType.values.length
          ? InputType.values[inputTypeIndex]
          : InputType.unknown,
    );
  }

  @override
  String toString() {
    return 'Device(id: $id, name: $name, type: $type, online: $isOnline)';
  }
}
