import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/device_status.dart';
import '../../common/error_card.dart';
import '../../charts/sparkline_widget.dart';

/// Detail view for weather stations - shows all weather metrics in user-friendly format
class WeatherStationDetail extends StatelessWidget {
  final String deviceId;
  final WeatherStationStatus? status;
  final List<double> temperatureHistory;
  final List<double> humidityHistory;

  const WeatherStationDetail({
    super.key,
    required this.deviceId,
    this.status,
    this.temperatureHistory = const [],
    this.humidityHistory = const [],
  });

  void _navigateToHistory(BuildContext context, String metric) {
    context.push('/statistics/$deviceId?type=weather&metric=$metric');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (status == null) {
      return ErrorCard(message: l10n.errorGeneric);
    }

    return Column(
      children: [
        // Main weather display
        _buildMainWeatherCard(context, l10n),
        const SizedBox(height: 16),
        // Weather details grid
        _buildDetailsCard(context, l10n),
      ],
    );
  }

  Widget _buildMainWeatherCard(BuildContext context, AppLocalizations l10n) {
    // For now we show stable since we don't have historical data
    // In a real app, you'd pass previous values from the provider
    final tempTrend = status!.getTemperatureTrend(null);
    final humidityTrend = status!.getHumidityTrend(null);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Temperature with trend and history button
            InkWell(
              onTap: () => _navigateToHistory(context, 'temperature'),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      AppIcons.temperature,
                      size: 32,
                      color: AppColors.weatherStation,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status!.temperatureDisplay,
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildTrendBadge(tempTrend, l10n),
                    const SizedBox(width: 8),
                    Icon(
                      AppIcons.statistics,
                      size: 20,
                      color: AppColors.textHint,
                    ),
                  ],
                ),
              ),
            ),
            // Temperature sparkline with min/max
            if (temperatureHistory.length >= 2) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SparklineWidget(
                  data: temperatureHistory,
                  lineColor: AppColors.weatherStation,
                  height: 40,
                ),
              ),
              const SizedBox(height: 8),
              // Min/Max row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_downward,
                    size: 14,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${temperatureHistory.reduce((a, b) => a < b ? a : b).toStringAsFixed(1)}°',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.arrow_upward,
                    size: 14,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${temperatureHistory.reduce((a, b) => a > b ? a : b).toStringAsFixed(1)}°',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            // Humidity with trend and history button
            InkWell(
              onTap: () => _navigateToHistory(context, 'humidity'),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppIcons.humidity,
                      size: 20,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${l10n.humidity}: ${status!.humidityDisplay}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildTrendBadge(humidityTrend, l10n, small: true),
                    const SizedBox(width: 4),
                    Icon(
                      AppIcons.statistics,
                      size: 16,
                      color: AppColors.textHint,
                    ),
                  ],
                ),
              ),
            ),
            // Humidity sparkline
            if (humidityHistory.length >= 2) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SparklineWidget(
                  data: humidityHistory,
                  lineColor: AppColors.info,
                  height: 32,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrendBadge(ValueTrend trend, AppLocalizations l10n, {bool small = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: trend.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(small ? 6 : 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            trend.arrow,
            style: TextStyle(
              fontSize: small ? 12 : 16,
              fontWeight: FontWeight.bold,
              color: trend.color,
            ),
          ),
          if (!small) ...[
            const SizedBox(width: 4),
            Text(
              trend.labelLocalized(l10n),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: trend.color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.currentWeather,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            // Pressure with trend
            _buildPressureTile(context, l10n),
            const SizedBox(height: 16),
            // UV with danger level
            _buildUvTile(context, l10n),
            const SizedBox(height: 16),
            // Wind with gusts
            _buildWindTile(context, l10n),
            const SizedBox(height: 16),
            // Rain today
            _buildRainTile(context, l10n),
            const SizedBox(height: 16),
            // Solar irradiance
            _buildSolarTile(context, l10n),
            const SizedBox(height: 16),
            // Battery
            _buildBatteryTile(l10n),
            // Last updated timestamp
            if (status!.lastUpdated != null) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time_outlined,
                    size: 14,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${l10n.lastUpdated}: ${Formatters.timeAgo(status!.lastUpdated!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
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
    required IconData icon,
    required String label,
    required Widget content,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    final tile = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
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
                content,
              ],
            ),
          ),
          if (onTap != null)
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
            ),
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

  Widget _buildPressureTile(BuildContext context, AppLocalizations l10n) {
    // For now we show stable since we don't have historical data
    // In a real app, you'd pass previousPressure from the provider
    final trend = status!.getPressureTrend(null);

    return _buildDetailTile(
      icon: AppIcons.pressure,
      label: l10n.pressure,
      onTap: () => _navigateToHistory(context, 'pressure'),
      content: Row(
        children: [
          Text(
            status!.pressureDisplay,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: trend.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  trend.arrow,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: trend.color,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  trend.labelLocalized(l10n),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: trend.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUvTile(BuildContext context, AppLocalizations l10n) {
    final dangerLevel = status!.uvDangerLevel;

    return _buildDetailTile(
      icon: AppIcons.uvIndex,
      label: l10n.uvIndex,
      iconColor: dangerLevel.color,
      onTap: () => _navigateToHistory(context, 'uv'),
      content: Row(
        children: [
          Text(
            status!.uvDisplay,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: dangerLevel.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  dangerLevel.icon,
                  size: 14,
                  color: dangerLevel.color,
                ),
                const SizedBox(width: 4),
                Text(
                  dangerLevel.labelLocalized(l10n),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: dangerLevel.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWindTile(BuildContext context, AppLocalizations l10n) {
    return _buildDetailTile(
      icon: AppIcons.wind,
      label: l10n.windSpeed,
      onTap: () => _navigateToHistory(context, 'wind'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                status!.windSpeedDisplay,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                status!.windDirectionLocalized(l10n),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (status!.windGust > 0) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${l10n.windGust}: ',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  status!.windGustDisplay,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRainTile(BuildContext context, AppLocalizations l10n) {
    return _buildDetailTile(
      icon: AppIcons.rain,
      label: l10n.rain,
      iconColor: status!.precipitation > 0 ? AppColors.info : null,
      onTap: () => _navigateToHistory(context, 'rain'),
      content: Row(
        children: [
          Text(
            status!.precipitationDisplay,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              l10n.rainToday,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolarTile(BuildContext context, AppLocalizations l10n) {
    // Determine solar intensity level based on W/m²
    // Clear sky sunlight is ~1000 W/m², overcast is ~100-300 W/m²
    String solarLevel;
    Color levelColor;
    final irradiance = status!.solarIrradiance;

    if (irradiance < 10) {
      solarLevel = l10n.solarDark;
      levelColor = const Color(0xFF5C6BC0); // Indigo
    } else if (irradiance < 100) {
      solarLevel = l10n.solarCloudy;
      levelColor = AppColors.textSecondary;
    } else if (irradiance < 500) {
      solarLevel = l10n.solarPartlySunny;
      levelColor = AppColors.warning;
    } else if (irradiance < 800) {
      solarLevel = l10n.solarSunny;
      levelColor = const Color(0xFFFF9800); // Orange
    } else {
      solarLevel = l10n.solarVerySunny;
      levelColor = const Color(0xFFFF5722); // Deep Orange
    }

    return _buildDetailTile(
      icon: AppIcons.light,
      label: l10n.solar,
      iconColor: levelColor,
      onTap: () => _navigateToHistory(context, 'solar'),
      content: Row(
        children: [
          Text(
            status!.solarIrradianceDisplay,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: levelColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              solarLevel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: levelColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryTile(AppLocalizations l10n) {
    final batteryColor = status!.isBatteryLow ? AppColors.warning : AppColors.success;
    final batteryIcon = status!.isBatteryLow ? AppIcons.batteryLow : AppIcons.battery;

    String batteryLevel;
    if (status!.batteryPercent >= 80) {
      batteryLevel = l10n.batteryFull;
    } else if (status!.batteryPercent >= 50) {
      batteryLevel = l10n.batteryGood;
    } else if (status!.batteryPercent >= 20) {
      batteryLevel = l10n.batteryLow;
    } else {
      batteryLevel = l10n.batteryCritical;
    }

    return _buildDetailTile(
      icon: batteryIcon,
      label: l10n.battery,
      iconColor: batteryColor,
      content: Row(
        children: [
          Text(
            status!.batteryDisplay,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: batteryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              batteryLevel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: batteryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
