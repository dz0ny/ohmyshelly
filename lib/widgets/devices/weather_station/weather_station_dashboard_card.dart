import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../data/models/device.dart';
import '../../../data/models/device_status.dart';
import '../../charts/sparkline_widget.dart';

/// Dashboard card for weather stations - shows temperature, wind, and rain (read-only)
class WeatherStationDashboardCard extends StatelessWidget {
  final Device device;
  final WeatherStationStatus? status;
  final List<double> temperatureHistory;
  final List<double> humidityHistory;
  final VoidCallback? onTap;

  const WeatherStationDashboardCard({
    super.key,
    required this.device,
    this.status,
    this.temperatureHistory = const [],
    this.humidityHistory = const [],
    this.onTap,
  });

  /// Get icon based on solar irradiance/illumination
  IconData get _weatherIcon {
    if (status == null) return AppIcons.weatherStation;

    final irradiance = status!.solarIrradiance;
    if (irradiance < 10) {
      return Icons.nights_stay_rounded; // Night/dark
    } else if (irradiance < 100) {
      return Icons.cloud_rounded; // Cloudy
    } else if (irradiance < 500) {
      return Icons.wb_cloudy_rounded; // Partly cloudy
    } else {
      return Icons.wb_sunny_rounded; // Sunny
    }
  }

  /// Get color based on solar irradiance
  Color get _weatherColor {
    if (status == null) return AppColors.weatherStation;

    final irradiance = status!.solarIrradiance;
    if (irradiance < 10) {
      return const Color(0xFF5C6BC0); // Indigo - night
    } else if (irradiance < 100) {
      return AppColors.textSecondary; // Cloudy
    } else if (irradiance < 500) {
      return AppColors.warning; // Partly sunny
    } else {
      return const Color(0xFFFF9800); // Orange - sunny
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Get trends (null for now since we don't have historical data)
    final tempTrend = status?.getTemperatureTrend(null);
    final humidityTrend = status?.getHumidityTrend(null);

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
                      color: _weatherColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _weatherIcon,
                      color: _weatherColor,
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
                  // Temperature display with trend
                  if (status != null && device.isOnline)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          status!.temperatureDisplay,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.weatherStation,
                          ),
                        ),
                        if (tempTrend != null) ...[
                          const SizedBox(width: 4),
                          _buildTrendArrow(tempTrend),
                        ],
                      ],
                    ),
                ],
              ),
              // Temperature sparkline
              if (status != null && device.isOnline && temperatureHistory.length >= 2) ...[
                const SizedBox(height: 8),
                SparklineWidget(
                  data: temperatureHistory,
                  lineColor: AppColors.weatherStation,
                  height: 32,
                ),
              ],
              // Weather details
              if (status != null && device.isOnline) ...[
                const SizedBox(height: 12),
                // Humidity with trend and solar irradiance
                Row(
                  children: [
                    Icon(
                      AppIcons.humidity,
                      size: 16,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status!.humidityDisplay,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (humidityTrend != null) ...[
                      const SizedBox(width: 4),
                      _buildTrendArrow(humidityTrend, small: true),
                    ],
                    const Spacer(),
                    // Solar irradiance
                    Icon(
                      AppIcons.light,
                      size: 16,
                      color: _weatherColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status!.solarIrradianceDisplay,
                      style: TextStyle(
                        fontSize: 14,
                        color: _weatherColor,
                      ),
                    ),
                  ],
                ),
                // Humidity sparkline
                if (humidityHistory.length >= 2) ...[
                  const SizedBox(height: 8),
                  SparklineWidget(
                    data: humidityHistory,
                    lineColor: AppColors.info,
                    height: 24,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildWeatherStat(
                        AppIcons.wind,
                        l10n.windSpeed,
                        '${status!.windSpeedDisplay} ${status!.windDirectionLocalized(l10n)}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildRainStat(l10n),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendArrow(ValueTrend trend, {bool small = false}) {
    return Text(
      trend.arrow,
      style: TextStyle(
        fontSize: small ? 12 : 16,
        fontWeight: FontWeight.bold,
        color: trend.color,
      ),
    );
  }

  Widget _buildWeatherStat(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.weatherStation,
          ),
          const SizedBox(width: 8),
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
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRainStat(AppLocalizations l10n) {
    final hasRain = status!.precipitation > 0;
    final rainColor = hasRain ? AppColors.info : AppColors.weatherStation;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasRain
            ? AppColors.info.withValues(alpha: 0.1)
            : AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.rain,
            size: 18,
            color: rainColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.rain} ${l10n.rainToday}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  status!.precipitationDisplay,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: hasRain ? rainColor : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
