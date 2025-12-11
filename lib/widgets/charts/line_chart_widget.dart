import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../common/date_range_picker.dart';

class ChartDataPoint {
  final double x;
  final double y;
  final DateTime? timestamp;

  ChartDataPoint({required this.x, required this.y, this.timestamp});
}

class LineChartWidget extends StatefulWidget {
  final List<ChartDataPoint> dataPoints;
  final Color lineColor;
  final String unit;
  final bool showGrid;
  final bool showDots;
  final DateRangeType? rangeType;
  final DateTime? selectedDate;

  const LineChartWidget({
    super.key,
    required this.dataPoints,
    required this.lineColor,
    this.unit = '',
    this.showGrid = true,
    this.showDots = false,
    this.rangeType,
    this.selectedDate,
  });

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  late List<ChartDataPoint> _filledDataPoints;
  late List<String> _labels;
  String? _lastLocale;

  @override
  void initState() {
    super.initState();
    _filledDataPoints = [];
    _labels = [];
  }

  @override
  void didUpdateWidget(LineChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dataPoints != widget.dataPoints ||
        oldWidget.rangeType != widget.rangeType ||
        oldWidget.selectedDate != widget.selectedDate) {
      _lastLocale = null; // Force rebuild
    }
  }

  void _prepareData(AppLocalizations l10n) {
    final currentLocale = l10n.localeName;
    if (_lastLocale == currentLocale && _filledDataPoints.isNotEmpty) {
      return; // Already prepared for this locale
    }
    _lastLocale = currentLocale;

    if (widget.rangeType == null) {
      // Legacy mode - use raw data points
      _filledDataPoints = widget.dataPoints;
      _labels = [];
      return;
    }

    switch (widget.rangeType!) {
      case DateRangeType.day:
        _prepareDayData();
        break;
      case DateRangeType.week:
        _prepareWeekData(l10n);
        break;
      case DateRangeType.month:
        _prepareMonthData();
        break;
      case DateRangeType.year:
        _prepareYearData(l10n);
        break;
    }
  }

  void _prepareDayData() {
    // 24 hours: 0h, 1h, 2h, ... 23h
    final selectedDate = widget.selectedDate ?? DateTime.now();
    final day = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    _filledDataPoints = [];
    _labels = [];

    for (int hour = 0; hour < 24; hour++) {
      final timestamp = DateTime(day.year, day.month, day.day, hour);
      final existing = widget.dataPoints.where((p) {
        if (p.timestamp != null) {
          return p.timestamp!.hour == hour &&
                 p.timestamp!.day == day.day &&
                 p.timestamp!.month == day.month &&
                 p.timestamp!.year == day.year;
        }
        // Fallback to x as milliseconds
        final t = DateTime.fromMillisecondsSinceEpoch(p.x.toInt());
        return t.hour == hour &&
               t.day == day.day &&
               t.month == day.month &&
               t.year == day.year;
      }).firstOrNull;

      _filledDataPoints.add(ChartDataPoint(
        x: timestamp.millisecondsSinceEpoch.toDouble(),
        y: existing?.y ?? 0,
        timestamp: timestamp,
      ));
      _labels.add('${hour}h');
    }
  }

  void _prepareWeekData(AppLocalizations l10n) {
    // 7 days: Mon, Tue, Wed, Thu, Fri, Sat, Sun
    final dayNames = [
      l10n.dayMon, l10n.dayTue, l10n.dayWed, l10n.dayThu,
      l10n.dayFri, l10n.daySat, l10n.daySun
    ];
    final selectedDate = widget.selectedDate ?? DateTime.now();
    final daysFromMonday = selectedDate.weekday - 1;
    final monday = DateTime(selectedDate.year, selectedDate.month, selectedDate.day - daysFromMonday);

    _filledDataPoints = [];
    _labels = [];

    for (int i = 0; i < 7; i++) {
      final date = DateTime(monday.year, monday.month, monday.day + i);
      final existing = widget.dataPoints.where((p) {
        if (p.timestamp != null) {
          return p.timestamp!.day == date.day &&
                 p.timestamp!.month == date.month &&
                 p.timestamp!.year == date.year;
        }
        final t = DateTime.fromMillisecondsSinceEpoch(p.x.toInt());
        return t.day == date.day &&
               t.month == date.month &&
               t.year == date.year;
      }).firstOrNull;

      _filledDataPoints.add(ChartDataPoint(
        x: date.millisecondsSinceEpoch.toDouble(),
        y: existing?.y ?? 0,
        timestamp: date,
      ));
      _labels.add(dayNames[i]);
    }
  }

  void _prepareMonthData() {
    // Days of selected month: 1, 2, 3, ... 28/29/30/31
    final selectedDate = widget.selectedDate ?? DateTime.now();
    final lastOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final daysInMonth = lastOfMonth.day;

    _filledDataPoints = [];
    _labels = [];

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(selectedDate.year, selectedDate.month, day);
      final existing = widget.dataPoints.where((p) {
        if (p.timestamp != null) {
          return p.timestamp!.day == day &&
                 p.timestamp!.month == selectedDate.month &&
                 p.timestamp!.year == selectedDate.year;
        }
        final t = DateTime.fromMillisecondsSinceEpoch(p.x.toInt());
        return t.day == day &&
               t.month == selectedDate.month &&
               t.year == selectedDate.year;
      }).firstOrNull;

      _filledDataPoints.add(ChartDataPoint(
        x: date.millisecondsSinceEpoch.toDouble(),
        y: existing?.y ?? 0,
        timestamp: date,
      ));
      _labels.add('$day');
    }
  }

  void _prepareYearData(AppLocalizations l10n) {
    // 12 months: Jan, Feb, Mar, ... Dec
    final monthNames = [
      l10n.monthJan, l10n.monthFeb, l10n.monthMar, l10n.monthApr,
      l10n.monthMay, l10n.monthJun, l10n.monthJul, l10n.monthAug,
      l10n.monthSep, l10n.monthOct, l10n.monthNov, l10n.monthDec
    ];
    final selectedDate = widget.selectedDate ?? DateTime.now();

    _filledDataPoints = [];
    _labels = [];

    for (int month = 1; month <= 12; month++) {
      final date = DateTime(selectedDate.year, month, 1);
      // For weather data, we average values for the month (not sum like power)
      final monthData = widget.dataPoints.where((p) {
        if (p.timestamp != null) {
          return p.timestamp!.month == month && p.timestamp!.year == selectedDate.year;
        }
        final t = DateTime.fromMillisecondsSinceEpoch(p.x.toInt());
        return t.month == month && t.year == selectedDate.year;
      });

      double avgValue = 0;
      if (monthData.isNotEmpty) {
        avgValue = monthData.fold<double>(0, (acc, p) => acc + p.y) / monthData.length;
      }

      _filledDataPoints.add(ChartDataPoint(
        x: date.millisecondsSinceEpoch.toDouble(),
        y: avgValue,
        timestamp: date,
      ));
      _labels.add(monthNames[month - 1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    _prepareData(l10n);

    if (kDebugMode) {
      debugPrint('LineChartWidget: ${_filledDataPoints.length} data points, rangeType: ${widget.rangeType}');
    }

    if (_filledDataPoints.isEmpty) {
      return Center(
        child: Text(
          l10n.noDataAvailable,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final spots = _filledDataPoints
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.y))
        .toList();

    final minY = _filledDataPoints.map((p) => p.y).reduce((a, b) => a < b ? a : b);
    final maxY = _filledDataPoints.map((p) => p.y).reduce((a, b) => a > b ? a : b);

    // Handle case where all values are the same (including all zeros)
    final range = maxY - minY;
    final double effectiveMinY;
    final double effectiveMaxY;

    if (range == 0) {
      // All values are the same - create a reasonable range around the value
      if (minY == 0) {
        // All zeros - show 0 to 10 range
        effectiveMinY = 0;
        effectiveMaxY = 10;
      } else {
        // All same non-zero value - show ±20% range
        final padding = minY.abs() * 0.2;
        effectiveMinY = minY - padding;
        effectiveMaxY = maxY + padding;
      }
    } else {
      // Normal case with varying values
      final padding = range * 0.1;
      effectiveMinY = minY - padding;
      effectiveMaxY = maxY + padding;
    }

    final horizontalInterval = _calculateInterval(effectiveMinY, effectiveMaxY);
    final labelInterval = _calculateLabelInterval(_filledDataPoints.length);

    try {
      return _buildChart(spots, effectiveMinY, effectiveMaxY, horizontalInterval, labelInterval, l10n);
    } catch (e, stackTrace) {
      debugPrint('LineChartWidget ERROR: $e');
      debugPrint('LineChartWidget STACK: $stackTrace');
      return Center(
        child: Text(
          'Chart error: $e',
          style: const TextStyle(color: Colors.red, fontSize: 12),
        ),
      );
    }
  }

  Widget _buildChart(
    List<FlSpot> spots,
    double effectiveMinY,
    double effectiveMaxY,
    double horizontalInterval,
    double labelInterval,
    AppLocalizations l10n,
  ) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: widget.showGrid,
          drawVerticalLine: false,
          horizontalInterval: horizontalInterval,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.border,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: labelInterval,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= _filledDataPoints.length) {
                  return const SizedBox.shrink();
                }

                // Use pre-computed labels if available
                if (_labels.isNotEmpty && index < _labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _labels[index],
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                // Fallback to timestamp formatting
                final point = _filledDataPoints[index];
                final timestamp = point.timestamp ??
                    DateTime.fromMillisecondsSinceEpoch(point.x.toInt());
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _formatAxisLabel(timestamp, l10n),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: horizontalInterval,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '${value.toStringAsFixed(value.abs() < 10 ? 1 : 0)}${widget.unit}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: effectiveMinY,
        maxY: effectiveMaxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: widget.lineColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: widget.showDots),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  widget.lineColor.withValues(alpha: 0.3),
                  widget.lineColor.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.spotIndex;
                if (index < 0 || index >= _filledDataPoints.length) {
                  return null;
                }
                final point = _filledDataPoints[index];
                final timestamp = point.timestamp ??
                    DateTime.fromMillisecondsSinceEpoch(point.x.toInt());

                String timeLabel;
                if (_labels.isNotEmpty && index < _labels.length) {
                  timeLabel = _labels[index];
                } else {
                  timeLabel = Formatters.time(timestamp);
                }

                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)}${widget.unit}\n$timeLabel',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
      ),
    );
  }

  double _calculateInterval(double min, double max) {
    final range = max - min;
    if (range <= 0) return 1;
    if (range <= 10) return 2;
    if (range <= 50) return 10;
    if (range <= 100) return 20;
    if (range <= 500) return 100;
    return (range / 5).ceilToDouble();
  }

  double _calculateLabelInterval(int count) {
    if (count <= 6) return 1;
    if (count <= 12) return 2;
    if (count <= 24) return 4;
    return (count / 6).ceilToDouble();
  }

  String _formatAxisLabel(DateTime timestamp, AppLocalizations l10n) {
    if (widget.rangeType != null) {
      switch (widget.rangeType!) {
        case DateRangeType.day:
          return '${timestamp.hour}h';
        case DateRangeType.week:
          final dayNames = [
            l10n.dayMon, l10n.dayTue, l10n.dayWed, l10n.dayThu,
            l10n.dayFri, l10n.daySat, l10n.daySun
          ];
          return dayNames[timestamp.weekday - 1];
        case DateRangeType.month:
          return '${timestamp.day}';
        case DateRangeType.year:
          final monthNames = [
            l10n.monthJan, l10n.monthFeb, l10n.monthMar, l10n.monthApr,
            l10n.monthMay, l10n.monthJun, l10n.monthJul, l10n.monthAug,
            l10n.monthSep, l10n.monthOct, l10n.monthNov, l10n.monthDec
          ];
          return monthNames[timestamp.month - 1];
      }
    }
    return Formatters.time(timestamp);
  }
}
