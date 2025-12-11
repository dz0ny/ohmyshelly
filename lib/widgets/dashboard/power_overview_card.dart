import 'package:flutter/material.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/utils/formatters.dart';

class PowerOverviewCard extends StatelessWidget {
  final double totalPower;
  final int deviceCount;
  final VoidCallback? onTap;

  const PowerOverviewCard({
    super.key,
    required this.totalPower,
    required this.deviceCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.powerDevice.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      AppIcons.power,
                      color: AppColors.powerDevice,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.totalPower,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$deviceCount ${l10n.devices}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Power display
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.power(totalPower),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.powerDevice,
                      height: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Power bar visualization
              _buildPowerBar(),

              const SizedBox(height: 8),

              // Power scale labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '0 W',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                  Text(
                    _getMaxPowerLabel(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPowerBar() {
    // Calculate fill percentage (max 3000W for visualization)
    final maxPower = _getMaxPower();
    final fillPercentage = (totalPower / maxPower).clamp(0.0, 1.0);

    return Container(
      height: 12,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: fillPercentage,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.powerDevice.withValues(alpha: 0.7),
                AppColors.powerDevice,
              ],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  double _getMaxPower() {
    // Determine scale based on total power
    if (totalPower <= 100) return 100;
    if (totalPower <= 500) return 500;
    if (totalPower <= 1000) return 1000;
    if (totalPower <= 2000) return 2000;
    if (totalPower <= 3000) return 3000;
    return (totalPower * 1.2).ceilToDouble();
  }

  String _getMaxPowerLabel() {
    return Formatters.power(_getMaxPower());
  }
}
