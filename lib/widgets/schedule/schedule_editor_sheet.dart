import 'package:flutter/material.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/schedule.dart';
import 'day_selector.dart';

/// Result from the schedule editor.
class ScheduleEditorResult {
  final int hour;
  final int minute;
  final List<int> days;
  final bool turnOn;

  const ScheduleEditorResult({
    required this.hour,
    required this.minute,
    required this.days,
    required this.turnOn,
  });
}

/// Bottom sheet for creating or editing a schedule.
class ScheduleEditorSheet extends StatefulWidget {
  final Schedule? existingSchedule;

  const ScheduleEditorSheet({
    super.key,
    this.existingSchedule,
  });

  /// Show the schedule editor and return the result.
  static Future<ScheduleEditorResult?> show(
    BuildContext context, {
    Schedule? existingSchedule,
  }) {
    return showModalBottomSheet<ScheduleEditorResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ScheduleEditorSheet(
        existingSchedule: existingSchedule,
      ),
    );
  }

  @override
  State<ScheduleEditorSheet> createState() => _ScheduleEditorSheetState();
}

class _ScheduleEditorSheetState extends State<ScheduleEditorSheet> {
  late int _hour;
  late int _minute;
  late List<int> _selectedDays;
  late bool _turnOn;

  @override
  void initState() {
    super.initState();

    if (widget.existingSchedule != null) {
      final parsed = widget.existingSchedule!.parsed;
      _hour = parsed.hour;
      _minute = parsed.minute;
      _selectedDays = List.from(parsed.weekdays);
      _turnOn = widget.existingSchedule!.action ?? true;
    } else {
      // Default: current time rounded to next hour, all days, turn on
      final now = TimeOfDay.now();
      _hour = (now.hour + 1) % 24;
      _minute = 0;
      _selectedDays = TimespecHelper.allDays;
      _turnOn = true;
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
                  isEditing ? l10n.editSchedule : l10n.addSchedule,
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

            const SizedBox(height: 24),

            // Time picker
            _buildSectionLabel(l10n.scheduleTime),
            const SizedBox(height: 8),
            _buildTimePicker(context),

            const SizedBox(height: 24),

            // Day selector
            _buildSectionLabel(l10n.scheduleDays),
            const SizedBox(height: 12),
            DaySelector(
              selectedDays: _selectedDays,
              onChanged: (days) {
                setState(() => _selectedDays = days);
              },
            ),

            const SizedBox(height: 24),

            // Action selector
            _buildSectionLabel(l10n.scheduleAction),
            const SizedBox(height: 8),
            _buildActionSelector(l10n),

            const SizedBox(height: 32),

            // Save button
            FilledButton(
              onPressed: _selectedDays.isNotEmpty ? _save : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                isEditing ? l10n.save : l10n.addSchedule,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
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
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
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
              color: AppColors.primary,
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

  Widget _buildActionSelector(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: l10n.turnOn,
            icon: Icons.power,
            isSelected: _turnOn,
            color: AppColors.success,
            onTap: () => setState(() => _turnOn = true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            label: l10n.turnOff,
            icon: Icons.power_off,
            isSelected: !_turnOn,
            color: AppColors.error,
            onTap: () => setState(() => _turnOn = false),
          ),
        ),
      ],
    );
  }

  void _save() {
    Navigator.of(context).pop(ScheduleEditorResult(
      hour: _hour,
      minute: _minute,
      days: _selectedDays,
      turnOn: _turnOn,
    ));
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : null,
          border: Border.all(
            color: isSelected ? color : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
