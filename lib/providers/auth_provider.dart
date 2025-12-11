import 'package:flutter/foundation.dart';
import '../data/models/user.dart';
import '../data/services/auth_service.dart';
import '../data/services/storage_service.dart';
import '../data/services/api_service.dart';

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
        _state = AuthState.authenticated;
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
      _user = user;
      _state = AuthState.authenticated;
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

  // Logout
  Future<void> logout() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      await _storageService.deleteUser();
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
