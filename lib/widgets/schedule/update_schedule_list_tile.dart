import 'package:flutter/material.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/schedule.dart';

/// A list tile displaying a firmware update schedule.
///
/// System-managed schedules that auto-update the device firmware.
/// Only allows toggle, no edit/delete.
class UpdateScheduleListTile extends StatelessWidget {
  final Schedule schedule;
  final ValueChanged<bool> onToggle;
  final bool isLoading;

  const UpdateScheduleListTile({
    super.key,
    required this.schedule,
    required this.onToggle,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: schedule.enabled
              ? AppColors.info.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHighest,
        ),
        child: Icon(
          Icons.system_update,
          size: 20,
          color: schedule.enabled
              ? AppColors.info
              : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
      title: Text(
        l10n.autoUpdateSchedule,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: schedule.enabled
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
      subtitle: Text(
        '${schedule.timeDisplay} · ${_getDaysSummary(l10n)}',
        style: TextStyle(
          fontSize: 13,
          color: schedule.enabled
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
      trailing: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Switch(
              value: schedule.enabled,
              onChanged: onToggle,
              activeTrackColor: AppColors.primary,
            ),
    );
  }

  String _getDaysSummary(AppLocalizations l10n) {
    final parsed = schedule.parsed;
    final weekdays = parsed.weekdays;

    if (weekdays.length == 7) {
      return l10n.everyDay;
    }

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

    if (weekdays.length == 2 &&
        weekdays.contains(0) &&
        weekdays.contains(6)) {
      return l10n.weekends;
    }

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
