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
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gateway Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                if (status != null) ...[
                  _buildInfoRow(
                    'Cloud',
                    status!.cloudConnected ? l10n.online : l10n.offline,
                    status!.cloudConnected ? AppColors.success : AppColors.error,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    l10n.ipAddress,
                    status!.ipAddress ?? 'N/A',
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    l10n.wifiNetwork,
                    status!.ssid ?? 'N/A',
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    l10n.signalStrength,
                    status!.signalStrengthLocalized(l10n),
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    l10n.uptime,
                    status!.uptimeDisplay,
                  ),
                ] else ...[
                  Center(
                    child: Text(
                      l10n.noDataAvailable,
                      style: const TextStyle(color: AppColors.textSecondary),
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

  Widget _buildInfoRow(String label, String value, [Color? valueColor]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
