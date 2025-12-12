import 'package:flutter/material.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/action_log.dart';

/// A widget displaying a list of action log entries grouped by day.
class ActionLogList extends StatelessWidget {
  final List<ActionLogEntry> entries;
  final int maxEntries;

  const ActionLogList({
    super.key,
    required this.entries,
    this.maxEntries = 20,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final displayEntries = entries.take(maxEntries).toList();

    if (displayEntries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 40,
                color: colorScheme.outline,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.noActivity,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Group entries by day
    final groupedEntries = _groupByDay(displayEntries);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedEntries.entries.map((group) {
        final dayLabel = _getDayLabel(group.key, l10n);
        final isOlderDay = group.key != today && group.key != yesterday;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DayHeader(label: dayLabel),
            ...group.value.map(
              (entry) => _ActionLogTile(entry: entry, showDate: isOlderDay),
            ),
          ],
        );
      }).toList(),
    );
  }

  /// Group entries by day (date only, ignoring time).
  Map<DateTime, List<ActionLogEntry>> _groupByDay(
      List<ActionLogEntry> entries) {
    final Map<DateTime, List<ActionLogEntry>> grouped = {};

    for (final entry in entries) {
      final dateKey = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );

      grouped.putIfAbsent(dateKey, () => []).add(entry);
    }

    // Sort by date descending (most recent first)
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Map.fromEntries(
      sortedKeys.map((key) => MapEntry(key, grouped[key]!)),
    );
  }

  /// Get a human-readable label for the day.
  String _getDayLabel(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return l10n.today;
    } else if (date == yesterday) {
      return l10n.yesterday;
    } else {
      // Format as "Mon, Dec 12"
      final weekday = _getWeekdayName(date.weekday, l10n);
      final month = _getMonthName(date.month, l10n);
      return '$weekday, $month ${date.day}';
    }
  }

  String _getWeekdayName(int weekday, AppLocalizations l10n) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday - 1];
  }

  String _getMonthName(int month, AppLocalizations l10n) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}

class _DayHeader extends StatelessWidget {
  final String label;

  const _DayHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ActionLogTile extends StatelessWidget {
  final ActionLogEntry entry;
  final bool showDate;

  const _ActionLogTile({required this.entry, this.showDate = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (entry.isOn ? AppColors.success : AppColors.error)
              .withValues(alpha: 0.15),
        ),
        child: Icon(
          entry.isOn ? Icons.power : Icons.power_off,
          size: 18,
          color: entry.isOn ? AppColors.success : AppColors.error,
        ),
      ),
      title: Text(
        entry.isOn ? l10n.on : l10n.off,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Row(
        children: [
          Icon(
            entry.source.icon,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            entry.source.displayName(l10n),
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      trailing: Text(
        showDate ? _formatDateTime(entry.timestamp) : entry.timeDisplay,
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.outline,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }
}
