import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../data/models/schedule.dart';
import '../data/models/action_log.dart';
import '../data/services/api_service.dart';
import '../data/services/websocket_service.dart';

/// Provider for managing device schedules and action logs.
class ScheduleProvider extends ChangeNotifier {
  final WebSocketService _webSocketService;
  final ApiService _apiService;

  // API credentials (set from AuthProvider)
  String? _apiUrl;
  String? _token;

  // State: schedules per device
  final Map<String, List<Schedule>> _schedules = {};
  final Map<String, bool> _isLoading = {};
  final Map<String, String?> _errors = {};

  // State: action logs per device (limited to last 20 entries)
  final Map<String, List<ActionLogEntry>> _actionLogs = {};
  static const int _maxActionLogEntries = 20;

  // Subscription to action log events from DeviceProvider
  StreamSubscription<({String deviceId, ActionLogEntry entry})>? _actionLogSubscription;

  ScheduleProvider({
    required WebSocketService webSocketService,
    required ApiService apiService,
  })  : _webSocketService = webSocketService,
        _apiService = apiService;

  /// Subscribe to action log events from DeviceProvider.
  /// Call this after both providers are created.
  void subscribeToActionLogEvents(
    Stream<({String deviceId, ActionLogEntry entry})> eventStream,
  ) {
    _actionLogSubscription?.cancel();
    _actionLogSubscription = eventStream.listen((event) {
      addActionLogEntry(event.deviceId, event.entry);
    });
  }

  /// Set API credentials for event log fetching.
  void setCredentials(String? apiUrl, String? token) {
    _apiUrl = apiUrl;
    _token = token;
  }

  // --- Getters ---

  /// Get schedules for a device.
  List<Schedule> getSchedules(String deviceId) => _schedules[deviceId] ?? [];

  /// Get action log for a device.
  List<ActionLogEntry> getActionLog(String deviceId) =>
      _actionLogs[deviceId] ?? [];

  /// Check if schedules are loading for a device.
  bool isLoading(String deviceId) => _isLoading[deviceId] ?? false;

  /// Get error for a device.
  String? getError(String deviceId) => _errors[deviceId];

  /// Check if WebSocket is connected.
  bool get isConnected => _webSocketService.isConnected;

  // --- Schedule Operations ---

  /// Fetch schedules for a device via WebSocket RPC.
  Future<void> fetchSchedules(String deviceId) async {
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
        method: 'schedule.list',
        params: {},
      );

      final result = response['result'] as Map<String, dynamic>?;
      final jobs = result?['jobs'] as List<dynamic>? ?? [];

      _schedules[deviceId] = jobs
          .map((j) => Schedule.fromJson(j as Map<String, dynamic>))
          .toList();

