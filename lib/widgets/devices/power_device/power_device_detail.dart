import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../data/models/device.dart';
import '../../../data/models/device_status.dart';
import '../../controls/power_toggle.dart';
import '../../charts/sparkline_widget.dart';

/// Detail view for power devices - shows toggle and stats
class PowerDeviceDetail extends StatelessWidget {
  final Device device;
  final PowerDeviceStatus? status;
  final bool isToggling;
  final ValueChanged<bool>? onToggle;
  final List<double> powerHistory;

  const PowerDeviceDetail({
    super.key,
    required this.device,
    this.status,
    this.isToggling = false,
    this.onToggle,
    this.powerHistory = const [],
  });

  void _navigateToHistory(BuildContext context, String metric) {
    context.push('/statistics/${device.id}?type=power&metric=$metric');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isOn = status?.isOn ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Power toggle
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PowerToggle(
                    isOn: isOn,
                    isLoading: isToggling,
                    size: 80,
                    onChanged: device.isOnline ? onToggle : null,
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOn ? l10n.on : l10n.off,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isOn ? AppColors.deviceOn : AppColors.textSecondary,
                        ),
                      ),
                      if (!device.isOnline)
                        Text(
                          l10n.offline,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textHint,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Stats list (line by line, tappable for history)
          if (status != null) _buildStatsCard(context, l10n),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.power,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            // Power - tappable for history with sparkline
            _buildDetailTile(
              context: context,
              icon: AppIcons.power,
              label: l10n.power,
              value: status!.powerDisplay,
              iconColor: device.displayColor,
              onTap: () => _navigateToHistory(context, 'power'),
              sparklineData: powerHistory,
              sparklineColor: device.displayColor,
            ),
            const SizedBox(height: 16),
            // Voltage
            _buildDetailTile(
              context: context,
              icon: AppIcons.voltage,
              label: l10n.voltage,
              value: status!.voltageDisplay,
            ),
            const SizedBox(height: 16),
            // Current
            _buildDetailTile(
              context: context,
              icon: AppIcons.current,
              label: l10n.current,
              value: status!.currentDisplay,
            ),
            const SizedBox(height: 16),
            // Relay Temperature
            _buildDetailTile(
              context: context,
              icon: AppIcons.temperature,
              label: l10n.temperature,
              value: status!.temperatureDisplay,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
    VoidCallback? onTap,
    List<double>? sparklineData,
    Color? sparklineColor,
  }) {
    final tile = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: iconColor ?? AppColors.textSecondary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textHint,
                ),
            ],
          ),
          // Sparkline chart if data is available
          if (sparklineData != null && sparklineData.length >= 2) ...[
            const SizedBox(height: 12),
            SparklineWidget(
              data: sparklineData,
              lineColor: sparklineColor ?? iconColor ?? device.displayColor,
              height: 32,
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: tile,
      );
    }
    return tile;
  }
}
