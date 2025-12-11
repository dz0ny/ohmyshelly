import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/device_type_helper.dart';
import '../../data/models/device.dart';
import '../../providers/device_provider.dart';

class DeviceSettingsScreen extends StatelessWidget {
  final String deviceId;

  const DeviceSettingsScreen({
    super.key,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<DeviceProvider>(
      builder: (context, deviceProvider, _) {
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

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.settings),
          ),
          body: ListView(
            children: [
              // Device Info Section
              _buildSectionHeader('Device Information'),
              _buildInfoTile('Name', device.name),
              _buildInfoTile('Model', device.code),
              _buildInfoTile('Type', DeviceTypeHelper.friendlyName(device.type, l10n)),
              _buildInfoTile('Generation', device.gen.isNotEmpty ? device.gen : '-'),
              _buildInfoTile('Device ID', device.id),
              if (device.serial != null)
                _buildInfoTile('Serial', device.serial.toString()),
              if (device.roomName != null)
                _buildInfoTile('Room', device.roomName!),

              const SizedBox(height: 8),

              // Connection Status Section
              _buildSectionHeader('Connection'),
              _buildInfoTile(
                'Status',
                device.isOnline ? l10n.online : l10n.offline,
                valueColor: device.isOnline ? AppColors.success : AppColors.error,
              ),
              if (status?.rawJson != null) ...[
                if (status!.rawJson['wifi'] != null) ...[
                  _buildInfoTile(
                    'WiFi Network',
                    status.rawJson['wifi']['ssid'] as String? ?? '-',
                  ),
                  _buildInfoTile(
                    'IP Address',
                    status.rawJson['wifi']['sta_ip'] as String? ?? '-',
                  ),
                  _buildInfoTile(
                    'Signal Strength',
                    '${status.rawJson['wifi']['rssi'] ?? '-'} dBm',
                  ),
                ],
                if (status.rawJson['sys'] != null) ...[
                  _buildInfoTile(
                    'Uptime',
                    _formatUptime(status.rawJson['sys']['uptime'] as int? ?? 0),
                  ),
                  _buildInfoTile(
                    'RAM Free',
                    _formatBytes(status.rawJson['sys']['ram_free'] as int? ?? 0),
                  ),
                ],
              ],

              const SizedBox(height: 8),

              // Settings Section
              _buildSectionHeader('Settings'),
              // TODO: These toggles would need backend support
              _buildSwitchTile(
                'Show in Dashboard',
                'Display this device on the dashboard',
                true, // This would come from device settings
                (value) {
                  // TODO: Implement when backend supports it
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Setting saved'),
                      duration: Duration(seconds: 1),
                    ),
                  );
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

  Widget _buildInfoTile(String label, String value, {Color? valueColor}) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: valueColor ?? AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      value: value,
      onChanged: onChanged,
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
