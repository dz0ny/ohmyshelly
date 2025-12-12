import 'package:flutter/foundation.dart';

class PowerStatistics {
  final List<PowerDataPoint> dataPoints;
  final double totalConsumption;
  final double averageConsumption;
  final double peakConsumption;
  final String interval;
  final String timezone;

  PowerStatistics({
    required this.dataPoints,
    required this.totalConsumption,
    required this.averageConsumption,
    required this.peakConsumption,
    required this.interval,
    this.timezone = '',
  });

  factory PowerStatistics.fromJson(Map<String, dynamic> json) {
    final historyList = json['history'] as List<dynamic>? ?? [];
    final interval = json['interval'] as String? ?? 'day';
    final timezone = json['timezone'] as String? ?? '';

    final dataPoints = <PowerDataPoint>[];
    for (final item in historyList) {
      final data = item as Map<String, dynamic>;
      // Skip missing data points
      if (data['missing'] == true) continue;

      // Parse UTC timestamp (with Z suffix) and convert to local time
      dataPoints.add(PowerDataPoint(
        timestamp: DateTime.parse(data['datetime'] as String).toLocal(),
        consumption: (data['consumption'] as num?)?.toDouble() ?? 0.0,
        voltage: (data['voltage'] as num?)?.toDouble() ?? 0.0,
        reversed: (data['reversed'] as num?)?.toDouble() ?? 0.0,
        cost: (data['cost'] as num?)?.toDouble() ?? 0.0,
        purpose: data['purpose'] as String?,
      ));
    }

    // Sort by timestamp
    dataPoints.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (dataPoints.isEmpty) {
      return PowerStatistics(
        dataPoints: [],
        totalConsumption: 0,
        averageConsumption: 0,
        peakConsumption: 0,
        interval: interval,
        timezone: timezone,
      );
    }

    final total = dataPoints.fold<double>(0, (sum, p) => sum + p.consumption);
    final average = total / dataPoints.length;
    final peak = dataPoints
        .map((p) => p.consumption)
        .reduce((a, b) => a > b ? a : b);

    return PowerStatistics(
      dataPoints: dataPoints,
      totalConsumption: total,
      averageConsumption: average,
      peakConsumption: peak,
      interval: interval,
      timezone: timezone,
    );
  }

  String get totalDisplay => '${totalConsumption.toStringAsFixed(2)} Wh';
  String get averageDisplay => '${averageConsumption.toStringAsFixed(2)} Wh';
  String get peakDisplay => '${peakConsumption.toStringAsFixed(2)} Wh';
}

class PowerDataPoint {
  final DateTime timestamp;
  final double consumption;
  final double voltage;
  final double reversed;
  final double cost;
  final String? purpose;

  PowerDataPoint({
    required this.timestamp,
    required this.consumption,
    this.voltage = 0,
    this.reversed = 0,
    this.cost = 0,
    this.purpose,
  });

  String get consumptionDisplay => '${consumption.toStringAsFixed(2)} Wh';
  String get voltageDisplay => '${voltage.toStringAsFixed(1)} V';
}

class WeatherStatistics {
  final List<WeatherDataPoint> dataPoints;
  final double minTemperature;
  final double maxTemperature;
  final double avgTemperature;
  final double avgHumidity;
  final double totalPrecipitation;
  final double avgPressure;
  final String interval;
  final String timezone;

  WeatherStatistics({
    required this.dataPoints,
    required this.minTemperature,
    required this.maxTemperature,
    required this.avgTemperature,
    required this.avgHumidity,
    required this.totalPrecipitation,
    required this.avgPressure,
    required this.interval,
    this.timezone = '',
  });

