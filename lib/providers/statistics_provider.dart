import 'package:flutter/foundation.dart';
import '../data/models/statistics.dart';
import '../data/services/device_service.dart';
import '../data/services/api_service.dart';
import '../widgets/common/date_range_picker.dart';
import '../core/utils/api_retry_mixin.dart';
import 'auth_provider.dart';

enum StatisticsLoadState {
  initial,
  loading,
  loaded,
  error,
}

class StatisticsProvider extends ChangeNotifier with ApiRetryMixin {
  final AuthProvider _authProvider;
  final DeviceService _deviceService;

  // ApiRetryMixin implementation - read directly from AuthProvider
  @override
  String? get currentApiUrl => _authProvider.apiUrl;

  @override
  String? get currentToken => _authProvider.token;

  @override
  void onCredentialsUpdated(String apiUrl, String token) {
    // No-op: we read credentials directly from AuthProvider
  }

  PowerStatistics? _powerStatistics;
  WeatherStatistics? _weatherStatistics;
  StatisticsLoadState _state = StatisticsLoadState.initial;
  String? _error;
  DateRangeSelection _selection = DateRangeSelection(
    type: DateRangeType.week,
    selectedDate: DateTime.now(),
  );
  String? _currentDeviceId;
  String? _currentStatsType; // 'power' or 'weather'

  StatisticsProvider({
    required AuthProvider authProvider,
    required ApiService apiService,
  })  : _authProvider = authProvider,
        _deviceService = DeviceService(apiService) {
    // Set up reauth callback to use AuthProvider
    reauthCallback = () async {
      final success = await _authProvider.reauthenticate();
      if (success && _authProvider.user != null) {
        return (
          apiUrl: _authProvider.user!.userApiUrl,
          token: _authProvider.user!.token,
        );
      }
      return null;
    };
  }

  // Getters
  PowerStatistics? get powerStatistics => _powerStatistics;
  WeatherStatistics? get weatherStatistics => _weatherStatistics;
  StatisticsLoadState get state => _state;
  String? get error => _error;
  DateRangeSelection get selection => _selection;
  bool get isLoading => _state == StatisticsLoadState.loading;

  // Set selected date range
  void setSelection(DateRangeSelection selection) {
    if (_selection != selection) {
      _selection = selection;
      notifyListeners();

      // Refetch data with new range if we have a device
      if (_currentDeviceId != null && _currentStatsType != null) {
        if (_currentStatsType == 'power') {
          fetchPowerStatistics(_currentDeviceId!);
        } else {
          fetchWeatherStatistics(_currentDeviceId!);
        }
      }
    }
  }

  // Fetch power statistics
  Future<void> fetchPowerStatistics(String deviceId) async {
    if (currentApiUrl == null || currentToken == null) {
      _error = 'Not authenticated';
      _state = StatisticsLoadState.error;
      notifyListeners();
      return;
    }

    _currentDeviceId = deviceId;
    _currentStatsType = 'power';
    _state = StatisticsLoadState.loading;
    _error = null;
    notifyListeners();

    try {
      final dateRange = _selection.getDateRange();
      // Use withAutoReauth to handle session expiration
      _powerStatistics = await withAutoReauth(
        (apiUrl, token) => _deviceService.fetchPowerStatisticsForRange(
          apiUrl,
          token,
          deviceId,
          dateRange.from,
          dateRange.to,
        ),
      );
      _state = StatisticsLoadState.loaded;
    } on ApiException catch (e) {
      debugPrint('Power statistics API error: ${e.message} (code: ${e.statusCode})');
      _error = e.friendlyMessage;
      _state = StatisticsLoadState.error;
    } catch (e, stackTrace) {
      debugPrint('Power statistics error: $e');
      debugPrint('Power statistics stackTrace: $stackTrace');
      _error = 'Failed to load statistics';
      _state = StatisticsLoadState.error;
    }

    notifyListeners();
  }

  // Fetch weather statistics
  Future<void> fetchWeatherStatistics(String deviceId) async {
    if (currentApiUrl == null || currentToken == null) {
      _error = 'Not authenticated';
      _state = StatisticsLoadState.error;
      notifyListeners();
      return;
    }

    _currentDeviceId = deviceId;
    _currentStatsType = 'weather';
    _state = StatisticsLoadState.loading;
    _error = null;
    notifyListeners();

    try {
      final dateRange = _selection.getDateRange();
      // Use withAutoReauth to handle session expiration
      _weatherStatistics = await withAutoReauth(
        (apiUrl, token) => _deviceService.fetchWeatherStatisticsForRange(
          apiUrl,
          token,
          deviceId,
          dateRange.from,
          dateRange.to,
        ),
      );
      _state = StatisticsLoadState.loaded;
    } on ApiException catch (e) {
      debugPrint('Weather statistics API error: ${e.message} (code: ${e.statusCode})');
      _error = e.friendlyMessage;
      _state = StatisticsLoadState.error;
    } catch (e, stackTrace) {
      debugPrint('Weather statistics error: $e');
      debugPrint('Weather statistics stackTrace: $stackTrace');
      _error = 'Failed to load statistics';
      _state = StatisticsLoadState.error;
    }

    notifyListeners();
  }

  // Clear statistics
  void clearStatistics() {
    _powerStatistics = null;
    _weatherStatistics = null;
    _currentDeviceId = null;
    _state = StatisticsLoadState.initial;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    if (_state == StatisticsLoadState.error) {
      _state = StatisticsLoadState.initial;
    }
    notifyListeners();
  }
}
