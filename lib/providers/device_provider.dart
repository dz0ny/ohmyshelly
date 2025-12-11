import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/models/device.dart';
import '../data/models/device_status.dart';
import '../data/models/statistics.dart';
import '../data/services/device_service.dart';
import '../data/services/api_service.dart';
import '../core/utils/device_type_helper.dart';

enum DeviceLoadState {
  initial,
  loading,
  loaded,
  error,
}

class DeviceProvider extends ChangeNotifier {
  final DeviceService _deviceService;
  String? _apiUrl;
  String? _token;

  List<Device> _devices = [];
  Map<String, DeviceStatus> _deviceStatuses = {};
  DeviceLoadState _state = DeviceLoadState.initial;
  String? _error;
  Timer? _refreshTimer;
  bool _isRefreshing = false;

  // History for sparkline charts (from statistics API)
  final Map<String, List<double>> _temperatureHistory = {};
  final Map<String, List<double>> _humidityHistory = {};
  final Map<String, List<double>> _powerHistory = {};
  final Map<String, List<double>> _energyHistory = {};
  bool _isLoadingHistory = false;

  static const Duration _refreshInterval = Duration(seconds: 30);

  DeviceProvider({required ApiService apiService})
      : _deviceService = DeviceService(apiService);

  // Getters
  List<Device> get devices => _devices;
  Map<String, DeviceStatus> get deviceStatuses => _deviceStatuses;
  DeviceLoadState get state => _state;
  String? get error => _error;
  bool get isLoading => _state == DeviceLoadState.loading;
  bool get isRefreshing => _isRefreshing;

  // Filtered device lists
  List<Device> get powerDevices =>
      _devices.where((d) => d.type == DeviceType.powerSwitch).toList();

  List<Device> get weatherStations =>
      _devices.where((d) => d.type == DeviceType.weatherStation).toList();

  List<Device> get gateways =>
      _devices.where((d) => d.type == DeviceType.gateway).toList();

  List<Device> get onlineDevices => _devices.where((d) => d.isOnline).toList();

  // Get status for a specific device
  DeviceStatus? getStatus(String deviceId) => _deviceStatuses[deviceId];

  PowerDeviceStatus? getPowerStatus(String deviceId) =>
      _deviceStatuses[deviceId]?.powerStatus;

  WeatherStationStatus? getWeatherStatus(String deviceId) =>
      _deviceStatuses[deviceId]?.weatherStatus;

  GatewayStatus? getGatewayStatus(String deviceId) =>
      _deviceStatuses[deviceId]?.gatewayStatus;

  /// Get temperature history for a device (for sparkline charts)
  List<double> getTemperatureHistory(String deviceId) =>
      _temperatureHistory[deviceId] ?? [];

  /// Get humidity history for a device (for sparkline charts)
  List<double> getHumidityHistory(String deviceId) =>
      _humidityHistory[deviceId] ?? [];

  /// Get power history for a device (for sparkline charts)
  List<double> getPowerHistory(String deviceId) =>
      _powerHistory[deviceId] ?? [];

  /// Get energy history for a device (for sparkline charts)
  List<double> getEnergyHistory(String deviceId) =>
      _energyHistory[deviceId] ?? [];

