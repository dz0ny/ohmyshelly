# OhMyShelly - Flutter Smart Home App

## IMPORTANT: Build Instructions

**DO NOT run build commands directly.** The user will run all build commands manually.

Only use `flutter analyze` for checking code issues. For everything else, inform the user to run the appropriate `make` command.

## Makefile Commands

```bash
make help          # Show all available commands
make deps          # Install dependencies (flutter pub get)
make analyze       # Run Flutter analyze
make test          # Run tests
make icon          # Generate app icons from icon.png
make version       # Show current and next version
make bump          # Bump version in pubspec.yaml
make build         # Build release APK (auto-bumps version)
make build-no-bump # Build release APK without bumping version
make release       # Build APK + create GitHub release + iOS TestFlight
make release-android # Build APK + create GitHub release (Android only)
make release-ios   # Build iOS and upload to TestFlight
make clean         # Clean build artifacts
make run           # Run app in development mode
make build-all     # Build for Android and iOS
```

## Project Overview

A user-friendly Flutter app for managing Shelly smart home devices. Features authentication, device management, live dashboard, and statistics with charts.

## Project Structure

```
lib/
├── main.dart                     # Entry point with Provider setup
├── core/
│   ├── constants/                # Colors, strings, icons
│   ├── theme/                    # App theme (Material 3)
│   └── utils/                    # Formatters, device type helpers
├── data/
│   ├── models/                   # User, Device, Statistics models
│   └── services/                 # API, Auth, Storage services
├── providers/                    # State management (Provider)
│   ├── auth_provider.dart        # Authentication state
│   ├── device_provider.dart      # Device list & status
│   ├── dashboard_provider.dart   # Aggregated dashboard data
│   └── statistics_provider.dart  # Chart data
├── screens/                      # Full-page screens
│   ├── splash/                   # Splash screen
│   ├── onboarding/               # Welcome screens
│   ├── auth/                     # Login screen
│   ├── home/                     # Main tabs (Dashboard first, Devices second)
│   ├── device_detail/            # Device detail screens
│   └── statistics/               # Charts and history
├── widgets/                      # Reusable components
│   ├── common/                   # Loading, error, empty states
│   ├── cards/                    # Device cards
│   ├── controls/                 # Toggle, stat tiles
│   ├── charts/                   # Line and bar charts (fl_chart)
│   ├── devices/                  # Device-specific widgets
│   │   ├── power_device/         # Power switch cards and details
│   │   ├── weather_station/      # Weather station cards and details
│   │   └── gateway/              # Gateway cards and details
│   └── dashboard/                # Dashboard widgets
└── router/                       # GoRouter navigation
```

## Key Technologies

- **State Management**: Provider
- **Navigation**: GoRouter
- **Charts**: fl_chart (line charts for hourly data, bar charts for daily/weekly/monthly/yearly)
- **Secure Storage**: flutter_secure_storage
- **HTTP**: http package
- **Icons**: flutter_launcher_icons (run `make icon` to generate)

## API Endpoints

The app connects to Shelly Cloud API:

- **Login**: `POST https://api.shelly.cloud/auth/login`
- **Device List**: `GET {user_api_url}/interface/device/list`
- **All Status**: `GET {user_api_url}/device/all_status`
- **Toggle Device**: `POST {user_api_url}/device/relay/control`
- **Power Stats**: `GET {user_api_url}/v2/statistics/power-consumption`
- **Weather Stats**: `GET {user_api_url}/v2/statistics/weather-station`

Statistics API uses `date_range=custom` with `date_from` and `date_to` parameters.

## Device Types Supported

| Type | Code Pattern | Features |
|------|-------------|----------|
| Smart Plug | S3PL-* | Power, voltage, current, temperature, ON/OFF toggle |
| Weather Station | SBWS-* | Temperature, humidity, pressure, UV, wind, rain |
| Gateway | SNGW-* | Connection status |

## Statistics Date Ranges

| Range | Period | Chart Type | X-axis Labels |
|-------|--------|------------|---------------|
| Today | Start to end of today | Line chart | Hours (0h, 1h, ... 23h) |
| Week | This week (Mon-Sun) | Bar chart | Day names (Mon, Tue, ...) |
| Month | 1st to last day of month | Bar chart | Day numbers (1, 2, ... 31) |
| Year | Jan 1 to Dec 31 | Bar chart | Month names (Jan, Feb, ...) |

