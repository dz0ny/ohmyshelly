import 'package:intl/intl.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';

class Formatters {
  Formatters._();

  // Power formatting
  static String power(double watts) {
    if (watts >= 1000) {
      return '${(watts / 1000).toStringAsFixed(1)} kW';
    }
    return '${watts.toStringAsFixed(1)} W';
  }

  static String energy(double wattHours) {
    if (wattHours >= 1000) {
      return '${(wattHours / 1000).toStringAsFixed(2)} kWh';
    }
    return '${wattHours.toStringAsFixed(0)} Wh';
  }

  static String voltage(double volts) {
    return '${volts.toStringAsFixed(0)} V';
  }

  static String current(double amps) {
    return '${amps.toStringAsFixed(2)} A';
  }

  // Temperature formatting
  static String temperature(double celsius) {
    return '${celsius.toStringAsFixed(1)}\u00B0C';
  }

  static String temperatureShort(double celsius) {
    return '${celsius.round()}\u00B0';
  }

  // Weather formatting
  static String humidity(double percent) {
    return '${percent.toStringAsFixed(0)}%';
  }

  static String pressure(double hPa) {
    return '${hPa.toStringAsFixed(0)} hPa';
  }

  static String uvIndex(double index) {
    return index.toStringAsFixed(1);
  }

  static String windSpeed(double kmh) {
    return '${kmh.toStringAsFixed(1)} km/h';
  }

  static String windDirection(double degrees, [AppLocalizations? l10n]) {
    final index = ((degrees + 22.5) / 45).floor() % 8;
    if (l10n != null) {
      final directions = [
        l10n.directionN,
        l10n.directionNE,
        l10n.directionE,
        l10n.directionSE,
        l10n.directionS,
        l10n.directionSW,
        l10n.directionW,
        l10n.directionNW,
      ];
      return directions[index];
    }
    // Fallback to English
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return directions[index];
  }

  static String precipitation(double mm) {
    return '${mm.toStringAsFixed(1)} mm';
  }

  static String illuminance(double luxValue) {
    if (luxValue >= 1000) {
      return '${(luxValue / 1000).toStringAsFixed(1)}k lux';
    }
    return '${luxValue.toStringAsFixed(0)} lux';
  }

  static String solarIrradiance(double wm2) {
    return '${wm2.toStringAsFixed(0)} W/m\u00B2';
  }

  static String battery(double percent) {
    return '${percent.toStringAsFixed(0)}%';
  }

  // Date/Time formatting
  static String dateTime(DateTime dt) {
    return DateFormat('MMM d, y HH:mm').format(dt);
  }

  static String date(DateTime dt) {
    return DateFormat('MMM d, y').format(dt);
  }

  static String time(DateTime dt) {
    return DateFormat('HH:mm').format(dt);
  }

  static String timeAgo(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return date(dt);
    }
  }

  static String chartAxisTime(DateTime dt, String interval) {
    switch (interval) {
      case 'hour':
        return DateFormat('HH:mm').format(dt);
      case 'day':
        return DateFormat('HH:00').format(dt);
      case 'month':
        return DateFormat('d').format(dt);
      case 'year':
        return DateFormat('MMM').format(dt);
      default:
        return DateFormat('HH:mm').format(dt);
    }
  }
}
