import 'package:flutter/foundation.dart';
import '../data/models/scene.dart';
import '../data/services/scene_service.dart';
import '../data/services/api_service.dart';
import '../core/utils/api_retry_mixin.dart';
import 'auth_provider.dart';

enum SceneLoadState {
  initial,
  loading,
  loaded,
  error,
}

class SceneProvider extends ChangeNotifier with ApiRetryMixin {
  final AuthProvider _authProvider;
  final SceneService _sceneService;

  // ApiRetryMixin implementation - read directly from AuthProvider
  @override
  String? get currentApiUrl => _authProvider.apiUrl;

  @override
  String? get currentToken => _authProvider.token;

  @override
  void onCredentialsUpdated(String apiUrl, String token) {
    // No-op: we read credentials directly from AuthProvider
  }

  List<Scene> _scenes = [];
  SceneLoadState _state = SceneLoadState.initial;
  String? _error;
  bool _isRefreshing = false;

  SceneProvider({
    required AuthProvider authProvider,
    required SceneService sceneService,
  })  : _authProvider = authProvider,
        _sceneService = sceneService {
    // Set up reauth callback to use AuthProvider
    reauthCallback = () async {
      final success = await _authProvider.reauthenticate();
      if (success && _authProvider.user != null) {
        return (
          apiUrl: _authProvider.user!.userApiUrl,
          token: _authProvider.user!.token,
        );
      }
      return null;
    };
  }

  // Getters
  List<Scene> get scenes => _scenes;
  SceneLoadState get state => _state;
  String? get error => _error;
  bool get isLoading => _state == SceneLoadState.loading;
  bool get isRefreshing => _isRefreshing;

  // Filtered scene lists
  List<Scene> get enabledScenes => _scenes.where((s) => s.enabled).toList();
  List<Scene> get disabledScenes => _scenes.where((s) => !s.enabled).toList();

  /// Get scenes grouped by room
  Map<String, List<Scene>> get scenesByRoom {
    final grouped = <String, List<Scene>>{};
    for (final scene in _scenes) {
      final roomName = scene.roomName;
      if (!grouped.containsKey(roomName)) {
        grouped[roomName] = [];
      }
      grouped[roomName]!.add(scene);
    }
    return grouped;
  }

  /// Fetch all scenes
  Future<void> fetchScenes() async {
    if (currentApiUrl == null || currentToken == null) {
      _state = SceneLoadState.error;
      _error = 'Not authenticated';
      notifyListeners();
      return;
    }

    _state = SceneLoadState.loading;
    _error = null;
    notifyListeners();

    try {
      // Use withAutoReauth to handle session expiration
      _scenes = await withAutoReauth(
        (apiUrl, token) => _sceneService.fetchScenes(apiUrl, token),
      );
      _state = SceneLoadState.loaded;
      _error = null;
    } on ApiException catch (e) {
      _state = SceneLoadState.error;
      _error = e.friendlyMessage;
      debugPrint('Failed to fetch scenes: $e');
    } catch (e) {
      _state = SceneLoadState.error;
      _error = e.toString();
      debugPrint('Failed to fetch scenes: $e');
    }

    notifyListeners();
  }

  /// Refresh scenes (pull-to-refresh)
  Future<void> refresh() async {
    if (currentApiUrl == null || currentToken == null) return;
    if (_isRefreshing) return;

    _isRefreshing = true;
    notifyListeners();

    try {
      // Use withAutoReauth to handle session expiration
      _scenes = await withAutoReauth(
        (apiUrl, token) => _sceneService.fetchScenes(apiUrl, token),
      );
      _state = SceneLoadState.loaded;
      _error = null;
    } catch (e) {
      debugPrint('Failed to refresh scenes: $e');
      // Keep existing data on refresh error
    }

    _isRefreshing = false;
    notifyListeners();
  }

  /// Toggle scene enabled state with optimistic update
  Future<bool> toggleScene(int sceneId, bool enabled) async {
    if (currentApiUrl == null || currentToken == null) return false;

    try {
      // Optimistic update
      final index = _scenes.indexWhere((s) => s.id == sceneId);
      if (index != -1) {
        _scenes[index] = _scenes[index].copyWith(enabled: enabled);
        notifyListeners();
      }

      // API call with auto-reauth
      await withAutoReauth(
        (apiUrl, token) => _sceneService.toggleScene(apiUrl, token, sceneId, enabled),
      );
      return true;
    } catch (e) {
      debugPrint('Failed to toggle scene: $e');

      // Revert optimistic update on failure
      final index = _scenes.indexWhere((s) => s.id == sceneId);
      if (index != -1) {
        _scenes[index] = _scenes[index].copyWith(enabled: !enabled);
        notifyListeners();
      }

      return false;
    }
  }

  /// Run scene manually
  Future<bool> runScene(int sceneId) async {
    if (currentApiUrl == null || currentToken == null) return false;

    try {
      // API call with auto-reauth
      await withAutoReauth(
        (apiUrl, token) => _sceneService.runScene(apiUrl, token, sceneId),
      );
      return true;
    } catch (e) {
      debugPrint('Failed to run scene: $e');
      return false;
    }
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear all data (for logout)
  void clear() {
    _scenes = [];
    _state = SceneLoadState.initial;
    _error = null;
    // Credentials are managed by AuthProvider
    notifyListeners();
  }
}
