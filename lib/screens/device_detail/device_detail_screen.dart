import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_icons.dart';
import '../../core/utils/device_type_helper.dart';
import '../../data/models/device.dart';
import '../../providers/device_provider.dart';
import '../../widgets/devices/power_device/power_device_detail.dart';
import '../../widgets/devices/weather_station/weather_station_detail.dart';
import '../../widgets/devices/gateway/gateway_detail.dart';
import '../../widgets/devices/unknown/unknown_device_detail.dart';

class DeviceDetailScreen extends StatefulWidget {
  final String deviceId;

  const DeviceDetailScreen({
    super.key,
    required this.deviceId,
  });

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  bool _isToggling = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceProvider>(
      builder: (context, deviceProvider, _) {
        final device = deviceProvider.devices.firstWhere(
          (d) => d.id == widget.deviceId,
          orElse: () => Device(
            id: widget.deviceId,
            name: 'Unknown Device',
            code: '',
            type: DeviceType.unknown,
            isOnline: false,
          ),
        );
        final status = deviceProvider.getStatus(widget.deviceId);

        return Scaffold(
          appBar: AppBar(
            title: Text(device.name),
            actions: [
              // Schedule icon only for power devices
              if (device.isPowerDevice)
                IconButton(
                  icon: const Icon(AppIcons.schedule),
                  tooltip: 'Schedules',
                  onPressed: () => context.push('/device/${device.id}/schedules'),
                ),
              IconButton(
                icon: const Icon(AppIcons.info),
                tooltip: 'Info',
                onPressed: () => context.push('/device/${device.id}/settings'),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => deviceProvider.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: _buildDeviceContent(device, status, deviceProvider),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeviceContent(
    Device device,
    dynamic status,
    DeviceProvider deviceProvider,
  ) {
    if (device.isPowerDevice) {
      return PowerDeviceDetail(
        device: device,
        status: status?.powerStatus,
        isToggling: _isToggling,
        onToggle: (turnOn) => _handleToggle(deviceProvider, device.id, turnOn),
        powerHistory: deviceProvider.getPowerHistory(device.id),
      );
    } else if (device.isWeatherStation) {
      return WeatherStationDetail(
        deviceId: device.id,
        status: status?.weatherStatus,
        temperatureHistory: deviceProvider.getTemperatureHistory(device.id),
        humidityHistory: deviceProvider.getHumidityHistory(device.id),
        pressureHistory: deviceProvider.getPressureHistory(device.id),
        uvHistory: deviceProvider.getUvHistory(device.id),
        solarHistory: deviceProvider.getSolarHistory(device.id),
        rainHistory: deviceProvider.getRainHistory(device.id),
      );
    } else if (device.isGateway) {
      return GatewayDetail(
        status: status?.gatewayStatus,
      );
    }

    // Unknown/unsupported device - show raw JSON
    return UnknownDeviceDetail(
      deviceCode: device.code,
      rawJson: status?.rawJson,
    );
  }

  Future<void> _handleToggle(
    DeviceProvider provider,
    String deviceId,
    bool turnOn,
  ) async {
    if (_isToggling) return;

    setState(() => _isToggling = true);

    try {
      await provider.toggleDevice(deviceId, turnOn);
    } finally {
      if (mounted) {
        setState(() => _isToggling = false);
      }
    }
  }

}
