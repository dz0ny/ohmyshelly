import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';

/// UV Index danger levels based on WHO/EPA guidelines
enum UvDangerLevel {
  low,      // 0-2
  moderate, // 3-5
  high,     // 6-7
  veryHigh, // 8-10
  extreme,  // 11+
}

extension UvDangerLevelExtension on UvDangerLevel {
  String get label {
    switch (this) {
      case UvDangerLevel.low:
        return 'Low';
      case UvDangerLevel.moderate:
        return 'Moderate';
      case UvDangerLevel.high:
        return 'High';
      case UvDangerLevel.veryHigh:
        return 'Very High';
      case UvDangerLevel.extreme:
        return 'Extreme';
    }
  }

  String labelLocalized(AppLocalizations l10n) {
    switch (this) {
      case UvDangerLevel.low:
        return l10n.uvLow;
      case UvDangerLevel.moderate:
        return l10n.uvModerate;
      case UvDangerLevel.high:
        return l10n.uvHigh;
      case UvDangerLevel.veryHigh:
        return l10n.uvVeryHigh;
      case UvDangerLevel.extreme:
        return l10n.uvExtreme;
    }
  }

  Color get color {
    switch (this) {
      case UvDangerLevel.low:
        return AppColors.success;
      case UvDangerLevel.moderate:
        return AppColors.warning;
      case UvDangerLevel.high:
        return const Color(0xFFFF9800); // Orange
      case UvDangerLevel.veryHigh:
        return AppColors.error;
      case UvDangerLevel.extreme:
        return const Color(0xFF9C27B0); // Purple
    }
  }

  IconData get icon {
    switch (this) {
      case UvDangerLevel.low:
        return Icons.check_circle_outline;
      case UvDangerLevel.moderate:
        return Icons.warning_amber_outlined;
      case UvDangerLevel.high:
      case UvDangerLevel.veryHigh:
      case UvDangerLevel.extreme:
        return Icons.warning_rounded;
    }
  }
}

/// Generic trend direction for values like temperature, humidity, pressure
enum ValueTrend {
  rising,
  stable,
  falling,
}

extension ValueTrendExtension on ValueTrend {
  String get label {
    switch (this) {
      case ValueTrend.rising:
        return 'Rising';
      case ValueTrend.stable:
        return 'Stable';
      case ValueTrend.falling:
        return 'Falling';
    }
  }

  String labelLocalized(AppLocalizations l10n) {
    switch (this) {
      case ValueTrend.rising:
        return l10n.pressureRising;
      case ValueTrend.stable:
        return l10n.pressureStable;
      case ValueTrend.falling:
        return l10n.pressureFalling;
    }
  }

  String get arrow {
    switch (this) {
      case ValueTrend.rising:
        return '↑';
      case ValueTrend.stable:
        return '→';
      case ValueTrend.falling:
        return '↓';
    }
  }

  Color get color {
    switch (this) {
      case ValueTrend.rising:
        return AppColors.success;
      case ValueTrend.stable:
        return AppColors.textSecondary;
      case ValueTrend.falling:
        return AppColors.info;
    }
  }
}

/// Alias for backward compatibility
typedef PressureTrend = ValueTrend;

class PowerDeviceStatus {
  final bool isOn;
  final double power;
  final double voltage;
  final double current;
  final double frequency;
  final double temperature;
  final double totalEnergy;
  final String? ipAddress;
  final int? rssi;
  final String? ssid;
  final int uptime;
  final DateTime? lastUpdated;
  final String? firmwareVersion;

  PowerDeviceStatus({
    required this.isOn,
    required this.power,
    required this.voltage,
    required this.current,
    required this.frequency,
    required this.temperature,
    required this.totalEnergy,
    this.ipAddress,
    this.rssi,
    this.ssid,
    this.uptime = 0,
    this.lastUpdated,
    this.firmwareVersion,
  });