  /// Fetch weather history from statistics API for weather stations
  Future<void> fetchWeatherHistory(String deviceId) async {
    if (_apiUrl == null || _token == null) return;
    if (_isLoadingHistory) return;

    _isLoadingHistory = true;

    try {
      final stats = await _deviceService.fetchWeatherStatistics(
        _apiUrl!,
        _token!,
        deviceId,
        DateRange.day, // Get today's hourly data
      );

      if (stats.dataPoints.isNotEmpty) {
        // Extract average temperature from each data point
        _temperatureHistory[deviceId] = stats.dataPoints
            .map((p) => p.avgTemperature)
            .toList();
        // Extract humidity from each data point
        _humidityHistory[deviceId] = stats.dataPoints
            .map((p) => p.humidity)
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to fetch weather history: $e');
    } finally {
      _isLoadingHistory = false;
    }
  }

  /// Fetch power history from statistics API for power devices
  Future<void> fetchPowerHistory(String deviceId) async {
    if (_apiUrl == null || _token == null) return;

    try {
      final stats = await _deviceService.fetchPowerStatistics(
        _apiUrl!,
        _token!,
        deviceId,
        DateRange.day, // Get today's hourly data
      );

      if (stats.dataPoints.isNotEmpty) {
        // Extract consumption from each data point
        _powerHistory[deviceId] = stats.dataPoints
            .map((p) => p.consumption)
            .toList();

        // Calculate cumulative energy
        double cumulative = 0;
        _energyHistory[deviceId] = stats.dataPoints.map((p) {
          cumulative += p.consumption;
          return cumulative;
        }).toList();

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to fetch power history: $e');
    }
  }

  /// Fetch history for all devices
  Future<void> _fetchAllHistories() async {
    // Fetch for weather stations
    final weatherStations = _devices.where((d) => d.isWeatherStation).toList();
    for (final device in weatherStations) {
      await fetchWeatherHistory(device.id);
    }

    // Fetch for power devices
    final powerDevices = _devices.where((d) => d.isPowerDevice).toList();
    for (final device in powerDevices) {
      await fetchPowerHistory(device.id);
    }
  }

  // Set credentials (called when auth changes)
  void setCredentials(String? apiUrl, String? token) {
    _apiUrl = apiUrl;
    _token = token;

    if (apiUrl != null && token != null) {
      // Start auto-refresh when credentials are set
      _startAutoRefresh();
    } else {
      // Stop auto-refresh and clear data when logged out
      _stopAutoRefresh();
      _devices = [];
      _deviceStatuses = {};
      _state = DeviceLoadState.initial;
      notifyListeners();
    }
  }

  // Fetch devices and statuses in a single API call
  Future<void> fetchDevices() async {
    if (_apiUrl == null || _token == null) {
      _error = 'Not authenticated';
      _state = DeviceLoadState.error;
      notifyListeners();
      return;
    }

    _state = DeviceLoadState.loading;
    _error = null;
    notifyListeners();

    try {
      // v2 API returns both devices and statuses in one call
      final result = await _deviceService.fetchDevicesWithStatuses(_apiUrl!, _token!);
      _devices = result.devices;
      _deviceStatuses = result.statuses;

      _state = DeviceLoadState.loaded;
      notifyListeners();

      // Fetch history for sparklines (non-blocking)
      _fetchAllHistories();
    } on ApiException catch (e) {
      _error = e.friendlyMessage;
      _state = DeviceLoadState.error;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load devices';
      _state = DeviceLoadState.error;
      notifyListeners();
    }
  }

  // Refresh statuses (now uses same v2 API)
  Future<void> fetchAllStatuses() async {
    if (_apiUrl == null || _token == null) return;

    try {
      final result = await _deviceService.fetchDevicesWithStatuses(_apiUrl!, _token!);
      _devices = result.devices;
      _deviceStatuses = result.statuses;
      notifyListeners();
    } catch (e) {
      // Don't update error state for status refresh failures
      debugPrint('Failed to fetch statuses: $e');
    }
  }

  // Refresh data (for pull-to-refresh)
  Future<void> refresh() async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    notifyListeners();

    try {
      await fetchDevices();
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  // Toggle device
  Future<bool> toggleDevice(String deviceId, bool turnOn) async {
    if (_apiUrl == null || _token == null) return false;

    try {
      await _deviceService.toggleDevice(_apiUrl!, _token!, deviceId, turnOn);

      // Optimistically update local state
      final status = _deviceStatuses[deviceId];
      if (status?.powerStatus != null) {
        _deviceStatuses[deviceId] = DeviceStatus(
          powerStatus: PowerDeviceStatus(
            isOn: turnOn,
            power: status!.powerStatus!.power,
            voltage: status.powerStatus!.voltage,
            current: status.powerStatus!.current,
            frequency: status.powerStatus!.frequency,
            temperature: status.powerStatus!.temperature,
            totalEnergy: status.powerStatus!.totalEnergy,
            lastUpdated: DateTime.now(),
          ),
          weatherStatus: status.weatherStatus,
          gatewayStatus: status.gatewayStatus,
          rawJson: status.rawJson,
        );
        notifyListeners();
      }

      // Refresh status after a short delay
      Future.delayed(const Duration(milliseconds: 500), fetchAllStatuses);

      return true;
    } catch (e) {
      debugPrint('Failed to toggle device: $e');
      return false;
    }
  }

  // Auto-refresh management
  void _startAutoRefresh() {
    _stopAutoRefresh();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      fetchAllStatuses();
    });
  }

  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  // Pause/resume auto-refresh (for app lifecycle)
  void pauseAutoRefresh() {
    _stopAutoRefresh();
  }

  void resumeAutoRefresh() {
    if (_apiUrl != null && _token != null) {
      _startAutoRefresh();
      fetchAllStatuses(); // Immediate refresh on resume
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    if (_state == DeviceLoadState.error && _devices.isNotEmpty) {
      _state = DeviceLoadState.loaded;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    super.dispose();
  }
}
