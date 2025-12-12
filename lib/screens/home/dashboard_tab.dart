import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_icons.dart';
import '../../providers/device_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/devices/power_device/power_device_dashboard_card.dart';
import '../../widgets/devices/weather_station/weather_station_dashboard_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_card.dart';
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

          return RefreshIndicator(
            onRefresh: () => deviceProvider.refresh(),
            child: _buildDeviceGrid(
              context,
              displayDevices,
              deviceProvider,
              l10n,
            ),
          );
        },
      ),
    );
  }

  /// Build the device grid respecting the saved order.
  /// Power devices are displayed 2-per-row, weather stations full-width.
  /// Consecutive power devices are grouped into rows.
  Widget _buildDeviceGrid(
    BuildContext context,
    List<Device> devices,
    DeviceProvider deviceProvider,
    AppLocalizations l10n,
  ) {
    final List<Widget> children = [];
    int i = 0;

    while (i < devices.length) {
      final device = devices[i];

      if (device.isWeatherStation) {
        // Weather station: full-width
        final status = deviceProvider.getStatus(device.id);
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: WeatherStationDashboardCard(
              device: device,
              status: status?.weatherStatus,
              temperatureHistory: deviceProvider.getTemperatureHistory(device.id),
              humidityHistory: deviceProvider.getHumidityHistory(device.id),
            ),
          ),
        );
        i++;
      } else {
        // Power device: check if next device is also a power device for pairing
        final device1 = device;
        final status1 = deviceProvider.getStatus(device1.id);

        // Look ahead for another power device to pair
        Device? device2;
        DeviceStatus? status2;
        if (i + 1 < devices.length && !devices[i + 1].isWeatherStation) {
          device2 = devices[i + 1];
          status2 = deviceProvider.getStatus(device2.id);
        }

        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: PowerDeviceDashboardCard(
                      device: device1,
                      status: status1?.powerStatus,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: device2 != null
                        ? PowerDeviceDashboardCard(
                            device: device2,
                            status: status2?.powerStatus,
                          )
                        : const SizedBox(), // Empty placeholder for odd count
                  ),
                ],
              ),
            ),
          ),
        );

        // Move index: +2 if paired, +1 if single
        i += device2 != null ? 2 : 1;
      }
    }

    // Add reorder button at the end
    children.add(_buildReorderButton(context, l10n));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: children,
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
