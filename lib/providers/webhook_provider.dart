import 'package:flutter/foundation.dart';
import '../data/models/webhook.dart';
import '../data/services/websocket_service.dart';

/// Provider for managing device webhooks (actions).
class WebhookProvider extends ChangeNotifier {
  final WebSocketService _webSocketService;

  // State: webhooks per device
  final Map<String, List<Webhook>> _webhooks = {};
  final Map<String, bool> _isLoading = {};
  final Map<String, String?> _errors = {};
  final Map<String, int> _revisions = {};

  WebhookProvider({
    required WebSocketService webSocketService,
  }) : _webSocketService = webSocketService;

  // --- Getters ---

  /// Get webhooks for a device.
  List<Webhook> getWebhooks(String deviceId) => _webhooks[deviceId] ?? [];

  /// Check if webhooks are loading for a device.
  bool isLoading(String deviceId) => _isLoading[deviceId] ?? false;

  /// Get error for a device.
  String? getError(String deviceId) => _errors[deviceId];

  /// Check if WebSocket is connected.
  bool get isConnected => _webSocketService.isConnected;

  /// Get revision number for a device's webhooks.
  int getRevision(String deviceId) => _revisions[deviceId] ?? 0;

  // --- Webhook Operations ---

  /// Fetch webhooks for a device via WebSocket RPC.
  Future<void> fetchWebhooks(String deviceId) async {
    if (!_webSocketService.isConnected) {
      _errors[deviceId] = 'Not connected';
      notifyListeners();
      return;
    }

    _isLoading[deviceId] = true;
    _errors[deviceId] = null;
    notifyListeners();

    try {
      final response = await _webSocketService.sendRpc(
        deviceId: deviceId,
        method: 'webhook.list',
        params: {},
      );

      final result = response['result'] as Map<String, dynamic>?;
      final hooks = result?['hooks'] as List<dynamic>? ?? [];
      final rev = result?['rev'] as int? ?? 0;

      _webhooks[deviceId] = hooks
          .map((h) => Webhook.fromJson(h as Map<String, dynamic>))
          .toList();
      _revisions[deviceId] = rev;

      if (kDebugMode) {
        debugPrint(
            '[WebhookProvider] Loaded ${_webhooks[deviceId]!.length} webhooks for $deviceId');
      }
    } on WebSocketException catch (e) {
      _errors[deviceId] = e.message;
      if (kDebugMode) {
        debugPrint('[WebhookProvider] Failed to fetch webhooks: $e');
      }
    } catch (e) {
      _errors[deviceId] = 'Failed to load webhooks';
      if (kDebugMode) {
        debugPrint('[WebhookProvider] Failed to fetch webhooks: $e');
      }
    } finally {
      _isLoading[deviceId] = false;
      notifyListeners();
    }
  }

  /// Create a new webhook for a device.
  Future<bool> createWebhook(
    String deviceId, {
    required String event,
    required String name,
    required List<String> urls,
    int cid = 0,
    String? sslCa,
    String? condition,
    int repeatPeriod = 0,
  }) async {
    if (!_webSocketService.isConnected) return false;

    try {
      final params = <String, dynamic>{
        'cid': cid,
        'enable': true,
        'event': event,
        'name': name,
        'urls': urls,
        'repeat_period': repeatPeriod,
      };

      if (sslCa != null) {
        params['ssl_ca'] = sslCa;
      }
      if (condition != null && condition.isNotEmpty) {
        params['condition'] = condition;
      }

      final response = await _webSocketService.sendRpc(
        deviceId: deviceId,
        method: 'webhook.create',
        params: params,
      );

      final result = response['result'] as Map<String, dynamic>?;
      if (result != null && result['id'] != null) {
        // Refresh webhooks to get updated list
        await fetchWebhooks(deviceId);
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[WebhookProvider] Failed to create webhook: $e');
      }
      return false;
    }
  }

