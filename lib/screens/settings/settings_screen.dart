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
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.theme,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ThemeMode>(
                initialValue: settings.themeMode,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text(l10n.themeSystem),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text(l10n.themeLight),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text(l10n.themeDark),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    settings.setThemeMode(value);
                  }
                },
              ),
            ],
          ),
        );
      },
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
            SwitchListTile(
              title: Text(l10n.showDeviceInfoButton),
              subtitle: Text(
                l10n.showDeviceInfoButtonDesc,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              value: settings.showDeviceInfoButton,
              onChanged: (value) => settings.setShowDeviceInfoButton(value),
            ),
            SwitchListTile(
              title: Text(l10n.showScheduleButton),
              subtitle: Text(
                l10n.showScheduleButtonDesc,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              value: settings.showScheduleButton,
              onChanged: (value) => settings.setShowScheduleButton(value),
            ),
            SwitchListTile(
              title: Text(l10n.showActionsButton),
              subtitle: Text(
                l10n.showActionsButtonDesc,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              value: settings.showActionsButton,
              onChanged: (value) => settings.setShowActionsButton(value),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageSection(BuildContext context, AppLocalizations l10n) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final languageOptions = _getLanguageOptions(context, l10n);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.language,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: settings.currentLanguageCode,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                isExpanded: true,
                items: languageOptions.map((option) {
                  return DropdownMenuItem<String?>(
                    value: option.code,
                    child: Text(
                      option.code == null
                          ? '${option.title} (${option.nativeName})'
                          : '${option.title} - ${option.nativeName}',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) {
                    settings.setLocale(null);
                  } else {
                    settings.setLocale(Locale(value));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<_LanguageOption> _getLanguageOptions(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return [
      _LanguageOption(null, l10n.languageSystem, _getSystemLanguageName(context)),
      _LanguageOption('en', l10n.languageEnglish, 'English'),
      _LanguageOption('de', l10n.languageGerman, 'Deutsch'),
      _LanguageOption('fr', l10n.languageFrench, 'Français'),
      _LanguageOption('es', l10n.languageSpanish, 'Español'),
      _LanguageOption('pt', l10n.languagePortuguese, 'Português'),
      _LanguageOption('it', l10n.languageItalian, 'Italiano'),
      _LanguageOption('nl', l10n.languageDutch, 'Nederlands'),
      _LanguageOption('ca', l10n.languageCatalan, 'Català'),
      _LanguageOption('sv', l10n.languageSwedish, 'Svenska'),
      _LanguageOption('no', l10n.languageNorwegian, 'Norsk'),
      _LanguageOption('da', l10n.languageDanish, 'Dansk'),
      _LanguageOption('fi', l10n.languageFinnish, 'Suomi'),
      _LanguageOption('is', l10n.languageIcelandic, 'Íslenska'),
      _LanguageOption('pl', l10n.languagePolish, 'Polski'),
      _LanguageOption('cs', l10n.languageCzech, 'Čeština'),
      _LanguageOption('sk', l10n.languageSlovak, 'Slovenčina'),
      _LanguageOption('hu', l10n.languageHungarian, 'Magyar'),
      _LanguageOption('ro', l10n.languageRomanian, 'Română'),
      _LanguageOption('bg', l10n.languageBulgarian, 'Български'),
      _LanguageOption('uk', l10n.languageUkrainian, 'Українська'),
      _LanguageOption('ru', l10n.languageRussian, 'Русский'),
      _LanguageOption('lt', l10n.languageLithuanian, 'Lietuvių'),
      _LanguageOption('lv', l10n.languageLatvian, 'Latviešu'),
      _LanguageOption('et', l10n.languageEstonian, 'Eesti'),
      _LanguageOption('sl', l10n.languageSlovenian, 'Slovenščina'),
      _LanguageOption('hr', l10n.languageCroatian, 'Hrvatski'),
      _LanguageOption('sr', l10n.languageSerbian, 'Српски'),
      _LanguageOption('el', l10n.languageGreek, 'Ελληνικά'),
    ];
  }

  String _getSystemLanguageName(BuildContext context) {
    final systemLocale = View.of(context).platformDispatcher.locale;
    final code = systemLocale.languageCode;
    final country = systemLocale.countryCode;

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
}

class _LanguageOption {
  final String? code;
  final String title;
  final String nativeName;

  _LanguageOption(this.code, this.title, this.nativeName);
}
