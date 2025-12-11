import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_icons.dart';
import '../../providers/device_provider.dart';
import '../../widgets/devices/power_device/power_device_dashboard_card.dart';
import '../../widgets/devices/weather_station/weather_station_dashboard_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_card.dart';
import '../../data/models/device.dart';
import '../../data/models/device_status.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard),
        actions: [
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

          // Filter out gateways - only show devices with data (power, weather)
          final displayDevices = deviceProvider.devices
              .where((d) => !d.isGateway)
              .toList();

          if (displayDevices.isEmpty) {
            return EmptyState(
              icon: AppIcons.dashboard,
              title: l10n.noDevices,
              message: l10n.noDevicesDesc,
            );
          }

          return RefreshIndicator(
            onRefresh: () => deviceProvider.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: displayDevices.length,
              itemBuilder: (context, index) {
                final device = displayDevices[index];
                final status = deviceProvider.getStatus(device.id);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildDeviceCard(device, status, deviceProvider),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeviceCard(Device device, DeviceStatus? status, DeviceProvider deviceProvider) {
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