      if (kDebugMode) {
        debugPrint(
            '[ScheduleProvider] Loaded ${_schedules[deviceId]!.length} schedules for $deviceId');
      }
    } on WebSocketException catch (e) {
      _errors[deviceId] = e.message;
      if (kDebugMode) {
        debugPrint('[ScheduleProvider] Failed to fetch schedules: $e');
      }
    } catch (e) {
      _errors[deviceId] = 'Failed to load schedules';
      if (kDebugMode) {
        debugPrint('[ScheduleProvider] Failed to fetch schedules: $e');
      }
    } finally {
      _isLoading[deviceId] = false;
      notifyListeners();
    }
  }

  /// Create a new schedule for a device.
  Future<bool> createSchedule(
    String deviceId, {
    required int hour,
    required int minute,
    required List<int> days,
    required bool turnOn,
  }) async {
    if (!_webSocketService.isConnected) return false;

    try {
      final timespec = TimespecHelper.build(hour, minute, days);
      final call = ScheduleCall.switchSet(on: turnOn);

      final response = await _webSocketService.sendRpc(
        deviceId: deviceId,
        method: 'schedule.create',
        params: {
          'enable': true,
          'timespec': timespec,
          'calls': [call.toJson()],
        },
      );

      final result = response['result'] as Map<String, dynamic>?;
      if (result != null && result['id'] != null) {
        // Refresh schedules to get updated list
        await fetchSchedules(deviceId);
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ScheduleProvider] Failed to create schedule: $e');
      }
      return false;
    }
  }

  /// Update an existing schedule.
  Future<bool> updateSchedule(
    String deviceId,
    Schedule schedule, {
    int? hour,
    int? minute,
    List<int>? days,
    bool? turnOn,
    bool? enabled,
  }) async {
    if (!_webSocketService.isConnected) return false;

    try {
      final params = <String, dynamic>{'id': schedule.id};

      // Only include changed fields
      if (enabled != null) {
        params['enable'] = enabled;
      }

      if (hour != null || minute != null || days != null) {
        final parsed = schedule.parsed;
        final newTimespec = TimespecHelper.build(
          hour ?? parsed.hour,
          minute ?? parsed.minute,
          days ?? parsed.weekdays,
        );
        params['timespec'] = newTimespec;
      }

      if (turnOn != null) {
        final call = ScheduleCall.switchSet(on: turnOn);
        params['calls'] = [call.toJson()];
      }

      await _webSocketService.sendRpc(
        deviceId: deviceId,
        method: 'schedule.update',
        params: params,
      );

      // Refresh schedules to get updated list
      await fetchSchedules(deviceId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ScheduleProvider] Failed to update schedule: $e');
      }
      return false;
    }
  }

  /// Toggle schedule enabled state.
  Future<bool> toggleSchedule(
    String deviceId,
    int scheduleId,
    bool enabled,
  ) async {
    if (!_webSocketService.isConnected) return false;

    // Optimistic update
    final schedules = _schedules[deviceId];
    if (schedules != null) {
      final index = schedules.indexWhere((s) => s.id == scheduleId);
      if (index != -1) {
        _schedules[deviceId] = List.from(schedules)
          ..[index] = schedules[index].copyWith(enabled: enabled);
        notifyListeners();
      }
    }

    try {
      await _webSocketService.sendRpc(
        deviceId: deviceId,
        method: 'schedule.update',
        params: {
          'id': scheduleId,
          'enable': enabled,
        },
      );
      return true;
    } catch (e) {
      // Revert optimistic update on failure
      await fetchSchedules(deviceId);
      if (kDebugMode) {
        debugPrint('[ScheduleProvider] Failed to toggle schedule: $e');
      }
      return false;
    }
  }

  /// Delete a schedule.
  Future<bool> deleteSchedule(String deviceId, int scheduleId) async {
    if (!_webSocketService.isConnected) return false;

    try {
      await _webSocketService.sendRpc(
        deviceId: deviceId,
        method: 'schedule.delete',
        params: {'id': scheduleId},
      );

      // Refresh schedules to get updated list
      await fetchSchedules(deviceId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ScheduleProvider] Failed to delete schedule: $e');
      }
      return false;
    }
  }

  // --- Action Log Operations ---

  /// Fetch historical event log from API.
  ///
  /// This loads recent on/off events from the Shelly Cloud API.
  Future<void> fetchEventLog(String deviceId, {int limit = 10}) async {
    if (_apiUrl == null || _token == null) {
      if (kDebugMode) {
        debugPrint('[ScheduleProvider] Cannot fetch event log: no credentials');
      }
      return;
    }

    try {
      final response = await _apiService.postJson(
        '$_apiUrl/statistics/event-log',
        {
          'tags': [deviceId],
          'limit': limit,
        },
        token: _token,
      );

      final result = response['result'] as Map<String, dynamic>?;
      if (result == null) return;

      final events = result[deviceId] as List<dynamic>?;
      if (events == null || events.isEmpty) return;

      final entries = <ActionLogEntry>[];
      for (final event in events) {
        final entry = _parseEventLogEntry(event as Map<String, dynamic>);
        if (entry != null) {
          entries.add(entry);
        }
      }

      if (entries.isNotEmpty) {
        // Merge with existing entries, avoiding duplicates
        final existing = _actionLogs[deviceId] ?? [];
        final merged = _mergeActionLogs(entries, existing);
        _actionLogs[deviceId] = merged.take(_maxActionLogEntries).toList();
        notifyListeners();

        if (kDebugMode) {
          debugPrint(
              '[ScheduleProvider] Loaded ${entries.length} event log entries for $deviceId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ScheduleProvider] Failed to fetch event log: $e');
      }
    }
  }

  /// Parse a single event log entry from the API response.
  ActionLogEntry? _parseEventLogEntry(Map<String, dynamic> event) {
    try {
      // Event type 1 = switch state change
      final eventType = event['e'] as int?;
      if (eventType != 1) return null;

      final timestamp = event['t'] as int?;
      if (timestamp == null) return null;

      // Parse the params JSON string: ["deviceId", switchId, isOn]
      final paramsStr = event['p'] as String?;
      if (paramsStr == null) return null;

      final params = jsonDecode(paramsStr) as List<dynamic>;
      if (params.length < 3) return null;

      final isOn = params[2] as bool;

      return ActionLogEntry(
        timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
        isOn: isOn,
        source: ActionSource.unknown, // API doesn't provide source
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ScheduleProvider] Failed to parse event log entry: $e');
      }
      return null;
    }
  }

  /// Merge two action log lists, removing duplicates by timestamp.
  List<ActionLogEntry> _mergeActionLogs(
    List<ActionLogEntry> newEntries,
    List<ActionLogEntry> existing,
  ) {
    final merged = <ActionLogEntry>[];
    final seenTimestamps = <int>{};

    // Add new entries first (they're from API, more authoritative)
    for (final entry in newEntries) {
      final ts = entry.timestamp.millisecondsSinceEpoch;
      if (!seenTimestamps.contains(ts)) {
        seenTimestamps.add(ts);
        merged.add(entry);
      }
    }

    // Add existing entries that don't overlap
    for (final entry in existing) {
      final ts = entry.timestamp.millisecondsSinceEpoch;
      // Allow some tolerance for timestamp matching (within 2 seconds)
      final isDuplicate = seenTimestamps.any(
        (seen) => (seen - ts).abs() < 2000,
      );
      if (!isDuplicate) {
        seenTimestamps.add(ts);
        merged.add(entry);
      }
    }

    // Sort by timestamp descending (newest first)
    merged.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return merged;
  }

  /// Add an action log entry for a device.
  void addActionLogEntry(String deviceId, ActionLogEntry entry) {
    final log = _actionLogs[deviceId] ?? [];

    // Check if this is a duplicate (same timestamp and action)
    if (log.isNotEmpty) {
      final lastEntry = log.first;
      if (lastEntry.isOn == entry.isOn &&
          lastEntry.timestamp.difference(entry.timestamp).inSeconds.abs() < 2) {
        return; // Skip duplicate
      }
    }

    // Add at the beginning (newest first)
    _actionLogs[deviceId] = [entry, ...log].take(_maxActionLogEntries).toList();
    notifyListeners();
  }

  /// Record an action from status change.
  void recordAction({
    required String deviceId,
    required bool isOn,
    required String? source,
    DateTime? timestamp,
  }) {
    final entry = ActionLogEntry.fromStatusChange(
      isOn: isOn,
      source: source,
      timestamp: timestamp,
    );
    addActionLogEntry(deviceId, entry);
  }

  /// Clear action log for a device.
  void clearActionLog(String deviceId) {
    _actionLogs[deviceId] = [];
    notifyListeners();
  }

  /// Clear all data for a device.
  void clearDevice(String deviceId) {
    _schedules.remove(deviceId);
    _actionLogs.remove(deviceId);
    _isLoading.remove(deviceId);
    _errors.remove(deviceId);
    notifyListeners();
  }

  /// Clear all data.
  void clearAll() {
    _schedules.clear();
    _actionLogs.clear();
    _isLoading.clear();
    _errors.clear();
    notifyListeners();
  }
}
