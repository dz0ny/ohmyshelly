import 'package:flutter/foundation.dart';
import '../data/models/device_status.dart';
import '../core/utils/device_type_helper.dart';
import 'device_provider.dart';

class DashboardSummary {
  final int totalDevices;
  final int onlineDevices;
  final int powerDevicesCount;
  final int weatherStationsCount;
  final double totalPowerUsage;
  final WeatherStationStatus? currentWeather;

  DashboardSummary({
    required this.totalDevices,
    required this.onlineDevices,
    required this.powerDevicesCount,
    required this.weatherStationsCount,
    required this.totalPowerUsage,
    this.currentWeather,
  });

  static DashboardSummary empty() {
    return DashboardSummary(
      totalDevices: 0,
      onlineDevices: 0,
      powerDevicesCount: 0,
      weatherStationsCount: 0,
      totalPowerUsage: 0,
    );
  }
}

class DashboardProvider extends ChangeNotifier {
  DeviceProvider? _deviceProvider;
  DashboardSummary _summary = DashboardSummary.empty();

  DashboardSummary get summary => _summary;

  // Convenience getters
  int get totalDevices => _summary.totalDevices;
  int get onlineDevices => _summary.onlineDevices;
  int get activeDevices => _summary.onlineDevices;
  double get totalPowerUsage => _summary.totalPowerUsage;
  WeatherStationStatus? get currentWeather => _summary.currentWeather;

  bool get hasWeatherStation => _summary.weatherStationsCount > 0;
  bool get hasPowerDevices => _summary.powerDevicesCount > 0;

  void setDeviceProvider(DeviceProvider deviceProvider) {
    // Remove old listener if exists
    _deviceProvider?.removeListener(_updateSummary);

    _deviceProvider = deviceProvider;
    _deviceProvider?.addListener(_updateSummary);

    // Initial update
    _updateSummary();
  }

  void _updateSummary() {
    if (_deviceProvider == null) {
      _summary = DashboardSummary.empty();
      notifyListeners();
      return;
    }

    final devices = _deviceProvider!.devices;
    final statuses = _deviceProvider!.deviceStatuses;

    // Count devices by type
    final powerDevices =
        devices.where((d) => d.type == DeviceType.powerSwitch).toList();
    final weatherStations =
        devices.where((d) => d.type == DeviceType.weatherStation).toList();
    final onlineDevices = devices.where((d) => d.isOnline).length;

    // Calculate total power usage from all power devices
    double totalPower = 0;
    for (final device in powerDevices) {
      final status = statuses[device.id];
      if (status?.powerStatus != null) {
        totalPower += status!.powerStatus!.power;
      }
    }

    // Get current weather from first weather station
    WeatherStationStatus? weather;
    for (final station in weatherStations) {
      final status = statuses[station.id];
      if (status?.weatherStatus != null) {
        weather = status!.weatherStatus;
        break;
      }
    }

    _summary = DashboardSummary(
      totalDevices: devices.length,
      onlineDevices: onlineDevices,
      powerDevicesCount: powerDevices.length,
      weatherStationsCount: weatherStations.length,
      totalPowerUsage: totalPower,
      currentWeather: weather,
    );

    notifyListeners();
  }

  @override
  void dispose() {
    _deviceProvider?.removeListener(_updateSummary);
    super.dispose();
  }
}
