import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/statistics.dart';
import '../../providers/statistics_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_card.dart';
import '../../widgets/common/date_range_picker.dart';
import '../../widgets/charts/line_chart_widget.dart';
import '../../widgets/charts/bar_chart_widget.dart';

/// Available power metrics for filtering
enum PowerMetric {
  power,
  voltage,
  current,
  energy,
}

extension PowerMetricExtension on PowerMetric {
  String get displayName {
    switch (this) {
      case PowerMetric.power:
        return 'Power';
      case PowerMetric.voltage:
        return 'Voltage';
      case PowerMetric.current:
        return 'Current';
      case PowerMetric.energy:
        return 'Energy';
    }
  }

  static PowerMetric? fromString(String? value) {
    if (value == null) return null;
    return PowerMetric.values.cast<PowerMetric?>().firstWhere(
          (m) => m?.name == value,
          orElse: () => null,
        );
  }
}

/// Available weather metrics for filtering
enum WeatherMetric {
  temperature,
  humidity,
  pressure,
  uv,
  wind,
  rain,
  solar,
}

extension WeatherMetricExtension on WeatherMetric {
  String get displayName {
    switch (this) {
      case WeatherMetric.temperature:
        return 'Temperature';
      case WeatherMetric.humidity:
        return 'Humidity';
      case WeatherMetric.pressure:
        return 'Pressure';
      case WeatherMetric.uv:
        return 'UV Index';
      case WeatherMetric.wind:
        return 'Wind';
      case WeatherMetric.rain:
        return 'Rain';
      case WeatherMetric.solar:
        return 'Solar';
    }
  }

  static WeatherMetric? fromString(String? value) {
    if (value == null) return null;
    return WeatherMetric.values.cast<WeatherMetric?>().firstWhere(
          (m) => m?.name == value,
          orElse: () => null,
        );
  }
}

class StatisticsScreen extends StatefulWidget {
  final String deviceId;
  final String deviceType;
  final String? metric;

