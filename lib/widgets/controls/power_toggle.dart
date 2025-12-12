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

/// Large push button for momentary switch devices.
/// Triggers toggle on press (not a toggle switch - just a momentary action).
class PushButton extends StatefulWidget {
  final bool isOn;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double size;

  const PushButton({
    super.key,
    required this.isOn,
    this.onPressed,
    this.isLoading = false,
    this.size = 60,
  });

  @override
  State<PushButton> createState() => _PushButtonState();
}

class _PushButtonState extends State<PushButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = _isPressed || widget.isOn;

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.deviceOn : colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: isActive ? AppColors.deviceOn : colorScheme.outlineVariant,
          width: 2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.deviceOn.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      transform: _isPressed
          ? Matrix4.diagonal3Values(0.95, 0.95, 1.0)
          : Matrix4.identity(),
      transformAlignment: Alignment.center,
      child: widget.isLoading
          ? Padding(
              padding: EdgeInsets.all(widget.size * 0.3),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isActive ? Colors.white : colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : Icon(
              Icons.touch_app_rounded,
              size: widget.size * 0.5,
              color: isActive ? Colors.white : colorScheme.onSurfaceVariant,
            ),
    );

    // If no onPressed callback, return content directly
    // This allows parent widgets (like InkWell) to handle taps
    if (widget.onPressed == null) {
      return content;
    }

    // Wrap with GestureDetector for press animation and callback
    return GestureDetector(
      onTapDown: widget.isLoading
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: widget.isLoading
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onPressed!();
            },
      onTapCancel: () => setState(() => _isPressed = false),
      child: content,
    );
  }
}

/// Compact push button for card lists (momentary switch devices).
/// Shows as a filled button that triggers on press.
class PushButtonCompact extends StatefulWidget {
  final bool isOn;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PushButtonCompact({
    super.key,
    required this.isOn,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  State<PushButtonCompact> createState() => _PushButtonCompactState();
}

class _PushButtonCompactState extends State<PushButtonCompact> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.isLoading) {
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

    final isActive = _isPressed || widget.isOn;

    return GestureDetector(
      onTapDown: widget.onPressed == null
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: widget.onPressed == null
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onPressed!();
            },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 52,
        height: 32,
        transform: _isPressed
            ? Matrix4.diagonal3Values(0.95, 0.95, 1.0)
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isActive ? AppColors.deviceOn : colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: isActive ? AppColors.deviceOn : colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.touch_app_rounded,
            size: 18,
            color: isActive ? Colors.white : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
