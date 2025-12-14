import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException: $message';

  String get friendlyMessage {
    if (code == 'invalid_credentials' ||
        message.toLowerCase().contains('invalid') ||
        message.toLowerCase().contains('incorrect')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('connection')) {
      return 'Unable to connect. Please check your internet.';
    }
    return 'Unable to sign in. Please try again.';
  }
}

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<User> login(String email, String password) async {
    // Hash password with SHA1 as required by Shelly API
    final hashedPassword = hashPassword(password);
    return loginWithHashedPassword(email, hashedPassword);
  }

  /// Login with an already-hashed password (for auto-reauthentication)
  Future<User> loginWithHashedPassword(String email, String hashedPassword) async {
    try {
      final response = await _apiService.post(
        '${ApiService.authBaseUrl}/auth/login',
        {
          'email': email,
          'password': hashedPassword,
        },
      );

      if (response['isok'] == true && response['data'] != null) {
        return User.fromLoginResponse(response, email);
      } else {
        final errors = response['errors'] as Map<String, dynamic>?;
        throw AuthException(
          errors?['message'] as String? ?? 'Login failed',
          code: errors?['code'] as String?,
        );
      }
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  /// Hash password with SHA1 (public for storing credentials)
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha1.convert(bytes);
    return digest.toString();
  }
}
