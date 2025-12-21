import 'package:flutter/material.dart';
import '../../core/utils/responsive_utils.dart';
import '../../data/models/device.dart';
import '../../providers/device_provider.dart';
import '../devices/power_device/power_device_dashboard_card.dart';
import '../devices/weather_station/weather_station_dashboard_card.dart';

/// A reusable responsive grid view for displaying devices.
/// Handles tablet grid layout vs phone list layout automatically.
/// Groups consecutive devices by type for efficient display.
class DeviceGridView extends StatelessWidget {
  final List<Device> devices;
  final DeviceProvider deviceProvider;
  final Widget? footer;

  const DeviceGridView({
    super.key,
    required this.devices,
    required this.deviceProvider,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = !constraints.isCompact;
        final powerColumns = constraints.powerDeviceColumns;

        // Group consecutive devices by type for efficient grid layout
        final sections = _groupDevicesByType(devices);

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sections.length + (footer != null ? 1 : 0),
          itemBuilder: (context, sectionIndex) {
            // Last item is the footer (if provided)
            if (sectionIndex == sections.length) {
              return footer!;
            }

            final section = sections[sectionIndex];

            // Weather stations: full width in portrait, constrained in landscape
            if (section.isWeatherSection) {
              // Only constrain width in landscape mode (3+ columns)
              final constrainWidth = isTablet && powerColumns >= 3;
              // Account for ListView padding (16px each side)
              final availableWidth = constraints.maxWidth - 32;
              final weatherMaxWidth = availableWidth * 0.5;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: section.devices.map((device) {
                  final status = deviceProvider.getStatus(device.id);
                  final weatherCard = WeatherStationDashboardCard(
                    device: device,
                    status: status?.weatherStatus,
                    temperatureHistory:
                        deviceProvider.getTemperatureHistory(device.id),
                    humidityHistory:
                        deviceProvider.getHumidityHistory(device.id),
                    todayRainTotal:
                        deviceProvider.getTodayRainTotal(device.id),
                    currentRainIntensity:
                        deviceProvider.getCurrentRainIntensity(device.id),
                    windTrend: deviceProvider.getWindTrend(device.id),
                    recentWindSpeeds:
                        deviceProvider.getRecentWindSpeeds(device.id),
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: constrainWidth
                        ? ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: weatherMaxWidth),
                            child: weatherCard,
                          )
                        : weatherCard,
                  );
                }).toList(),
              );
            }

            // Power devices: always use grid (2 columns on phone, more on tablet)
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildPowerDeviceGrid(
                section.devices,
                powerColumns,
                constraints.maxWidth,
              ),
            );
          },
        );
      },
    );
  }

  /// Group consecutive devices by type (weather vs power)
  List<_DeviceSection> _groupDevicesByType(List<Device> devices) {
    if (devices.isEmpty) return [];

    final sections = <_DeviceSection>[];
    var currentDevices = <Device>[];
    var currentIsWeather = devices.first.isWeatherStation;

    for (final device in devices) {
      final isWeather = device.isWeatherStation;
      if (isWeather != currentIsWeather) {
        // Type changed, save current section
        if (currentDevices.isNotEmpty) {
          sections.add(_DeviceSection(currentDevices, currentIsWeather));
        }
        currentDevices = [device];
        currentIsWeather = isWeather;
      } else {
        currentDevices.add(device);
      }
    }

    // Add final section
    if (currentDevices.isNotEmpty) {
      sections.add(_DeviceSection(currentDevices, currentIsWeather));
    }

    return sections;
  }

  /// Build a responsive grid for power devices
  Widget _buildPowerDeviceGrid(List<Device> devices, int columns, double maxWidth) {
    // Calculate aspect ratio based on actual card width
    // Card content needs ~140px height minimum
    final cardWidth = (maxWidth - 32 - (columns - 1) * 12) / columns;
    // Use square cards for phone (narrow), wider for tablet
    final aspectRatio = cardWidth < 200 ? 1.0 : (columns == 2 ? 2.2 : 1.8);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        final status = deviceProvider.getStatus(device.id);
        return PowerDeviceDashboardCard(
          device: device,
          status: status?.powerStatus,
          actionLog: deviceProvider.getActionLog(device.id),
        );
      },
    );
  }
}

/// Helper class to group consecutive devices of the same type
class _DeviceSection {
  final List<Device> devices;
  final bool isWeatherSection;

  _DeviceSection(this.devices, this.isWeatherSection);
}
