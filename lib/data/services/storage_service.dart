import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class StorageService {
  late FlutterSecureStorage _storage;

  static const String _userKey = 'user_data';
  static const String _onboardingKey = 'onboarding_complete';
  static const String _languageKey = 'language_code';

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

  // Clear all data (for logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
