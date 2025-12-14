import 'package:flutter/foundation.dart';
import '../../data/services/api_service.dart';

/// Callback type for reauthentication.
/// Returns new credentials if successful, null if failed.
typedef ReauthCallback = Future<({String apiUrl, String token})?> Function();

/// Mixin providing retry logic with automatic reauthentication for API calls.
///
/// Providers that make API calls should use this mixin to handle 401 errors
/// by automatically reauthenticating and retrying the failed request.
mixin ApiRetryMixin {
  /// Callback for reauthentication, should be set by the provider owner
  ReauthCallback? reauthCallback;

  /// Current API URL
  String? get currentApiUrl;

  /// Current token
  String? get currentToken;

  /// Called when credentials are updated after reauthentication
  void onCredentialsUpdated(String apiUrl, String token);

  /// Execute an API call with automatic retry on 401 errors.
  ///
  /// If the call fails with a 401 (session expired), this method will:
  /// 1. Call the reauthCallback to get new credentials
  /// 2. Update the credentials via onCredentialsUpdated
  /// 3. Retry the API call once with the new credentials
  ///
  /// The [apiCall] function receives the current apiUrl and token.
  Future<T> withAutoReauth<T>(
    Future<T> Function(String apiUrl, String token) apiCall,
  ) async {
    final apiUrl = currentApiUrl;
    final token = currentToken;

    if (apiUrl == null || token == null) {
      throw ApiException(message: 'Not authenticated');
    }

    try {
      return await apiCall(apiUrl, token);
    } on ApiException catch (e) {
      if (e.isSessionExpired && reauthCallback != null) {
        debugPrint('[ApiRetryMixin] Session expired, attempting reauthentication...');

        final newCredentials = await reauthCallback!();
        if (newCredentials != null) {
          debugPrint('[ApiRetryMixin] Reauthentication successful, retrying request...');
          onCredentialsUpdated(newCredentials.apiUrl, newCredentials.token);
          // Retry with new credentials
          return await apiCall(newCredentials.apiUrl, newCredentials.token);
        } else {
          debugPrint('[ApiRetryMixin] Reauthentication failed');
        }
      }
      rethrow;
    }
  }
}
