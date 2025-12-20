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
import '../../widgets/dashboard/room_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_card.dart';
import '../../widgets/common/connectivity_banner.dart';
import '../../widgets/common/device_grid_view.dart';
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

              // Device grid or room grouped list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => deviceProvider.refresh(),
                  child: settingsProvider.groupByRoom
                      ? _buildRoomGroupedList(
                          context,
                          displayDevices,
                          deviceProvider,
                          l10n,
                        )
                      : DeviceGridView(
                          devices: displayDevices,
                          deviceProvider: deviceProvider,
                          footer: _buildReorderButton(context, l10n),
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

  /// Build the room-grouped grid view
  Widget _buildRoomGroupedList(
    BuildContext context,
    List<Device> devices,
    DeviceProvider deviceProvider,
    AppLocalizations l10n,
  ) {
    final roomGroups = _groupDevicesByRoom(devices, l10n);
    final roomNames = roomGroups.keys.toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = !constraints.isCompact;
        final columns = constraints.powerDeviceColumns;
        // Balanced room cards - content is ~130px, allow some padding
        final aspectRatio = columns == 2 ? 2.2 : 1.8;

        if (isTablet) {
          // Tablet: grid of room cards
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  childAspectRatio: aspectRatio,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: roomNames.length,
                itemBuilder: (context, index) {
                  final roomName = roomNames[index];
                  final roomDevices = roomGroups[roomName]!;
                  final stats = _calculateRoomStats(roomDevices, deviceProvider);

                  return RoomCard(
                    roomName: roomName,
                    deviceCount: roomDevices.length,
                    activeCount: stats.activeCount,
                    totalPower: stats.totalPower,
                  );
                },
              ),
              _buildReorderButton(context, l10n),
            ],
          );
        }

        // Phone: list of room cards
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: roomNames.length + 1,
          itemBuilder: (context, index) {
            if (index == roomNames.length) {
              return _buildReorderButton(context, l10n);
            }

            final roomName = roomNames[index];
            final roomDevices = roomGroups[roomName]!;
            final stats = _calculateRoomStats(roomDevices, deviceProvider);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RoomCard(
                roomName: roomName,
                deviceCount: roomDevices.length,
                activeCount: stats.activeCount,
                totalPower: stats.totalPower,
              ),
            );
          },
        );
      },
    );
  }

  /// Group devices by room name
  Map<String, List<Device>> _groupDevicesByRoom(
    List<Device> devices,
    AppLocalizations l10n,
  ) {
    final groups = <String, List<Device>>{};
    final otherKey = l10n.otherRoom;

    for (final device in devices) {
      final roomName = device.roomName ?? otherKey;
      groups.putIfAbsent(roomName, () => []).add(device);
    }

    // Sort rooms alphabetically, but keep "Other" at the end
    final sortedKeys = groups.keys.toList()
      ..sort((a, b) {
        if (a == otherKey) return 1;
        if (b == otherKey) return -1;
        return a.compareTo(b);
      });

    return {for (final key in sortedKeys) key: groups[key]!};
  }

  /// Calculate stats for a room (active count, total power)
  _RoomStats _calculateRoomStats(
    List<Device> devices,
    DeviceProvider deviceProvider,
  ) {
    var activeCount = 0;
    var totalPower = 0.0;

    for (final device in devices) {
      final status = deviceProvider.getStatus(device.id);
      if (status != null) {
        // Check if device is active (on)
        if (device.isPowerDevice && status.powerStatus?.isOn == true) {
          activeCount++;
          totalPower += status.powerStatus?.power ?? 0;
        }
        // Weather stations are always "active" if online
        if (device.isWeatherStation && device.isOnline) {
          activeCount++;
        }
      }
    }

    return _RoomStats(activeCount: activeCount, totalPower: totalPower);
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

/// Helper class for room statistics
class _RoomStats {
  final int activeCount;
  final double totalPower;

  _RoomStats({required this.activeCount, required this.totalPower});
}
