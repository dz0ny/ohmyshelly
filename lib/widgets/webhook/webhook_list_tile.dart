import 'package:flutter/material.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../data/models/webhook.dart';

/// A list tile displaying a webhook with enable toggle and actions.
class WebhookListTile extends StatelessWidget {
  final Webhook webhook;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isLoading;

  const WebhookListTile({
    super.key,
    required this.webhook,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: webhook.enabled
              ? AppColors.primary.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHighest,
        ),
        child: Icon(
          AppIcons.webhook,
          size: 20,
          color: webhook.enabled
              ? AppColors.primary
              : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
      title: Text(
        webhook.name.isNotEmpty ? webhook.name : l10n.webhookNoName,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: webhook.enabled
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            webhook.eventDescription,
            style: TextStyle(
              fontSize: 13,
              color: webhook.enabled
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          if (webhook.urls.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              webhook.urls.first,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.outline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
      isThreeLine: webhook.urls.isNotEmpty,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Switch(
              value: webhook.enabled,
              onChanged: onToggle,
              activeTrackColor: AppColors.primary,
            ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n.editWebhook),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, size: 20, color: AppColors.error),
                    const SizedBox(width: 12),
                    Text(
                      l10n.deleteWebhook,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
