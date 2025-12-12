import 'package:flutter/material.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final bool isOnline;
  final bool showLabel;

  const StatusBadge({
    super.key,
    required this.isOnline,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isOnline ? AppColors.success : colorScheme.outline,
            shape: BoxShape.circle,
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 6),
          Text(
            isOnline ? l10n.online : l10n.offline,
            style: TextStyle(
              fontSize: 12,
              color: isOnline ? AppColors.success : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
