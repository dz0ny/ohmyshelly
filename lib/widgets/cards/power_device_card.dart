import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../data/models/device.dart';
import '../../data/models/device_status.dart';
import '../common/device_card_footer.dart';
import '../common/status_badge.dart';
import '../controls/power_toggle.dart';

class PowerDeviceCard extends StatefulWidget {
  final Device device;
  final PowerDeviceStatus? status;
  final VoidCallback? onTap;
  final Future<bool> Function(bool turnOn)? onToggle;

  const PowerDeviceCard({
    super.key,
    required this.device,
    this.status,
    this.onTap,
    this.onToggle,
  });

  @override
  State<PowerDeviceCard> createState() => _PowerDeviceCardState();
}

class _PowerDeviceCardState extends State<PowerDeviceCard> {
  bool _isToggling = false;

  Future<void> _handleToggle(bool turnOn) async {
    if (_isToggling || widget.onToggle == null) return;

    setState(() => _isToggling = true);

    try {
      await widget.onToggle!(turnOn);
    } finally {
      if (mounted) {
        setState(() => _isToggling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOn = widget.status?.isOn ?? false;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Device icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.powerDevice.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      AppIcons.powerDevice,
                      color: AppColors.powerDevice,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Device info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.device.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            StatusBadge(isOnline: widget.device.isOnline),
                            if (widget.status != null) ...[
                              const SizedBox(width: 12),
                              Icon(
                                AppIcons.power,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.status!.powerDisplay,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Toggle switch
                  PowerToggleCompact(
                    isOn: isOn,
                    isLoading: _isToggling,
                    onChanged: widget.device.isOnline && widget.onToggle != null
                        ? _handleToggle
                        : null,
                  ),
                ],
              ),
            ),
            // Footer with connection details
            DeviceCardFooter(
              ipAddress: widget.status?.ipAddress,
              ssid: widget.status?.ssid,
              lastUpdated: widget.status?.lastUpdated,
            ),
          ],
        ),
      ),
    );
  }
}
