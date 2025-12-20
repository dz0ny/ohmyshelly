import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';

/// A card that represents a room folder in the dashboard.
/// Styled like PowerDeviceDashboardCard for consistency.
/// Tapping navigates to the room detail screen.
class RoomCard extends StatelessWidget {
  final String roomName;
  final int deviceCount;
  final int activeCount;
  final double totalPower;

  const RoomCard({
    super.key,
    required this.roomName,
    required this.deviceCount,
    required this.activeCount,
    required this.totalPower,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final hasActive = activeCount > 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => context.push('/room/${Uri.encodeComponent(roomName)}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: icon badge + active status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Room icon badge
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.home_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  // Active status badge
                  _buildStatusBadge(context, hasActive, l10n),
                ],
              ),
              const SizedBox(height: 12),
              // Device count (small muted) - like room name in device cards
              Text(
                l10n.devicesInRoom(deviceCount),
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.outline,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Room name (label)
              Text(
                roomName,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Power value (if any devices have power)
              Row(
                children: [
                  Expanded(
                    child: totalPower > 0
                        ? _buildPowerDisplay(context)
                        : const SizedBox.shrink(),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colorScheme.outline,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(
    BuildContext context,
    bool hasActive,
    AppLocalizations l10n,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: hasActive
            ? AppColors.deviceOn.withValues(alpha: 0.1)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: hasActive ? AppColors.deviceOn : colorScheme.outline,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            l10n.activeInRoom(activeCount),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: hasActive ? AppColors.deviceOn : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerDisplay(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasActive = activeCount > 0;

    return Row(
      children: [
        Icon(
          Icons.bolt_rounded,
          size: 16,
          color: hasActive ? AppColors.primary : colorScheme.outline,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '${totalPower.toStringAsFixed(1)} W',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: hasActive ? AppColors.primary : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
