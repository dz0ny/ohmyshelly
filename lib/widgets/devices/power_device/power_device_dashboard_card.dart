import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../data/models/action_log.dart';
import '../../../data/models/device.dart';
import '../../../data/models/device_status.dart';

/// Compact dashboard tile for power devices - designed for 2-column grid layout
/// Shows device icon, name, ON/OFF status badge, and power consumption or recent activity
class PowerDeviceDashboardCard extends StatelessWidget {
  final Device device;
  final PowerDeviceStatus? status;
  final VoidCallback? onTap;
  final List<ActionLogEntry> actionLog;

  const PowerDeviceDashboardCard({
    super.key,
    required this.device,
    this.status,
    this.onTap,
    this.actionLog = const [],
  });

  /// Get icon based on device usage/type
  IconData get _deviceIcon => device.displayIcon;

  /// Get color based on device usage/type
  Color get _deviceColor => device.displayColor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isOn = status?.isOn ?? false;
    final isOnline = device.isOnline;
    final hasPower = status != null && isOnline && status!.hasPowerMonitoring;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap ?? () => context.push('/device/${device.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: icon badge + ON/OFF status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon badge
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: _deviceColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _deviceIcon,
                      color: _deviceColor,
                      size: 18,
                    ),
                  ),
                  // ON/OFF status badge
                  _buildStatusBadge(context, isOn, isOnline, l10n),
                ],
              ),
              const SizedBox(height: 12),
              // Room name (small muted)
              if (device.roomName != null && device.roomName!.isNotEmpty)
                Text(
                  device.roomName!,
                  style: TextStyle(
                    fontSize: 10,
                    color: colorScheme.outline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              // Device name (label)
              Text(
                device.name,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Power value or recent activity
              Row(
                children: [
                  Expanded(
                    child: hasPower
                        ? _buildPowerDisplay(context)
                        : _buildRecentActivityDisplay(context, l10n),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colorScheme.outline,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(
    BuildContext context,
    bool isOn,
    bool isOnline,
    AppLocalizations l10n,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!isOnline) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          l10n.offline,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: colorScheme.outline,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOn
            ? AppColors.deviceOn.withValues(alpha: 0.1)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isOn ? AppColors.deviceOn : colorScheme.outline,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isOn ? l10n.on : l10n.off,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isOn ? AppColors.deviceOn : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerDisplay(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOn = status?.isOn ?? false;

    return Row(
      children: [
        Icon(
          AppIcons.power,
          size: 16,
          color: isOn ? _deviceColor : colorScheme.outline,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              status!.powerDisplay,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isOn ? _deviceColor : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivityDisplay(BuildContext context, AppLocalizations l10n) {
    // For push buttons, filter to only show "on" events (activations)
    final entries = device.isPushButton
        ? actionLog.where((e) => e.isOn).toList()
        : actionLog;

    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show up to 2 events in a compact format (3 overflows the card)
    final displayEntries = entries.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < displayEntries.length; i++) ...[
          _buildCompactActivityRow(context, l10n, displayEntries[i], i == 0),
          // Show duration between consecutive on->off pairs
          if (!device.isPushButton &&
              i < displayEntries.length - 1 &&
              !displayEntries[i].isOn &&
              displayEntries[i + 1].isOn)
            _buildCompactDuration(
              context,
              displayEntries[i + 1].timestamp,
              displayEntries[i].timestamp,
            ),
        ],
      ],
    );
  }

  Widget _buildCompactActivityRow(
    BuildContext context,
    AppLocalizations l10n,
    ActionLogEntry entry,
    bool isFirst,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOn = entry.isOn;

    // Compact format: "On · 5m ago" or "Off · 2h ago"
    final action = device.isPushButton ? '' : '${isOn ? l10n.on : l10n.off} · ';
    final relativeTime = entry.getRelativeTime(l10n);

    return Padding(
      padding: EdgeInsets.only(top: isFirst ? 0 : 2),
      child: Row(
        children: [
          // Small status dot
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isOn ? AppColors.deviceOn : colorScheme.outline,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '$action$relativeTime',
              style: TextStyle(
                fontSize: 11,
                color: isFirst ? colorScheme.onSurfaceVariant : colorScheme.outline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDuration(BuildContext context, DateTime start, DateTime end) {
    final colorScheme = Theme.of(context).colorScheme;
    final duration = end.difference(start);

    return Padding(
      padding: const EdgeInsets.only(left: 2, top: 1, bottom: 1),
      child: Row(
        children: [
          // Vertical connector line
          Container(
            width: 2,
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: AppColors.deviceOn.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.timer_outlined,
            size: 10,
            color: colorScheme.outline,
          ),
          const SizedBox(width: 2),
          Text(
            _formatDuration(duration),
            style: TextStyle(
              fontSize: 10,
              color: colorScheme.outline,
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
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}
