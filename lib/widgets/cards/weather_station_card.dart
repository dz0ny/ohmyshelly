import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../data/models/device.dart';
import '../../data/models/device_status.dart';
import '../common/device_card_footer.dart';
import '../common/status_badge.dart';

class WeatherStationCard extends StatelessWidget {
  final Device device;
  final WeatherStationStatus? status;
  final VoidCallback? onTap;

  const WeatherStationCard({
    super.key,
    required this.device,
    this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
                      color: AppColors.weatherStation.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      AppIcons.weatherStation,
                      color: AppColors.weatherStation,
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
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
                              _buildBatteryIndicator(context),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Weather summary
                  if (status != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              AppIcons.temperature,
                              size: 18,
                              color: AppColors.weatherStation,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              status!.temperatureDisplay,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              AppIcons.humidity,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              status!.humidityDisplay,
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    Icon(
                      Icons.chevron_right,
                      color: colorScheme.outline,
                    ),
                ],
              ),
            ),
            // Footer with signal and last updated time
            DeviceCardFooter(
              rssi: status?.rssi,
              lastUpdated: status?.lastUpdated,
              firmwareVersion: status?.firmwareVersion,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryIndicator(BuildContext context) {
    if (status == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final batteryPercent = status!.batteryPercent;
    final isLow = batteryPercent < 20;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isLow ? AppIcons.batteryLow : AppIcons.battery,
          size: 14,
          color: isLow ? AppColors.warning : colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          status!.batteryDisplay,
          style: TextStyle(
            fontSize: 12,
            color: isLow ? AppColors.warning : colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
