import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../models/device.dart';
import '../models/local_device_info.dart';

class StorageService {
  late FlutterSecureStorage _storage;

  static const String _userKey = 'user_data';
  static const String _onboardingKey = 'onboarding_complete';
  static const String _languageKey = 'language_code';
  static const String _themeModeKey = 'theme_mode';
  static const String _showDevicesTabKey = 'show_devices_tab';
  static const String _showScenesTabKey = 'show_scenes_tab';
  static const String _showDeviceInfoButtonKey = 'show_device_info_button';
  static const String _showScheduleButtonKey = 'show_schedule_button';
  static const String _showActionsButtonKey = 'show_actions_button';
  static const String _dashboardDeviceOrderKey = 'dashboard_device_order';
  static const String _dashboardExcludedDevicesKey = 'dashboard_excluded_devices';
  static const String _localDeviceInfoKey = 'local_device_info';
  static const String _credentialsKey = 'auth_credentials';

  Future<void> init() async {
    _storage = const FlutterSecureStorage(
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

  // Credentials methods (for auto-reauthentication)
  Future<void> saveCredentials(String email, String hashedPassword) async {
    final data = jsonEncode({
      'email': email,
      'hashedPassword': hashedPassword,
    });
    await _storage.write(key: _credentialsKey, value: data);
  }

  Future<Map<String, String>?> getCredentials() async {
    final json = await _storage.read(key: _credentialsKey);
    if (json == null) return null;

    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return {
        'email': data['email'] as String,
        'hashedPassword': data['hashedPassword'] as String,
      };
    } catch (e) {
      await deleteCredentials();
      return null;
    }
  }

  Future<void> deleteCredentials() async {
    await _storage.delete(key: _credentialsKey);
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

  // Show device info button setting (default: false - hidden by default)
  Future<bool> getShowDeviceInfoButton() async {
    final value = await _storage.read(key: _showDeviceInfoButtonKey);
    return value == 'true'; // Default to false
  }

  Future<void> setShowDeviceInfoButton(bool show) async {
    await _storage.write(key: _showDeviceInfoButtonKey, value: show.toString());
  }

  // Show schedule button setting (default: true)
  Future<bool> getShowScheduleButton() async {
    final value = await _storage.read(key: _showScheduleButtonKey);
    return value != 'false'; // Default to true
  }

  Future<void> setShowScheduleButton(bool show) async {
    await _storage.write(key: _showScheduleButtonKey, value: show.toString());
  }

  // Show actions button setting (default: false - hidden by default)
  Future<bool> getShowActionsButton() async {
    final value = await _storage.read(key: _showActionsButtonKey);
    return value == 'true'; // Default to false
  }

  Future<void> setShowActionsButton(bool show) async {
    await _storage.write(key: _showActionsButtonKey, value: show.toString());
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

  // Cached devices (for offline mode)
  static const String _cachedDevicesKey = 'cached_devices';

  Future<void> saveCachedDevices(List<Device> devices) async {
    final encoded = jsonEncode(devices.map((d) => d.toJson()).toList());
    await _storage.write(key: _cachedDevicesKey, value: encoded);
  }

  Future<List<Device>> getCachedDevices() async {
    final json = await _storage.read(key: _cachedDevicesKey);
    if (json == null) return [];

    try {
      final data = jsonDecode(json) as List<dynamic>;
      return data
          .map((d) => Device.fromCacheJson(d as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearCachedDevices() async {
    await _storage.delete(key: _cachedDevicesKey);
  }

  // Device backup (schedules and webhooks)
  static const String _deviceBackupPrefix = 'device_backup_';

  Future<void> saveDeviceBackup(String deviceId, Map<String, dynamic> backup) async {
    final encoded = jsonEncode(backup);
    await _storage.write(key: '$_deviceBackupPrefix$deviceId', value: encoded);
  }

  Future<Map<String, dynamic>?> getDeviceBackup(String deviceId) async {
    final json = await _storage.read(key: '$_deviceBackupPrefix$deviceId');
    if (json == null) return null;

    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<bool> hasDeviceBackup(String deviceId) async {
    final json = await _storage.read(key: '$_deviceBackupPrefix$deviceId');
    return json != null;
  }

  Future<void> deleteDeviceBackup(String deviceId) async {
    await _storage.delete(key: '$_deviceBackupPrefix$deviceId');
  }

  // Clear all data (for logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
