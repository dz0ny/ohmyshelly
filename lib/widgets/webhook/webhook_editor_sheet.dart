import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/device.dart';
import '../../data/models/webhook.dart';
import '../../providers/device_provider.dart';

/// Result from the webhook editor.
class WebhookEditorResult {
  final String name;
  final String event;
  final List<String> urls;
  final int repeatPeriod;

  const WebhookEditorResult({
    required this.name,
    required this.event,
    required this.urls,
    required this.repeatPeriod,
  });
}

/// Target action types for webhooks.
enum WebhookAction {
  turnOn,
  turnOff,
  toggle,
}

/// Bottom sheet for creating or editing a webhook.
class WebhookEditorSheet extends StatefulWidget {
  final Webhook? existingWebhook;
  final String? currentDeviceId;

  const WebhookEditorSheet({
    super.key,
    this.existingWebhook,
    this.currentDeviceId,
  });

  /// Show the webhook editor and return the result.
  static Future<WebhookEditorResult?> show(
    BuildContext context, {
    Webhook? existingWebhook,
    String? currentDeviceId,
  }) {
    return showModalBottomSheet<WebhookEditorResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => WebhookEditorSheet(
        existingWebhook: existingWebhook,
        currentDeviceId: currentDeviceId,
      ),
    );
  }

  @override
  State<WebhookEditorSheet> createState() => _WebhookEditorSheetState();
}

class _WebhookEditorSheetState extends State<WebhookEditorSheet> {
  late TextEditingController _nameController;
  late String _selectedEvent;
  late int _repeatPeriod;

  // Device-based URL construction
  bool _useDeviceSelector = true;
  Device? _selectedTargetDevice;
  WebhookAction _selectedAction = WebhookAction.turnOn;
  int _toggleAfter = 0; // seconds, 0 = disabled

  // Custom URL fallback
  late List<TextEditingController> _urlControllers;

  @override
  void initState() {
    super.initState();

    if (widget.existingWebhook != null) {
      _nameController = TextEditingController(text: widget.existingWebhook!.name);
      _selectedEvent = widget.existingWebhook!.event;
      _repeatPeriod = widget.existingWebhook!.repeatPeriod;
      _urlControllers = widget.existingWebhook!.urls
          .map((url) => TextEditingController(text: url))
          .toList();

      // Try to parse existing URL to determine if it's a device action
      _parseExistingUrl(widget.existingWebhook!.urls.firstOrNull);
    } else {
      _nameController = TextEditingController();
      _selectedEvent = WebhookEvent.inputButtonPush;
      _repeatPeriod = 0;
      _urlControllers = [TextEditingController()];
    }
  }