  const StatisticsScreen({
    super.key,
    required this.deviceId,
    required this.deviceType,
    this.metric,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    // Defer to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndFetch();
    });
  }

  void _initializeAndFetch() {
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    final statsProvider = context.read<StatisticsProvider>();

    statsProvider.setCredentials(auth.apiUrl, auth.token);

    if (widget.deviceType == 'power') {
      statsProvider.fetchPowerStatistics(widget.deviceId);
    } else {
      statsProvider.fetchWeatherStatistics(widget.deviceId);
    }
  }

  WeatherMetric? get _selectedWeatherMetric =>
      WeatherMetricExtension.fromString(widget.metric);

  PowerMetric? get _selectedPowerMetric =>
      PowerMetricExtension.fromString(widget.metric);

  String _getTitle(AppLocalizations l10n) {
    if (widget.deviceType == 'power') {
      final metric = _selectedPowerMetric;
      if (metric != null) {
        switch (metric) {
          case PowerMetric.power:
            return l10n.powerHistory;
          case PowerMetric.voltage:
            return l10n.voltageHistory;
          case PowerMetric.current:
            return l10n.currentHistory;
          case PowerMetric.energy:
            return l10n.energyHistory;
        }
      }
      return l10n.powerHistory;
    }
    final metric = _selectedWeatherMetric;
    if (metric != null) {
      switch (metric) {
        case WeatherMetric.temperature:
          return l10n.temperatureHistory;
        case WeatherMetric.humidity:
          return l10n.humidityHistory;
        case WeatherMetric.pressure:
          return l10n.pressureHistory;
        case WeatherMetric.uv:
          return l10n.uvHistory;
        case WeatherMetric.wind:
          return l10n.weatherHistory;
        case WeatherMetric.rain:
          return l10n.rainHistory;
        case WeatherMetric.solar:
          return l10n.solarHistory;
      }
    }
    return l10n.weatherHistory;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPower = widget.deviceType == 'power';

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(l10n)),
      ),
      body: Consumer<StatisticsProvider>(
        builder: (context, statsProvider, _) {
          return Column(
            children: [
              // Period selector
              _buildPeriodSelector(statsProvider),

              // Content
              Expanded(
                child: _buildContent(statsProvider, isPower, l10n),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector(StatisticsProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DateRangePicker(
        selection: provider.selection,
        onChanged: (selection) {
          provider.setSelection(selection);
        },
      ),
    );
  }

  Widget _buildContent(StatisticsProvider provider, bool isPower, AppLocalizations l10n) {
    if (kDebugMode) {
      debugPrint('StatisticsScreen: state=${provider.state}, isLoading=${provider.isLoading}');
      debugPrint('StatisticsScreen: isPower=$isPower, powerStats=${provider.powerStatistics != null}, weatherStats=${provider.weatherStatistics != null}');
      if (provider.powerStatistics != null) {
        debugPrint('StatisticsScreen: powerStats dataPoints=${provider.powerStatistics!.dataPoints.length}');
      }
      if (provider.weatherStatistics != null) {
        debugPrint('StatisticsScreen: weatherStats dataPoints=${provider.weatherStatistics!.dataPoints.length}');
      }
      if (provider.error != null) {
        debugPrint('StatisticsScreen: error=${provider.error}');
      }
    }

    if (provider.isLoading) {
      return LoadingIndicator(message: l10n.loadingStatistics);
    }

    if (provider.state == StatisticsLoadState.error) {
      return ErrorCard(
        message: provider.error ?? l10n.errorGeneric,
        onRetry: () {
          if (isPower) {
            provider.fetchPowerStatistics(widget.deviceId);
          } else {
            provider.fetchWeatherStatistics(widget.deviceId);
          }
        },
      );
    }

    if (isPower && provider.powerStatistics != null) {
      return _buildPowerContent(provider.powerStatistics!, provider.selection.type, provider.selection.selectedDate, l10n);
    } else if (!isPower && provider.weatherStatistics != null) {
      return _buildWeatherContent(provider.weatherStatistics!, provider.selection.type, provider.selection.selectedDate, l10n);
    }

    return Center(
      child: Text(l10n.noDataAvailable),
    );
  }

  Widget _buildPowerContent(PowerStatistics stats, DateRangeType rangeType, DateTime selectedDate, AppLocalizations l10n) {
    if (stats.dataPoints.isEmpty) {
      return Center(
        child: Text(
          l10n.noPowerData,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.powerUsage,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${l10n.total}: ${Formatters.energy(stats.totalConsumption)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildPowerChart(stats, rangeType, selectedDate),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPowerChart(PowerStatistics stats, DateRangeType rangeType, DateTime selectedDate) {
    final dataPoints = stats.dataPoints
        .map((p) => BarChartDataPoint(
              y: p.consumption,
              timestamp: p.timestamp,
            ))
        .toList();

    // Use bar chart for all power statistics (day/week/month/year)
    return BarChartWidget(
      dataPoints: dataPoints,
      barColor: AppColors.powerDevice,
      unit: 'Wh',
      rangeType: rangeType,
    );
  }

  Widget _buildWeatherContent(WeatherStatistics stats, DateRangeType rangeType, DateTime selectedDate, AppLocalizations l10n) {
    if (stats.dataPoints.isEmpty) {
      return Center(
        child: Text(
          l10n.noWeatherData,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final metric = _selectedWeatherMetric;

    // If a specific metric is selected, show only that chart
    if (metric != null) {
      return _buildMetricChart(stats, metric, rangeType, selectedDate, l10n);
    }

    // Otherwise show all weather data (legacy behavior)
    return _buildAllWeatherCharts(stats, rangeType, selectedDate, l10n);
  }

  Widget _buildMetricChart(WeatherStatistics stats, WeatherMetric metric, DateRangeType rangeType, DateTime selectedDate, AppLocalizations l10n) {
    List<ChartDataPoint> dataPoints;
    String unit;
    Color lineColor;
    String chartTitle;
    Widget summaryCard;

    switch (metric) {
      case WeatherMetric.temperature:
        dataPoints = stats.dataPoints
            .map((p) => ChartDataPoint(
                  x: p.timestamp.millisecondsSinceEpoch.toDouble(),
                  y: p.avgTemperature,
                  timestamp: p.timestamp,
                ))
            .toList();
        unit = '\u00B0C';
        lineColor = AppColors.weatherStation;
        chartTitle = l10n.temperature;
        summaryCard = _buildTemperatureSummary(stats, l10n);
        break;

      case WeatherMetric.humidity:
        dataPoints = stats.dataPoints
            .map((p) => ChartDataPoint(
                  x: p.timestamp.millisecondsSinceEpoch.toDouble(),
                  y: p.humidity,
                  timestamp: p.timestamp,
                ))
            .toList();
        unit = '%';
        lineColor = AppColors.info;
        chartTitle = l10n.humidity;
        summaryCard = _buildHumiditySummary(stats, l10n);
        break;

      case WeatherMetric.pressure:
        dataPoints = stats.dataPoints
            .map((p) => ChartDataPoint(
                  x: p.timestamp.millisecondsSinceEpoch.toDouble(),
                  y: p.avgPressure,
                  timestamp: p.timestamp,
                ))
            .toList();
        unit = 'hPa';
        lineColor = const Color(0xFF7E57C2); // Purple
        chartTitle = l10n.pressure;
        summaryCard = _buildPressureSummary(stats, l10n);
        break;

      case WeatherMetric.uv:
        dataPoints = stats.dataPoints
            .map((p) => ChartDataPoint(
                  x: p.timestamp.millisecondsSinceEpoch.toDouble(),
                  y: p.uvIndex,
                  timestamp: p.timestamp,
                ))
            .toList();
        unit = '';
        lineColor = AppColors.warning;
        chartTitle = l10n.uvIndex;
        summaryCard = _buildUvSummary(stats, l10n);
        break;

      case WeatherMetric.rain:
        dataPoints = stats.dataPoints
            .map((p) => ChartDataPoint(
                  x: p.timestamp.millisecondsSinceEpoch.toDouble(),
                  y: p.precipitation,
                  timestamp: p.timestamp,
                ))
            .toList();
        unit = 'mm';
        lineColor = AppColors.info;
        chartTitle = l10n.rain;
        summaryCard = _buildRainSummary(stats, l10n);
        break;

      case WeatherMetric.solar:
        // Convert lux to W/m² (approximate)
        dataPoints = stats.dataPoints
            .map((p) => ChartDataPoint(
                  x: p.timestamp.millisecondsSinceEpoch.toDouble(),
                  y: p.illuminance / 120,
                  timestamp: p.timestamp,
                ))
            .toList();
        unit = 'W/m²';
        lineColor = const Color(0xFFFF9800); // Orange
        chartTitle = l10n.solar;
        summaryCard = _buildSolarSummary(stats, l10n);
        break;

      case WeatherMetric.wind:
        // Shelly API doesn't provide historical wind data
        return Center(
          child: Text(
            l10n.windHistoryNotAvailable,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chartTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: LineChartWidget(
                      dataPoints: dataPoints,
                      lineColor: lineColor,
                      unit: unit,
                      rangeType: rangeType,
                      selectedDate: selectedDate,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          summaryCard,
        ],
      ),
    );
  }

  Widget _buildTemperatureSummary(WeatherStatistics stats, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.summary,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              l10n.min,
              Formatters.temperature(stats.minTemperature),
              Icons.arrow_downward,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              l10n.max,
              Formatters.temperature(stats.maxTemperature),
              Icons.arrow_upward,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              l10n.average,
              Formatters.temperature(stats.avgTemperature),
              Icons.trending_flat,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHumiditySummary(WeatherStatistics stats, AppLocalizations l10n) {
    final minHumidity = stats.dataPoints.map((p) => p.humidity).reduce((a, b) => a < b ? a : b);
    final maxHumidity = stats.dataPoints.map((p) => p.humidity).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.summary,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              l10n.min,
              Formatters.humidity(minHumidity),
              Icons.arrow_downward,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              l10n.max,
              Formatters.humidity(maxHumidity),
              Icons.arrow_upward,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              l10n.average,
              Formatters.humidity(stats.avgHumidity),
              Icons.trending_flat,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPressureSummary(WeatherStatistics stats, AppLocalizations l10n) {
    final minPressure = stats.dataPoints.map((p) => p.minPressure).reduce((a, b) => a < b ? a : b);
    final maxPressure = stats.dataPoints.map((p) => p.maxPressure).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.summary,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              l10n.min,
              Formatters.pressure(minPressure),
              Icons.arrow_downward,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              l10n.max,
              Formatters.pressure(maxPressure),
              Icons.arrow_upward,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              l10n.average,
              Formatters.pressure(stats.avgPressure),
              Icons.trending_flat,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUvSummary(WeatherStatistics stats, AppLocalizations l10n) {
    final maxUv = stats.dataPoints.map((p) => p.uvIndex).reduce((a, b) => a > b ? a : b);
    final avgUv = stats.dataPoints.fold<double>(0, (sum, p) => sum + p.uvIndex) / stats.dataPoints.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.summary,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              l10n.peakUv,
              maxUv.toStringAsFixed(1),
              Icons.arrow_upward,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              l10n.average,
              avgUv.toStringAsFixed(1),
              Icons.trending_flat,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRainSummary(WeatherStatistics stats, AppLocalizations l10n) {
    final maxRain = stats.dataPoints.map((p) => p.precipitation).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.summary,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              l10n.total,
              Formatters.precipitation(stats.totalPrecipitation),
              AppIcons.rain,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              l10n.peak,
              Formatters.precipitation(maxRain),
              Icons.arrow_upward,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolarSummary(WeatherStatistics stats, AppLocalizations l10n) {
    // Convert lux to W/m²
    final solarValues = stats.dataPoints.map((p) => p.illuminance / 120).toList();
    final maxSolar = solarValues.reduce((a, b) => a > b ? a : b);
    final avgSolar = solarValues.fold<double>(0, (sum, v) => sum + v) / solarValues.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.summary,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              l10n.peak,
              Formatters.solarIrradiance(maxSolar),
              Icons.arrow_upward,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              l10n.average,
              Formatters.solarIrradiance(avgSolar),
              Icons.trending_flat,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllWeatherCharts(WeatherStatistics stats, DateRangeType rangeType, DateTime selectedDate, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Temperature chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.temperature,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: LineChartWidget(
                      dataPoints: stats.dataPoints
                          .map((p) => ChartDataPoint(
                                x: p.timestamp.millisecondsSinceEpoch.toDouble(),
                                y: p.avgTemperature,
                                timestamp: p.timestamp,
                              ))
                          .toList(),
                      lineColor: AppColors.weatherStation,
                      unit: '\u00B0C',
                      rangeType: rangeType,
                      selectedDate: selectedDate,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Summary card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.summary,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow(
                    l10n.min,
                    Formatters.temperature(stats.minTemperature),
                    Icons.arrow_downward,
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    l10n.max,
                    Formatters.temperature(stats.maxTemperature),
                    Icons.arrow_upward,
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    l10n.average,
                    Formatters.temperature(stats.avgTemperature),
                    Icons.trending_flat,
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    l10n.humidityAvg,
                    Formatters.humidity(stats.avgHumidity),
                    AppIcons.humidity,
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    l10n.rainTotal,
                    Formatters.precipitation(stats.totalPrecipitation),
                    AppIcons.rain,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
