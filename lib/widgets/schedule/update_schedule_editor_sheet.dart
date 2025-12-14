import 'package:flutter/material.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/schedule.dart';
import 'day_selector.dart';

/// Result from the update schedule editor.
class UpdateScheduleEditorResult {
  final int hour;
  final int minute;
  final List<int> days;

  const UpdateScheduleEditorResult({
    required this.hour,
    required this.minute,
    required this.days,
  });
}

/// Bottom sheet for creating or editing an auto-update schedule.
class UpdateScheduleEditorSheet extends StatefulWidget {
  final Schedule? existingSchedule;

  const UpdateScheduleEditorSheet({
    super.key,
    this.existingSchedule,
  });

  /// Show the update schedule editor and return the result.
  static Future<UpdateScheduleEditorResult?> show(
    BuildContext context, {
    Schedule? existingSchedule,
  }) {
    return showModalBottomSheet<UpdateScheduleEditorResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => UpdateScheduleEditorSheet(
        existingSchedule: existingSchedule,
      ),
    );
  }

  @override
  State<UpdateScheduleEditorSheet> createState() =>
      _UpdateScheduleEditorSheetState();
}

class _UpdateScheduleEditorSheetState extends State<UpdateScheduleEditorSheet> {
  late int _hour;
  late int _minute;
  late List<int> _selectedDays;

  @override
  void initState() {
    super.initState();

    if (widget.existingSchedule != null) {
      final parsed = widget.existingSchedule!.parsed;
      _hour = parsed.hour;
      _minute = parsed.minute;
      _selectedDays = List.from(parsed.weekdays);
    } else {
      // Default: 3:00 AM every day (good time for updates)
      _hour = 3;
      _minute = 0;
      _selectedDays = TimespecHelper.allDays;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isEditing = widget.existingSchedule != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing
                      ? l10n.editAutoUpdateSchedule
                      : l10n.addAutoUpdateSchedule,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              l10n.autoUpdateScheduleHint,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            // Time picker
            _buildSectionLabel(context, l10n.scheduleTime),
            const SizedBox(height: 8),
            _buildTimePicker(context),

            const SizedBox(height: 24),

            // Day selector
            _buildSectionLabel(context, l10n.scheduleDays),
            const SizedBox(height: 12),
            DaySelector(
              selectedDays: _selectedDays,
              onChanged: (days) {
                setState(() => _selectedDays = days);
              },
            ),

            const SizedBox(height: 32),

            // Save button
            FilledButton(
              onPressed: _selectedDays.isNotEmpty ? _save : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.info,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.system_update, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isEditing ? l10n.save : l10n.addAutoUpdateSchedule,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    final theme = Theme.of(context);
    final timeOfDay = TimeOfDay(hour: _hour, minute: _minute);

    return InkWell(
      onTap: () async {
        final result = await showTimePicker(
          context: context,
          initialTime: timeOfDay,
          builder: (context, child) {
            return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            );
          },
        );
        if (result != null) {
          setState(() {
            _hour = result.hour;
            _minute = result.minute;
          });
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time,
              color: AppColors.info,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    Navigator.of(context).pop(UpdateScheduleEditorResult(
      hour: _hour,
      minute: _minute,
      days: _selectedDays,
    ));
  }
}
