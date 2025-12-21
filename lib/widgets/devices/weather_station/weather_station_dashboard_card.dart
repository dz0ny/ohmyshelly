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
  final double? todayRainTotal;
  final double? currentRainIntensity;
  final double? windTrend;
  final List<double> recentWindSpeeds;
  final VoidCallback? onTap;

  const WeatherStationDashboardCard({
    super.key,
    required this.device,
    this.status,
    this.temperatureHistory = const [],
    this.humidityHistory = const [],
    this.todayRainTotal,
    this.currentRainIntensity,
    this.windTrend,
    this.recentWindSpeeds = const [],
    this.onTap,
  });

  /// Get wind intensity label based on km/h (Beaufort scale simplified)
  /// - Calm: < 1 km/h
  /// - Light Breeze: 1 - 12 km/h
  /// - Moderate: 12 - 30 km/h
  /// - Strong: 30 - 50 km/h
  /// - Gale: 50 - 75 km/h
  /// - Storm: > 75 km/h
  String _getWindIntensityLabel(double speed, AppLocalizations l10n) {
    if (speed < 1) return l10n.windCalm;
    if (speed < 12) return l10n.windLight;
    if (speed < 30) return l10n.windModerate;
    if (speed < 50) return l10n.windStrong;
    if (speed < 75) return l10n.windGale;
    return l10n.windStorm;
  }

  /// Get rain intensity label based on mm/h
  /// - Dew/Mist: < 1 mm/h
  /// - Drizzle: 1 - 2.5 mm/h
  /// - Light rain: 2.5 - 7.5 mm/h
  /// - Moderate rain: 7.5 - 15 mm/h
  /// - Heavy rain: 15 - 30 mm/h
  /// - Downpour: > 30 mm/h
  String _getRainIntensityLabel(double intensity, AppLocalizations l10n) {
    if (intensity < 1) return l10n.rainDew;
    if (intensity < 2.5) return l10n.rainDrizzle;
    if (intensity < 7.5) return l10n.rainLight;
    if (intensity < 15) return l10n.rainModerate;
    if (intensity < 30) return l10n.rainHeavy;
    return l10n.rainDownpour;
  }

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
  Color _getWeatherColor(BuildContext context) {
    if (status == null) return AppColors.weatherStation;

    final colorScheme = Theme.of(context).colorScheme;
    final irradiance = status!.solarIrradiance;
    if (irradiance < 10) {
      return const Color(0xFF5C6BC0); // Indigo - night
    } else if (irradiance < 100) {
      return colorScheme.onSurfaceVariant; // Cloudy
    } else if (irradiance < 500) {
      return AppColors.warning; // Partly sunny
    } else {
      return const Color(0xFFFF9800); // Orange - sunny
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    // Get trends using most recent historical values
    final lastValidTemp = temperatureHistory.where((t) => t != 0.0).lastOrNull;
    final lastValidHumidity = humidityHistory.where((h) => h != 0.0).lastOrNull;
    final tempTrend = status?.getTemperatureTrend(lastValidTemp);
    final humidityTrend = status?.getHumidityTrend(lastValidHumidity);

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
                      color: _getWeatherColor(context).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _weatherIcon,
                      color: _getWeatherColor(context),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                      ],
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
              // Feels like (only show if different from actual temp by more than 1°C)
              if (status != null && device.isOnline && (status!.feelsLike - status!.temperature).abs() > 1) ...[
                const SizedBox(height: 4),
                Text(
                  '${l10n.feelsLike} ${status!.feelsLikeShort}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.outline,
                  ),
                ),
              ],
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
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
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
                      color: _getWeatherColor(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status!.solarIrradianceDisplay,
                      style: TextStyle(
                        fontSize: 14,
                        color: _getWeatherColor(context),
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
                      child: _buildWindStat(context, l10n),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildRainStat(context, l10n),
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

  Widget _buildWindStat(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final direction = status!.windDirection;
    final rotationAngle = direction * (3.14159 / 180);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Compass circle with cardinal points
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Cardinal points
                Positioned(
                  top: 2,
                  child: Text(l10n.directionN, style: TextStyle(fontSize: 6, color: colorScheme.outline, fontWeight: FontWeight.w500)),
                ),
                Positioned(
                  bottom: 2,
                  child: Text(l10n.directionS, style: TextStyle(fontSize: 6, color: colorScheme.outline)),
                ),
                Positioned(
                  left: 2,
                  child: Text(l10n.directionW, style: TextStyle(fontSize: 6, color: colorScheme.outline)),
                ),
                Positioned(
                  right: 2,
                  child: Text(l10n.directionE, style: TextStyle(fontSize: 6, color: colorScheme.outline)),
                ),
                // Direction arrow
                Transform.rotate(
                  angle: rotationAngle,
                  child: Icon(
                    Icons.navigation_rounded,
                    size: 14,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getWindIntensityLabel(status!.windSpeed, l10n),
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${status!.windSpeedDisplay} ${status!.windDirectionLocalized(l10n)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (windTrend != null && windTrend!.abs() > 1) ...[
                      const SizedBox(width: 4),
                      Text(
                        windTrend! > 0 ? '↑' : '↓',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: windTrend! > 0 ? AppColors.warning : AppColors.info,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRainStat(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    // Use today's total rain from statistics if available
    final rainValue = todayRainTotal ?? 0.0;
    final isRaining = currentRainIntensity != null && currentRainIntensity! > 0;
    final hasRain = rainValue > 0 || isRaining;
    final rainColor = isRaining ? AppColors.info : (hasRain ? AppColors.info : AppColors.weatherStation);

    // Format rain display - show intensity if actively raining, otherwise show today's total
    String rainDisplay;
    String label;
    if (isRaining) {
      rainDisplay = '${currentRainIntensity!.toStringAsFixed(1)} mm/h';
      // Rain intensity labels based on mm/h
      label = _getRainIntensityLabel(currentRainIntensity!, l10n);
    } else {
      // Show more precision for small values
      if (rainValue == 0) {
        rainDisplay = '0 mm';
      } else if (rainValue < 1) {
        rainDisplay = '${rainValue.toStringAsFixed(2)} mm';
      } else {
        rainDisplay = '${rainValue.toStringAsFixed(1)} mm';
      }
      label = '${l10n.rain} ${l10n.rainToday}';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isRaining
            ? AppColors.info.withValues(alpha: 0.15)
            : (hasRain ? AppColors.info.withValues(alpha: 0.1) : colorScheme.surfaceContainerHighest),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isRaining ? Icons.grain_rounded : AppIcons.rain,
            size: 18,
            color: rainColor,
          ),
          const SizedBox(width: 8),
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
                Text(
                  rainDisplay,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: hasRain ? rainColor : colorScheme.onSurface,
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
