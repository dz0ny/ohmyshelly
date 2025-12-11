import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../data/models/device.dart';
import '../../data/models/device_status.dart';
import '../common/status_badge.dart';

class GatewayCard extends StatelessWidget {
  final Device device;
  final GatewayStatus? status;
  final VoidCallback? onTap;
  final int? connectedDevices;

  const GatewayCard({
    super.key,
    required this.device,
    this.status,
    this.onTap,
    this.connectedDevices,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Device icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.gateway.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  AppIcons.gateway,
                  color: AppColors.gateway,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Device info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        StatusBadge(isOnline: device.isOnline),
                        if (status != null) ...[
                          const SizedBox(width: 12),
                          _buildSignalStrength(),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Gateway status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (connectedDevices != null) ...[
                    Text(
                      '$connectedDevices',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gateway,
                      ),
                    ),
                    const Text(
                      'devices',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ] else ...[
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textHint,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignalStrength() {
    if (status?.rssi == null) return const SizedBox.shrink();

    final strength = status!.signalStrength;
    final color = _getSignalColor(strength);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.signal_wifi_4_bar,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          strength,
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getSignalColor(String strength) {
    switch (strength) {
      case 'Excellent':
        return AppColors.success;
      case 'Good':
        return AppColors.success;
      case 'Fair':
        return AppColors.warning;
      case 'Weak':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
