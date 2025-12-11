import 'package:flutter/material.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/action_log.dart';

/// A widget displaying a list of action log entries.
class ActionLogList extends StatelessWidget {
  final List<ActionLogEntry> entries;
  final int maxEntries;

  const ActionLogList({
    super.key,
    required this.entries,
    this.maxEntries = 10,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                color: AppColors.textHint,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.noActivity,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: displayEntries.map((entry) {
        return _ActionLogTile(entry: entry);
      }).toList(),
    );
  }
}

class _ActionLogTile extends StatelessWidget {
  final ActionLogEntry entry;

  const _ActionLogTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Format date/time for subtitle when source is unknown
    final hasKnownSource = entry.source != ActionSource.unknown;
    final dateTimeStr = _formatDateTime(entry.timestamp);

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
            hasKnownSource ? entry.source.icon : Icons.access_time,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            hasKnownSource ? entry.source.displayName(l10n) : dateTimeStr,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      trailing: Text(
        entry.getRelativeTime(l10n),
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textHint,
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
