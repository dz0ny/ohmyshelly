import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/models/user.dart';
import '../data/services/auth_service.dart';
import '../data/services/storage_service.dart';
import '../data/services/api_service.dart';
import '../core/utils/jwt_utils.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final StorageService _storageService;
  final AuthService _authService;

  User? _user;
  AuthState _state = AuthState.initial;
  String? _error;
  bool _isFirstLaunch = true;

  // Token refresh timer
  Timer? _tokenRefreshTimer;
  static const Duration _tokenRefreshMargin = Duration(minutes: 5);
  bool _isRefreshing = false;

  AuthProvider({
    required StorageService storageService,
    required ApiService apiService,
  })  : _storageService = storageService,
        _authService = AuthService(apiService);

  // Getters
  User? get user => _user;
  AuthState get state => _state;
  String? get error => _error;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;
  bool get isLoading => _state == AuthState.loading;
  String? get token => _user?.token;
  String? get apiUrl => _user?.userApiUrl;

  /// Check if the current token is expired
  bool get isTokenExpired => _user?.token != null && JwtUtils.isExpired(_user!.token);

  /// Check if the current token will expire soon
  bool get isTokenExpiringSoon =>
      _user?.token != null && JwtUtils.willExpireSoon(_user!.token, margin: _tokenRefreshMargin);

  /// Get remaining time until token expiration
  Duration? get tokenTimeRemaining =>
      _user?.token != null ? JwtUtils.getTimeUntilExpiration(_user!.token) : null;

  /// Get human-readable token expiration
  String? get tokenExpirationString =>
      _user?.token != null ? JwtUtils.getExpirationString(_user!.token) : null;

  // Initialize - check for stored credentials
  Future<void> initialize() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      // Check onboarding status
      _isFirstLaunch = !(await _storageService.isOnboardingComplete());

      // Check for stored user
      final storedUser = await _storageService.getUser();
      if (storedUser != null) {
        _user = storedUser;

        // Check if token is expired or about to expire
        if (isTokenExpired || isTokenExpiringSoon) {
          if (kDebugMode) {
            debugPrint('[Auth] Stored token expired/expiring, refreshing...');
          }
          final refreshed = await reauthenticate();
          if (!refreshed) {
            // Reauthentication failed, but we still have stored credentials
            // The UI will work with cloud API auto-reauth
            if (kDebugMode) {
              debugPrint('[Auth] Token refresh failed, will retry on next API call');
            }
          }
        }

        _state = AuthState.authenticated;
        _scheduleTokenRefresh();
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (e) {
      _state = AuthState.unauthenticated;
      _error = e.toString();
    }

    notifyListeners();
  }

  // Login
  Future<bool> login(String email, String password) async {
    _state = AuthState.loading;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.login(email, password);
      await _storageService.saveUser(user);
      // Store hashed credentials for auto-reauthentication
      final hashedPassword = _authService.hashPassword(password);
      await _storageService.saveCredentials(email, hashedPassword);
      _user = user;
      _state = AuthState.authenticated;
      _scheduleTokenRefresh();
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.friendlyMessage;
      _state = AuthState.error;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Unable to sign in. Please try again.';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  /// Attempt to reauthenticate using stored credentials.
  /// Returns true if successful, false otherwise.
  /// Does not change UI state on failure - caller handles that.
  Future<bool> reauthenticate() async {
    if (_isRefreshing) {
      if (kDebugMode) {
        debugPrint('[Auth] Already refreshing token, skipping');
      }
      return false;
    }

    _isRefreshing = true;
    try {
      final credentials = await _storageService.getCredentials();
      if (credentials == null) {
        debugPrint('[Auth] Reauthentication failed: no stored credentials');
        return false;
      }

      final user = await _authService.loginWithHashedPassword(
        credentials['email']!,
        credentials['hashedPassword']!,
      );
      await _storageService.saveUser(user);
      _user = user;
      _state = AuthState.authenticated;
      _scheduleTokenRefresh();
      notifyListeners();

      if (kDebugMode) {
        debugPrint('[Auth] Reauthentication successful, token valid for $tokenExpirationString');
      }
      return true;
    } catch (e) {
      debugPrint('[Auth] Reauthentication failed: $e');
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Schedule automatic token refresh before expiration
  void _scheduleTokenRefresh() {
    _tokenRefreshTimer?.cancel();

    if (_user?.token == null) return;

    final remaining = tokenTimeRemaining;
    if (remaining == null) return;

    // Schedule refresh with margin before expiration
    final refreshIn = remaining - _tokenRefreshMargin;
    if (refreshIn.isNegative) {
      // Token already needs refresh
      if (kDebugMode) {
        debugPrint('[Auth] Token needs immediate refresh');
      }
      _refreshToken();
      return;
    }

    if (kDebugMode) {
      debugPrint('[Auth] Scheduling token refresh in ${refreshIn.inMinutes}m (token expires in ${remaining.inMinutes}m)');
    }

    _tokenRefreshTimer = Timer(refreshIn, _refreshToken);
  }

  /// Perform automatic token refresh
  Future<void> _refreshToken() async {
    if (kDebugMode) {
      debugPrint('[Auth] Auto-refreshing token...');
    }
    await reauthenticate();
  }

  /// Cancel token refresh timer
  void _cancelTokenRefresh() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
  }

  // Logout
  Future<void> logout() async {
    _state = AuthState.loading;
    notifyListeners();

    _cancelTokenRefresh();

    try {
      await _storageService.deleteUser();
      await _storageService.deleteCredentials();
      _user = null;
      _state = AuthState.unauthenticated;
    } catch (e) {
      // Even if storage fails, clear local state
      _user = null;
      _state = AuthState.unauthenticated;
    }

    notifyListeners();
  }

  // Mark onboarding as complete
  Future<void> completeOnboarding() async {
    await _storageService.markOnboardingComplete();
    _isFirstLaunch = false;
    notifyListeners();
  }

  // Reset onboarding (for re-showing onboarding flow)
  Future<void> resetOnboarding() async {
    await _storageService.resetOnboarding();
    _isFirstLaunch = true;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    if (_state == AuthState.error) {
      _state = _user != null ? AuthState.authenticated : AuthState.unauthenticated;
    }
    notifyListeners();
  }

  // Update token if needed (e.g., after refresh)
  Future<void> updateToken(String newToken) async {
    if (_user != null) {
      _user = _user!.copyWith(token: newToken);
      await _storageService.saveUser(_user!);
      notifyListeners();
    }
  }
}
