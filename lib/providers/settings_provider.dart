import 'package:flutter/material.dart';
import '../data/services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storageService;

  Locale? _locale;
  bool _isInitialized = false;

  SettingsProvider({required StorageService storageService})
      : _storageService = storageService;

  Locale? get locale => _locale;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    final languageCode = await _storageService.getLanguageCode();
    if (languageCode != null) {
      _locale = Locale(languageCode);
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    await _storageService.setLanguageCode(locale?.languageCode);
    notifyListeners();
  }

  // Helper to get current language selection
  // null = system default, 'en' = English, 'sl' = Slovenian
  String? get currentLanguageCode => _locale?.languageCode;
}
