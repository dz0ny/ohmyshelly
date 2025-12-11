import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final String? details;

  ApiException({
    this.statusCode,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'ApiException: $message (code: $statusCode)';

  String get friendlyMessage {
    if (statusCode == 401) {
      return 'Your session has expired. Please sign in again.';
    }
    if (statusCode == 403) {
      return 'You don\'t have permission to access this.';
    }
    if (statusCode == 404) {
      return 'The requested resource was not found.';
    }
    if (statusCode != null && statusCode! >= 500) {
      return 'Server is temporarily unavailable. Please try again later.';
    }
    if (message.contains('SocketException') ||
        message.contains('ClientException')) {
      return 'Unable to connect. Please check your internet connection.';
    }
    return 'Something went wrong. Please try again.';
  }
}

class ApiService {
  final http.Client _client;

  /// Enable/disable verbose API response logging
  static bool enableResponseLogging = false;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String authBaseUrl = 'https://api.shelly.cloud';

  Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body, {
    String? token,
    bool isFormEncoded = true,
  }) async {
    try {
      final headers = <String, String>{
        if (isFormEncoded)
          'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8'
        else
          'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      // For form-encoded, convert all values to strings
      final encodedBody = isFormEncoded
          ? body.map((k, v) => MapEntry(k, v.toString()))
          : jsonEncode(body);

      final response = await _client.post(
        Uri.parse(url),
        headers: headers,
        body: encodedBody,
      );

      return _handleResponse(response, url: url);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  /// POST with JSON body (for v2 API)
  Future<Map<String, dynamic>> postJson(
    String url,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await _client.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      return _handleJsonResponse(response, url: url);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> get(
    String url, {
    String? token,
    Map<String, String>? queryParams,
  }) async {
    try {
      var uri = Uri.parse(url);
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final headers = <String, String>{
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await _client.get(uri, headers: headers);
      return _handleResponse(response, url: uri.toString());
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response, {String? url}) {
    final body = response.body;

    // Log response in debug mode
    if (kDebugMode && enableResponseLogging) {
      _logResponse(url ?? 'unknown', response.statusCode, body);
    }

    // Always log URL and status (but not body) for debugging
    if (kDebugMode) {
      debugPrint('API: ${response.statusCode} $url');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final json = jsonDecode(body) as Map<String, dynamic>;

        // Check for Shelly API error format
        if (json['isok'] == false) {
          final errors = json['errors'] as Map<String, dynamic>?;
          throw ApiException(
            statusCode: response.statusCode,
            message: errors?['message'] as String? ?? 'API error',
            details: errors?.toString(),
          );
        }

        return json;
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Invalid response format',
        );
      }
    } else {
      String errorMessage = 'Request failed';
      try {
        final json = jsonDecode(body) as Map<String, dynamic>;
        errorMessage = json['message'] as String? ??
            json['error'] as String? ??
            'Request failed';
      } catch (_) {
        // Body is not JSON
      }

      throw ApiException(
        statusCode: response.statusCode,
        message: errorMessage,
      );
    }
  }

  /// Handle JSON response that can be array or object (for v2 API)
  Map<String, dynamic> _handleJsonResponse(http.Response response, {String? url}) {
    final body = response.body;

    // Log response in debug mode
    if (kDebugMode && enableResponseLogging) {
      _logResponse(url ?? 'unknown', response.statusCode, body);
    }

    // Always log URL and status (but not body) for debugging
    if (kDebugMode) {
      debugPrint('API: ${response.statusCode} $url');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = jsonDecode(body);

        // v2 API can return array directly
        if (decoded is List) {
          return {'data': decoded};
        }

        final json = decoded as Map<String, dynamic>;

        // Check for Shelly API error format
        if (json['isok'] == false) {
          final errors = json['errors'] as Map<String, dynamic>?;
          throw ApiException(
            statusCode: response.statusCode,
            message: errors?['message'] as String? ?? 'API error',
            details: errors?.toString(),
          );
        }

        return json;
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Invalid response format',
        );
      }
    } else {
      String errorMessage = 'Request failed';
      try {
        final json = jsonDecode(body) as Map<String, dynamic>;
        errorMessage = json['message'] as String? ??
            json['error'] as String? ??
            'Request failed';
      } catch (_) {
        // Body is not JSON
      }

      throw ApiException(
        statusCode: response.statusCode,
        message: errorMessage,
      );
    }
  }

  void _logResponse(String url, int statusCode, String body) {
    // Pretty print JSON
    String prettyBody;
    try {
      final json = jsonDecode(body);
      prettyBody = const JsonEncoder.withIndent('  ').convert(json);
    } catch (_) {
      prettyBody = body;
    }

    // Use debugPrint for reliable console output
    debugPrint('╔══════════════════════════════════════════════════════════════');
    debugPrint('║ API Response');
    debugPrint('╠══════════════════════════════════════════════════════════════');
    debugPrint('║ URL: $url');
    debugPrint('║ Status: $statusCode');
    debugPrint('╠══════════════════════════════════════════════════════════════');
    // Split long JSON into chunks (debugPrint has a limit)
    final lines = prettyBody.split('\n');
    for (final line in lines) {
      debugPrint(line);
    }
    debugPrint('╚══════════════════════════════════════════════════════════════');
  }

  void dispose() {
    _client.close();
  }
}
