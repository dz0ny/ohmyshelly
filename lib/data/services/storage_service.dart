import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../models/local_device_info.dart';

class StorageService {
  late FlutterSecureStorage _storage;

  static const String _userKey = 'user_data';
  static const String _onboardingKey = 'onboarding_complete';
  static const String _languageKey = 'language_code';
  static const String _themeModeKey = 'theme_mode';
  static const String _showDevicesTabKey = 'show_devices_tab';
  static const String _showScenesTabKey = 'show_scenes_tab';
  static const String _dashboardDeviceOrderKey = 'dashboard_device_order';
  static const String _dashboardExcludedDevicesKey = 'dashboard_excluded_devices';
  static const String _localDeviceInfoKey = 'local_device_info';

  Future<void> init() async {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    );
  }

  // User methods
  Future<void> saveUser(User user) async {
    final json = jsonEncode(user.toJson());
    await _storage.write(key: _userKey, value: json);
  }

  Future<User?> getUser() async {
    final json = await _storage.read(key: _userKey);
    if (json == null) return null;

    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return User.fromJson(data);
    } catch (e) {
      // Corrupted data, clear it
      await deleteUser();
      return null;
    }
  }

  Future<void> deleteUser() async {
    await _storage.delete(key: _userKey);
  }

  Future<bool> hasUser() async {
    final user = await getUser();
    return user != null;
  }

  // Onboarding methods
  Future<bool> isOnboardingComplete() async {
    final value = await _storage.read(key: _onboardingKey);
    return value == 'true';
  }

  Future<void> markOnboardingComplete() async {
    await _storage.write(key: _onboardingKey, value: 'true');
  }

  Future<void> resetOnboarding() async {
    await _storage.delete(key: _onboardingKey);
  }

  // Language methods
  Future<String?> getLanguageCode() async {
    return await _storage.read(key: _languageKey);
  }

  Future<void> setLanguageCode(String? languageCode) async {
    if (languageCode == null) {
      await _storage.delete(key: _languageKey);
    } else {
      await _storage.write(key: _languageKey, value: languageCode);
    }
  }

  // Theme mode methods (system, light, dark)
  Future<String?> getThemeMode() async {
    return await _storage.read(key: _themeModeKey);
  }

  Future<void> setThemeMode(String? themeMode) async {
    if (themeMode == null) {
      await _storage.delete(key: _themeModeKey);
    } else {
      await _storage.write(key: _themeModeKey, value: themeMode);
    }
  }

  // Show devices tab setting (default: true)
  Future<bool> getShowDevicesTab() async {
    final value = await _storage.read(key: _showDevicesTabKey);
    return value != 'false'; // Default to true
  }

  Future<void> setShowDevicesTab(bool show) async {
    await _storage.write(key: _showDevicesTabKey, value: show.toString());
  }

  // Show scenes tab setting (default: false - hidden by default)
  Future<bool> getShowScenesTab() async {
    final value = await _storage.read(key: _showScenesTabKey);
    return value == 'true'; // Default to false
  }

  Future<void> setShowScenesTab(bool show) async {
    await _storage.write(key: _showScenesTabKey, value: show.toString());
  }

  // Dashboard device order (list of device IDs)
  Future<List<String>> getDashboardDeviceOrder() async {
    final value = await _storage.read(key: _dashboardDeviceOrderKey);
    if (value == null || value.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(value);
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }

  Future<void> setDashboardDeviceOrder(List<String> deviceIds) async {
    final encoded = jsonEncode(deviceIds);
    await _storage.write(key: _dashboardDeviceOrderKey, value: encoded);
  }

  // Dashboard excluded devices (list of device IDs to hide from dashboard)
  Future<List<String>> getDashboardExcludedDevices() async {
    final value = await _storage.read(key: _dashboardExcludedDevicesKey);
    if (value == null || value.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(value);
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }

  Future<void> setDashboardExcludedDevices(List<String> deviceIds) async {
    final encoded = jsonEncode(deviceIds);
    await _storage.write(key: _dashboardExcludedDevicesKey, value: encoded);
  }

  // Local device info methods (for local network connection)
  Future<void> saveLocalDeviceInfo(String deviceId, LocalDeviceInfo info) async {
    final allInfo = await getLocalDeviceInfo();
    allInfo[deviceId.toLowerCase()] = info;
    final encoded = jsonEncode(
      allInfo.map((k, v) => MapEntry(k, v.toJson())),
    );
    await _storage.write(key: _localDeviceInfoKey, value: encoded);
  }

  Future<Map<String, LocalDeviceInfo>> getLocalDeviceInfo() async {
    final json = await _storage.read(key: _localDeviceInfoKey);
    if (json == null) return {};

    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return data.map(
        (k, v) => MapEntry(k, LocalDeviceInfo.fromJson(v as Map<String, dynamic>)),
      );
    } catch (e) {
      return {};
    }
  }

  Future<void> clearLocalDeviceInfo() async {
    await _storage.delete(key: _localDeviceInfoKey);
  }

  // Clear all data (for logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
