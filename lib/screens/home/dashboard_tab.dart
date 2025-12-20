import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_icons.dart';
import '../../core/utils/responsive_utils.dart';
import '../../providers/device_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/devices/power_device/power_device_dashboard_card.dart';
import '../../widgets/devices/weather_station/weather_station_dashboard_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_card.dart';
import '../../widgets/common/connectivity_banner.dart';
import '../../data/models/device.dart';
import '../../data/models/device_status.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  bool _isReorderMode = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard),
        actions: [
          if (_isReorderMode)
            TextButton(
              onPressed: () {
                setState(() {
                  _isReorderMode = false;
                });
              },
              child: Text(l10n.reorderDevicesDone),
            ),
          IconButton(
            icon: const Icon(AppIcons.settings),
            tooltip: l10n.settings,
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            icon: const Icon(AppIcons.profile),
            tooltip: l10n.profile,
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: Consumer2<DeviceProvider, SettingsProvider>(
        builder: (context, deviceProvider, settingsProvider, _) {
          if (deviceProvider.isLoading &&
              deviceProvider.state == DeviceLoadState.loading) {
            return LoadingIndicator(message: l10n.loadingDevices);
          }

          if (deviceProvider.state == DeviceLoadState.error &&
              deviceProvider.devices.isEmpty) {
            return ErrorCard(
              message: deviceProvider.error ?? l10n.errorGeneric,
              onRetry: () => deviceProvider.fetchDevices(),
            );
          }

          // Filter out gateways and excluded devices
          final excludedDevices = settingsProvider.dashboardExcludedDevices;
          final allDevices = deviceProvider.devices
              .where((d) => !d.isGateway && !excludedDevices.contains(d.id))
              .toList();

          if (allDevices.isEmpty) {
            return EmptyState(
              icon: AppIcons.dashboard,
              title: l10n.noDevices,
              message: l10n.noDevicesDesc,
            );
          }

          // Sort devices based on saved order
          final displayDevices = _sortDevices(
            allDevices,
            settingsProvider.dashboardDeviceOrder,
          );

          if (_isReorderMode) {
            return _buildReorderableList(
              context,
              displayDevices,
              deviceProvider,
              settingsProvider,
              l10n,
            );
          }

          // Determine connectivity banner type
          final bannerType = _getConnectivityBannerType(deviceProvider);
          final deviceNetworks = deviceProvider.devicesDiscoveredOnNetworks;

          return Column(
            children: [
              // Connectivity banner (if needed)
              if (bannerType != null)
                ConnectivityBanner(
                  type: bannerType,
                  deviceNetworkName:
                      deviceNetworks.isNotEmpty ? deviceNetworks.first : null,
                ),

              // Device grid
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => deviceProvider.refresh(),
                  child: _buildDeviceGrid(
                    context,
                    displayDevices,
                    deviceProvider,
                    l10n,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Determine which connectivity banner to show (if any)
  /// Only shows banner for error states, not informational ones
  ConnectivityBannerType? _getConnectivityBannerType(
      DeviceProvider deviceProvider) {
    // Only show banner for actual problems
    if (deviceProvider.isPhoneOffline) {
      return ConnectivityBannerType.offline;
    }
    if (deviceProvider.isOnDifferentWifiNetwork) {
      return ConnectivityBannerType.differentWifi;
    }
    // Don't show banner for cellular - it's not an error, just slower
    return null;
  }

  /// Build the device list respecting the saved order.
  /// Uses responsive grid for power devices on tablets.
  Widget _buildDeviceGrid(
    BuildContext context,
    List<Device> devices,
    DeviceProvider deviceProvider,
    AppLocalizations l10n,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = !constraints.isCompact;
        final powerColumns = constraints.powerDeviceColumns;

        // Group consecutive devices by type for efficient grid layout
        final sections = _groupDevicesByType(devices);

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sections.length + 1, // +1 for reorder button
          itemBuilder: (context, sectionIndex) {
            // Last item is the reorder button
            if (sectionIndex == sections.length) {
              return _buildReorderButton(context, l10n);
            }

            final section = sections[sectionIndex];

            // Weather stations always full width
            if (section.isWeatherSection) {
              return Column(
                children: section.devices.map((device) {
                  final status = deviceProvider.getStatus(device.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: WeatherStationDashboardCard(
                      device: device,
                      status: status?.weatherStatus,
                      temperatureHistory:
                          deviceProvider.getTemperatureHistory(device.id),
                      humidityHistory:
                          deviceProvider.getHumidityHistory(device.id),
                    ),
                  );
                }).toList(),
              );
            }

            // Power devices: grid on tablet, full width on phone
            if (isTablet) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPowerDeviceGrid(
                  section.devices,
                  deviceProvider,
                  powerColumns,
                ),
              );
            }

            // Phone: full width cards
            return Column(
              children: section.devices.map((device) {
                final status = deviceProvider.getStatus(device.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PowerDeviceDashboardCard(
                    device: device,
                    status: status?.powerStatus,
                  ),
                );
              }).toList(),
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
  Widget _buildPowerDeviceGrid(
    List<Device> devices,
    DeviceProvider deviceProvider,
    int columns,
  ) {
    // More compact cards: wider aspect ratio = shorter height
    // 2 columns: 1.8 ratio, 3+ columns: 1.5 ratio
    final aspectRatio = columns == 2 ? 1.8 : 1.5;

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
        );
      },
    );
  }

  Widget _buildReorderButton(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Center(
        child: TextButton.icon(
          onPressed: () {
            setState(() {
              _isReorderMode = true;
            });
          },
          icon: Icon(
            AppIcons.reorder,
            size: 18,
            color: colorScheme.outline,
          ),
          label: Text(
            l10n.reorderDevices,
            style: TextStyle(
              color: colorScheme.outline,
              fontSize: 13,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ),
    );
  }

  List<Device> _sortDevices(List<Device> devices, List<String> savedOrder) {
    if (savedOrder.isEmpty) {
      return devices;
    }

    final deviceMap = {for (var d in devices) d.id: d};
    final sortedDevices = <Device>[];

    // Add devices in saved order
    for (final id in savedOrder) {
      final device = deviceMap.remove(id);
      if (device != null) {
        sortedDevices.add(device);
      }
    }

    // Add any remaining devices (new devices not in saved order)
    sortedDevices.addAll(deviceMap.values);

    return sortedDevices;
  }

  Widget _buildReorderableList(
    BuildContext context,
    List<Device> devices,
    DeviceProvider deviceProvider,
    SettingsProvider settingsProvider,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.dragToReorder,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            buildDefaultDragHandles: false,
            padding: const EdgeInsets.all(16),
            itemCount: devices.length,
            onReorder: (oldIndex, newIndex) {
              _onReorder(
                oldIndex,
                newIndex,
                devices,
                settingsProvider,
              );
            },
            itemBuilder: (context, index) {
              final device = devices[index];
              final status = deviceProvider.getStatus(device.id);

              return Padding(
                key: ValueKey(device.id),
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildReorderableCard(device, status, deviceProvider, index),
              );
            },
          ),
        ),
      ],
    );
  }

  void _onReorder(
    int oldIndex,
    int newIndex,
    List<Device> devices,
    SettingsProvider settingsProvider,
  ) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final reorderedDevices = List<Device>.from(devices);
    final device = reorderedDevices.removeAt(oldIndex);
    reorderedDevices.insert(newIndex, device);

    // Save the new order
    final newOrder = reorderedDevices.map((d) => d.id).toList();
    settingsProvider.setDashboardDeviceOrder(newOrder);
  }

  Widget _buildReorderableCard(
    Device device,
    DeviceStatus? status,
    DeviceProvider deviceProvider,
    int index,
  ) {
    return Row(
      children: [
        ReorderableDragStartListener(
          index: index,
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.drag_handle,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: IgnorePointer(
            child: _buildDeviceCard(device, status, deviceProvider),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceCard(
    Device device,
    DeviceStatus? status,
    DeviceProvider deviceProvider,
  ) {
    if (device.isPowerDevice) {
      return PowerDeviceDashboardCard(
        device: device,
        status: status?.powerStatus,
      );
    } else if (device.isWeatherStation) {
      return WeatherStationDashboardCard(
        device: device,
        status: status?.weatherStatus,
        temperatureHistory: deviceProvider.getTemperatureHistory(device.id),
        humidityHistory: deviceProvider.getHumidityHistory(device.id),
      );
    }

    // Default: treat as power device (for switches/relays)
    return PowerDeviceDashboardCard(
      device: device,
      status: status?.powerStatus,
    );
  }
}

/// Helper class to group consecutive devices of the same type
class _DeviceSection {
  final List<Device> devices;
  final bool isWeatherSection;

  _DeviceSection(this.devices, this.isWeatherSection);
}
