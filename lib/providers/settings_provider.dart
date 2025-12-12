import 'package:flutter/material.dart';
import '../data/services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storageService;

  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.system;
  bool _showDevicesTab = true;
  bool _showScenesTab = false;
  bool _isInitialized = false;
  List<String> _dashboardDeviceOrder = [];
  List<String> _dashboardExcludedDevices = [];

  SettingsProvider({required StorageService storageService})
      : _storageService = storageService;

  Locale? get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  bool get showDevicesTab => _showDevicesTab;
  bool get showScenesTab => _showScenesTab;
  bool get isInitialized => _isInitialized;
  List<String> get dashboardDeviceOrder => _dashboardDeviceOrder;
  List<String> get dashboardExcludedDevices => _dashboardExcludedDevices;

  Future<void> init() async {
    final languageCode = await _storageService.getLanguageCode();
    if (languageCode != null) {
      _locale = Locale(languageCode);
    }
    final themeModeStr = await _storageService.getThemeMode();
    _themeMode = _themeModeFromString(themeModeStr);
    _showDevicesTab = await _storageService.getShowDevicesTab();
    _showScenesTab = await _storageService.getShowScenesTab();
    _dashboardDeviceOrder = await _storageService.getDashboardDeviceOrder();
    _dashboardExcludedDevices = await _storageService.getDashboardExcludedDevices();
    _isInitialized = true;
    notifyListeners();
  }

  ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String? _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return null;
    }
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    await _storageService.setLanguageCode(locale?.languageCode);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _storageService.setThemeMode(_themeModeToString(mode));
    notifyListeners();
  }

  Future<void> setShowDevicesTab(bool show) async {
    _showDevicesTab = show;
    await _storageService.setShowDevicesTab(show);
    notifyListeners();
  }

  Future<void> setShowScenesTab(bool show) async {
    _showScenesTab = show;
    await _storageService.setShowScenesTab(show);
    notifyListeners();
  }

  // Helper to get current language selection
  // null = system default, 'en' = English, 'sl' = Slovenian
  String? get currentLanguageCode => _locale?.languageCode;

  Future<void> setDashboardDeviceOrder(List<String> deviceIds) async {
    _dashboardDeviceOrder = deviceIds;
    await _storageService.setDashboardDeviceOrder(deviceIds);
    notifyListeners();
  }

  /// Check if a device is excluded from dashboard
  bool isDeviceExcludedFromDashboard(String deviceId) {
    return _dashboardExcludedDevices.contains(deviceId);
  }

  /// Toggle device exclusion from dashboard
  Future<void> setDeviceExcludedFromDashboard(String deviceId, bool excluded) async {
    if (excluded) {
      if (!_dashboardExcludedDevices.contains(deviceId)) {
        _dashboardExcludedDevices = [..._dashboardExcludedDevices, deviceId];
      }
    } else {
      _dashboardExcludedDevices = _dashboardExcludedDevices.where((id) => id != deviceId).toList();
    }
    await _storageService.setDashboardExcludedDevices(_dashboardExcludedDevices);
    notifyListeners();
  }
}
