import 'package:flutter/widgets.dart';

/// Breakpoint constants following Material Design guidelines
class Breakpoints {
  Breakpoints._();

  /// Compact width (phones)
  static const double compact = 600;

  /// Medium width (tablets portrait)
  static const double medium = 840;

  /// Expanded width (tablets landscape / desktop)
  static const double expanded = 1200;
}

/// Extension on BoxConstraints for responsive layout calculations
extension ResponsiveConstraints on BoxConstraints {
  /// Whether the available width is phone-sized (< 600px)
  bool get isCompact => maxWidth < Breakpoints.compact;

  /// Whether the available width is tablet-sized (600-1199px)
  bool get isMedium =>
      maxWidth >= Breakpoints.compact && maxWidth < Breakpoints.expanded;

  /// Whether the available width is large tablet/desktop (>= 1200px)
  bool get isExpanded => maxWidth >= Breakpoints.expanded;

  /// Number of columns for power device grid on dashboard
  /// - Phone: 2 columns
  /// - Tablet portrait: 2 columns
  /// - Tablet landscape: 3 columns
  /// - Large tablet: 4 columns
  int get powerDeviceColumns {
    if (maxWidth >= Breakpoints.expanded) return 4;
    if (maxWidth >= Breakpoints.medium) return 3;
    return 2;
  }

  /// Number of columns for weather station grid on dashboard
  /// - Phone: 1 column (full width)
  /// - Tablet+: 2 columns
  int get weatherStationColumns {
    if (maxWidth >= Breakpoints.compact) return 2;
    return 1;
  }

  /// Number of columns for device list
  /// - Phone: 1 column
  /// - Tablet: 2 columns
  /// - Large tablet: 3 columns
  int get deviceListColumns {
    if (maxWidth >= Breakpoints.expanded) return 3;
    if (maxWidth >= Breakpoints.compact) return 2;
    return 1;
  }

  /// Number of columns for stat tile grids
  /// - Phone: 2 columns
  /// - Tablet: 3 columns
  /// - Large tablet: 4 columns
  int get statTileColumns {
    if (maxWidth >= Breakpoints.expanded) return 4;
    if (maxWidth >= Breakpoints.compact) return 3;
    return 2;
  }
}