For yearly view, daily data is summed by month.

## Chart Data Pre-population (IMPORTANT)

All charts MUST pre-populate their x-axis with zero values for the complete expected range before overlaying actual API data. This ensures consistent chart display regardless of missing data.

### Implementation Pattern

The `BarChartWidget` (`lib/widgets/charts/bar_chart_widget.dart`) demonstrates the correct approach:

1. **Day View (24 hours)**: Create 24 slots (0h-23h), fill with zeros, overlay matching API data
2. **Week View (7 days)**: Create 7 slots (Mon-Sun), fill with zeros, overlay matching API data
3. **Month View (28-31 days)**: Create slots for each day of month, fill with zeros, overlay matching API data
4. **Year View (12 months)**: Create 12 slots (Jan-Dec), fill with zeros, SUM daily data into monthly buckets

### Code Example (Week)

```dart
void _prepareWeekData() {
  const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final now = DateTime.now();
  final daysFromMonday = now.weekday - 1;
  final monday = DateTime(now.year, now.month, now.day - daysFromMonday);

  _filledDataPoints = [];
  _labels = [];

  for (int i = 0; i < 7; i++) {
    final date = DateTime(monday.year, monday.month, monday.day + i);
    // Find matching data point from API response
    final existing = widget.dataPoints.where(
      (p) => p.timestamp.day == date.day &&
             p.timestamp.month == date.month &&
             p.timestamp.year == date.year
    ).firstOrNull;

    // Use existing value or default to 0
    _filledDataPoints.add(BarChartDataPoint(
      y: existing?.y ?? 0,
      timestamp: date,
    ));
    _labels.add(dayNames[i]);
  }
}
```

### Key Rules

- ALWAYS create the full expected range first (24 hours, 7 days, N days in month, 12 months)
- ALWAYS default missing data points to `0`
- For yearly view, SUM all daily values into monthly buckets (not average)
- Match API data by comparing date components (day, month, year) not raw timestamps
- Labels array must match data points array in order and length

## Weather Charts (Line Charts)

Weather statistics use **line charts** (`LineChartWidget`) for all date ranges because weather data is continuous sensor readings (temperature, humidity, pressure, etc.).

### Line Chart Pre-population

`LineChartWidget` (`lib/widgets/charts/line_chart_widget.dart`) now supports the same zero-filling pattern as `BarChartWidget`:

```dart
LineChartWidget(
  dataPoints: stats.dataPoints
      .map((p) => ChartDataPoint(
            x: p.timestamp.millisecondsSinceEpoch.toDouble(),
            y: p.avgTemperature,
            timestamp: p.timestamp,  // Include timestamp for matching
          ))
      .toList(),
  lineColor: AppColors.weatherStation,
  unit: '°C',
  rangeType: rangeType,        // DateRangeType.day/week/month/year
  selectedDate: selectedDate,   // The selected date for the range
)
```

**Key differences from BarChartWidget:**
- For **yearly view**, values are **AVERAGED** per month (not summed) - appropriate for sensor readings
- Line charts show continuous data with curved lines and gradient fill
- Supports both new API (`rangeType` + `selectedDate`) and legacy API (raw data points)

### Chart Usage by Metric

