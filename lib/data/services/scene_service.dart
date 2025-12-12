import '../models/scene.dart';
import 'api_service.dart';

class SceneService {
  final ApiService _apiService;

  SceneService(this._apiService);

  /// Fetch all scenes from Shelly Cloud API
  /// POST {apiUrl}/scene/list
  Future<List<Scene>> fetchScenes(String apiUrl, String token) async {
    final response = await _apiService.post(
      '$apiUrl/scene/list',
      {},
      token: token,
    );

    if (response['isok'] != true || response['data'] == null) {
      return [];
    }

    final data = response['data'] as Map<String, dynamic>;
    final sceneScripts = data['scene_scripts'] as Map<String, dynamic>? ?? {};

    final scenes = <Scene>[];
    sceneScripts.forEach((idStr, sceneJson) {
      if (sceneJson is Map<String, dynamic>) {
        final id = int.tryParse(idStr) ?? sceneJson['_id'] as int? ?? 0;
        scenes.add(Scene.fromJson(id, sceneJson));
      }
    });

    // Sort by position
    scenes.sort((a, b) => a.position.compareTo(b.position));

    return scenes;
  }

  /// Toggle scene enabled state
  /// POST {apiUrl}/scene/enable
  Future<void> toggleScene(
    String apiUrl,
    String token,
    int sceneId,
    bool enabled,
  ) async {
    final response = await _apiService.post(
      '$apiUrl/scene/enable',
      {
        'id': sceneId.toString(),
        'enabled': enabled.toString(),
      },
      token: token,
    );

    if (response['isok'] != true) {
      throw ApiException(message: 'Failed to toggle scene');
    }
  }

  /// Run scene manually
  /// POST {apiUrl}/scene/manual_run
  Future<void> runScene(
    String apiUrl,
    String token,
    int sceneId,
  ) async {
    final response = await _apiService.post(
      '$apiUrl/scene/manual_run',
      {
        'id': sceneId.toString(),
      },
      token: token,
    );

    if (response['isok'] != true) {
      throw ApiException(message: 'Failed to run scene');
    }
  }
}
