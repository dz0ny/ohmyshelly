import 'package:flutter/material.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/device.dart';
import '../../../data/models/device_status.dart';
import '../../controls/power_toggle.dart';

/// Detail view for simple relay devices without power monitoring
class RelayDetail extends StatelessWidget {
  final Device device;
  final PowerDeviceStatus? status;
  final bool isToggling;
  final ValueChanged<bool>? onToggle;

  const RelayDetail({
    super.key,
    required this.device,
    this.status,
    this.isToggling = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isOn = status?.isOn ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Power toggle - entire card is tappable
          Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: device.isOnline && !isToggling && onToggle != null
                  ? () => onToggle!(!isOn)
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PowerToggle(
                      isOn: isOn,
                      isLoading: isToggling,
                      size: 100,
                      onChanged: null, // Handled by card tap
                    ),
                    const SizedBox(width: 28),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOn ? l10n.on : l10n.off,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isOn ? AppColors.deviceOn : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (!device.isOnline)
                          Text(
                            l10n.offline,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.outline,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Simple status card (no power metrics)
          if (status != null) _buildStatusCard(context, l10n),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.status,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            // Relay Temperature
            _buildDetailTile(
              context: context,
              icon: AppIcons.temperature,
              label: l10n.temperature,
              value: status!.temperatureDisplay,
            ),
            // Last updated
            if (status!.lastUpdated != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${l10n.lastUpdated}: ${Formatters.timeAgo(status!.lastUpdated!, l10n)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
