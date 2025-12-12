import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/device_type_helper.dart';
import '../../data/models/device.dart';
import '../../providers/device_provider.dart';
import '../../providers/settings_provider.dart';

class DeviceSettingsScreen extends StatelessWidget {
  final String deviceId;

  const DeviceSettingsScreen({
    super.key,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer2<DeviceProvider, SettingsProvider>(
      builder: (context, deviceProvider, settingsProvider, _) {
        final device = deviceProvider.devices.firstWhere(
          (d) => d.id == deviceId,
          orElse: () => Device(
            id: deviceId,
            name: l10n.unknownDevice,
            code: '',
            type: DeviceType.unknown,
            isOnline: false,
          ),
        );
        final status = deviceProvider.getStatus(deviceId);
        final isExcludedFromDashboard = settingsProvider.isDeviceExcludedFromDashboard(deviceId);

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.deviceInfo),
          ),
          body: ListView(
            children: [
              // Device Info Section
              _buildSectionHeader(l10n.deviceInfo),
              _buildInfoTile(context, l10n.name, device.name),
              _buildInfoTile(context, l10n.model, device.code),
              _buildInfoTile(context, l10n.type, DeviceTypeHelper.friendlyName(device.type, l10n)),
              _buildInfoTile(context, l10n.generation, device.gen.isNotEmpty ? device.gen : '-'),
              _buildInfoTile(context, l10n.deviceId, device.id),
              if (device.serial != null)
                _buildInfoTile(context, l10n.serial, device.serial.toString()),
              if (status != null) ...[
                if (status.powerStatus?.firmwareVersion != null)
                  _buildInfoTile(context, l10n.firmware, 'v${status.powerStatus!.firmwareVersion}'),
                if (status.weatherStatus?.firmwareVersion != null)
                  _buildInfoTile(context, l10n.firmware, 'v${status.weatherStatus!.firmwareVersion}'),
                if (status.gatewayStatus?.firmwareVersion != null)
                  _buildInfoTile(context, l10n.firmware, 'v${status.gatewayStatus!.firmwareVersion}'),
              ],
              if (device.roomName != null)
                _buildInfoTile(context, l10n.room, device.roomName!),

              const SizedBox(height: 8),

              // Connection Status Section
              _buildSectionHeader(l10n.connection),
              _buildInfoTile(
                context,
                l10n.status,
                device.isOnline ? l10n.online : l10n.offline,
                valueColor: device.isOnline ? AppColors.success : AppColors.error,
              ),
              if (status?.rawJson != null) ...[
                if (status!.rawJson['wifi'] != null) ...[
                  _buildInfoTile(
                    context,
                    l10n.wifiNetwork,
                    status.rawJson['wifi']['ssid'] as String? ?? '-',
                  ),
                  _buildInfoTile(
                    context,
                    l10n.ipAddress,
                    status.rawJson['wifi']['sta_ip'] as String? ?? '-',
                  ),
                  _buildInfoTile(
                    context,
                    l10n.signalStrength,
                    '${status.rawJson['wifi']['rssi'] ?? '-'} dBm',
                  ),
                ],
                if (status.rawJson['sys'] != null) ...[
                  _buildInfoTile(
                    context,
                    l10n.uptime,
                    _formatUptime(status.rawJson['sys']['uptime'] as int? ?? 0),
                  ),
                  _buildInfoTile(
                    context,
                    l10n.ramFree,
                    _formatBytes(status.rawJson['sys']['ram_free'] as int? ?? 0),
                  ),
                ],
              ],

              const SizedBox(height: 8),

              // Settings Section
              _buildSectionHeader(l10n.settings),
              SwitchListTile(
                title: Text(l10n.hideFromDashboard),
                subtitle: Text(l10n.hideFromDashboardDesc),
                value: isExcludedFromDashboard,
                onChanged: (value) {
                  settingsProvider.setDeviceExcludedFromDashboard(deviceId, value);
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, String label, String value, {Color? valueColor}) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: valueColor ?? colorScheme.onSurface,
        ),
      ),
    );
  }

  String _formatUptime(int seconds) {
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) return '${(seconds / 60).floor()}m';
    if (seconds < 86400) return '${(seconds / 3600).floor()}h ${((seconds % 3600) / 60).floor()}m';
    final days = (seconds / 86400).floor();
    final hours = ((seconds % 86400) / 3600).floor();
    return '${days}d ${hours}h';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
