import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/device_status.dart';

/// Detail view for gateways - shows connection info
class GatewayDetail extends StatelessWidget {
  final GatewayStatus? status;

  const GatewayDetail({
    super.key,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
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
                    status!.cloudConnected ? 'Connected' : 'Disconnected',
                    status!.cloudConnected ? AppColors.success : AppColors.error,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    'IP Address',
                    status!.ipAddress ?? 'N/A',
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    'WiFi Network',
                    status!.ssid ?? 'N/A',
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    'Signal Strength',
                    status!.signalStrength,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    'Uptime',
                    status!.uptimeDisplay,
                  ),
                ] else ...[
                  const Center(
                    child: Text(
                      'No status data available',
                      style: TextStyle(color: AppColors.textSecondary),
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
