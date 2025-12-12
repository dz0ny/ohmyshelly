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
          _buildThemeSection(context, l10n),
          const Divider(height: 1),
          _buildAppearanceSection(context, l10n),
          const Divider(height: 1),
          _buildLanguageSection(context, l10n),
        ],
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context, AppLocalizations l10n) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.theme,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            _buildThemeOption(
              context: context,
              title: l10n.themeSystem,
              isSelected: settings.themeMode == ThemeMode.system,
              onTap: () => settings.setThemeMode(ThemeMode.system),
            ),
            _buildThemeOption(
              context: context,
              title: l10n.themeLight,
              isSelected: settings.themeMode == ThemeMode.light,
              onTap: () => settings.setThemeMode(ThemeMode.light),
            ),
            _buildThemeOption(
              context: context,
              title: l10n.themeDark,
              isSelected: settings.themeMode == ThemeMode.dark,
              onTap: () => settings.setThemeMode(ThemeMode.dark),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildAppearanceSection(BuildContext context, AppLocalizations l10n) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.appearance,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            SwitchListTile(
              title: Text(l10n.showDevicesTab),
              subtitle: Text(
                l10n.showDevicesTabDesc,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              value: settings.showDevicesTab,
              onChanged: (value) => settings.setShowDevicesTab(value),
            ),
            SwitchListTile(
              title: Text(l10n.showScenesTab),
              subtitle: Text(
                l10n.showScenesTabDesc,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              value: settings.showScenesTab,
              onChanged: (value) => settings.setShowScenesTab(value),
            ),
          ],
        );
      },
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
              subtitle: _getSystemLanguageName(context),
              isSelected: settings.currentLanguageCode == null,
              onTap: () => settings.setLocale(null),
            ),
            // English variants
            _buildLanguageOption(
              context: context,
              title: l10n.languageEnglish,
              subtitle: 'English',
              isSelected: settings.currentLanguageCode == 'en',
              onTap: () => settings.setLocale(const Locale('en')),
            ),
            _buildLanguageOption(
              context: context,
              title: l10n.languageEnglishUS,
              subtitle: 'English (US)',
              isSelected: settings.currentLanguageCode == 'en_US',
              onTap: () => settings.setLocale(const Locale('en', 'US')),
            ),
            // Western Europe
            _buildLanguageOption(
              context: context,
              title: l10n.languageGerman,
              subtitle: 'Deutsch',
              isSelected: settings.currentLanguageCode == 'de',
              onTap: () => settings.setLocale(const Locale('de')),
            ),
            _buildLanguageOption(
              context: context,
              title: l10n.languageFrench,
              subtitle: 'Français',
              isSelected: settings.currentLanguageCode == 'fr',
              onTap: () => settings.setLocale(const Locale('fr')),
            ),
            _buildLanguageOption(
              context: context,
              title: l10n.languageFrenchCanada,
              subtitle: 'Français (Canada)',
              isSelected: settings.currentLanguageCode == 'fr_CA',
              onTap: () => settings.setLocale(const Locale('fr', 'CA')),
            ),
            _buildLanguageOption(
              context: context,
              title: l10n.languageSpanish,
              subtitle: 'Español',
              isSelected: settings.currentLanguageCode == 'es',
              onTap: () => settings.setLocale(const Locale('es')),
            ),
            _buildLanguageOption(
              context: context,
              title: l10n.languageSpanishMexico,
              subtitle: 'Español (México)',
              isSelected: settings.currentLanguageCode == 'es_MX',
              onTap: () => settings.setLocale(const Locale('es', 'MX')),
            ),
            _buildLanguageOption(
              context: context,
              title: l10n.languagePortuguese,
              subtitle: 'Português',
              isSelected: settings.currentLanguageCode == 'pt',
              onTap: () => settings.setLocale(const Locale('pt')),
            ),
            _buildLanguageOption(
              context: context,
              title: l10n.languageItalian,
              subtitle: 'Italiano',
              isSelected: settings.currentLanguageCode == 'it',
              onTap: () => settings.setLocale(const Locale('it')),
            ),
            _buildLanguageOption(
              context: context,
              title: l10n.languageDutch,
              subtitle: 'Nederlands',
              isSelected: settings.currentLanguageCode == 'nl',
              onTap: () => settings.setLocale(const Locale('nl')),
            ),
            _buildLanguageOption(
              context: context,
              title: l10n.languageCatalan,
              subtitle: 'Català',
              isSelected: settings.currentLanguageCode == 'ca',
              onTap: () => settings.setLocale(const Locale('ca')),
            ),
            // Nordic
            _buildLanguageOption(
              context: context,
              title: l10n.languageSwedish,
              subtitle: 'Svenska',
              isSelected: settings.currentLanguageCode == 'sv',
              onTap: () => settings.setLocale(const Locale('sv')),
            ),
            _buildLanguageOption(
              context: context,
              title: l10n.languageNorwegian,
              subtitle: 'Norsk',
              isSelected: settings.currentLanguageCode == 'no',
              onTap: () => settings.setLocale(const Locale('no')),
            ),
            _buildLanguageOption(
              context: context,
              title: l10n.languageDanish,
              subtitle: 'Dansk',
              isSelected: settings.currentLanguageCode == 'da',
              onTap: () => settings.setLocale(const Locale('da')),
            ),
            _buildLanguageOption(
              context: context,
              title: l10n.languageFinnish,
              subtitle: 'Suomi',
              isSelected: settings.currentLanguageCode == 'fi',
              onTap: () => settings.setLocale(const Locale('fi')),
            ),
            _buildLanguageOption(
              context: context,
              title: l10n.languageIcelandic,
              subtitle: 'Íslenska',
              isSelected: settings.currentLanguageCode == 'is',
              onTap: () => settings.setLocale(const Locale('is')),
            ),
            // Central Europe
            _buildLanguageOption(
              context: context,
              title: l10n.languagePolish,
              subtitle: 'Polski',
              isSelected: settings.currentLanguageCode == 'pl',
              onTap: () => settings.setLocale(const Locale('pl')),
            ),
            _buildLanguageOption(
              context: context,
              title: l10n.languageCzech,
              subtitle: 'Čeština',
              isSelected: settings.currentLanguageCode == 'cs',
              onTap: () => settings.setLocale(const Locale('cs')),
            ),
            _buildLanguageOption(
              context: context,
              title: l10n.languageSlovak,
              subtitle: 'Slovenčina',
              isSelected: settings.currentLanguageCode == 'sk',
              onTap: () => settings.setLocale(const Locale('sk')),
            ),
            _buildLanguageOption(
              context: context,
              title: l10n.languageHungarian,
              subtitle: 'Magyar',
              isSelected: settings.currentLanguageCode == 'hu',
              onTap: () => settings.setLocale(const Locale('hu')),
            ),
            // Eastern Europe
            _buildLanguageOption(
              context: context,
              title: l10n.languageRomanian,
              subtitle: 'Română',
              isSelected: settings.currentLanguageCode == 'ro',
              onTap: () => settings.setLocale(const Locale('ro')),
            ),
            _buildLanguageOption(
              context: context,
              title: l10n.languageBulgarian,
              subtitle: 'Български',
              isSelected: settings.currentLanguageCode == 'bg',
              onTap: () => settings.setLocale(const Locale('bg')),
            ),
            _buildLanguageOption(
              context: context,
              title: l10n.languageUkrainian,
              subtitle: 'Українська',
              isSelected: settings.currentLanguageCode == 'uk',
              onTap: () => settings.setLocale(const Locale('uk')),
            ),
            _buildLanguageOption(
              context: context,
              title: l10n.languageRussian,
              subtitle: 'Русский',
              isSelected: settings.currentLanguageCode == 'ru',
              onTap: () => settings.setLocale(const Locale('ru')),
            ),
            // Baltic
            _buildLanguageOption(
              context: context,
              title: l10n.languageLithuanian,
              subtitle: 'Lietuvių',
              isSelected: settings.currentLanguageCode == 'lt',
              onTap: () => settings.setLocale(const Locale('lt')),
            ),
            _buildLanguageOption(
              context: context,
              title: l10n.languageLatvian,
              subtitle: 'Latviešu',
              isSelected: settings.currentLanguageCode == 'lv',
              onTap: () => settings.setLocale(const Locale('lv')),
            ),
            _buildLanguageOption(
              context: context,
              title: l10n.languageEstonian,
              subtitle: 'Eesti',
              isSelected: settings.currentLanguageCode == 'et',
              onTap: () => settings.setLocale(const Locale('et')),
            ),
            // Balkan
            _buildLanguageOption(
              context: context,
              title: l10n.languageSlovenian,
              subtitle: 'Slovenščina',
              isSelected: settings.currentLanguageCode == 'sl',
              onTap: () => settings.setLocale(const Locale('sl')),
            ),
            _buildLanguageOption(
              context: context,
              title: l10n.languageCroatian,
              subtitle: 'Hrvatski',
              isSelected: settings.currentLanguageCode == 'hr',
              onTap: () => settings.setLocale(const Locale('hr')),
            ),
            _buildLanguageOption(
              context: context,
              title: l10n.languageSerbian,
              subtitle: 'Српски',
              isSelected: settings.currentLanguageCode == 'sr',
              onTap: () => settings.setLocale(const Locale('sr')),
            ),
            _buildLanguageOption(
              context: context,
              title: l10n.languageGreek,
              subtitle: 'Ελληνικά',
              isSelected: settings.currentLanguageCode == 'el',
              onTap: () => settings.setLocale(const Locale('el')),
            ),
          ],
        );
      },
    );
  }

  String _getSystemLanguageName(BuildContext context) {
    final systemLocale = View.of(context).platformDispatcher.locale;
    final code = systemLocale.languageCode;
    final country = systemLocale.countryCode;

    // Handle regional variants first
    if (code == 'en' && country == 'US') return 'English (US)';
    if (code == 'es' && country == 'MX') return 'Español (México)';
    if (code == 'fr' && country == 'CA') return 'Français (Canada)';

    switch (code) {
      case 'en': return 'English';
      case 'de': return 'Deutsch';
      case 'fr': return 'Français';
      case 'es': return 'Español';
      case 'pt': return 'Português';
      case 'it': return 'Italiano';
      case 'nl': return 'Nederlands';
      case 'ca': return 'Català';
      case 'sv': return 'Svenska';
      case 'no': return 'Norsk';
      case 'da': return 'Dansk';
      case 'fi': return 'Suomi';
      case 'is': return 'Íslenska';
      case 'pl': return 'Polski';
      case 'cs': return 'Čeština';
      case 'sk': return 'Slovenčina';
      case 'hu': return 'Magyar';
      case 'ro': return 'Română';
      case 'bg': return 'Български';
      case 'uk': return 'Українська';
      case 'ru': return 'Русский';
      case 'lt': return 'Lietuvių';
      case 'lv': return 'Latviešu';
      case 'et': return 'Eesti';
      case 'sl': return 'Slovenščina';
      case 'hr': return 'Hrvatski';
      case 'sr': return 'Српски';
      case 'el': return 'Ελληνικά';
      default: return 'English';
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
