import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// A simple sparkline chart for showing trends in a compact space
class SparklineWidget extends StatelessWidget {
  final List<double> data;
  final Color lineColor;
  final double height;
  final bool showGradient;
  final bool showDots;
  final bool showHourLabels;

  const SparklineWidget({
    super.key,
    required this.data,
    required this.lineColor,
    this.height = 40,
    this.showGradient = true,
    this.showDots = false,
    this.showHourLabels = false,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || data.length < 2) {
      return SizedBox(height: height + (showHourLabels ? 20 : 0));
    }

    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    final minY = data.reduce((a, b) => a < b ? a : b);
    final maxY = data.reduce((a, b) => a > b ? a : b);

    // Handle case where all values are the same
    final range = maxY - minY;
    final double effectiveMinY;
    final double effectiveMaxY;

    if (range == 0) {
      final padding = minY.abs() * 0.1;
      effectiveMinY = minY - (padding == 0 ? 1 : padding);
      effectiveMaxY = maxY + (padding == 0 ? 1 : padding);
    } else {
      final padding = range * 0.1;
      effectiveMinY = minY - padding;
      effectiveMaxY = maxY + padding;
    }

    // Calculate label interval based on data length
    final labelInterval = _calculateLabelInterval(data.length);

    return SizedBox(
      height: height + (showHourLabels ? 20 : 0),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            show: showHourLabels,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: showHourLabels,
                reservedSize: 20,
                interval: labelInterval,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${index}h',
                      style: TextStyle(
                        fontSize: 9,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
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
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: lineColor,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: showDots,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 2,
                    color: lineColor,
                    strokeWidth: 0,
                  );
                },
              ),
              belowBarData: showGradient
                  ? BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          lineColor.withValues(alpha: 0.3),
                          lineColor.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    )
                  : BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateLabelInterval(int count) {
    if (count <= 6) return 1;
    if (count <= 12) return 2;
    if (count <= 24) return 4;
    return (count / 6).ceilToDouble();
  }
}