  /// Create a webhook from backup data.
  Future<bool> createWebhookFromBackup(
    String deviceId,
    Webhook webhook,
  ) async {
    if (!_webSocketService.isConnected) return false;

    try {
      final params = <String, dynamic>{
        'cid': webhook.cid,
        'enable': webhook.enabled,
        'event': webhook.event,
        'name': webhook.name,
        'urls': webhook.urls,
        'repeat_period': webhook.repeatPeriod,
      };

      if (webhook.sslCa != null) {
        params['ssl_ca'] = webhook.sslCa;
      }
      if (webhook.condition != null && webhook.condition!.isNotEmpty) {
        params['condition'] = webhook.condition;
      }

      final response = await _webSocketService.sendRpc(
        deviceId: deviceId,
        method: 'webhook.create',
        params: params,
      );

      final result = response['result'] as Map<String, dynamic>?;
      return result != null && result['id'] != null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[WebhookProvider] Failed to create webhook from backup: $e');
      }
      return false;
    }
  }

  /// Update an existing webhook.
  Future<bool> updateWebhook(
    String deviceId,
    Webhook webhook, {
    String? event,
    String? name,
    List<String>? urls,
    String? sslCa,
    String? condition,
    int? repeatPeriod,
    bool? enabled,
  }) async {
    if (!_webSocketService.isConnected) return false;

    try {
      final params = <String, dynamic>{'id': webhook.id};

      // Only include changed fields
      if (enabled != null) {
        params['enable'] = enabled;
      }
      if (event != null) {
        params['event'] = event;
      }
      if (name != null) {
        params['name'] = name;
      }
      if (urls != null) {
        params['urls'] = urls;
      }
      if (sslCa != null) {
        params['ssl_ca'] = sslCa;
      }
      if (condition != null) {
        params['condition'] = condition;
      }
      if (repeatPeriod != null) {
        params['repeat_period'] = repeatPeriod;
      }

      await _webSocketService.sendRpc(
        deviceId: deviceId,
        method: 'webhook.update',
        params: params,
      );

      // Refresh webhooks to get updated list
      await fetchWebhooks(deviceId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[WebhookProvider] Failed to update webhook: $e');
      }
      return false;
    }
  }

  /// Toggle webhook enabled state.
  Future<bool> toggleWebhook(
    String deviceId,
    int webhookId,
    bool enabled,
  ) async {
    if (!_webSocketService.isConnected) return false;

    // Optimistic update
    final webhooks = _webhooks[deviceId];
    if (webhooks != null) {
      final index = webhooks.indexWhere((w) => w.id == webhookId);
      if (index != -1) {
        _webhooks[deviceId] = List.from(webhooks)
          ..[index] = webhooks[index].copyWith(enabled: enabled);
        notifyListeners();
      }
    }

    try {
      await _webSocketService.sendRpc(
        deviceId: deviceId,
        method: 'webhook.update',
        params: {
          'id': webhookId,
          'enable': enabled,
        },
      );
      return true;
    } catch (e) {
      // Revert optimistic update on failure
      await fetchWebhooks(deviceId);
      if (kDebugMode) {
        debugPrint('[WebhookProvider] Failed to toggle webhook: $e');
      }
      return false;
    }
  }

  /// Delete a webhook.
  Future<bool> deleteWebhook(String deviceId, int webhookId) async {
    if (!_webSocketService.isConnected) return false;

    try {
      await _webSocketService.sendRpc(
        deviceId: deviceId,
        method: 'webhook.delete',
        params: {'id': webhookId},
      );

      // Refresh webhooks to get updated list
      await fetchWebhooks(deviceId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[WebhookProvider] Failed to delete webhook: $e');
      }
      return false;
    }
  }

  /// Clear all data for a device.
  void clearDevice(String deviceId) {
    _webhooks.remove(deviceId);
    _isLoading.remove(deviceId);
    _errors.remove(deviceId);
    _revisions.remove(deviceId);
    notifyListeners();
  }

  /// Clear all data.
  void clearAll() {
    _webhooks.clear();
    _isLoading.clear();
    _errors.clear();
    _revisions.clear();
    notifyListeners();
  }
}