  factory WeatherStatistics.fromJson(Map<String, dynamic> json) {
    final historyList = json['history'] as List<dynamic>? ?? [];
    final interval = json['interval'] as String? ?? 'day';
    final timezone = json['timezone'] as String? ?? '';

    final dataPoints = <WeatherDataPoint>[];
    for (final item in historyList) {
      final data = item as Map<String, dynamic>;
      // Skip missing data points
      if (data['missing'] == true) continue;

      // Parse UTC timestamp (with Z suffix) and convert to local time
      final rawDatetime = data['datetime'] as String;
      final parsedUtc = DateTime.parse(rawDatetime);
      final localTime = parsedUtc.toLocal();

      // Debug: Log first few timestamp conversions
      if (kDebugMode && dataPoints.length < 3) {
        debugPrint('WeatherStats parse: raw=$rawDatetime, parsedUtc=$parsedUtc (isUtc=${parsedUtc.isUtc}), local=$localTime (hour=${localTime.hour})');
      }

      dataPoints.add(WeatherDataPoint(
        timestamp: localTime,
        minTemperature: (data['min_temperature'] as num?)?.toDouble() ?? 0.0,
        maxTemperature: (data['max_temperature'] as num?)?.toDouble() ?? 0.0,
        humidity: (data['humidity'] as num?)?.toDouble() ?? 0.0,
        precipitation: (data['precipitation'] as num?)?.toDouble() ?? 0.0,
        uvIndex: (data['uv'] as num?)?.toDouble() ?? 0.0,
        minPressure: (data['min_pressure'] as num?)?.toDouble() ?? 0.0,
        maxPressure: (data['max_pressure'] as num?)?.toDouble() ?? 0.0,
        illuminance: (data['illuminance'] as num?)?.toDouble() ?? 0.0,
        windSpeed: (data['wind_speed'] as num?)?.toDouble() ?? 0.0,
        windGust: (data['wind_gust'] as num?)?.toDouble() ?? 0.0,
        windDirection: (data['wind_direction'] as num?)?.toDouble() ?? 0.0,
      ));
    }

    // Sort by timestamp
    dataPoints.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (dataPoints.isEmpty) {
      return WeatherStatistics(
        dataPoints: [],
        minTemperature: 0,
        maxTemperature: 0,
        avgTemperature: 0,
        avgHumidity: 0,
        totalPrecipitation: 0,
        avgPressure: 0,
        interval: interval,
        timezone: timezone,
      );
    }

    final minTemp = dataPoints
        .map((p) => p.minTemperature)
        .reduce((a, b) => a < b ? a : b);
    final maxTemp = dataPoints
        .map((p) => p.maxTemperature)
        .reduce((a, b) => a > b ? a : b);
    final avgTemp = dataPoints.fold<double>(
            0, (sum, p) => sum + (p.minTemperature + p.maxTemperature) / 2) /
        dataPoints.length;
    final avgHum =
        dataPoints.fold<double>(0, (sum, p) => sum + p.humidity) /
            dataPoints.length;
    final totalPrecip =
        dataPoints.fold<double>(0, (sum, p) => sum + p.precipitation);
    final avgPress = dataPoints.fold<double>(
            0, (sum, p) => sum + (p.minPressure + p.maxPressure) / 2) /
        dataPoints.length;

    return WeatherStatistics(
      dataPoints: dataPoints,
      minTemperature: minTemp,
      maxTemperature: maxTemp,
      avgTemperature: avgTemp,
      avgHumidity: avgHum,
      totalPrecipitation: totalPrecip,
      avgPressure: avgPress,
      interval: interval,
      timezone: timezone,
    );
  }
}

class WeatherDataPoint {
  final DateTime timestamp;
  final double minTemperature;
  final double maxTemperature;
  final double humidity;
  final double precipitation;
  final double uvIndex;
  final double minPressure;
  final double maxPressure;
  final double illuminance;
  final double windSpeed;
  final double windGust;
  final double windDirection;

  WeatherDataPoint({
    required this.timestamp,
    required this.minTemperature,
    required this.maxTemperature,
    required this.humidity,
    required this.precipitation,
    required this.uvIndex,
    required this.minPressure,
    required this.maxPressure,
    required this.illuminance,
    this.windSpeed = 0.0,
    this.windGust = 0.0,
    this.windDirection = 0.0,
  });

  double get avgTemperature => (minTemperature + maxTemperature) / 2;
  double get avgPressure => (minPressure + maxPressure) / 2;
}

/// Date range for statistics queries
enum DateRange {
  day,    // Today, interval: hour
  week,   // This week (Monday to Sunday), interval: day
  month,  // This month, interval: day
  year,   // This year, interval: month
}

extension DateRangeExtension on DateRange {
  String get displayName {
    switch (this) {
      case DateRange.day:
        return 'Today';
      case DateRange.week:
        return 'Week';
      case DateRange.month:
        return 'Month';
      case DateRange.year:
        return 'Year';
    }
  }

  /// Calculate date range for API call
  ({DateTime from, DateTime to}) getDateRange() {
    final now = DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (this) {
      case DateRange.day:
        // Today: from start of today to end of today
        final startOfToday = DateTime(now.year, now.month, now.day, 0, 0, 0);
        return (from: startOfToday, to: endOfToday);

      case DateRange.week:
        // This week: Monday to Sunday
        // weekday: 1 = Monday, 7 = Sunday
        final daysFromMonday = now.weekday - 1;
        final monday = DateTime(now.year, now.month, now.day - daysFromMonday, 0, 0, 0);
        final sunday = DateTime(monday.year, monday.month, monday.day + 6, 23, 59, 59);
        return (from: monday, to: sunday);

      case DateRange.month:
        // This month: 1st to last day
        final firstOfMonth = DateTime(now.year, now.month, 1, 0, 0, 0);
        final lastOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return (from: firstOfMonth, to: lastOfMonth);

      case DateRange.year:
        // This year: Jan 1 to Dec 31
        final firstOfYear = DateTime(now.year, 1, 1, 0, 0, 0);
        final lastOfYear = DateTime(now.year, 12, 31, 23, 59, 59);
        return (from: firstOfYear, to: lastOfYear);
    }
  }
}
