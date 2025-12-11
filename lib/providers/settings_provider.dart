import 'package:flutter/material.dart';
import '../data/services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storageService;

  Locale? _locale;
  bool _showDevicesTab = true;
  bool _isInitialized = false;
  List<String> _dashboardDeviceOrder = [];

  SettingsProvider({required StorageService storageService})
      : _storageService = storageService;

  Locale? get locale => _locale;
  bool get showDevicesTab => _showDevicesTab;
  bool get isInitialized => _isInitialized;
  List<String> get dashboardDeviceOrder => _dashboardDeviceOrder;

  Future<void> init() async {
    final languageCode = await _storageService.getLanguageCode();
    if (languageCode != null) {
      _locale = Locale(languageCode);
    }
    _showDevicesTab = await _storageService.getShowDevicesTab();
    _dashboardDeviceOrder = await _storageService.getDashboardDeviceOrder();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    await _storageService.setLanguageCode(locale?.languageCode);
    notifyListeners();
  }

  Future<void> setShowDevicesTab(bool show) async {
    _showDevicesTab = show;
    await _storageService.setShowDevicesTab(show);
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
}
