import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/utils/formatters.dart';
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

          // Stats list (line by line, tappable for history)
          if (status != null) _buildStatsCard(context, l10n),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasPowerMonitoring = status!.hasPowerMonitoring;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hasPowerMonitoring ? l10n.power : l10n.status,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            // Power metrics - only show if power monitoring is available
            if (hasPowerMonitoring) ...[
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
            ],
            // Relay Temperature - always show if available
            _buildDetailTile(
              context: context,
              icon: AppIcons.temperature,
              label: l10n.temperature,
              value: status!.temperatureDisplay,
            ),
            // Last updated
            if (status!.lastUpdated != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${l10n.lastUpdated}: ${Formatters.timeAgo(status!.lastUpdated!, l10n)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
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
    final colorScheme = Theme.of(context).colorScheme;
    final tile = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: iconColor ?? colorScheme.onSurfaceVariant),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.outline,
                ),
            ],
          ),
          // Sparkline chart if data is available
          if (sparklineData != null && sparklineData.length >= 2) ...[
            const SizedBox(height: 12),
            SparklineWidget(
              data: sparklineData,
              lineColor: sparklineColor ?? iconColor ?? device.displayColor,
              height: 40,
              showDots: true,
              showHourLabels: true,
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
