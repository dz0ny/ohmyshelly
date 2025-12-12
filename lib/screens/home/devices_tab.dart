import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../data/models/device.dart';
import '../../data/models/device_status.dart';
import '../../providers/device_provider.dart';
import '../../widgets/cards/power_device_card.dart';
import '../../widgets/cards/weather_station_card.dart';
import '../../widgets/cards/gateway_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_card.dart';

class DevicesTab extends StatelessWidget {
  const DevicesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myDevices),
      ),
      body: Consumer<DeviceProvider>(
        builder: (context, deviceProvider, _) {
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

          if (deviceProvider.devices.isEmpty) {
            return EmptyState(
              icon: AppIcons.devices,
              title: l10n.noDevices,
              message: l10n.noDevicesDesc,
            );
          }

          // Group devices by room
          final devicesByRoom = _groupDevicesByRoom(deviceProvider.devices);
          final roomNames = devicesByRoom.keys.toList();

          return RefreshIndicator(
            onRefresh: () => deviceProvider.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: roomNames.length,
              itemBuilder: (context, roomIndex) {
                final roomName = roomNames[roomIndex];
                final roomDevices = devicesByRoom[roomName]!;

                final isOtherRoom = roomName == '___OTHER___';
                final displayRoomName = isOtherRoom ? l10n.otherDevices : roomName;

                final colorScheme = Theme.of(context).colorScheme;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Room header
                    Padding(
                      padding: EdgeInsets.only(
                        top: roomIndex == 0 ? 0 : 16,
                        bottom: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isOtherRoom
                                ? AppIcons.unknownDevice
                                : Icons.room,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              displayRoomName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${roomDevices.length}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Devices in this room
                    ...roomDevices.map((device) {
                      final status = deviceProvider.getStatus(device.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildDeviceCard(
                          context,
                          device,
                          status,
                          deviceProvider,
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// Groups devices by room name, with "Other" for devices without a room.
  /// Rooms are sorted alphabetically, with "Other" always at the end.
  Map<String, List<Device>> _groupDevicesByRoom(List<Device> devices) {
    final Map<String, List<Device>> grouped = {};
    const otherKey = '__other__'; // Internal key for sorting

    for (final device in devices) {
      final roomKey = device.roomName?.isNotEmpty == true
          ? device.roomName!
          : otherKey;
      grouped.putIfAbsent(roomKey, () => []).add(device);
    }

    // Sort rooms alphabetically, keeping "Other" at the end
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        if (a == otherKey) return 1;
        if (b == otherKey) return -1;
        return a.toLowerCase().compareTo(b.toLowerCase());
      });

    // Rebuild map in sorted order, replacing internal key with localized name
    final result = <String, List<Device>>{};
    for (final key in sortedKeys) {
      // We'll use a placeholder that gets replaced in the UI
      result[key == otherKey ? '___OTHER___' : key] = grouped[key]!;
    }
    return result;
  }

  Widget _buildDeviceCard(
    BuildContext context,
    Device device,
    DeviceStatus? status,
    DeviceProvider deviceProvider,
  ) {
    // In debug mode, wrap cards with long-press to copy JSON
    Widget card;

    if (device.isPowerDevice) {
      card = PowerDeviceCard(
        device: device,
        status: status?.powerStatus,
        onTap: () => context.push('/device/${device.id}'),
        onToggle: (turnOn) => deviceProvider.toggleDevice(device.id, turnOn),
      );
    } else if (device.isWeatherStation) {
      card = WeatherStationCard(
        device: device,
        status: status?.weatherStatus,
        onTap: () => context.push('/device/${device.id}'),
      );
    } else if (device.isGateway) {
      card = GatewayCard(
        device: device,
        status: status?.gatewayStatus,
        onTap: () => context.push('/device/${device.id}'),
      );
    } else {
      // Default card for unknown device types
      final colorScheme = Theme.of(context).colorScheme;
      card = Card(
        child: ListTile(
          leading: const Icon(AppIcons.unknownDevice),
          title: Text(device.name),
          subtitle: Text(device.code),
          trailing: Icon(
            device.isOnline ? AppIcons.online : AppIcons.offline,
            color: device.isOnline ? AppColors.success : colorScheme.outline,
          ),
          onTap: () => context.push('/device/${device.id}'),
        ),
      );
    }

    // In debug/dev mode, add long-press to copy JSON
    if (kDebugMode) {
      return GestureDetector(
        onLongPress: () => _showDeviceJsonDialog(context, device, status),
        child: card,
      );
    }

    return card;
  }

  void _showDeviceJsonDialog(
    BuildContext context,
    Device device,
    DeviceStatus? status,
  ) {
    final deviceJson = {
      'device': {
        'id': device.id,
        'name': device.name,
        'code': device.code,
        'type': device.type.toString(),
        'isOnline': device.isOnline,
      },
      'status': status?.rawJson ?? {},
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(deviceJson);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.code, color: AppColors.info),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Device JSON - ${device.name}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy JSON',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: jsonString));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('JSON copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // JSON content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  jsonString,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
