import 'package:flutter/material.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/schedule.dart';

/// A list tile displaying a schedule with enable toggle and actions.
class ScheduleListTile extends StatelessWidget {
  final Schedule schedule;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isLoading;

  const ScheduleListTile({
    super.key,
    required this.schedule,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final action = schedule.action;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: schedule.enabled
              ? (action == true ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHighest,
        ),
        child: Icon(
          action == true ? Icons.power : Icons.power_off,
          size: 20,
          color: schedule.enabled
              ? (action == true ? AppColors.success : AppColors.error)
              : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
      title: Text(
        schedule.timeDisplay,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: schedule.enabled
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
      subtitle: Text(
        _getDaysSummary(l10n),
        style: TextStyle(
          fontSize: 13,
          color: schedule.enabled
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Switch(
              value: schedule.enabled,
              onChanged: onToggle,
              activeTrackColor: AppColors.primary,
            ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n.editSchedule),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, size: 20, color: AppColors.error),
                    const SizedBox(width: 12),
                    Text(
                      l10n.deleteSchedule,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDaysSummary(AppLocalizations l10n) {
    final parsed = schedule.parsed;
    final weekdays = parsed.weekdays;

    if (weekdays.length == 7) {
      return l10n.everyDay;
    }

    // Check for weekdays (Mon-Fri)
    if (weekdays.length == 5 &&
        weekdays.contains(1) &&
        weekdays.contains(2) &&
        weekdays.contains(3) &&
        weekdays.contains(4) &&
        weekdays.contains(5) &&
        !weekdays.contains(0) &&
        !weekdays.contains(6)) {
      return l10n.weekdays;
    }

    // Check for weekends (Sat-Sun)
    if (weekdays.length == 2 &&
        weekdays.contains(0) &&
        weekdays.contains(6)) {
      return l10n.weekends;
    }

    // Day labels in order: Sun, Mon, Tue, Wed, Thu, Fri, Sat
    final dayLabels = [
      l10n.daySun,
      l10n.dayMon,
      l10n.dayTue,
      l10n.dayWed,
      l10n.dayThu,
      l10n.dayFri,
      l10n.daySat,
    ];

    return weekdays.map((d) => dayLabels[d]).join(', ');
  }
}
