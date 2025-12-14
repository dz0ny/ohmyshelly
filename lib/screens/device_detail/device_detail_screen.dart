import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_icons.dart';
import '../../core/utils/device_type_helper.dart';
import '../../data/models/action_log.dart';
import '../../data/models/device.dart';
import '../../providers/device_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/devices/power_device/power_device_detail.dart';
import '../../widgets/devices/power_device/relay_detail.dart';
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
  // Cache power monitoring detection to avoid flickering between widgets
  bool? _hasPowerMonitoring;
  bool _eventLogFetched = false;
  StreamSubscription<({String deviceId, ActionLogEntry entry})>? _actionLogSubscription;

  @override
  void initState() {
    super.initState();
    // Fetch event log and subscribe to real-time updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchEventLogIfNeeded();
      _subscribeToActionLogEvents();
    });
  }

  @override
  void dispose() {
    _actionLogSubscription?.cancel();
    super.dispose();
  }

  void _fetchEventLogIfNeeded() {
    if (_eventLogFetched) return;
    _eventLogFetched = true;

    final scheduleProvider = context.read<ScheduleProvider>();
    scheduleProvider.fetchEventLog(widget.deviceId, limit: 20);
  }

  void _subscribeToActionLogEvents() {
    final deviceProvider = context.read<DeviceProvider>();
    final scheduleProvider = context.read<ScheduleProvider>();

    _actionLogSubscription = deviceProvider.actionLogEvents.listen((event) {
      if (event.deviceId == widget.deviceId) {
        scheduleProvider.addActionLogEntry(event.deviceId, event.entry);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<DeviceProvider, ScheduleProvider, SettingsProvider>(
      builder: (context, deviceProvider, scheduleProvider, settingsProvider, _) {
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
        final actionLog = scheduleProvider.getActionLog(widget.deviceId);

        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (device.roomName != null && device.roomName!.isNotEmpty)
                  Text(
                    device.roomName!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                Text(device.name),
              ],
            ),
            actions: [
              // Schedule icon only for power devices (if enabled in settings)
              if (device.isPowerDevice && settingsProvider.showScheduleButton)
                IconButton(
                  icon: const Icon(AppIcons.schedule),
                  tooltip: 'Schedules',
                  onPressed: () => context.push('/device/${device.id}/schedules'),
                ),
              // Webhook/Actions icon for power devices only (if enabled in settings)
              if (device.isPowerDevice && device.isOnline && settingsProvider.showActionsButton)
                IconButton(
                  icon: const Icon(AppIcons.webhook),
                  tooltip: 'Actions',
                  onPressed: () => context.push('/device/${device.id}/webhooks'),
                ),
              // Info icon (if enabled in settings)
              if (settingsProvider.showDeviceInfoButton)
                IconButton(
                  icon: const Icon(AppIcons.info),
                  tooltip: 'Info',
                  onPressed: () => context.push('/device/${device.id}/settings'),
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await deviceProvider.refresh();
              await scheduleProvider.fetchEventLog(widget.deviceId, limit: 20);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: _buildDeviceContent(device, status, deviceProvider, actionLog),
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
    List<ActionLogEntry> actionLog,
  ) {
    if (device.isPowerDevice) {
      final powerStatus = status?.powerStatus;

      // Cache power monitoring detection - once detected, remember it
      // This prevents flickering between RelayDetail and PowerDeviceDetail
      if (powerStatus != null && _hasPowerMonitoring == null) {
        _hasPowerMonitoring = powerStatus.hasPowerMonitoring;
      }

      // Predict from device code if not yet detected from status
      // Plugs (code contains "PL") typically have power monitoring
      final predictedHasPowerMonitoring = device.code.contains('PL');
      final usePowerMonitoring = _hasPowerMonitoring ?? predictedHasPowerMonitoring;

      if (usePowerMonitoring) {
        return PowerDeviceDetail(
          device: device,
          status: powerStatus,
          isToggling: _isToggling,
          onToggle: (turnOn) => _handleToggle(deviceProvider, device.id, turnOn),
          powerHistory: deviceProvider.getPowerHistory(device.id),
        );
      } else {
        return RelayDetail(
          device: device,
          status: powerStatus,
          isToggling: _isToggling,
          onToggle: (turnOn) => _handleToggle(deviceProvider, device.id, turnOn),
          actionLog: actionLog,
        );
      }
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
