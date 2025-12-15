import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_icons.dart';
import '../../providers/auth_provider.dart';
import '../../providers/device_provider.dart';
import '../../providers/scene_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/statistics_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 24),
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                AppIcons.profile,
                size: 48,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    AppIcons.email,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(l10n.email),
                  subtitle: Text(
                    user?.email ?? '-',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.public_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(l10n.timezoneLabel),
                  subtitle: Text(
                    user?.timezone ?? l10n.timezoneNotSet,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.cloud_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(l10n.serverUrl),
                  subtitle: Text(
                    _formatServerUrl(user?.userApiUrl),
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.tonal(
              onPressed: () => _showLogoutDialog(context),
              style: FilledButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                minimumSize: const Size.fromHeight(48),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(AppIcons.logout),
                  const SizedBox(width: 8),
                  Text(l10n.signOut),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatServerUrl(String? url) {
    if (url == null || url.isEmpty) return '-';
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (_) {
      return url;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.signOutConfirmTitle),
        content: Text(l10n.signOutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Clear all provider credentials before logout
              context.read<DeviceProvider>().setCredentials(null, null);
              context.read<SceneProvider>().setCredentials(null, null);
              context.read<ScheduleProvider>().setCredentials(null, null);
              context.read<StatisticsProvider>().setCredentials(null, null);
              // Then logout
              context.read<AuthProvider>().logout();
              context.go('/login');
            },
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }
}
