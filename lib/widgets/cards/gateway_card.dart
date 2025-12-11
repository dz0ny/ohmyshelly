import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../data/models/device.dart';
import '../../data/models/device_status.dart';
import '../../l10n/app_localizations.dart';
import '../common/device_card_footer.dart';
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
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
                              _buildSignalStrength(context),
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
            // Footer with connection details
            DeviceCardFooter(
              ipAddress: status?.ipAddress,
              ssid: status?.ssid,
              uptime: status?.uptimeDisplay,
              lastUpdated: status?.lastUpdated,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalStrength(BuildContext context) {
    if (status?.rssi == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final strength = status!.signalStrengthLocalized(l10n);
    final color = _getSignalColor(status!.rssi);

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

  Color _getSignalColor(int? rssi) {
    if (rssi == null) return AppColors.textSecondary;
    if (rssi > -50) return AppColors.success;  // Excellent
    if (rssi > -60) return AppColors.success;  // Good
    if (rssi > -70) return AppColors.warning;  // Fair
    return AppColors.error;                     // Weak
  }
}
