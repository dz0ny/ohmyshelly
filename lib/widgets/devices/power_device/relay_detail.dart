import 'package:flutter/material.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/action_log.dart';
import '../../../data/models/device.dart';
import '../../../data/models/device_status.dart';
import '../../controls/power_toggle.dart';

/// Detail view for simple relay devices without power monitoring
class RelayDetail extends StatelessWidget {
  final Device device;
  final PowerDeviceStatus? status;
  final bool isToggling;
  final ValueChanged<bool>? onToggle;
  final List<ActionLogEntry> actionLog;

  const RelayDetail({
    super.key,
    required this.device,
    this.status,
    this.isToggling = false,
    this.onToggle,
    this.actionLog = const [],
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isOn = status?.isOn ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Power toggle - entire card is tappable
          Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: device.isOnline && !isToggling && onToggle != null
                  ? () => onToggle!(!isOn)
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (device.isPushButton)
                      PushButton(
                        isOn: isOn,
                        isLoading: isToggling,
                        size: 100,
                        onPressed: null, // Handled by card tap
                      )
                    else
                      PowerToggle(
                        isOn: isOn,
                        isLoading: isToggling,
                        size: 100,
                        onChanged: null, // Handled by card tap
                      ),
                    const SizedBox(width: 28),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOn ? l10n.on : l10n.off,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isOn ? AppColors.deviceOn : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (!device.isOnline)
                          Text(
                            l10n.offline,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.outline,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Show action log for all relay devices without power monitoring
          _buildActionLogCard(context, l10n),
        ],
      ),
    );
  }

  Widget _buildActionLogCard(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;

    // For push buttons, filter to only show "on" events (activations)
    // since each press creates an on+off pair
    // For switches, show all on/off events
    final entries = device.isPushButton
        ? actionLog.where((e) => e.isOn).toList()
        : actionLog;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.recentActivity,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        device.isPushButton
                            ? Icons.touch_app_outlined
                            : Icons.power_settings_new_outlined,
                        size: 40,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.noRecentActivity,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < entries.take(10).length; i++) ...[
                      _buildActivityEntry(context, l10n, entries[i]),
                      // Show duration between off->on pairs (for switches only)
                      if (!device.isPushButton &&
                          i < entries.take(10).length - 1 &&
                          !entries[i].isOn &&
                          entries[i + 1].isOn)
                        _buildDurationIndicator(
                          context,
                          entries[i + 1].timestamp,
                          entries[i].timestamp,
                        )
                      else if (i < entries.take(10).length - 1)
                        Divider(
                          height: 1,
                          indent: 44,
                          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationIndicator(BuildContext context, DateTime start, DateTime end) {
    final colorScheme = Theme.of(context).colorScheme;
    final duration = end.difference(start);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        children: [
          // Vertical line connector
          SizedBox(
            width: 32,
            child: Center(
              child: Container(
                width: 2,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.deviceOn.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Duration chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.deviceOn.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.deviceOn.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 14,
                  color: AppColors.deviceOn.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDuration(duration),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      final days = duration.inDays;
      final hours = duration.inHours % 24;
      if (hours > 0) {
        return '${days}d ${hours}h';
      }
      return '${days}d';
    } else if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (minutes > 0) {
        return '${hours}h ${minutes}m';
      }
      return '${hours}h';
    } else if (duration.inMinutes > 0) {
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      if (seconds > 0 && minutes < 10) {
        return '${minutes}m ${seconds}s';
      }
      return '${minutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  Widget _buildActivityEntry(BuildContext context, AppLocalizations l10n, ActionLogEntry entry) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOn = entry.isOn;

    // For push buttons, show touch icon
    // For switches, show device icon (garage door, light, etc.)
    final icon = device.isPushButton
        ? Icons.touch_app_rounded
        : device.displayIcon;
    final iconColor = isOn ? AppColors.deviceOn : colorScheme.outline;
    final bgColor = isOn
        ? AppColors.deviceOn.withValues(alpha: 0.15)
        : colorScheme.outline.withValues(alpha: 0.15);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Activity icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),
          // Time info and status for switches
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatActivityTime(entry, l10n),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (!device.isPushButton)
                  Text(
                    isOn ? l10n.turnedOn : l10n.turnedOff,
                    style: TextStyle(
                      fontSize: 13,
                      color: isOn ? AppColors.deviceOn : colorScheme.outline,
                    ),
                  ),
              ],
            ),
          ),
          // Relative time
          Text(
            entry.getRelativeTime(l10n),
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  String _formatActivityTime(ActionLogEntry entry, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);

    final time = entry.timeDisplay;

    if (entryDate == today) {
      return '${l10n.today}, $time';
    } else if (entryDate == today.subtract(const Duration(days: 1))) {
      return '${l10n.yesterday}, $time';
    } else {
      // Format as "Dec 12, 14:30"
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[entry.timestamp.month - 1]} ${entry.timestamp.day}, $time';
    }
  }
}
