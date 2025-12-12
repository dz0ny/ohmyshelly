import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/device_status.dart';
import '../../../l10n/app_localizations.dart';

/// Detail view for gateways - shows connection info
class GatewayDetail extends StatelessWidget {
  final GatewayStatus? status;

  const GatewayDetail({
    super.key,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gateway Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                if (status != null) ...[
                  _buildInfoRow(
                    context,
                    'Cloud',
                    status!.cloudConnected ? l10n.online : l10n.offline,
                    status!.cloudConnected ? AppColors.success : AppColors.error,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    l10n.ipAddress,
                    status!.ipAddress ?? 'N/A',
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    l10n.wifiNetwork,
                    status!.ssid ?? 'N/A',
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    l10n.signalStrength,
                    status!.signalStrengthLocalized(l10n),
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    l10n.uptime,
                    status!.uptimeDisplay,
                  ),
                ] else ...[
                  Center(
                    child: Text(
                      l10n.noDataAvailable,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, [Color? valueColor]) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: valueColor ?? colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
