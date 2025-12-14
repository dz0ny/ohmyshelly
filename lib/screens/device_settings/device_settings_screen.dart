import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/device_type_helper.dart';
import '../../data/models/device.dart';
import '../../data/models/schedule.dart';
import '../../data/models/webhook.dart';
import '../../data/services/storage_service.dart';
import '../../providers/device_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/webhook_provider.dart';

class DeviceSettingsScreen extends StatefulWidget {
  final String deviceId;

  const DeviceSettingsScreen({
    super.key,
    required this.deviceId,
  });

  @override
  State<DeviceSettingsScreen> createState() => _DeviceSettingsScreenState();
}

class _DeviceSettingsScreenState extends State<DeviceSettingsScreen> {
  bool _hasBackup = false;
  String? _backupDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkBackup();
  }

  Future<void> _checkBackup() async {
    final storageService = context.read<StorageService>();
    final backup = await storageService.getDeviceBackup(widget.deviceId);
    if (mounted) {
      setState(() {
        _hasBackup = backup != null;
        if (backup != null && backup['timestamp'] != null) {
          final timestamp = DateTime.tryParse(backup['timestamp'] as String);
          if (timestamp != null) {
            _backupDate = '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
          }
        }
      });
    }
  }

  Future<void> _createBackup() async {
    setState(() => _isLoading = true);

    try {
      final scheduleProvider = context.read<ScheduleProvider>();
      final webhookProvider = context.read<WebhookProvider>();
      final storageService = context.read<StorageService>();

      final schedules = scheduleProvider.getSchedules(widget.deviceId);
      final webhooks = webhookProvider.getWebhooks(widget.deviceId);

      final backup = {
        'timestamp': DateTime.now().toIso8601String(),
        'deviceId': widget.deviceId,
        'schedules': schedules.map((s) => s.toJson()).toList(),
        'webhooks': webhooks.map((w) => w.toJson()).toList(),
      };

      await storageService.saveDeviceBackup(widget.deviceId, backup);
      await _checkBackup();

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.backupCreated)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _restoreBackup() async {
    final l10n = AppLocalizations.of(context)!;

    // Cache providers before any async gap
    final storageService = context.read<StorageService>();
    final scheduleProvider = context.read<ScheduleProvider>();
    final webhookProvider = context.read<WebhookProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.backupRestore),
        content: Text(l10n.backupRestoreConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final backup = await storageService.getDeviceBackup(widget.deviceId);
      if (backup == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.backupNotFound)),
          );
        }
        return;
      }

      // Restore schedules
      final schedulesJson = backup['schedules'] as List<dynamic>? ?? [];
      for (final scheduleJson in schedulesJson) {
        final schedule = Schedule.fromJson(scheduleJson as Map<String, dynamic>);
        // Only restore user schedules (power schedules), skip system schedules
        if (schedule.isUserSchedule) {
          await scheduleProvider.createScheduleFromBackup(
            widget.deviceId,
            schedule,
          );
        }
      }

      // Restore webhooks
      final webhooksJson = backup['webhooks'] as List<dynamic>? ?? [];
      for (final webhookJson in webhooksJson) {
        final webhook = Webhook.fromJson(webhookJson as Map<String, dynamic>);
        await webhookProvider.createWebhookFromBackup(
          widget.deviceId,
          webhook,
        );
      }

      // Refresh data
      await scheduleProvider.fetchSchedules(widget.deviceId);
      await webhookProvider.fetchWebhooks(widget.deviceId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.backupRestored)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteBackup() async {
    final l10n = AppLocalizations.of(context)!;

    // Cache provider before any async gap
    final storageService = context.read<StorageService>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.backupDelete),
        content: Text(l10n.backupDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await storageService.deleteDeviceBackup(widget.deviceId);
    await _checkBackup();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.backupDeleted)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer2<DeviceProvider, SettingsProvider>(
      builder: (context, deviceProvider, settingsProvider, _) {
        final device = deviceProvider.devices.firstWhere(
          (d) => d.id == widget.deviceId,
          orElse: () => Device(
            id: widget.deviceId,
            name: l10n.unknownDevice,
            code: '',
            type: DeviceType.unknown,
            isOnline: false,
          ),
        );
        final status = deviceProvider.getStatus(widget.deviceId);
        final isExcludedFromDashboard = settingsProvider.isDeviceExcludedFromDashboard(widget.deviceId);

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
                  settingsProvider.setDeviceExcludedFromDashboard(widget.deviceId, value);
                },
              ),

              // Backup Section (only for power devices)
              if (device.isPowerDevice) ...[
                const SizedBox(height: 8),

                _buildSectionHeader(l10n.backupSettings),
                ListTile(
                  title: Text(l10n.backupSettingsDesc),
                  subtitle: Text(
                    _hasBackup
                        ? l10n.backupInfo(_backupDate ?? '')
                        : l10n.backupNoBackup,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: _isLoading || !device.isOnline ? null : _createBackup,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.backup, size: 18),
                        label: Text(l10n.backupCreate),
                      ),
                      if (_hasBackup) ...[
                        OutlinedButton.icon(
                          onPressed: _isLoading || !device.isOnline ? null : _restoreBackup,
                          icon: const Icon(Icons.restore, size: 18),
                          label: Text(l10n.backupRestore),
                        ),
                        TextButton.icon(
                          onPressed: _isLoading ? null : _deleteBackup,
                          icon: Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                          label: Text(
                            l10n.backupDelete,
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

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
