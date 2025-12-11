import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// A simple sparkline chart for showing trends in a compact space
class SparklineWidget extends StatelessWidget {
  final List<double> data;
  final Color lineColor;
  final double height;
  final bool showGradient;

  const SparklineWidget({
    super.key,
    required this.data,
    required this.lineColor,
    this.height = 40,
    this.showGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || data.length < 2) {
      return SizedBox(height: height);
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

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
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
              dotData: const FlDotData(show: false),
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
}
