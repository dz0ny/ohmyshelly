import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../common/date_range_picker.dart';

class BarChartDataPoint {
  final double y;
  final DateTime timestamp;

  BarChartDataPoint({
    required this.y,
    required this.timestamp,
  });
}

class BarChartWidget extends StatefulWidget {
  final List<BarChartDataPoint> dataPoints;
  final Color barColor;
  final String unit;
  final DateRangeType rangeType;

  const BarChartWidget({
    super.key,
    required this.dataPoints,
    required this.barColor,
    this.unit = '',
    required this.rangeType,
  });

  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget> {
  int touchedIndex = -1;
  late List<BarChartDataPoint> _filledDataPoints;
  late List<String> _labels;
  String? _lastLocale;

  @override
  void initState() {
    super.initState();
    _filledDataPoints = [];
    _labels = [];
  }

  @override
  void didUpdateWidget(BarChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dataPoints != widget.dataPoints ||
        oldWidget.rangeType != widget.rangeType) {
      _lastLocale = null; // Force rebuild
    }
  }

  void _prepareData(AppLocalizations l10n) {
    final currentLocale = l10n.localeName;
    if (_lastLocale == currentLocale && _filledDataPoints.isNotEmpty) {
      return; // Already prepared for this locale
    }
    _lastLocale = currentLocale;

    switch (widget.rangeType) {
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _filledDataPoints = [];
    _labels = [];

    for (int hour = 0; hour < 24; hour++) {
      final timestamp = DateTime(today.year, today.month, today.day, hour);
      final existing = widget.dataPoints.where(
        (p) => p.timestamp.hour == hour &&
               p.timestamp.day == today.day &&
               p.timestamp.month == today.month
      ).firstOrNull;

      _filledDataPoints.add(BarChartDataPoint(
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
    final now = DateTime.now();
    final daysFromMonday = now.weekday - 1;
    final monday = DateTime(now.year, now.month, now.day - daysFromMonday);

    _filledDataPoints = [];
    _labels = [];

    for (int i = 0; i < 7; i++) {
      final date = DateTime(monday.year, monday.month, monday.day + i);
      final existing = widget.dataPoints.where(
        (p) => p.timestamp.day == date.day &&
               p.timestamp.month == date.month &&
               p.timestamp.year == date.year
      ).firstOrNull;

      _filledDataPoints.add(BarChartDataPoint(
        y: existing?.y ?? 0,
        timestamp: date,
      ));
      _labels.add(dayNames[i]);
    }
  }

  void _prepareMonthData() {
    // Days of current month: 1, 2, 3, ... 28/29/30/31
    final now = DateTime.now();
    final lastOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysInMonth = lastOfMonth.day;

    _filledDataPoints = [];
    _labels = [];

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(now.year, now.month, day);
      final existing = widget.dataPoints.where(
        (p) => p.timestamp.day == day &&
               p.timestamp.month == now.month &&
               p.timestamp.year == now.year
      ).firstOrNull;

      _filledDataPoints.add(BarChartDataPoint(
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
    final now = DateTime.now();

    _filledDataPoints = [];
    _labels = [];

    for (int month = 1; month <= 12; month++) {
      final date = DateTime(now.year, month, 1);
      // Sum all data points for this month
      final monthData = widget.dataPoints.where(
        (p) => p.timestamp.month == month && p.timestamp.year == now.year
      );
      final sum = monthData.fold<double>(0, (acc, p) => acc + p.y);

      _filledDataPoints.add(BarChartDataPoint(
        y: sum,
        timestamp: date,
      ));
      _labels.add(monthNames[month - 1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    _prepareData(l10n);

    if (_filledDataPoints.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      return Center(
        child: Text(
          l10n.noDataAvailable,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    return BarChart(
      mainBarData(colorScheme),
      duration: const Duration(milliseconds: 250),
    );
  }

  BarChartData mainBarData(ColorScheme colorScheme) {
    final maxY = _filledDataPoints.map((p) => p.y).reduce((a, b) => a > b ? a : b);
    // Calculate nice round maxY and interval to avoid label overlap
    final (effectiveMaxY, interval) = _calculateNiceScale(maxY);

    return BarChartData(
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipHorizontalAlignment: FLHorizontalAlignment.center,
          tooltipMargin: 8,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            if (groupIndex >= _filledDataPoints.length) return null;
            final point = _filledDataPoints[groupIndex];
            return BarTooltipItem(
              '${_labels[groupIndex]}\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: Formatters.energy(point.y),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) => _getBottomTitles(value, meta, colorScheme),
            reservedSize: 30,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: interval,
            getTitlesWidget: (value, meta) => _getLeftTitles(value, meta, colorScheme),
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: _buildBarGroups(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: interval,
        getDrawingHorizontalLine: (value) => FlLine(
          color: AppColors.border,
          strokeWidth: 1,
        ),
      ),
      maxY: effectiveMaxY,
      minY: 0,
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(_filledDataPoints.length, (i) {
      return _makeGroupData(
        i,
        _filledDataPoints[i].y,
        isTouched: i == touchedIndex,
      );
    });
  }

  /// Calculate nice round scale for y-axis to avoid label overlap
  (double maxY, double interval) _calculateNiceScale(double dataMax) {
    if (dataMax == 0) return (10.0, 2.0);

    // Find a nice interval (1, 2, 5, 10, 20, 50, etc.)
    final rough = dataMax / 4; // We want ~4 intervals
    final magnitude = _magnitude(rough);
    final residual = rough / magnitude;

    double niceInterval;
    if (residual <= 1.5) {
      niceInterval = magnitude;
    } else if (residual <= 3) {
      niceInterval = 2 * magnitude;
    } else if (residual <= 7) {
      niceInterval = 5 * magnitude;
    } else {
      niceInterval = 10 * magnitude;
    }

    // Round maxY up to the next nice interval
    final niceMax = (dataMax / niceInterval).ceil() * niceInterval;

    return (niceMax.toDouble(), niceInterval);
  }

  double _magnitude(double value) {
    if (value == 0) return 1;
    final exp = (math.log(value.abs()) / math.ln10).floor();
    return math.pow(10, exp).toDouble();
  }

  BarChartGroupData _makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
  }) {
    final touchedColor = widget.barColor.withValues(alpha: 1.0);
    final normalColor = widget.barColor.withValues(alpha: 0.8);
    final maxY = _filledDataPoints.map((p) => p.y).reduce((a, b) => a > b ? a : b);
    final (effectiveMaxY, _) = _calculateNiceScale(maxY);

    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y * 1.02 : y,
          color: isTouched ? touchedColor : normalColor,
          width: _calculateBarWidth(),
          borderSide: isTouched
              ? BorderSide(color: touchedColor, width: 2)
              : const BorderSide(color: Colors.transparent, width: 0),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: effectiveMaxY,
            color: AppColors.surfaceVariant.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  double _calculateBarWidth() {
    final count = _filledDataPoints.length;
    if (count <= 7) return 24;
    if (count <= 12) return 18;
    if (count <= 24) return 10;
    return 6;
  }

  Widget _getBottomTitles(double value, TitleMeta meta, ColorScheme colorScheme) {
    final index = value.toInt();
    if (index < 0 || index >= _labels.length) {
      return const SizedBox.shrink();
    }

    // Show fewer labels to prevent overlapping
    final count = _labels.length;
    // Month view (28-31 days): show every 5th day
    if (count > 24 && index % 5 != 0) return const SizedBox.shrink();
    // Day view (24 hours): show every 4th hour (0h, 4h, 8h, 12h, 16h, 20h)
    if (count == 24 && index % 4 != 0) return const SizedBox.shrink();
    // Year view (12 months): show every 2nd month
    if (count == 12 && index % 2 != 0) return const SizedBox.shrink();
    // Week view (7 days): show all

    return SideTitleWidget(
      meta: meta,
      space: 8,
      child: Text(
        _labels[index],
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _getLeftTitles(double value, TitleMeta meta, ColorScheme colorScheme) {
    return SideTitleWidget(
      meta: meta,
      space: 4,
      child: Text(
        _formatYAxisLabel(value),
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 10,
        ),
      ),
    );
  }

  String _formatYAxisLabel(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    if (value >= 10) {
      return value.toStringAsFixed(0);
    }
    if (value >= 1) {
      return value.toStringAsFixed(1);
    }
    if (value > 0) {
      // For very small values (e.g., rain in mm), show 2 decimal places
      return value.toStringAsFixed(2);
    }
    return '0';
  }
}
