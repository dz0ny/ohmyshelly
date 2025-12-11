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
                              _buildBatteryIndicator(),
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
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
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
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              status!.humidityDisplay,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textHint,
                    ),
                ],
              ),
            ),
            // Footer with signal and last updated time
            DeviceCardFooter(
              rssi: status?.rssi,
              lastUpdated: status?.lastUpdated,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryIndicator() {
    if (status == null) return const SizedBox.shrink();

    final batteryPercent = status!.batteryPercent;
    final isLow = batteryPercent < 20;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isLow ? AppIcons.batteryLow : AppIcons.battery,
          size: 14,
          color: isLow ? AppColors.warning : AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          status!.batteryDisplay,
          style: TextStyle(
            fontSize: 12,
            color: isLow ? AppColors.warning : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
