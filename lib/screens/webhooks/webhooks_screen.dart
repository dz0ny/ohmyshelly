import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/device_type_helper.dart';
import '../../data/models/device.dart';
import '../../data/models/webhook.dart';
import '../../providers/device_provider.dart';
import '../../providers/webhook_provider.dart';
import '../../widgets/webhook/webhook_list_tile.dart';
import '../../widgets/webhook/webhook_editor_sheet.dart';

class WebhooksScreen extends StatefulWidget {
  final String deviceId;

  const WebhooksScreen({
    super.key,
    required this.deviceId,
  });

  @override
  State<WebhooksScreen> createState() => _WebhooksScreenState();
}

class _WebhooksScreenState extends State<WebhooksScreen> {
  final Set<int> _loadingWebhookIds = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deviceProvider = context.read<DeviceProvider>();
      final webhookProvider = context.read<WebhookProvider>();

      // Fetch webhooks if device is online
      final device = deviceProvider.devices.firstWhere(
        (d) => d.id == widget.deviceId,
        orElse: () => Device(
          id: widget.deviceId,
          name: '',
          code: '',
          type: DeviceType.unknown,
          isOnline: false,
        ),
      );

      if (device.isOnline) {
        webhookProvider.fetchWebhooks(widget.deviceId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer2<DeviceProvider, WebhookProvider>(
      builder: (context, deviceProvider, webhookProvider, _) {
        final device = deviceProvider.devices.firstWhere(
          (d) => d.id == widget.deviceId,
          orElse: () => Device(
            id: widget.deviceId,
            name: l10n.unknownDevice,
            code: '',
            type: DeviceType.unknown,
            isOnline: false,
          ),
        );

        final webhooks = webhookProvider.getWebhooks(widget.deviceId);
        final isLoading = webhookProvider.isLoading(widget.deviceId);
        final error = webhookProvider.getError(widget.deviceId);

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.webhooks),
            actions: [
              if (device.isOnline && webhookProvider.isConnected)
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addWebhook(context, l10n, webhookProvider),
                  tooltip: l10n.addWebhook,
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => webhookProvider.fetchWebhooks(widget.deviceId),
            child: ListView(
              children: [
                _buildWebhooksContent(
                  context,
                  l10n,
                  device,
                  webhookProvider,
                  webhooks,
                  isLoading,
                  error,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWebhooksContent(
    BuildContext context,
    AppLocalizations l10n,
    Device device,
    WebhookProvider webhookProvider,
    List<Webhook> webhooks,
    bool isLoading,
    String? error,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoading && webhooks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null && webhooks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 12),
              Text(
                error,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => webhookProvider.fetchWebhooks(widget.deviceId),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (!device.isOnline) {
      return Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.cloud_off,
                size: 48,
                color: colorScheme.outline,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.deviceOffline,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (webhooks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.webhook,
                size: 48,
                color: colorScheme.outline,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.noWebhooks,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.noWebhooksDesc,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _addWebhook(context, l10n, webhookProvider),
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.addWebhook),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: webhooks.map(
        (webhook) => WebhookListTile(
          webhook: webhook,
          isLoading: _loadingWebhookIds.contains(webhook.id),
          onToggle: (enabled) => _toggleWebhook(
            webhookProvider,
            webhook,
            enabled,
          ),
          onEdit: () => _editWebhook(
            context,
            l10n,
            webhookProvider,
            webhook,
          ),
          onDelete: () => _deleteWebhook(
            context,
            l10n,
            webhookProvider,
            webhook,
          ),
        ),
      ).toList(),
    );
  }

  Future<void> _addWebhook(
    BuildContext context,
    AppLocalizations l10n,
    WebhookProvider webhookProvider,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await WebhookEditorSheet.show(
      context,
      currentDeviceId: widget.deviceId,
    );
    if (result == null) return;

    final success = await webhookProvider.createWebhook(
      widget.deviceId,
      event: result.event,
      name: result.name,
      urls: result.urls,
      repeatPeriod: result.repeatPeriod,
    );

    if (!success && mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.errorGeneric),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _editWebhook(
    BuildContext context,
    AppLocalizations l10n,
    WebhookProvider webhookProvider,
    Webhook webhook,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await WebhookEditorSheet.show(
      context,
      existingWebhook: webhook,
      currentDeviceId: widget.deviceId,
    );
    if (result == null) return;

    final success = await webhookProvider.updateWebhook(
      widget.deviceId,
      webhook,
      event: result.event,
      name: result.name,
      urls: result.urls,
      repeatPeriod: result.repeatPeriod,
    );

    if (!success && mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.errorGeneric),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _toggleWebhook(
    WebhookProvider webhookProvider,
    Webhook webhook,
    bool enabled,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    setState(() => _loadingWebhookIds.add(webhook.id));

    final success = await webhookProvider.toggleWebhook(
      widget.deviceId,
      webhook.id,
      enabled,
    );

    if (mounted) {
      setState(() => _loadingWebhookIds.remove(webhook.id));
    }

    if (!success && mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.errorGeneric),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _deleteWebhook(
    BuildContext context,
    AppLocalizations l10n,
    WebhookProvider webhookProvider,
    Webhook webhook,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteWebhook),
        content: Text(l10n.deleteWebhookConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await webhookProvider.deleteWebhook(
      widget.deviceId,
      webhook.id,
    );

    if (!success && mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.errorGeneric),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