  // User-friendly formatted values
  String get powerDisplay => Formatters.power(power);
  String get voltageDisplay => Formatters.voltage(voltage);
  String get currentDisplay => Formatters.current(current);
  String get temperatureDisplay => Formatters.temperature(temperature);
  String get totalEnergyDisplay => Formatters.energy(totalEnergy);
  String get frequencyDisplay => '${frequency.toStringAsFixed(1)} Hz';

  String get uptimeDisplay {
    if (uptime < 60) return '${uptime}s';
    if (uptime < 3600) return '${(uptime / 60).floor()}m';
    if (uptime < 86400) return '${(uptime / 3600).floor()}h';
    return '${(uptime / 86400).floor()}d';
  }

  String get signalStrength {
    if (rssi == null) return 'Unknown';
    if (rssi! > -50) return 'Excellent';
    if (rssi! > -60) return 'Good';
    if (rssi! > -70) return 'Fair';
    return 'Weak';
  }

  String signalStrengthLocalized(AppLocalizations l10n) {
    if (rssi == null) return l10n.signalUnknown;
    if (rssi! > -50) return l10n.signalExcellent;
    if (rssi! > -60) return l10n.signalGood;
    if (rssi! > -70) return l10n.signalFair;
    return l10n.signalWeak;
  }

  factory PowerDeviceStatus.fromJson(Map<String, dynamic> json) {
    final switchData = json['switch:0'] as Map<String, dynamic>? ?? {};
    final tempData = switchData['temperature'] as Map<String, dynamic>?;
    final aenergy = switchData['aenergy'] as Map<String, dynamic>?;
    final wifi = json['wifi'] as Map<String, dynamic>?;
    final sys = json['sys'] as Map<String, dynamic>?;
    final updatedStr = json['_updated'] as String?;

    return PowerDeviceStatus(
      isOn: switchData['output'] as bool? ?? false,
      power: (switchData['apower'] as num?)?.toDouble() ?? 0.0,
      voltage: (switchData['voltage'] as num?)?.toDouble() ?? 0.0,
      current: (switchData['current'] as num?)?.toDouble() ?? 0.0,
      frequency: (switchData['freq'] as num?)?.toDouble() ?? 0.0,
      temperature: (tempData?['tC'] as num?)?.toDouble() ?? 0.0,
      totalEnergy: (aenergy?['total'] as num?)?.toDouble() ?? 0.0,
      ipAddress: wifi?['sta_ip'] as String?,
      rssi: wifi?['rssi'] as int?,
      ssid: wifi?['ssid'] as String?,
      uptime: sys?['uptime'] as int? ?? 0,
      lastUpdated: updatedStr != null ? DateTime.tryParse(updatedStr) : null,
      firmwareVersion: _parseFirmwareVersion(sys?['fw_id'] as String?),
    );
  }

  /// Parse firmware version from fw_id (e.g., "20241011-114455/1.4.4-g6d2a586" -> "1.4.4")
  static String? _parseFirmwareVersion(String? fwId) {
    if (fwId == null || fwId.isEmpty) return null;
    // Format: "DATE/VERSION-HASH" - extract VERSION part
    final parts = fwId.split('/');
    if (parts.length < 2) return fwId;
    final versionPart = parts[1];
    // Remove git hash suffix if present (e.g., "1.4.4-g6d2a586" -> "1.4.4")
    final dashIndex = versionPart.indexOf('-g');
    return dashIndex > 0 ? versionPart.substring(0, dashIndex) : versionPart;
  }

  static PowerDeviceStatus empty() {
    return PowerDeviceStatus(
      isOn: false,
      power: 0,
      voltage: 0,
      current: 0,
      frequency: 0,
      temperature: 0,
      totalEnergy: 0,
    );
  }
}

class WeatherStationStatus {
  final double temperature;
  final double humidity;
  final double pressure;
  final double dewpoint;
  final double uvIndex;
  final double windSpeed;
  final double windGust;
  final double windDirection;
  final double precipitation;
  final double illuminance;
  final double batteryPercent;
  final double? batteryVoltage;
  final bool isInRange;
  final int? rssi;
  final DateTime? lastUpdated;
  final String? firmwareVersion;

