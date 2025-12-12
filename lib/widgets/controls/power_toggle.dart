import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PowerToggle extends StatelessWidget {
  final bool isOn;
  final ValueChanged<bool>? onChanged;
  final bool isLoading;
  final double size;

  const PowerToggle({
    super.key,
    required this.isOn,
    this.onChanged,
    this.isLoading = false,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: isLoading || onChanged == null
          ? null
          : () => onChanged!(!isOn),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isOn ? AppColors.deviceOn : colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: isOn ? AppColors.deviceOn : colorScheme.outlineVariant,
            width: 2,
          ),
          boxShadow: isOn
              ? [
                  BoxShadow(
                    color: AppColors.deviceOn.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: isLoading
            ? Padding(
                padding: EdgeInsets.all(size * 0.3),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOn ? Colors.white : colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            : Icon(
                Icons.power_settings_new_rounded,
                size: size * 0.5,
                color: isOn ? Colors.white : colorScheme.onSurfaceVariant,
              ),
      ),
    );
  }
}

class PowerToggleCompact extends StatelessWidget {
  final bool isOn;
  final ValueChanged<bool>? onChanged;
  final bool isLoading;

  const PowerToggleCompact({
    super.key,
    required this.isOn,
    this.onChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (isLoading) {
      return const SizedBox(
        width: 40,
        height: 24,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Switch(
      value: isOn,
      onChanged: onChanged,
      activeTrackColor: AppColors.deviceOn,
      inactiveThumbColor: colorScheme.outline,
      inactiveTrackColor: colorScheme.surfaceContainerHighest,
    );
  }
}
