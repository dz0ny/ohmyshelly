import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          _buildLanguageSection(context, l10n),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context, AppLocalizations l10n) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.language,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            _buildLanguageOption(
              context: context,
              title: l10n.languageSystem,
              subtitle: _getSystemLanguageName(context, l10n),
              isSelected: settings.currentLanguageCode == null,
              onTap: () => settings.setLocale(null),
            ),
            _buildLanguageOption(
              context: context,
              title: l10n.languageEnglish,
              subtitle: 'English',
              isSelected: settings.currentLanguageCode == 'en',
              onTap: () => settings.setLocale(const Locale('en')),
            ),
            _buildLanguageOption(
              context: context,
              title: l10n.languageSlovenian,
              subtitle: 'Slovenscina',
              isSelected: settings.currentLanguageCode == 'sl',
              onTap: () => settings.setLocale(const Locale('sl')),
            ),
          ],
        );
      },
    );
  }

  String _getSystemLanguageName(BuildContext context, AppLocalizations l10n) {
    final systemLocale = View.of(context).platformDispatcher.locale;
    switch (systemLocale.languageCode) {
      case 'sl':
        return 'Slovenscina';
      case 'en':
      default:
        return 'English';
    }
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: onTap,
    );
  }
}
