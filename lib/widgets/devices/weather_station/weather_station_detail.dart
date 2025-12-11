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
  final List<double> pressureHistory;

  const WeatherStationDetail({
    super.key,
    required this.deviceId,
    this.status,
    this.temperatureHistory = const [],
    this.humidityHistory = const [],
    this.pressureHistory = const [],
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
        // Hero temperature card
        _buildHeroCard(context, l10n),
        const SizedBox(height: 16),
        // Quick stats row
        _buildQuickStats(context, l10n),
        const SizedBox(height: 16),
        // Weather grid
        _buildWeatherGrid(context, l10n),
        // Last updated
        if (status!.lastUpdated != null) ...[
          const SizedBox(height: 16),
          _buildLastUpdated(l10n),
        ],
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context, AppLocalizations l10n) {
    final tempTrend = status!.getTemperatureTrend(null);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.weatherStation.withValues(alpha: 0.1),
              AppColors.weatherStation.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: InkWell(
          onTap: () => _navigateToHistory(context, 'temperature'),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Temperature display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Temperature value
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _formatTemperatureValue(status!.temperature),
                          style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w300,
                            color: AppColors.textPrimary,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                    // Degree symbol and unit
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        '°C',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Trend badge
                _buildTrendChip(tempTrend, l10n),
                // Sparkline
                if (temperatureHistory.length >= 2) ...[
                  const SizedBox(height: 20),
                  SparklineWidget(
                    data: temperatureHistory,
                    lineColor: AppColors.weatherStation,
                    height: 50,
                    showDots: true,
                    showHourLabels: true,
                  ),
                  const SizedBox(height: 12),
                  // Min/Max pills
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMinMaxPill(
                        icon: Icons.arrow_downward_rounded,
                        value:
                            '${temperatureHistory.reduce((a, b) => a < b ? a : b).toStringAsFixed(1)}°',
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 16),
                      _buildMinMaxPill(
                        icon: Icons.arrow_upward_rounded,
                        value:
                            '${temperatureHistory.reduce((a, b) => a > b ? a : b).toStringAsFixed(1)}°',
                        color: AppColors.error,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                // Tap hint
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      AppIcons.statistics,
                      size: 14,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.tapForHistory,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTemperatureValue(double temp) {
    if (temp == temp.roundToDouble()) {
      return temp.round().toString();
    }
    return temp.toStringAsFixed(1);
  }

  Widget _buildMinMaxPill({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChip(ValueTrend trend, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: trend.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
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
          const SizedBox(width: 6),
          Text(
            trend.labelLocalized(l10n),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: trend.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, AppLocalizations l10n) {
    final humidityTrend = status!.getHumidityTrend(null);

    // Calculate pressure trend from history
    // Compare current pressure with the first reading (start of day) to show day trend
    final pressureTrend = pressureHistory.isNotEmpty
        ? status!.getPressureTrend(pressureHistory.first)
        : ValueTrend.stable;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Humidity card
          Expanded(
            child: _buildQuickStatCard(
              context: context,
              icon: AppIcons.humidity,
              label: l10n.humidity,
              value: status!.humidityDisplay,
              color: AppColors.info,
              trend: humidityTrend,
              l10n: l10n,
              onTap: () => _navigateToHistory(context, 'humidity'),
              sparkline: humidityHistory.length >= 2
                  ? SparklineWidget(
                      data: humidityHistory,
                      lineColor: AppColors.info,
                      height: 40,
                      showDots: true,
                      showHourLabels: true,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // Pressure card
          Expanded(
            child: _buildQuickStatCard(
              context: context,
              icon: AppIcons.pressure,
              label: l10n.pressure,
              value: status!.pressureDisplay,
              color: const Color(0xFF7E57C2),
              trend: pressureTrend,
              l10n: l10n,
              onTap: () => _navigateToHistory(context, 'pressure'),
              sparkline: pressureHistory.length >= 2
                  ? SparklineWidget(
                      data: pressureHistory,
                      lineColor: const Color(0xFF7E57C2),
                      height: 40,
                      showDots: true,
                      showHourLabels: true,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required ValueTrend trend,
    required AppLocalizations l10n,
    required VoidCallback onTap,
    Widget? sparkline,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 18, color: color),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.textHint,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    trend.arrow,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: trend.color,
                    ),
                  ),
                ],
              ),
              if (sparkline != null) ...[
                const SizedBox(height: 12),
                sparkline,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherGrid(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        // UV and Solar row
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildUvTile(context, l10n)),
              const SizedBox(width: 12),
              Expanded(child: _buildSolarTile(context, l10n)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Wind and Rain row
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildWindTile(context, l10n)),
              const SizedBox(width: 12),
              Expanded(child: _buildRainTile(context, l10n)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Battery (full width)
        _buildBatteryTile(l10n),
      ],
    );
  }

  Widget _buildGridTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    String? subtitle,
    Widget? badge,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 18, color: color),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.textHint,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (badge != null) ...[
                const SizedBox(height: 8),
                badge,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUvTile(BuildContext context, AppLocalizations l10n) {
    final dangerLevel = status!.uvDangerLevel;

    return _buildGridTile(
      icon: AppIcons.uvIndex,
      label: l10n.uvIndex,
      value: status!.uvDisplay,
      color: dangerLevel.color,
      onTap: () => _navigateToHistory(context, 'uv'),
      badge: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: dangerLevel.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(dangerLevel.icon, size: 12, color: dangerLevel.color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                dangerLevel.labelLocalized(l10n),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: dangerLevel.color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolarTile(BuildContext context, AppLocalizations l10n) {
    final irradiance = status!.solarIrradiance;
    String solarLevel;
    Color levelColor;

    if (irradiance < 10) {
      solarLevel = l10n.solarDark;
      levelColor = const Color(0xFF5C6BC0);
    } else if (irradiance < 100) {
      solarLevel = l10n.solarCloudy;
      levelColor = AppColors.textSecondary;
    } else if (irradiance < 500) {
      solarLevel = l10n.solarPartlySunny;
      levelColor = AppColors.warning;
    } else if (irradiance < 800) {
      solarLevel = l10n.solarSunny;
      levelColor = const Color(0xFFFF9800);
    } else {
      solarLevel = l10n.solarVerySunny;
      levelColor = const Color(0xFFFF5722);
    }

    return _buildGridTile(
      icon: AppIcons.light,
      label: l10n.solar,
      value: status!.solarIrradianceDisplay,
      color: levelColor,
      onTap: () => _navigateToHistory(context, 'solar'),
      badge: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: levelColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          solarLevel,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: levelColor,
          ),
        ),
      ),
    );
  }

  Widget _buildWindTile(BuildContext context, AppLocalizations l10n) {
    // No onTap - Shelly API doesn't provide wind history
    return _buildGridTile(
      icon: AppIcons.wind,
      label: l10n.windSpeed,
      value: status!.windSpeedDisplay,
      color: AppColors.textSecondary,
      subtitle: status!.windGust > 0
          ? '${l10n.windGust}: ${status!.windGustDisplay}'
          : status!.windDirectionLocalized(l10n),
    );
  }

  Widget _buildRainTile(BuildContext context, AppLocalizations l10n) {
    final hasRain = status!.precipitation > 0;

    return _buildGridTile(
      icon: AppIcons.rain,
      label: l10n.rain,
      value: status!.precipitationDisplay,
      color: hasRain ? AppColors.info : AppColors.textSecondary,
      subtitle: l10n.rainToday,
      onTap: () => _navigateToHistory(context, 'rain'),
    );
  }

  Widget _buildBatteryTile(AppLocalizations l10n) {
    final batteryColor =
        status!.isBatteryLow ? AppColors.warning : AppColors.success;
    final batteryIcon =
        status!.isBatteryLow ? AppIcons.batteryLow : AppIcons.battery;

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

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: batteryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(batteryIcon, size: 22, color: batteryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.battery,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status!.batteryDisplay,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: batteryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
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
      ),
    );
  }

  Widget _buildLastUpdated(AppLocalizations l10n) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time_outlined,
              size: 14,
              color: AppColors.textHint,
            ),
            const SizedBox(width: 6),
            Text(
              '${l10n.lastUpdated}: ${Formatters.timeAgo(status!.lastUpdated!, l10n)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
