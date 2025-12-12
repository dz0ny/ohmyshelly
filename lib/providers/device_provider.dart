import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/models/device.dart';
import '../data/models/device_status.dart';
import '../data/models/statistics.dart';
import '../data/models/websocket_event.dart';
import '../data/models/action_log.dart';
import '../data/services/device_service.dart';
import '../data/services/api_service.dart';
import '../data/services/websocket_service.dart';
import '../core/utils/device_type_helper.dart';

enum DeviceLoadState {
  initial,
  loading,
  loaded,
  error,
}

class DeviceProvider extends ChangeNotifier {
  final DeviceService _deviceService;
  final WebSocketService? _webSocketService;
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
  final Map<String, List<double>> _pressureHistory = {};
  final Map<String, List<double>> _uvHistory = {};
  final Map<String, List<double>> _solarHistory = {};
  final Map<String, List<double>> _rainHistory = {};
  final Map<String, List<double>> _powerHistory = {};
  final Map<String, List<double>> _energyHistory = {};
  bool _isLoadingHistory = false;

  // WebSocket subscriptions
  StreamSubscription<WebSocketEvent>? _wsEventSubscription;
  StreamSubscription<WebSocketState>? _wsStateSubscription;

  // Action log stream for ScheduleProvider
  final _actionLogController = StreamController<({String deviceId, ActionLogEntry entry})>.broadcast();

  // Track previous output state to detect changes
  final Map<String, bool> _previousOutputState = {};

  // Track when devices were last updated via WebSocket (for API override protection)
  final Map<String, DateTime> _wsUpdateTimes = {};
  static const Duration _wsProtectionWindow = Duration(seconds: 10);

  static const Duration _refreshInterval = Duration(minutes: 1);

  DeviceProvider({
    required ApiService apiService,
    WebSocketService? webSocketService,
  })  : _deviceService = DeviceService(apiService),
        _webSocketService = webSocketService;

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

  /// Get pressure history for a device (for sparkline charts and trend calculation)
  List<double> getPressureHistory(String deviceId) =>
      _pressureHistory[deviceId] ?? [];

  /// Get UV index history for a device (for sparkline charts)
  List<double> getUvHistory(String deviceId) =>
      _uvHistory[deviceId] ?? [];

  /// Get solar irradiance history for a device (for sparkline charts)
  List<double> getSolarHistory(String deviceId) =>
      _solarHistory[deviceId] ?? [];

  /// Get rain/precipitation history for a device (for sparkline charts)
  List<double> getRainHistory(String deviceId) =>
      _rainHistory[deviceId] ?? [];

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
        // Extract average pressure from each data point
        _pressureHistory[deviceId] = stats.dataPoints
            .map((p) => p.avgPressure)
            .toList();
        // Extract UV index from each data point
        _uvHistory[deviceId] = stats.dataPoints
            .map((p) => p.uvIndex)
            .toList();
        // Extract solar irradiance from illuminance (lux / 120 = W/m²)
        _solarHistory[deviceId] = stats.dataPoints
            .map((p) => p.illuminance / 120)
            .toList();
        // Extract precipitation from each data point
        _rainHistory[deviceId] = stats.dataPoints
            .map((p) => p.precipitation)
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

  // WebSocket state getter
  WebSocketState get webSocketState =>
      _webSocketService?.state ?? WebSocketState.disconnected;

  /// Get the WebSocketService for direct RPC calls
  WebSocketService? get webSocketService => _webSocketService;

  /// Stream of action log events (for ScheduleProvider to subscribe)
  Stream<({String deviceId, ActionLogEntry entry})> get actionLogEvents =>
      _actionLogController.stream;

  // Set credentials (called when auth changes)
  void setCredentials(String? apiUrl, String? token) {
    _apiUrl = apiUrl;
    _token = token;

    if (apiUrl != null && token != null) {
      // Connect WebSocket and subscribe to events
      _connectWebSocket(apiUrl, token);
      // Start auto-refresh as fallback when credentials are set
      _startAutoRefresh();
    } else {
      // Stop auto-refresh and disconnect WebSocket when logged out
      _stopAutoRefresh();
      _disconnectWebSocket();
      _devices = [];
      _deviceStatuses = {};
      _state = DeviceLoadState.initial;
      notifyListeners();
    }
  }

  // WebSocket connection management
  void _connectWebSocket(String apiUrl, String token) {
    final ws = _webSocketService;
    if (ws == null) return;

    // Subscribe to WebSocket state changes
    _wsStateSubscription?.cancel();
    _wsStateSubscription = ws.stateStream.listen(
      _onWebSocketStateChanged,
    );

    // Subscribe to WebSocket events
    _wsEventSubscription?.cancel();
    _wsEventSubscription = ws.events.listen(
      _onWebSocketEvent,
    );

    // Connect
    ws.connect(apiUrl, token);
  }

  void _disconnectWebSocket() {
    _wsEventSubscription?.cancel();
    _wsEventSubscription = null;
    _wsStateSubscription?.cancel();
    _wsStateSubscription = null;
    _webSocketService?.disconnect();
  }

  void _onWebSocketStateChanged(WebSocketState state) {
    if (kDebugMode) {
      debugPrint('[DeviceProvider] WebSocket state: $state');
    }

    if (state == WebSocketState.connected) {
      // WebSocket connected - can reduce HTTP polling frequency
      // For now, we keep polling as backup but could disable it
    } else if (state == WebSocketState.disconnected ||
        state == WebSocketState.reconnecting) {
      // WebSocket disconnected - rely on HTTP polling
    }

    notifyListeners();
  }