  void _parseExistingUrl(String? url) {
    if (url == null || url.isEmpty) {
      _useDeviceSelector = true;
      return;
    }

    // Check if URL matches pattern: http://<ip>/rpc/switch.set?...
    final rpcPattern = RegExp(r'http://(\d+\.\d+\.\d+\.\d+)/rpc/');
    if (rpcPattern.hasMatch(url)) {
      final match = rpcPattern.firstMatch(url);
      if (match != null) {
        final ip = match.group(1);
        // Try to find matching device by IP
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final deviceProvider = context.read<DeviceProvider>();
          final devices = deviceProvider.devices;
          for (final device in devices) {
            final status = deviceProvider.getStatus(device.id);
            final deviceIp = status?.powerStatus?.ipAddress ?? status?.gatewayStatus?.ipAddress;
            if (deviceIp == ip) {
              // Parse action from URL
              WebhookAction parsedAction = WebhookAction.turnOn;
              if (url.contains('switch.toggle')) {
                parsedAction = WebhookAction.toggle;
              } else if (url.contains('on=true')) {
                parsedAction = WebhookAction.turnOn;
              } else if (url.contains('on=false')) {
                parsedAction = WebhookAction.turnOff;
              }

              // Parse toggle_after
              int parsedToggleAfter = 0;
              final toggleAfterMatch = RegExp(r'toggle_after=(\d+)').firstMatch(url);
              if (toggleAfterMatch != null) {
                parsedToggleAfter = int.tryParse(toggleAfterMatch.group(1)!) ?? 0;
              }

              setState(() {
                _selectedTargetDevice = device;
                _useDeviceSelector = true;
                _selectedAction = parsedAction;
                _toggleAfter = parsedToggleAfter;
              });
              return;
            }
          }
          // If no device found, fall back to custom URL mode
          setState(() => _useDeviceSelector = false);
        });
        return;
      }
    }

    // Not a device URL, use custom mode
    _useDeviceSelector = false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final controller in _urlControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _isValid {
    if (_nameController.text.trim().isEmpty) return false;

    if (_useDeviceSelector) {
      return _selectedTargetDevice != null;
    } else {
      final urls = _urlControllers
          .map((c) => c.text.trim())
          .where((u) => u.isNotEmpty)
          .toList();
      return urls.isNotEmpty;
    }
  }

  List<String> _buildUrls() {
    if (!_useDeviceSelector || _selectedTargetDevice == null) {
      return _urlControllers
          .map((c) => c.text.trim())
          .where((u) => u.isNotEmpty)
          .toList();
    }

    // Get device IP
    final deviceProvider = context.read<DeviceProvider>();
    final status = deviceProvider.getStatus(_selectedTargetDevice!.id);
    final ip = status?.powerStatus?.ipAddress ?? status?.gatewayStatus?.ipAddress;
    if (ip == null || ip.isEmpty) return [];

    // Build RPC URL based on action
    String rpcUrl;
    switch (_selectedAction) {
      case WebhookAction.turnOn:
        rpcUrl = 'http://$ip/rpc/switch.set?id=0&on=true';
        if (_toggleAfter > 0) {
          rpcUrl += '&toggle_after=$_toggleAfter';
        }
      case WebhookAction.turnOff:
        rpcUrl = 'http://$ip/rpc/switch.set?id=0&on=false';
        if (_toggleAfter > 0) {
          rpcUrl += '&toggle_after=$_toggleAfter';
        }
      case WebhookAction.toggle:
        rpcUrl = 'http://$ip/rpc/switch.toggle?id=0';
    }

    return [rpcUrl];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isEditing = widget.existingWebhook != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isEditing ? l10n.editWebhook : l10n.addWebhook,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name field
                    _buildSectionLabel(context, l10n.webhookName),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: l10n.webhookNameHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 20),

                    // Event selector
                    _buildSectionLabel(context, l10n.webhookEvent),
                    const SizedBox(height: 8),
                    _buildEventSelector(context),

                    const SizedBox(height: 20),

                    // Target mode selector
                    _buildModeSelector(context, l10n),

                    const SizedBox(height: 16),

                    if (_useDeviceSelector) ...[
                      // Device selector
                      _buildSectionLabel(context, l10n.webhookTargetDevice),
                      const SizedBox(height: 8),
                      _buildDeviceSelector(context, l10n),

                      const SizedBox(height: 20),

                      // Action selector
                      _buildSectionLabel(context, l10n.scheduleAction),
                      const SizedBox(height: 8),
                      _buildActionSelector(l10n),

                      const SizedBox(height: 20),

                      // Toggle after (timer)
                      _buildSectionLabel(context, l10n.webhookToggleAfter),
                      const SizedBox(height: 8),
                      _buildToggleAfterSelector(context, l10n),
                    ] else ...[
                      // Custom URLs
                      _buildSectionLabel(context, l10n.webhookUrls),
                      const SizedBox(height: 8),
                      _buildUrlList(context, l10n),
                    ],

                    const SizedBox(height: 20),

                    // Repeat period
                    _buildSectionLabel(context, l10n.webhookRepeatPeriod),
                    const SizedBox(height: 8),
                    _buildRepeatPeriodSelector(context, l10n),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Save button
            FilledButton(
              onPressed: _isValid ? _save : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                l10n.save,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildModeSelector(BuildContext context, AppLocalizations l10n) {
    return SegmentedButton<bool>(
      segments: [
        ButtonSegment(
          value: true,
          label: Text(l10n.webhookModeDevice),
        ),
        ButtonSegment(
          value: false,
          label: Text(l10n.webhookModeCustom),
        ),
      ],
      selected: {_useDeviceSelector},
      onSelectionChanged: (selected) {
        setState(() => _useDeviceSelector = selected.first);
      },
    );
  }

  Widget _buildEventSelector(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedEvent,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          borderRadius: BorderRadius.circular(12),
          items: WebhookEvent.allEvents.map((event) {
            return DropdownMenuItem(
              value: event,
              child: Text(WebhookEvent.getDescription(event)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedEvent = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDeviceSelector(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final deviceProvider = context.watch<DeviceProvider>();

    // Get all power devices except the current one
    final availableDevices = deviceProvider.devices
        .where((d) => d.isPowerDevice && d.id != widget.currentDeviceId && d.isOnline)
        .toList();

    if (availableDevices.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          l10n.webhookNoDevices,
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Device>(
          value: _selectedTargetDevice,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          borderRadius: BorderRadius.circular(12),
          hint: Text(l10n.webhookSelectDevice),
          items: availableDevices.map((device) {
            final status = deviceProvider.getStatus(device.id);
            final ip = status?.powerStatus?.ipAddress ?? status?.gatewayStatus?.ipAddress ?? '';
            return DropdownMenuItem(
              value: device,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(device.name),
                        if (ip.isNotEmpty)
                          Text(
                            ip,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedTargetDevice = value);
          },
        ),
      ),
    );
  }

  Widget _buildActionSelector(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: l10n.turnOn,
            icon: Icons.power,
            isSelected: _selectedAction == WebhookAction.turnOn,
            color: AppColors.success,
            onTap: () => setState(() => _selectedAction = WebhookAction.turnOn),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            label: l10n.turnOff,
            icon: Icons.power_off,
            isSelected: _selectedAction == WebhookAction.turnOff,
            color: AppColors.error,
            onTap: () => setState(() => _selectedAction = WebhookAction.turnOff),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            label: l10n.webhookToggle,
            icon: Icons.sync,
            isSelected: _selectedAction == WebhookAction.toggle,
            color: AppColors.primary,
            onTap: () => setState(() => _selectedAction = WebhookAction.toggle),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleAfterSelector(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    // Only show for turn on/off actions
    if (_selectedAction == WebhookAction.toggle) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          l10n.webhookToggleAfterNotAvailable,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.outline,
          ),
        ),
      );
    }

    final options = [
      (0, l10n.webhookToggleAfterNone),
      (30, l10n.webhookToggleAfter30s),
      (60, l10n.webhookToggleAfter1min),
      (300, l10n.webhookToggleAfter5min),
      (600, l10n.webhookToggleAfter10min),
      (1800, l10n.webhookToggleAfter30min),
      (3600, l10n.webhookToggleAfter1hour),
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _toggleAfter,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          borderRadius: BorderRadius.circular(12),
          items: options.map((option) {
            return DropdownMenuItem(
              value: option.$1,
              child: Text(option.$2),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _toggleAfter = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildUrlList(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ..._urlControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: l10n.webhookUrlHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    keyboardType: TextInputType.url,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                if (_urlControllers.length > 1) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: theme.colorScheme.error,
                    ),
                    onPressed: () => _removeUrl(index),
                    tooltip: l10n.webhookRemoveUrl,
                  ),
                ],
              ],
            ),
          );
        }),

        TextButton.icon(
          onPressed: _addUrl,
          icon: const Icon(Icons.add, size: 18),
          label: Text(l10n.webhookAddUrl),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildRepeatPeriodSelector(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    final options = [
      (0, l10n.webhookRepeatNone),
      (5, l10n.webhookRepeat5s),
      (15, l10n.webhookRepeat15s),
      (30, l10n.webhookRepeat30s),
      (60, l10n.webhookRepeat1min),
      (300, l10n.webhookRepeat5min),
      (900, l10n.webhookRepeat15min),
      (3600, l10n.webhookRepeat1hour),
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _repeatPeriod,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          borderRadius: BorderRadius.circular(12),
          items: options.map((option) {
            return DropdownMenuItem(
              value: option.$1,
              child: Text(option.$2),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _repeatPeriod = value);
            }
          },
        ),
      ),
    );
  }

  void _addUrl() {
    setState(() {
      _urlControllers.add(TextEditingController());
    });
  }

  void _removeUrl(int index) {
    setState(() {
      _urlControllers[index].dispose();
      _urlControllers.removeAt(index);
    });
  }

  void _save() {
    final urls = _buildUrls();
    if (urls.isEmpty) return;

    Navigator.of(context).pop(WebhookEditorResult(
      name: _nameController.text.trim(),
      event: _selectedEvent,
      urls: urls,
      repeatPeriod: _repeatPeriod,
    ));
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : null,
          border: Border.all(
            color: isSelected ? color : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
