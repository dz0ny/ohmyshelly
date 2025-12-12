import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/device_type_helper.dart';
import '../../data/models/device.dart';
import '../../data/models/schedule.dart';
import '../../providers/device_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../widgets/schedule/schedule_list_tile.dart';
import '../../widgets/schedule/schedule_editor_sheet.dart';
import '../../widgets/schedule/action_log_list.dart';

class SchedulesScreen extends StatefulWidget {
  final String deviceId;

  const SchedulesScreen({
    super.key,
    required this.deviceId,
  });

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  StreamSubscription? _actionLogSubscription;
  final Set<int> _loadingScheduleIds = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deviceProvider = context.read<DeviceProvider>();
      final scheduleProvider = context.read<ScheduleProvider>();

      // Subscribe to action log events
      _actionLogSubscription = deviceProvider.actionLogEvents.listen((event) {
        if (event.deviceId == widget.deviceId) {
          scheduleProvider.addActionLogEntry(event.deviceId, event.entry);
        }
      });

      // Fetch schedules and event log
      final device = deviceProvider.devices.firstWhere(
        (d) => d.id == widget.deviceId,
        orElse: () => Device(
          id: widget.deviceId,
          name: '',
          code: '',
          type: DeviceType.unknown,
          isOnline: false,
        ),
      );

      if (device.isOnline) {
        scheduleProvider.fetchSchedules(widget.deviceId);
      }

      // Always fetch historical event log (works even if device is offline)
      scheduleProvider.fetchEventLog(widget.deviceId);
    });
  }

  @override
  void dispose() {
    _actionLogSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer2<DeviceProvider, ScheduleProvider>(
      builder: (context, deviceProvider, scheduleProvider, _) {
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

        final schedules = scheduleProvider.getSchedules(widget.deviceId);
        final isLoading = scheduleProvider.isLoading(widget.deviceId);
        final error = scheduleProvider.getError(widget.deviceId);
        final actionLog = scheduleProvider.getActionLog(widget.deviceId);

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.schedules),
            actions: [
              if (device.isOnline && scheduleProvider.isConnected)
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addSchedule(context, l10n, scheduleProvider),
                  tooltip: l10n.addSchedule,
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => scheduleProvider.fetchSchedules(widget.deviceId),
            child: ListView(
              children: [
                // Schedules Section
                _buildSchedulesContent(
                  context,
                  l10n,
                  device,
                  scheduleProvider,
                  schedules,
                  isLoading,
                  error,
                ),

                const SizedBox(height: 16),

                // Activity Section
                _buildSectionHeader(l10n.activity),
                ActionLogList(entries: actionLog),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSchedulesContent(
    BuildContext context,
    AppLocalizations l10n,
    Device device,
    ScheduleProvider scheduleProvider,
    List<Schedule> schedules,
    bool isLoading,
    String? error,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    if (isLoading && schedules.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null && schedules.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 12),
              Text(
                error,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => scheduleProvider.fetchSchedules(widget.deviceId),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (!device.isOnline) {
      return Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.cloud_off,
                size: 48,
                color: colorScheme.outline,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.deviceOffline,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (schedules.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.schedule,
                size: 48,
                color: colorScheme.outline,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.noSchedules,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _addSchedule(context, l10n, scheduleProvider),
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.addSchedule),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: schedules.map((schedule) => ScheduleListTile(
        schedule: schedule,
        isLoading: _loadingScheduleIds.contains(schedule.id),
        onToggle: (enabled) => _toggleSchedule(
          scheduleProvider,
          schedule,
          enabled,
        ),
        onEdit: () => _editSchedule(
          context,
          l10n,
          scheduleProvider,
          schedule,
        ),
        onDelete: () => _deleteSchedule(
          context,
          l10n,
          scheduleProvider,
          schedule,
        ),
      )).toList(),
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

  Future<void> _addSchedule(
    BuildContext context,
    AppLocalizations l10n,
    ScheduleProvider scheduleProvider,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await ScheduleEditorSheet.show(context);
    if (result == null) return;

    final success = await scheduleProvider.createSchedule(
      widget.deviceId,
      hour: result.hour,
      minute: result.minute,
      days: result.days,
      turnOn: result.turnOn,
    );

    if (!success && mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.errorGeneric),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _editSchedule(
    BuildContext context,
    AppLocalizations l10n,
    ScheduleProvider scheduleProvider,
    Schedule schedule,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await ScheduleEditorSheet.show(
      context,
      existingSchedule: schedule,
    );
    if (result == null) return;

    final success = await scheduleProvider.updateSchedule(
      widget.deviceId,
      schedule,
      hour: result.hour,
      minute: result.minute,
      days: result.days,
      turnOn: result.turnOn,
    );

    if (!success && mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.errorGeneric),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _toggleSchedule(
    ScheduleProvider scheduleProvider,
    Schedule schedule,
    bool enabled,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    setState(() => _loadingScheduleIds.add(schedule.id));

    final success = await scheduleProvider.toggleSchedule(
      widget.deviceId,
      schedule.id,
      enabled,
    );

    if (mounted) {
      setState(() => _loadingScheduleIds.remove(schedule.id));
    }

    if (!success && mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.errorGeneric),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _deleteSchedule(
    BuildContext context,
    AppLocalizations l10n,
    ScheduleProvider scheduleProvider,
    Schedule schedule,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteSchedule),
        content: Text(l10n.deleteScheduleConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await scheduleProvider.deleteSchedule(
      widget.deviceId,
      schedule.id,
    );

    if (!success && mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.errorGeneric),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
