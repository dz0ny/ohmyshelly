/// Represents a scheduled action on a Shelly device.
///
/// Schedules are stored on the device and execute RPC calls at specified times.
class Schedule {
  final int id;
  final bool enabled;
  final String timespec;
  final List<ScheduleCall> calls;

  const Schedule({
    required this.id,
    required this.enabled,
    required this.timespec,
    required this.calls,
  });

  /// Parse from Shelly schedule.list response.
  factory Schedule.fromJson(Map<String, dynamic> json) {
    final callsList = json['calls'] as List<dynamic>? ?? [];
    return Schedule(
      id: json['id'] as int,
      enabled: json['enable'] as bool? ?? false,
      timespec: json['timespec'] as String? ?? '',
      calls: callsList
          .map((c) => ScheduleCall.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convert to API format for create/update.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enable': enabled,
      'timespec': timespec,
      'calls': calls.map((c) => c.toJson()).toList(),
    };
  }

  /// Get the action (on/off) from the first switch.set call.
  /// Returns true for on, false for off, null if unknown.
  bool? get action {
    for (final call in calls) {
      if (call.method == 'switch.set') {
        return call.params['on'] as bool?;
      }
    }
    return null;
  }

  /// Get the parsed time and days from timespec.
  ({int hour, int minute, List<int> weekdays}) get parsed =>
      TimespecHelper.parse(timespec);

  /// Human-readable time display (e.g., "18:00").
  String get timeDisplay {
    final p = parsed;
    return '${p.hour.toString().padLeft(2, '0')}:${p.minute.toString().padLeft(2, '0')}';
  }

  /// List of day abbreviations this schedule runs on.
  List<String> get daysDisplay {
    final p = parsed;
    return p.weekdays.map((d) => TimespecHelper.dayNames[d]).toList();
  }

  /// Human-readable days summary.
  String get daysSummary {
    final p = parsed;
    if (p.weekdays.length == 7) return 'Every day';
    if (p.weekdays.length == 5 &&
        p.weekdays.contains(1) &&
        p.weekdays.contains(2) &&
        p.weekdays.contains(3) &&
        p.weekdays.contains(4) &&
        p.weekdays.contains(5) &&
        !p.weekdays.contains(0) &&
        !p.weekdays.contains(6)) {
      return 'Weekdays';
    }
    if (p.weekdays.length == 2 &&
        p.weekdays.contains(0) &&
        p.weekdays.contains(6)) {
      return 'Weekends';
    }
    return daysDisplay.join(', ');
  }

  /// Check if schedule runs on specific weekday (0=Sun, 1=Mon, etc.).
  bool runsOnDay(int weekday) => parsed.weekdays.contains(weekday);

  Schedule copyWith({
    int? id,
    bool? enabled,
    String? timespec,
    List<ScheduleCall>? calls,
  }) {
    return Schedule(
      id: id ?? this.id,
      enabled: enabled ?? this.enabled,
      timespec: timespec ?? this.timespec,
      calls: calls ?? this.calls,
    );
  }
}

/// A single RPC call within a schedule.
class ScheduleCall {
  final String method;
  final Map<String, dynamic> params;

  const ScheduleCall({
    required this.method,
    required this.params,
  });

  factory ScheduleCall.fromJson(Map<String, dynamic> json) {
    return ScheduleCall(
      method: json['method'] as String? ?? '',
      params: Map<String, dynamic>.from(json['params'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'params': params,
    };
  }

  /// Create a switch.set call for turning device on/off.
  static ScheduleCall switchSet({required bool on, int switchId = 0}) {
    return ScheduleCall(
      method: 'switch.set',
      params: {'on': on, 'id': switchId},
    );
  }
}

/// Helper class to parse and build timespec strings.
///
/// Timespec format: `seconds minutes hours day_of_month month day_of_week`
/// Example: `"0 0 18 * * 0,1,2,3,4,5,6"` = At 18:00:00 every day
class TimespecHelper {
  /// Day names indexed by weekday (0=Sun, 1=Mon, etc.).
  static const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  /// Short day names for UI.
  static const shortDayNames = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  /// All weekdays (0-6) for "every day" selection.
  static List<int> get allDays => [0, 1, 2, 3, 4, 5, 6];

  /// Parse timespec to structured data.
  ///
  /// Returns hour, minute, and list of weekdays (0=Sun, 1=Mon, etc.).
  static ({int hour, int minute, List<int> weekdays}) parse(String timespec) {
    final parts = timespec.split(' ');
    if (parts.length < 6) {
      return (hour: 0, minute: 0, weekdays: <int>[]);
    }

    // Parts: seconds, minutes, hours, day_of_month, month, day_of_week
    final minute = int.tryParse(parts[1]) ?? 0;
    final hour = int.tryParse(parts[2]) ?? 0;
    final dowPart = parts[5];

    // Parse day of week - can be numbers (0,1,2) or names (SUN,MON,TUE)
    final weekdays = _parseDaysOfWeek(dowPart);

    return (hour: hour, minute: minute, weekdays: weekdays);
  }

  /// Build timespec from hour, minute, and weekdays.
  ///
  /// [weekdays] should be 0=Sunday, 1=Monday, ..., 6=Saturday
  static String build(int hour, int minute, List<int> weekdays) {
    final sortedDays = List<int>.from(weekdays)..sort();
    final dowString = sortedDays.join(',');
    return '0 $minute $hour * * $dowString';
  }

  /// Parse day of week string to list of integers.
  static List<int> _parseDaysOfWeek(String dowPart) {
    if (dowPart == '*') return allDays;

    final weekdays = <int>[];
    final parts = dowPart.split(',');

    for (final part in parts) {
      final trimmed = part.trim().toUpperCase();

      // Try numeric
      final num = int.tryParse(trimmed);
      if (num != null && num >= 0 && num <= 6) {
        weekdays.add(num);
        continue;
      }

      // Try name
      final index = _dayNameToIndex(trimmed);
      if (index != null) {
        weekdays.add(index);
      }
    }

    return weekdays..sort();
  }

  /// Convert day name to index (0=Sun, 1=Mon, etc.).
  static int? _dayNameToIndex(String name) {
    const names = {
      'SUN': 0,
      'MON': 1,
      'TUE': 2,
      'WED': 3,
      'THU': 4,
      'FRI': 5,
      'SAT': 6,
    };
    return names[name];
  }
}