| Metric | Unit | Color | Notes |
|--------|------|-------|-------|
| Temperature | °C | `AppColors.weatherStation` | Shows `avgTemperature` |
| Humidity | % | `AppColors.info` | Direct value |
| Pressure | hPa | Purple (#7E57C2) | Shows `avgPressure` |
| UV Index | (none) | `AppColors.warning` | Direct value |
| Rain | mm | `AppColors.info` | Shows `precipitation` |
| Solar | W/m² | Orange (#FF9800) | Converted from lux: `illuminance / 120` |

### Data Flow

1. API returns `WeatherStatistics` with `dataPoints` array
2. Each `WeatherDataPoint` has timestamp + all sensor values
3. Chart extracts specific metric with timestamp: `dataPoints.map((p) => ChartDataPoint(x: timestamp, y: p.avgTemperature, timestamp: p.timestamp))`
4. `LineChartWidget` pre-populates full range with zeros, then overlays API data
5. Renders with appropriate `unit`, `lineColor`, `rangeType`, and `selectedDate`

### Summary Cards

Each weather metric has a dedicated summary card showing:
- **Temperature**: Min, Max, Average
- **Humidity**: Min, Max, Average
- **Pressure**: Min, Max, Average
- **UV Index**: Peak, Average
- **Rain**: Total, Peak
- **Solar**: Peak, Average

### Implementation Location

Weather chart logic is in `lib/screens/statistics/statistics_screen.dart`:
- `_buildMetricChart()` - Single metric view with chart + summary
- `_buildAllWeatherCharts()` - Overview with temperature chart + combined summary

## Code Style

- Use friendly, non-technical language in UI (e.g., "Power" not "apower")
- Material Design 3 with Shelly blue primary color (`#4A90D9`)
- Auto-refresh every 30 seconds + pull-to-refresh
- Provider pattern for state management
- Use `WidgetsBinding.instance.addPostFrameCallback` to defer state changes in initState
- Dashboard tab is first (shows live values, no toggle), Devices tab is second (shows toggle)
- In debug mode, long-press device cards to copy JSON status
- **No icons in segmented buttons** - Keep SegmentedButton segments text-only for cleaner UI

## Dark Mode Support (IMPORTANT)

The app supports light/dark/system theme modes. **NEVER use hardcoded `AppColors` for text or backgrounds** - always use theme-aware `ColorScheme` colors.

### Color Usage Rules

| Use Case | CORRECT | WRONG |
|----------|---------|-------|
| Primary text | `colorScheme.onSurface` | `AppColors.textPrimary` |
| Secondary text | `colorScheme.onSurfaceVariant` | `AppColors.textSecondary` |
| Hint/disabled text | `colorScheme.outline` | `AppColors.textHint` |
| Card/tile background | `colorScheme.surfaceContainerHighest` | `AppColors.surfaceVariant` |
| Borders | `colorScheme.outlineVariant` | `AppColors.border` |
| Chevron icons | `colorScheme.outline` | `AppColors.textHint` |

### Implementation Pattern

```dart
@override
Widget build(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;

  return Container(
    decoration: BoxDecoration(
      color: colorScheme.surfaceContainerHighest,  // NOT AppColors.surfaceVariant
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      'Label',
      style: TextStyle(
        color: colorScheme.onSurfaceVariant,  // NOT AppColors.textSecondary
      ),
    ),
  );
}
```

### When to Use AppColors

AppColors should ONLY be used for:
- **Device type colors**: `AppColors.powerDevice`, `AppColors.weatherStation`, `AppColors.gateway`
- **Status colors**: `AppColors.deviceOn`, `AppColors.deviceOff`, `AppColors.success`, `AppColors.error`, `AppColors.warning`, `AppColors.info`
- **Primary brand color**: `AppColors.primary` (for accents that should stay consistent)

### ColorScheme Reference

| ColorScheme Property | Light Mode | Dark Mode | Use For |
|---------------------|------------|-----------|---------|
| `onSurface` | `#212121` | `#F5F5F5` | Primary text, titles |
| `onSurfaceVariant` | `#757575` | `#B0B0B0` | Secondary text, labels |
| `outline` | `#757575` | `#808080` | Hints, disabled, icons |
| `outlineVariant` | `#E0E0E0` | `#404040` | Borders, dividers |
| `surfaceContainerHighest` | `#E8E8E8` | `#353535` | Inner tiles, stat boxes |
| `surfaceContainerHigh` | `#F0F0F0` | `#282828` | Elevated surfaces |
| `surface` | `#FFFFFF` | `#1A1A1A` | Cards, dialogs |

### Files That Need Theme-Aware Colors

When editing these files, ensure all colors use `colorScheme`:
- `lib/screens/statistics/statistics_screen.dart` - Charts and date picker
- `lib/screens/home/devices_tab.dart` - Device list
- `lib/screens/home/scenes_tab.dart` - Scenes list
- `lib/widgets/common/date_range_picker.dart` - Date selector
- `lib/widgets/cards/*.dart` - All card widgets
- `lib/widgets/devices/**/*.dart` - Device-specific widgets

## Debug Features

- `ApiService.enableResponseLogging = true` to log full API responses
- Device type detection logs in debug mode
- Chart data point logs in debug mode
