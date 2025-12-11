import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../data/models/device.dart';
import '../../../data/models/device_status.dart';

/// Dashboard card for power devices - shows current power and switch status (read-only)
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
    final isOn = status?.isOn ?? false;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () => context.push('/device/${device.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _deviceColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _deviceIcon,
                      color: _deviceColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      device.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Switch status indicator
                  _buildSwitchStatus(isOn, l10n),
                ],
              ),
              // Power usage
              if (status != null && device.isOnline) ...[
                const SizedBox(height: 16),
                _buildPowerDisplay(l10n),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchStatus(bool isOn, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOn
            ? AppColors.deviceOn.withValues(alpha: 0.1)
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOn ? AppColors.deviceOn : AppColors.textHint,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOn ? l10n.on : l10n.off,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isOn ? AppColors.deviceOn : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerDisplay(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.power,
            size: 20,
            color: _deviceColor,
          ),
          const SizedBox(width: 8),
          Text(
            l10n.currentPowerUsage,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            status!.powerDisplay,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _deviceColor,
            ),
          ),
        ],
      ),
    );
  }
}
