import 'package:flutter/material.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../constants/app_colors.dart';
import '../constants/app_icons.dart';

enum DeviceType {
  powerSwitch,
  weatherStation,
  gateway,
  unknown,
}

class DeviceTypeHelper {
  DeviceTypeHelper._();

  static DeviceType fromCode(String code) {
    final upperCode = code.toUpperCase();

    // Power switches / plugs / relays
    if (upperCode.startsWith('S3PL') ||    // Shelly Plus Plug
        upperCode.startsWith('SHPLG') ||   // Shelly Plug
        upperCode.startsWith('SPSW') ||    // Shelly Plus Switch
        upperCode.startsWith('SNSW') ||    // Shelly Switch
        upperCode.startsWith('SNPL') ||    // Shelly Plug
        upperCode.startsWith('SHEM') ||    // Shelly EM
        upperCode.startsWith('SHSW') ||    // Shelly Switch
        upperCode.startsWith('S1PM') ||    // Shelly 1PM
        upperCode.startsWith('S2PM') ||    // Shelly 2PM
        upperCode.startsWith('SPRO') ||    // Shelly Pro
        upperCode.startsWith('S4SW') ||    // Shelly Gen 4 Switch
        upperCode.contains('PLUG') ||
        upperCode.contains('SWITCH') ||
        upperCode.contains('RELAY') ||
        upperCode.contains('1PM') ||
        upperCode.contains('2PM') ||
        upperCode.contains('PM')) {
      return DeviceType.powerSwitch;
    }

    // Weather stations
    if (upperCode.startsWith('SBWS') ||
        upperCode.contains('WEATHER') ||
        upperCode.contains('WS')) {
      return DeviceType.weatherStation;
    }

    // Gateways
    if (upperCode.startsWith('SNGW') ||
        upperCode.contains('GATEWAY') ||
        upperCode.contains('GW')) {
      return DeviceType.gateway;
    }

    return DeviceType.unknown;
  }

  static String friendlyName(DeviceType type, AppLocalizations l10n) {
    switch (type) {
      case DeviceType.powerSwitch:
        return l10n.smartPlug;
      case DeviceType.weatherStation:
        return l10n.weatherStation;
      case DeviceType.gateway:
        return l10n.gatewayDevice;
      case DeviceType.unknown:
        return l10n.unknownDevice;
    }
  }

  static IconData icon(DeviceType type) {
    switch (type) {
      case DeviceType.powerSwitch:
        return AppIcons.powerDevice;
      case DeviceType.weatherStation:
        return AppIcons.weatherStation;
      case DeviceType.gateway:
        return AppIcons.gateway;
      case DeviceType.unknown:
        return AppIcons.unknownDevice;
    }
  }

  static Color color(DeviceType type) {
    switch (type) {
      case DeviceType.powerSwitch:
        return AppColors.powerDevice;
      case DeviceType.weatherStation:
        return AppColors.weatherStation;
      case DeviceType.gateway:
        return AppColors.gateway;
      case DeviceType.unknown:
        return AppColors.textSecondary;
    }
  }

  static bool canToggle(DeviceType type) {
    return type == DeviceType.powerSwitch;
  }

  static bool hasStatistics(DeviceType type) {
    return type == DeviceType.powerSwitch || type == DeviceType.weatherStation;
  }
}
