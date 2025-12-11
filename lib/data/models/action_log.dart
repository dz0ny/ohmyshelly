import 'package:flutter/material.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';

/// Source of a device action.
enum ActionSource {
  button,
  schedule,
  shc, // Shelly Cloud (app)
  websocket,
  http,
  loopback,
  wifiRecovery,
  init,
  unknown,
}

extension ActionSourceExtension on ActionSource {
  /// Parse source string from device status.
  static ActionSource fromString(String? source) {
    if (source == null) return ActionSource.unknown;

    switch (source.toLowerCase()) {
      case 'button':
        return ActionSource.button;
      case 'schedule':
        return ActionSource.schedule;
      case 'shc':
        return ActionSource.shc;
      case 'ws':
      case 'websocket':
        return ActionSource.websocket;
      case 'http':
        return ActionSource.http;
      case 'loopback':
        return ActionSource.loopback;
      case 'wifi_recovery':
      case 'wifirecovery':
        return ActionSource.wifiRecovery;
      case 'init':
        return ActionSource.init;
      default:
        return ActionSource.unknown;
    }
  }

  /// Human-readable display name.
  String displayName(AppLocalizations l10n) {
    switch (this) {
      case ActionSource.button:
        return l10n.sourceButton;
      case ActionSource.schedule:
        return l10n.sourceSchedule;
      case ActionSource.shc:
      case ActionSource.websocket:
      case ActionSource.http:
        return l10n.sourceApp;
      case ActionSource.loopback:
      case ActionSource.wifiRecovery:
      case ActionSource.init:
        return l10n.sourceSystem;
      case ActionSource.unknown:
        return l10n.sourceUnknown;
    }
  }

  /// Icon for this source.
  IconData get icon {
    switch (this) {
      case ActionSource.button:
        return Icons.touch_app;
      case ActionSource.schedule:
        return Icons.schedule;
      case ActionSource.shc:
      case ActionSource.websocket:
      case ActionSource.http:
        return Icons.phone_android;
      case ActionSource.loopback:
      case ActionSource.wifiRecovery:
      case ActionSource.init:
        return Icons.settings;
      case ActionSource.unknown:
        return Icons.help_outline;
    }
  }
}

/// Represents a device action log entry.
class ActionLogEntry {
  final DateTime timestamp;
  final bool isOn;
  final ActionSource source;

  const ActionLogEntry({
    required this.timestamp,
    required this.isOn,
    required this.source,
  });

  /// Create from status change event.
  factory ActionLogEntry.fromStatusChange({
    required bool isOn,
    required String? source,
    DateTime? timestamp,
  }) {
    return ActionLogEntry(
      timestamp: timestamp ?? DateTime.now(),
      isOn: isOn,
      source: ActionSourceExtension.fromString(source),
    );
  }

  /// Get relative time string (e.g., "2 minutes ago").
  String getRelativeTime(AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inSeconds < 60) {
      return l10n.justNow;
    } else if (diff.inMinutes < 60) {
      return l10n.minutesAgo(diff.inMinutes);
    } else if (diff.inHours < 24) {
      return l10n.hoursAgo(diff.inHours);
    } else if (diff.inDays == 1) {
      return l10n.yesterday;
    } else {
      return l10n.daysAgo(diff.inDays);
    }
  }

  /// Formatted time (e.g., "18:30").
  String get timeDisplay {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
