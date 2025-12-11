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

          return RefreshIndicator(
            onRefresh: () => deviceProvider.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: deviceProvider.devices.length,
              itemBuilder: (context, index) {
                final device = deviceProvider.devices[index];
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
              },
            ),
          );
        },
      ),
    );
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
      card = Card(
        child: ListTile(
          leading: const Icon(AppIcons.unknownDevice),
          title: Text(device.name),
          subtitle: Text(device.code),
          trailing: Icon(
            device.isOnline ? AppIcons.online : AppIcons.offline,
            color: device.isOnline ? AppColors.success : AppColors.textHint,
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
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: AppColors.textPrimary,
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
