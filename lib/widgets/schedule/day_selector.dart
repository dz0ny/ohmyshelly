import 'package:flutter/material.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';

/// A widget for selecting days of the week.
///
/// Days are indexed as: 0=Sunday, 1=Monday, ..., 6=Saturday
class DaySelector extends StatelessWidget {
  final List<int> selectedDays;
  final ValueChanged<List<int>> onChanged;
  final bool enabled;

  const DaySelector({
    super.key,
    required this.selectedDays,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Day labels in order: Sun, Mon, Tue, Wed, Thu, Fri, Sat
    final dayLabels = [
      l10n.daySun,
      l10n.dayMon,
      l10n.dayTue,
      l10n.dayWed,
      l10n.dayThu,
      l10n.dayFri,
      l10n.daySat,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final isSelected = selectedDays.contains(index);
        return _DayButton(
          label: dayLabels[index][0], // First letter only
          isSelected: isSelected,
          enabled: enabled,
          onTap: () {
            if (!enabled) return;

            final newDays = List<int>.from(selectedDays);
            if (isSelected) {
              // Don't allow deselecting all days
              if (newDays.length > 1) {
                newDays.remove(index);
              }
            } else {
              newDays.add(index);
            }
            newDays.sort();
            onChanged(newDays);
          },
        );
      }),
    );
  }
}

class _DayButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  const _DayButton({
    required this.label,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? (enabled ? AppColors.primary : AppColors.primary.withValues(alpha: 0.5))
              : theme.colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (enabled
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
            ),
          ),
        ),
      ),
    );
  }
}
