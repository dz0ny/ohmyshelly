import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../data/models/scene.dart';
import '../../l10n/app_localizations.dart';

class SceneCard extends StatefulWidget {
  final Scene scene;
  final VoidCallback? onTap;
  final Future<bool> Function(bool enabled)? onToggle;
  final Future<bool> Function()? onRun;

  const SceneCard({
    super.key,
    required this.scene,
    this.onTap,
    this.onToggle,
    this.onRun,
  });

  @override
  State<SceneCard> createState() => _SceneCardState();
}

class _SceneCardState extends State<SceneCard> {
  bool _isToggling = false;
  bool _isRunning = false;

  Future<void> _handleToggle(bool enabled) async {
    if (_isToggling || widget.onToggle == null) return;

    setState(() => _isToggling = true);

    try {
      await widget.onToggle!(enabled);
    } finally {
      if (mounted) {
        setState(() => _isToggling = false);
      }
    }
  }

  Future<void> _handleRun() async {
    if (_isRunning || widget.onRun == null) return;

    setState(() => _isRunning = true);

    try {
      await widget.onRun!();
    } finally {
      if (mounted) {
        setState(() => _isRunning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = widget.scene.enabled;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Scene icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.scene.withValues(alpha: isEnabled ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  AppIcons.scene,
                  color: isEnabled ? AppColors.scene : colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Scene info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.scene.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isEnabled
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Room badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.scene.roomName,
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Status text
                        Text(
                          isEnabled ? l10n.sceneEnabled : l10n.sceneDisabled,
                          style: TextStyle(
                            fontSize: 12,
                            color: isEnabled
                                ? AppColors.success
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Run button
              if (widget.onRun != null)
                IconButton(
                  onPressed: _isRunning ? null : _handleRun,
                  icon: _isRunning
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.scene,
                          ),
                        )
                      : const Icon(
                          AppIcons.sceneRun,
                          color: AppColors.scene,
                        ),
                  tooltip: l10n.runScene,
                ),

              const SizedBox(width: 4),

              // Toggle switch
              if (widget.onToggle != null)
                _isToggling
                    ? const SizedBox(
                        width: 48,
                        height: 32,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      )
                    : Switch(
                        value: isEnabled,
                        onChanged: _handleToggle,
                        activeTrackColor: AppColors.scene,
                        activeThumbColor: Colors.white,
                      ),
            ],
          ),
        ),
      ),
    );
  }
}