  WeatherStationStatus({
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.dewpoint,
    required this.uvIndex,
    required this.windSpeed,
    required this.windGust,
    required this.windDirection,
    required this.precipitation,
    required this.illuminance,
    required this.batteryPercent,
    this.batteryVoltage,
    required this.isInRange,
    this.rssi,
    this.lastUpdated,
    this.firmwareVersion,
  });

  // User-friendly formatted values
  String get temperatureDisplay => Formatters.temperature(temperature);
  String get temperatureShort => Formatters.temperatureShort(temperature);
  String get humidityDisplay => Formatters.humidity(humidity);
  String get pressureDisplay => Formatters.pressure(pressure);
  String get dewpointDisplay => Formatters.temperature(dewpoint);

  /// Calculated "feels like" temperature using wind chill and heat index
  /// Wind Chill: Used when temp < 10°C and wind speed > 4.8 km/h
  /// Heat Index: Used when temp > 26°C and humidity > 40%
  double get feelsLike {
    // Wind Chill calculation (for cold weather)
    // Formula: 13.12 + 0.6215*T - 11.37*V^0.16 + 0.3965*T*V^0.16
    // where T is temperature in °C and V is wind speed in km/h
    if (temperature <= 10 && windSpeed > 4.8) {
      final v016 = math.pow(windSpeed, 0.16);
      return 13.12 + 0.6215 * temperature - 11.37 * v016 + 0.3965 * temperature * v016;
    }

    // Heat Index calculation (for hot weather)
    // Simplified Rothfusz regression
    if (temperature >= 26 && humidity > 40) {
      final t = temperature;
      final h = humidity;
      double hi = -8.78469475556 +
          1.61139411 * t +
          2.33854883889 * h -
          0.14611605 * t * h -
          0.012308094 * t * t -
          0.0164248277778 * h * h +
          0.002211732 * t * t * h +
          0.00072546 * t * h * h -
          0.000003582 * t * t * h * h;
      return hi;
    }

    // Default: actual temperature
    return temperature;
  }

  String get feelsLikeDisplay => Formatters.temperature(feelsLike);
  String get feelsLikeShort => Formatters.temperatureShort(feelsLike);
  String get uvDisplay => Formatters.uvIndex(uvIndex);
  String get windSpeedDisplay => Formatters.windSpeed(windSpeed);
  String get windGustDisplay => Formatters.windSpeed(windGust);
  String get windDirectionDisplay => Formatters.windDirection(windDirection);
  String windDirectionLocalized(AppLocalizations l10n) => Formatters.windDirection(windDirection, l10n);
  String get windDirectionDegrees => '${windDirection.toStringAsFixed(0)}\u00B0';
  String get precipitationDisplay => Formatters.precipitation(precipitation);
  String get illuminanceDisplay => Formatters.illuminance(illuminance);
  String get batteryDisplay => Formatters.battery(batteryPercent);

  /// Solar irradiance in W/m² (converted from lux)
  /// For sunlight, approximately 1 W/m² ≈ 120 lux
  double get solarIrradiance => illuminance / 120;
  String get solarIrradianceDisplay => Formatters.solarIrradiance(solarIrradiance);

  bool get isBatteryLow => batteryPercent < 20;

  String get signalStrength {
    if (rssi == null) return 'Unknown';
    if (rssi! > -50) return 'Excellent';
    if (rssi! > -60) return 'Good';
    if (rssi! > -70) return 'Fair';
    return 'Weak';
  }

  String signalStrengthLocalized(AppLocalizations l10n) {
    if (rssi == null) return l10n.signalUnknown;
    if (rssi! > -50) return l10n.signalExcellent;
    if (rssi! > -60) return l10n.signalGood;
    if (rssi! > -70) return l10n.signalFair;
    return l10n.signalWeak;
  }

