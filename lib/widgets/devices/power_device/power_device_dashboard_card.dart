import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../data/models/device.dart';
import '../../../data/models/device_status.dart';

/// Compact dashboard tile for power devices - designed for 2-column grid layout
/// Shows device icon, name, ON/OFF status badge, and power consumption
class PowerDeviceDashboardCard extends StatelessWidget {
  final Device device;
  final PowerDeviceStatus? status;
  final VoidCallback? onTap;

  const PowerDeviceDashboardCard({
    super.key,
    required this.device,
    this.status,
    this.onTap,
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
              // Power value (only if power monitoring available)
              Row(
                children: [
                  Expanded(
                    child: hasPower
                        ? _buildPowerDisplay(context)
                        : const SizedBox.shrink(), // Status already shown in badge
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
}
