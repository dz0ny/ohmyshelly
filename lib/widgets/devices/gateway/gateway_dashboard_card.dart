import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../data/models/device.dart';
import '../../../data/models/device_status.dart';

/// Dashboard card for gateways - shows connection status (read-only)
class GatewayDashboardCard extends StatelessWidget {
  final Device device;
  final GatewayStatus? status;

  const GatewayDashboardCard({
    super.key,
    required this.device,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = status?.cloudConnected ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.gateway.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                AppIcons.gateway,
                color: AppColors.gateway,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                device.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              isConnected ? Icons.cloud_done : Icons.cloud_off,
              color: isConnected ? AppColors.success : AppColors.textHint,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