  /// UV danger level based on WHO/EPA guidelines
  /// 0-2: Low, 3-5: Moderate, 6-7: High, 8-10: Very High, 11+: Extreme
  UvDangerLevel get uvDangerLevel {
    if (uvIndex < 3) return UvDangerLevel.low;
    if (uvIndex < 6) return UvDangerLevel.moderate;
    if (uvIndex < 8) return UvDangerLevel.high;
    if (uvIndex < 11) return UvDangerLevel.veryHigh;
    return UvDangerLevel.extreme;
  }

  /// Whether UV protection is recommended (Moderate or higher)
  bool get uvProtectionNeeded => uvIndex >= 3;

  /// Calculate pressure trend by comparing with previous reading
  /// A change of >1 hPa is considered significant
  ValueTrend getPressureTrend(double? previousPressure) {
    if (previousPressure == null) return ValueTrend.stable;
    final diff = pressure - previousPressure;
    if (diff > 1) return ValueTrend.rising;
    if (diff < -1) return ValueTrend.falling;
    return ValueTrend.stable;
  }

  /// Calculate temperature trend by comparing with previous reading
  /// A change of >0.5°C is considered significant
  ValueTrend getTemperatureTrend(double? previousTemperature) {
    if (previousTemperature == null) return ValueTrend.stable;
    final diff = temperature - previousTemperature;
    if (diff > 0.5) return ValueTrend.rising;
    if (diff < -0.5) return ValueTrend.falling;
    return ValueTrend.stable;
  }

  /// Calculate humidity trend by comparing with previous reading
  /// A change of >3% is considered significant
  ValueTrend getHumidityTrend(double? previousHumidity) {
    if (previousHumidity == null) return ValueTrend.stable;
    final diff = humidity - previousHumidity;
    if (diff > 3) return ValueTrend.rising;
    if (diff < -3) return ValueTrend.falling;
    return ValueTrend.stable;
  }

  factory WeatherStationStatus.fromJson(Map<String, dynamic> json) {
    final reporter = json['reporter'] as Map<String, dynamic>?;
    final devicePower = json['devicepower:0'] as Map<String, dynamic>?;
    final battery = devicePower?['battery'] as Map<String, dynamic>?;
    final wifi = json['wifi'] as Map<String, dynamic>?;
    final sys = json['sys'] as Map<String, dynamic>?;
    final updatedStr = json['_updated'] as String?;

    return WeatherStationStatus(
      temperature: (json['temperature:0']?['tC'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['humidity:0']?['rh'] as num?)?.toDouble() ?? 0.0,
      pressure: (json['pressure:0']?['value'] as num?)?.toDouble() ?? 0.0,
      dewpoint: (json['dewpoint:0']?['value'] as num?)?.toDouble() ?? 0.0,
      uvIndex: (json['UV:0']?['value'] as num?)?.toDouble() ?? 0.0,
      windSpeed: (json['speed:0']?['value'] as num?)?.toDouble() ?? 0.0,
      windGust: (json['speed:1']?['value'] as num?)?.toDouble() ?? 0.0,
      windDirection: (json['direction:0']?['value'] as num?)?.toDouble() ?? 0.0,
      precipitation: (json['precipitation:0']?['value'] as num?)?.toDouble() ?? 0.0,
      illuminance: (json['illuminance:0']?['lux'] as num?)?.toDouble() ?? 0.0,
      batteryPercent: (battery?['percent'] as num?)?.toDouble() ?? 0.0,
      batteryVoltage: (battery?['V'] as num?)?.toDouble(),
      isInRange: reporter?['inrange'] as bool? ?? false,
      rssi: (reporter?['rssi'] as int?) ?? (wifi?['rssi'] as int?),
      lastUpdated: updatedStr != null ? DateTime.tryParse(updatedStr) : null,
      firmwareVersion: _parseFirmwareVersion(sys?['fw_id'] as String?),
    );
  }

  /// Parse firmware version from fw_id (e.g., "20241011-114455/1.4.4-g6d2a586" -> "1.4.4")
  static String? _parseFirmwareVersion(String? fwId) {
    if (fwId == null || fwId.isEmpty) return null;
    final parts = fwId.split('/');
    if (parts.length < 2) return fwId;
    final versionPart = parts[1];
    final dashIndex = versionPart.indexOf('-g');
    return dashIndex > 0 ? versionPart.substring(0, dashIndex) : versionPart;
  }

  static WeatherStationStatus empty() {
    return WeatherStationStatus(
      temperature: 0,
      humidity: 0,
      pressure: 0,
      dewpoint: 0,
      uvIndex: 0,
      windSpeed: 0,
      windGust: 0,
      windDirection: 0,
      precipitation: 0,
      illuminance: 0,
      batteryPercent: 0,
      isInRange: false,
    );
  }
}

class GatewayStatus {
  final bool cloudConnected;
  final String? ipAddress;
  final int? rssi;
  final String? ssid;
  final int uptime;
  final DateTime? lastUpdated;
  final String? firmwareVersion;