  void _onWebSocketEvent(WebSocketEvent event) {
    switch (event) {
      case StatusChangeEvent e:
        _handleStatusChangeEvent(e);
      case OnlineChangeEvent e:
        _handleOnlineChangeEvent(e);
    }
  }

  void _handleStatusChangeEvent(StatusChangeEvent event) {
    if (kDebugMode) {
      debugPrint('[DeviceProvider] Status change for device: ${event.deviceId}');
    }

    // Add timestamp to status if not present (WebSocket events don't include _updated)
    final statusWithTimestamp = Map<String, dynamic>.from(event.status);
    statusWithTimestamp['_updated'] = DateTime.now().toIso8601String();

    // Parse the status using DeviceService
    final status = _deviceService.parseDeviceStatus(
      statusWithTimestamp,
      event.deviceCode,
    );

    // Check for output state change and emit action log event
    _checkOutputChange(event.deviceId, event.status, status);

    // Update device status
    _deviceStatuses[event.deviceId] = status;

    // Track WebSocket update time for API protection
    _wsUpdateTimes[event.deviceId] = DateTime.now();

    // Update device online status if available
    final deviceIndex = _devices.indexWhere((d) => d.id == event.deviceId);
    if (deviceIndex != -1) {
      // Device is online if we're receiving status updates
      final device = _devices[deviceIndex];
      if (!device.isOnline) {
        _devices[deviceIndex] = device.copyWith(isOnline: true);
      }
    }

    notifyListeners();
  }

  /// Check if output state changed and emit action log event
  void _checkOutputChange(
    String deviceId,
    Map<String, dynamic> rawStatus,
    DeviceStatus status,
  ) {
    // Only for power devices
    if (status.powerStatus == null) return;

    final currentOutput = status.powerStatus!.isOn;
    final previousOutput = _previousOutputState[deviceId];

    // Update tracking
    _previousOutputState[deviceId] = currentOutput;

    // Only emit if state actually changed (not first time)
    if (previousOutput != null && previousOutput != currentOutput) {
      // Extract source from switch:0.source
      final switchData = rawStatus['switch:0'] as Map<String, dynamic>?;
      final source = switchData?['source'] as String?;

      final entry = ActionLogEntry.fromStatusChange(
        isOn: currentOutput,
        source: source,
      );

      _actionLogController.add((deviceId: deviceId, entry: entry));

      if (kDebugMode) {
        debugPrint(
          '[DeviceProvider] Output changed for $deviceId: $previousOutput -> $currentOutput (source: $source)',
        );
      }
    }
  }

  void _handleOnlineChangeEvent(OnlineChangeEvent event) {
    if (kDebugMode) {
      debugPrint(
        '[DeviceProvider] Online change for device: ${event.deviceId} -> ${event.isOnline}',
      );
    }

    // Update device online status
    final deviceIndex = _devices.indexWhere((d) => d.id == event.deviceId);
    if (deviceIndex != -1) {
      final device = _devices[deviceIndex];
      if (device.isOnline != event.isOnline) {
        _devices[deviceIndex] = device.copyWith(isOnline: event.isOnline);
        notifyListeners();
      }
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
  // Merges API data with existing WebSocket data, keeping newer timestamps
  Future<void> fetchAllStatuses() async {
    if (_apiUrl == null || _token == null) return;

    try {
      final result = await _deviceService.fetchDevicesWithStatuses(_apiUrl!, _token!);
      _devices = result.devices;

      // Merge statuses: protect recent WebSocket data from API overwrites
      final now = DateTime.now();
      for (final entry in result.statuses.entries) {
        final deviceId = entry.key;
        final apiStatus = entry.value;
        final existingStatus = _deviceStatuses[deviceId];

        // Check if device was recently updated via WebSocket
        final wsUpdateTime = _wsUpdateTimes[deviceId];
        final isWsProtected = wsUpdateTime != null &&
            now.difference(wsUpdateTime) < _wsProtectionWindow;

        if (isWsProtected) {
          // Device was recently updated via WebSocket, skip API update
          if (kDebugMode) {
            debugPrint('[DeviceProvider] Skipping API update for $deviceId (WebSocket protected)');
          }
          continue;
        }

        if (existingStatus == null) {
          // No existing status, use API data
          _deviceStatuses[deviceId] = apiStatus;
        } else {
          // Compare timestamps to keep newer data
          final existingTime = _getStatusTimestamp(existingStatus);
          final apiTime = _getStatusTimestamp(apiStatus);

          if (apiTime != null && (existingTime == null || apiTime.isAfter(existingTime))) {
            // API data is newer, use it
            _deviceStatuses[deviceId] = apiStatus;
          }
          // Otherwise keep existing (WebSocket) data
        }
      }

      notifyListeners();
    } catch (e) {
      // Don't update error state for status refresh failures
      debugPrint('Failed to fetch statuses: $e');
    }
  }

  /// Extract timestamp from DeviceStatus for comparison
  DateTime? _getStatusTimestamp(DeviceStatus status) {
    // Check power status first
    if (status.powerStatus?.lastUpdated != null) {
      return status.powerStatus!.lastUpdated;
    }
    // Check weather status
    if (status.weatherStatus?.lastUpdated != null) {
      return status.weatherStatus!.lastUpdated;
    }
    // Check gateway status
    if (status.gatewayStatus?.lastUpdated != null) {
      return status.gatewayStatus!.lastUpdated;
    }
    return null;
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

      // Only fetch from API if WebSocket is not connected
      // WebSocket will provide real-time updates when connected
      if (webSocketState != WebSocketState.connected) {
        Future.delayed(const Duration(milliseconds: 500), fetchAllStatuses);
      }

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
    _disconnectWebSocket();
    _actionLogController.close();
    super.dispose();
  }
}
