import 'package:flutter/material.dart';
import '../../core/constants/app_icons.dart';
import '../../data/models/device.dart';
import '../../data/models/device_status.dart';
import '../../data/models/local_device_info.dart';
import '../common/device_card_footer.dart';
import '../common/status_badge.dart';
import '../controls/power_toggle.dart';

class PowerDeviceCard extends StatefulWidget {
  final Device device;
  final PowerDeviceStatus? status;
  final ConnectionSource? connectionSource;
  final VoidCallback? onTap;
  final Future<bool> Function(bool turnOn)? onToggle;

  const PowerDeviceCard({
    super.key,
    required this.device,
    this.status,
    this.connectionSource,
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
    final colorScheme = Theme.of(context).colorScheme;
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
                  // Device icon based on relay_usage
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.device.displayColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.device.displayIcon,
                      color: widget.device.displayColor,
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            StatusBadge(isOnline: widget.device.isOnline),
                            if (widget.status != null && widget.status!.hasPowerMonitoring) ...[
                              const SizedBox(width: 12),
                              Icon(
                                AppIcons.power,
                                size: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.status!.powerDisplay,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Toggle switch or push button based on device input type
                  if (widget.device.isPushButton)
                    PushButtonCompact(
                      isOn: isOn,
                      isLoading: _isToggling,
                      onPressed: widget.device.isOnline && widget.onToggle != null
                          ? () => _handleToggle(!isOn)
                          : null,
                    )
                  else
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
              rssi: widget.status?.rssi,
              lastUpdated: widget.status?.lastUpdated,
              firmwareVersion: widget.status?.firmwareVersion,
              connectionSource: widget.connectionSource,
            ),
          ],
        ),
      ),
    );
  }
}
