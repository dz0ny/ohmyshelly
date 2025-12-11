import 'package:flutter/material.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';

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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.powerDevice.withValues(alpha: 0.1),
              AppColors.powerDevice.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.powerDevice.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        AppIcons.power,
                        color: AppColors.powerDevice,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.totalPower,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$deviceCount ${l10n.devices.toLowerCase()}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onTap != null)
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textHint,
                        size: 24,
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // Power display - large centered
                Center(
                  child: Column(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _formatPowerValue(),
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.w300,
                            color: AppColors.textPrimary,
                            height: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getPowerUnit(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Power bar visualization
                _buildPowerBar(),

                const SizedBox(height: 8),

                // Power scale labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '0',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                    ),
                    Text(
                      _getMaxPowerLabel(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatPowerValue() {
    if (totalPower >= 1000) {
      return (totalPower / 1000).toStringAsFixed(2);
    }
    return totalPower.toStringAsFixed(1);
  }

  String _getPowerUnit() {
    return totalPower >= 1000 ? 'kW' : 'W';
  }

  Widget _buildPowerBar() {
    final maxPower = _getMaxPower();
    final fillPercentage = (totalPower / maxPower).clamp(0.0, 1.0);

    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.powerDevice.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: fillPercentage,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.powerDevice.withValues(alpha: 0.8),
                AppColors.powerDevice,
              ],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  double _getMaxPower() {
    if (totalPower <= 100) return 100;
    if (totalPower <= 500) return 500;
    if (totalPower <= 1000) return 1000;
    if (totalPower <= 2000) return 2000;
    if (totalPower <= 3000) return 3000;
    return (totalPower * 1.2).ceilToDouble();
  }

  String _getMaxPowerLabel() {
    final max = _getMaxPower();
    if (max >= 1000) {
      return '${(max / 1000).toStringAsFixed(0)} kW';
    }
    return '${max.toInt()} W';
  }
}