  GatewayStatus({
    required this.cloudConnected,
    this.ipAddress,
    this.rssi,
    this.ssid,
    required this.uptime,
    this.lastUpdated,
    this.firmwareVersion,
  });

  String get uptimeDisplay {
    if (uptime < 60) return '${uptime}s';
    if (uptime < 3600) return '${(uptime / 60).floor()}m';
    if (uptime < 86400) return '${(uptime / 3600).floor()}h';
    return '${(uptime / 86400).floor()}d';
  }

  String get signalStrength {
    if (rssi == null) return 'Unknown';
    if (rssi! > -50) return 'Excellent';
    if (rssi! > -60) return 'Good';
    if (rssi! > -70) return 'Fair';
    return 'Weak';
  }

  String signalStrengthLocalized(AppLocalizations l10n) {
    if (rssi == null) return l10n.signalUnknown;
    if (rssi! > -50) return l10n.signalExcellent;
    if (rssi! > -60) return l10n.signalGood;
    if (rssi! > -70) return l10n.signalFair;
    return l10n.signalWeak;
  }

  factory GatewayStatus.fromJson(Map<String, dynamic> json) {
    final wifi = json['wifi'] as Map<String, dynamic>?;
    final sys = json['sys'] as Map<String, dynamic>?;
    final cloud = json['cloud'] as Map<String, dynamic>?;
    final updatedStr = json['_updated'] as String?;

    return GatewayStatus(
      cloudConnected: cloud?['connected'] as bool? ?? false,
      ipAddress: wifi?['sta_ip'] as String?,
      rssi: wifi?['rssi'] as int?,
      ssid: wifi?['ssid'] as String?,
      uptime: sys?['uptime'] as int? ?? 0,
      lastUpdated: updatedStr != null ? DateTime.tryParse(updatedStr) : null,
      firmwareVersion: _parseFirmwareVersion(sys?['fw_id'] as String?),
    );
  }

  /// Parse firmware version from fw_id (e.g., "20241011-114455/1.4.4-g6d2a586" -> "1.4.4")
  static String? _parseFirmwareVersion(String? fwId) {
    if (fwId == null || fwId.isEmpty) return null;
    final parts = fwId.split('/');
    if (parts.length < 2) return fwId;
    final versionPart = parts[1];
    final dashIndex = versionPart.indexOf('-g');
    return dashIndex > 0 ? versionPart.substring(0, dashIndex) : versionPart;
  }

  static GatewayStatus empty() {
    return GatewayStatus(
      cloudConnected: false,
      uptime: 0,
    );
  }
}

// Union type for device status
class DeviceStatus {
  final PowerDeviceStatus? powerStatus;
  final WeatherStationStatus? weatherStatus;
  final GatewayStatus? gatewayStatus;
  final Map<String, dynamic> rawJson;

  DeviceStatus({
    this.powerStatus,
    this.weatherStatus,
    this.gatewayStatus,
    required this.rawJson,
  });

  bool get hasPowerStatus => powerStatus != null;
  bool get hasWeatherStatus => weatherStatus != null;
  bool get hasGatewayStatus => gatewayStatus != null;
}
