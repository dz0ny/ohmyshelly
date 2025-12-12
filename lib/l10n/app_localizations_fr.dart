// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'OhMyShelly';

  @override
  String get appTagline => 'Maison intelligente simplifiée';

  @override
  String get onboardingTitle1 => 'Votre tableau de bord domotique';

  @override
  String get onboardingDesc1 =>
      'Voyez tous vos appareils en un coup d\'œil. Surveillez la consommation d\'énergie, les données météo et l\'état des appareils en temps réel. Organisez par pièces.';

  @override
  String get onboardingTitle2 => 'Statistiques détaillées';

  @override
  String get onboardingDesc2 =>
      'Consultez les graphiques historiques pour la consommation d\'énergie et la météo. Suivez les tendances par jour, semaine, mois ou année avec de beaux graphiques.';

  @override
  String get onboardingTitle3 => 'Horaires et automatisation';

  @override
  String get onboardingDesc3 =>
      'Créez des horaires pour allumer ou éteindre automatiquement les appareils. Définissez les heures, choisissez les jours et laissez votre maison fonctionner toute seule.';

  @override
  String get getStarted => 'Commencer';

  @override
  String get skip => 'Passer';

  @override
  String get next => 'Suivant';

  @override
  String get signIn => 'Se connecter';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get emailHint => 'Entrez votre e-mail Shelly Cloud';

  @override
  String get passwordHint => 'Entrez votre mot de passe';

  @override
  String get signingIn => 'Connexion en cours...';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get invalidCredentials => 'E-mail ou mot de passe incorrect';

  @override
  String get connectionError =>
      'Impossible de se connecter. Vérifiez votre internet.';

  @override
  String get devices => 'Appareils';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get myDevices => 'Mes appareils';

  @override
  String get noDevices => 'Aucun appareil trouvé';

  @override
  String get noDevicesDesc =>
      'Ajoutez des appareils dans votre compte Shelly Cloud';

  @override
  String get smartPlug => 'Prise intelligente';

  @override
  String get weatherStation => 'Station météo';

  @override
  String get gatewayDevice => 'Passerelle';

  @override
  String get unknownDevice => 'Appareil';

  @override
  String get otherDevices => 'Autres';

  @override
  String get online => 'Connecté';

  @override
  String get offline => 'Hors ligne';

  @override
  String get on => 'Allumé';

  @override
  String get off => 'Éteint';

  @override
  String get power => 'Puissance';

  @override
  String get voltage => 'Tension';

  @override
  String get current => 'Courant';

  @override
  String get temperature => 'Température';

  @override
  String get feelsLike => 'Ressenti';

  @override
  String get totalEnergy => 'Énergie totale';

  @override
  String get humidity => 'Humidité';

  @override
  String get pressure => 'Pression';

  @override
  String get uvIndex => 'Indice UV';

  @override
  String get windSpeed => 'Vent';

  @override
  String get windGust => 'Rafales';

  @override
  String get windDirection => 'Direction';

  @override
  String get rain => 'Pluie';

  @override
  String get rainToday => 'Aujourd\'hui';

  @override
  String get illumination => 'Luminosité';

  @override
  String get solar => 'Solaire';

  @override
  String get battery => 'Batterie';

  @override
  String get uvLow => 'Faible';

  @override
  String get uvModerate => 'Modéré';

  @override
  String get uvHigh => 'Élevé';

  @override
  String get uvVeryHigh => 'Très élevé';

  @override
  String get uvExtreme => 'Extrême';

  @override
  String get pressureRising => 'En hausse';

  @override
  String get pressureFalling => 'En baisse';

  @override
  String get pressureStable => 'Stable';

  @override
  String get totalDevices => 'Total des appareils';

  @override
  String get activeDevices => 'Actifs';

  @override
  String get totalPower => 'Puissance totale';

  @override
  String get currentWeather => 'Météo actuelle';

  @override
  String get statistics => 'Statistiques';

  @override
  String get viewHistory => 'Voir l\'historique';

  @override
  String get hour => 'Heure';

  @override
  String get day => 'Jour';

  @override
  String get week => 'Semaine';

  @override
  String get month => 'Mois';

  @override
  String get year => 'Année';

  @override
  String get average => 'Moyenne';

  @override
  String get peak => 'Pic';

  @override
  String get total => 'Total';

  @override
  String get min => 'Min';

  @override
  String get max => 'Max';

  @override
  String get errorGeneric => 'Une erreur s\'est produite';

  @override
  String get errorNetwork => 'Vérifiez votre connexion internet';

  @override
  String get retry => 'Réessayer';

  @override
  String get pullToRefresh => 'Tirer pour actualiser';

  @override
  String get loadingDevices => 'Chargement des appareils...';

  @override
  String get watts => 'W';

  @override
  String get kilowattHours => 'kWh';

  @override
  String get volts => 'V';

  @override
  String get amps => 'A';

  @override
  String get celsius => '°C';

  @override
  String get percent => '%';

  @override
  String get hectopascals => 'hPa';

  @override
  String get kmPerHour => 'km/h';

  @override
  String get millimeters => 'mm';

  @override
  String get lux => 'lux';

  @override
  String get settings => 'Paramètres';

  @override
  String get appearance => 'Apparence';

  @override
  String get theme => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get showDevicesTab => 'Afficher l\'onglet Appareils';

  @override
  String get showDevicesTabDesc =>
      'Lorsque désactivé, seul le tableau de bord est affiché';

  @override
  String get language => 'Langue';

  @override
  String get languageSystem => 'Par défaut du système';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageSlovenian => 'Slovène';

  @override
  String get languageGerman => 'Allemand';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String get languagePortuguese => 'Portugais';

  @override
  String get languageItalian => 'Italien';

  @override
  String get languageDutch => 'Néerlandais';

  @override
  String get languageCatalan => 'Catalan';

  @override
  String get languageSwedish => 'Suédois';

  @override
  String get languageNorwegian => 'Norvégien';

  @override
  String get languageDanish => 'Danois';

  @override
  String get languageFinnish => 'Finnois';

  @override
  String get languageIcelandic => 'Islandais';

  @override
  String get languagePolish => 'Polonais';

  @override
  String get languageCzech => 'Tchèque';

  @override
  String get languageSlovak => 'Slovaque';

  @override
  String get languageHungarian => 'Hongrois';

  @override
  String get languageRomanian => 'Roumain';

  @override
  String get languageBulgarian => 'Bulgare';

  @override
  String get languageUkrainian => 'Ukrainien';

  @override
  String get languageRussian => 'Russe';

  @override
  String get languageLithuanian => 'Lituanien';

  @override
  String get languageLatvian => 'Letton';

  @override
  String get languageEstonian => 'Estonien';

  @override
  String get languageCroatian => 'Croate';

  @override
  String get languageSerbian => 'Serbe';

  @override
  String get languageGreek => 'Grec';

  @override
  String get languageSpanishMexico => 'Espagnol (Mexique)';

  @override
  String get languageFrenchCanada => 'Français (Canada)';

  @override
  String get languageEnglishUS => 'Anglais (US)';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get signOutConfirmTitle => 'Se déconnecter';

  @override
  String get signOutConfirmMessage =>
      'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get lastUpdated => 'Mis à jour';

  @override
  String get summary => 'Résumé';

  @override
  String get peakUv => 'UV max';

  @override
  String get powerUsage => 'Consommation';

  @override
  String get noPowerData => 'Aucune donnée de puissance pour cette période';

  @override
  String get noWeatherData => 'Aucune donnée météo pour cette période';

  @override
  String get noDataAvailable => 'Aucune donnée disponible';

  @override
  String get loadingStatistics => 'Chargement des statistiques...';

  @override
  String get windHistoryNotAvailable =>
      'L\'historique du vent n\'est pas disponible';

  @override
  String get humidityAvg => 'Humidité (moy)';

  @override
  String get rainTotal => 'Pluie (total)';

  @override
  String get directionN => 'N';

  @override
  String get directionNE => 'NE';

  @override
  String get directionE => 'E';

  @override
  String get directionSE => 'SE';

  @override
  String get directionS => 'S';

  @override
  String get directionSW => 'SO';

  @override
  String get directionW => 'O';

  @override
  String get directionNW => 'NO';

  @override
  String get profile => 'Profil';

  @override
  String get account => 'Compte';

  @override
  String get serverUrl => 'Serveur';

  @override
  String get timezoneLabel => 'Fuseau horaire';

  @override
  String get timezoneNotSet => 'Non défini';

  @override
  String get powerHistory => 'Historique de puissance';

  @override
  String get weatherHistory => 'Historique météo';

  @override
  String get temperatureHistory => 'Historique de température';

  @override
  String get humidityHistory => 'Historique d\'humidité';

  @override
  String get pressureHistory => 'Historique de pression';

  @override
  String get uvHistory => 'Historique UV';

  @override
  String get rainHistory => 'Historique de pluie';

  @override
  String get solarHistory => 'Historique solaire';

  @override
  String get voltageHistory => 'Historique de tension';

  @override
  String get currentHistory => 'Historique de courant';

  @override
  String get energyHistory => 'Historique d\'énergie';

  @override
  String get currentPowerUsage => 'Puissance';

  @override
  String get dayMon => 'Lun';

  @override
  String get dayTue => 'Mar';

  @override
  String get dayWed => 'Mer';

  @override
  String get dayThu => 'Jeu';

  @override
  String get dayFri => 'Ven';

  @override
  String get daySat => 'Sam';

  @override
  String get daySun => 'Dim';

  @override
  String get monthJan => 'Jan';

  @override
  String get monthFeb => 'Fév';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Avr';

  @override
  String get monthMay => 'Mai';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Aoû';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Déc';

  @override
  String get monthJanFull => 'Janvier';

  @override
  String get monthFebFull => 'Février';

  @override
  String get monthMarFull => 'Mars';

  @override
  String get monthAprFull => 'Avril';

  @override
  String get monthMayFull => 'Mai';

  @override
  String get monthJunFull => 'Juin';

  @override
  String get monthJulFull => 'Juillet';

  @override
  String get monthAugFull => 'Août';

  @override
  String get monthSepFull => 'Septembre';

  @override
  String get monthOctFull => 'Octobre';

  @override
  String get monthNovFull => 'Novembre';

  @override
  String get monthDecFull => 'Décembre';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get lastWeek => 'Semaine dernière';

  @override
  String get thisMonth => 'Ce mois-ci';

  @override
  String get lastMonth => 'Mois dernier';

  @override
  String get thisYear => 'Cette année';

  @override
  String get nextYear => 'Année prochaine';

  @override
  String get selectMonth => 'Sélectionner le mois';

  @override
  String get selectYear => 'Sélectionner l\'année';

  @override
  String get solarDark => 'Sombre';

  @override
  String get solarCloudy => 'Nuageux';

  @override
  String get solarPartlySunny => 'Partiellement ensoleillé';

  @override
  String get solarSunny => 'Ensoleillé';

  @override
  String get solarVerySunny => 'Très ensoleillé';

  @override
  String get batteryFull => 'Pleine';

  @override
  String get batteryGood => 'Bonne';

  @override
  String get batteryLow => 'Faible';

  @override
  String get batteryCritical => 'Critique';

  @override
  String get updateAvailable => 'Mise à jour disponible';

  @override
  String updateVersion(String version) {
    return 'Version $version';
  }

  @override
  String get updateDownload => 'Télécharger';

  @override
  String get updateDownloading => 'Téléchargement de la mise à jour...';

  @override
  String get updateReady => 'Mise à jour prête';

  @override
  String get updateTapToInstall => 'Appuyez pour installer';

  @override
  String get updateInstall => 'Installer';

  @override
  String get updateError => 'Erreur de mise à jour';

  @override
  String get updateClose => 'Fermer';

  @override
  String get schedules => 'Horaires';

  @override
  String get noSchedules => 'Aucun horaire';

  @override
  String get addSchedule => 'Ajouter un horaire';

  @override
  String get editSchedule => 'Modifier';

  @override
  String get deleteSchedule => 'Supprimer';

  @override
  String get deleteScheduleConfirm =>
      'Êtes-vous sûr de vouloir supprimer cet horaire ?';

  @override
  String get scheduleTime => 'Heure';

  @override
  String get scheduleDays => 'Jours';

  @override
  String get scheduleAction => 'Action';

  @override
  String get turnOn => 'Allumer';

  @override
  String get turnOff => 'Éteindre';

  @override
  String get everyDay => 'Tous les jours';

  @override
  String get weekdays => 'Jours de semaine';

  @override
  String get weekends => 'Week-ends';

  @override
  String get save => 'Enregistrer';

  @override
  String get autoUpdateSchedule => 'Auto-Update';

  @override
  String get autoUpdateScheduleDesc => 'Firmware updates at midnight';

  @override
  String get systemSchedule => 'System';

  @override
  String get userSchedules => 'User Schedules';

  @override
  String get activity => 'Activité';

  @override
  String get noActivity => 'Aucune activité récente';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get noRecentActivity => 'No recent activity';

  @override
  String get turnedOn => 'Turned on';

  @override
  String get turnedOff => 'Turned off';

  @override
  String get sourceButton => 'Bouton';

  @override
  String get sourceSchedule => 'Horaire';

  @override
  String get sourceApp => 'App';

  @override
  String get sourceSystem => 'Système';

  @override
  String get sourceUnknown => 'Inconnu';

  @override
  String get justNow => 'À l\'instant';

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count minutes',
      one: 'Il y a 1 minute',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count heures',
      one: 'Il y a 1 heure',
    );
    return '$_temp0';
  }

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get yesterday => 'Hier';

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count jours',
      one: 'Il y a 1 jour',
    );
    return '$_temp0';
  }

  @override
  String get deviceInfo => 'Informations sur l\'appareil';

  @override
  String get name => 'Nom';

  @override
  String get model => 'Modèle';

  @override
  String get type => 'Type';

  @override
  String get generation => 'Génération';

  @override
  String get deviceId => 'ID de l\'appareil';

  @override
  String get serial => 'Numéro de série';

  @override
  String get firmware => 'Micrologiciel';

  @override
  String get room => 'Pièce';

  @override
  String get connection => 'Connexion';

  @override
  String get status => 'État';

  @override
  String get wifiNetwork => 'Réseau WiFi';

  @override
  String get ipAddress => 'Adresse IP';

  @override
  String get signalStrength => 'Puissance du signal';

  @override
  String get signalExcellent => 'Excellent';

  @override
  String get signalGood => 'Bon';

  @override
  String get signalFair => 'Moyen';

  @override
  String get signalWeak => 'Faible';

  @override
  String get signalUnknown => 'Inconnu';

  @override
  String get uptime => 'Temps de fonctionnement';

  @override
  String get ramFree => 'RAM libre';

  @override
  String get deviceOffline => 'L\'appareil est hors ligne';

  @override
  String get tapForHistory => 'Appuyez pour l\'historique';

  @override
  String get reorderDevices => 'Réorganiser';

  @override
  String get reorderDevicesDone => 'Terminé';

  @override
  String get dragToReorder => 'Faites glisser pour réorganiser les appareils';

  @override
  String get scenes => 'Scènes';

  @override
  String get noScenes => 'Aucune scène trouvée';

  @override
  String get noScenesDesc => 'Créez des scènes dans votre compte Shelly Cloud';

  @override
  String get showScenesTab => 'Afficher l\'onglet Scènes';

  @override
  String get showScenesTabDesc =>
      'Afficher les scènes d\'automatisation dans la navigation';

  @override
  String get sceneEnabled => 'Activé';

  @override
  String get sceneDisabled => 'Désactivé';

  @override
  String get loadingScenes => 'Chargement des scènes...';

  @override
  String get runScene => 'Exécuter';

  @override
  String get sceneRunning => 'En cours d\'exécution...';

  @override
  String get hideFromDashboard => 'Masquer du tableau de bord';

  @override
  String get hideFromDashboardDesc =>
      'L\'appareil n\'apparaîtra que dans l\'onglet Appareils';

  @override
  String get unsupportedDevice => 'Appareil non pris en charge';

  @override
  String unsupportedDeviceDesc(String code) {
    return 'Le type d\'appareil \"$code\" n\'est pas encore pris en charge. Les données brutes sont affichées ci-dessous.';
  }

  @override
  String get deviceData => 'Données de l\'appareil';

  @override
  String get copyJson => 'Copier JSON';

  @override
  String get copiedToClipboard => 'Copié dans le presse-papiers';
}

/// The translations for French, as used in Canada (`fr_CA`).
class AppLocalizationsFrCa extends AppLocalizationsFr {
  AppLocalizationsFrCa() : super('fr_CA');

  @override
  String get appName => 'OhMyShelly';

  @override
  String get appTagline => 'Maison Intelligente Simplifiée';

  @override
  String get onboardingTitle1 => 'Votre Tableau de Bord Maison';

  @override
  String get onboardingDesc1 =>
      'Voyez tous vos appareils d\'un coup d\'œil. Surveillez la consommation d\'énergie, les données météo et l\'état des appareils en temps réel. Organisez par pièces.';

  @override
  String get onboardingTitle2 => 'Statistiques Détaillées';

  @override
  String get onboardingDesc2 =>
      'Visualisez les graphiques historiques pour l\'utilisation d\'énergie et la météo. Suivez les tendances par jour, semaine, mois ou année avec de beaux graphiques.';

  @override
  String get onboardingTitle3 => 'Horaires et Automatisation';

  @override
  String get onboardingDesc3 =>
      'Créez des horaires pour allumer ou éteindre les appareils automatiquement. Définissez les heures, choisissez les jours et laissez votre maison fonctionner toute seule.';

  @override
  String get getStarted => 'Commencer';

  @override
  String get skip => 'Passer';

  @override
  String get next => 'Suivant';

  @override
  String get signIn => 'Se Connecter';

  @override
  String get email => 'Courriel';

  @override
  String get password => 'Mot de Passe';

  @override
  String get emailHint => 'Entrez votre courriel Shelly Cloud';

  @override
  String get passwordHint => 'Entrez votre mot de passe';

  @override
  String get signingIn => 'Connexion en cours...';

  @override
  String get signOut => 'Se Déconnecter';

  @override
  String get invalidCredentials => 'Courriel ou mot de passe incorrect';

  @override
  String get connectionError =>
      'Impossible de se connecter. Vérifiez votre internet.';

  @override
  String get devices => 'Appareils';

  @override
  String get dashboard => 'Tableau de Bord';

  @override
  String get myDevices => 'Mes Appareils';

  @override
  String get noDevices => 'Aucun appareil trouvé';

  @override
  String get noDevicesDesc =>
      'Ajoutez des appareils dans votre compte Shelly Cloud';

  @override
  String get smartPlug => 'Prise Intelligente';

  @override
  String get weatherStation => 'Station Météo';

  @override
  String get gatewayDevice => 'Passerelle';

  @override
  String get unknownDevice => 'Appareil';

  @override
  String get otherDevices => 'Autres';

  @override
  String get online => 'Connecté';

  @override
  String get offline => 'Hors Ligne';

  @override
  String get on => 'Allumé';

  @override
  String get off => 'Éteint';

  @override
  String get power => 'Puissance';

  @override
  String get voltage => 'Tension';

  @override
  String get current => 'Courant';

  @override
  String get temperature => 'Température';

  @override
  String get feelsLike => 'Ressenti';

  @override
  String get totalEnergy => 'Énergie Totale';

  @override
  String get humidity => 'Humidité';

  @override
  String get pressure => 'Pression';

  @override
  String get uvIndex => 'Indice UV';

  @override
  String get windSpeed => 'Vent';

  @override
  String get windGust => 'Rafales';

  @override
  String get windDirection => 'Direction';

  @override
  String get rain => 'Pluie';

  @override
  String get rainToday => 'Aujourd\'hui';

  @override
  String get illumination => 'Illumination';

  @override
  String get solar => 'Solaire';

  @override
  String get battery => 'Batterie';

  @override
  String get uvLow => 'Faible';

  @override
  String get uvModerate => 'Modéré';

  @override
  String get uvHigh => 'Élevé';

  @override
  String get uvVeryHigh => 'Très Élevé';

  @override
  String get uvExtreme => 'Extrême';

  @override
  String get pressureRising => 'En Hausse';

  @override
  String get pressureFalling => 'En Baisse';

  @override
  String get pressureStable => 'Stable';

  @override
  String get totalDevices => 'Total d\'Appareils';

  @override
  String get activeDevices => 'Actifs';

  @override
  String get totalPower => 'Puissance Totale';

  @override
  String get currentWeather => 'Météo Actuelle';

  @override
  String get statistics => 'Statistiques';

  @override
  String get viewHistory => 'Voir l\'Historique';

  @override
  String get hour => 'Heure';

  @override
  String get day => 'Jour';

  @override
  String get week => 'Semaine';

  @override
  String get month => 'Mois';

  @override
  String get year => 'Année';

  @override
  String get average => 'Moyenne';

  @override
  String get peak => 'Pic';

  @override
  String get total => 'Total';

  @override
  String get min => 'Min';

  @override
  String get max => 'Max';

  @override
  String get errorGeneric => 'Quelque chose s\'est mal passé';

  @override
  String get errorNetwork => 'Vérifiez votre connexion internet';

  @override
  String get retry => 'Réessayer';

  @override
  String get pullToRefresh => 'Tirez pour actualiser';

  @override
  String get loadingDevices => 'Chargement des appareils...';

  @override
  String get watts => 'W';

  @override
  String get kilowattHours => 'kWh';

  @override
  String get volts => 'V';

  @override
  String get amps => 'A';

  @override
  String get celsius => '°C';

  @override
  String get percent => '%';

  @override
  String get hectopascals => 'hPa';

  @override
  String get kmPerHour => 'km/h';

  @override
  String get millimeters => 'mm';

  @override
  String get lux => 'lux';

  @override
  String get settings => 'Paramètres';

  @override
  String get appearance => 'Apparence';

  @override
  String get theme => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get showDevicesTab => 'Afficher l\'Onglet Appareils';

  @override
  String get showDevicesTabDesc =>
      'Lorsque désactivé, seul le Tableau de Bord est affiché';

  @override
  String get language => 'Langue';

  @override
  String get languageSystem => 'Par Défaut du Système';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageSlovenian => 'Slovène';

  @override
  String get languageGerman => 'Allemand';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String get languagePortuguese => 'Portugais';

  @override
  String get languageItalian => 'Italien';

  @override
  String get languageDutch => 'Néerlandais';

  @override
  String get languageCatalan => 'Catalan';

  @override
  String get languageSwedish => 'Suédois';

  @override
  String get languageNorwegian => 'Norvégien';

  @override
  String get languageDanish => 'Danois';

  @override
  String get languageFinnish => 'Finnois';

  @override
  String get languageIcelandic => 'Islandais';

  @override
  String get languagePolish => 'Polonais';

  @override
  String get languageCzech => 'Tchèque';

  @override
  String get languageSlovak => 'Slovaque';

  @override
  String get languageHungarian => 'Hongrois';

  @override
  String get languageRomanian => 'Roumain';

  @override
  String get languageBulgarian => 'Bulgare';

  @override
  String get languageUkrainian => 'Ukrainien';

  @override
  String get languageRussian => 'Russe';

  @override
  String get languageLithuanian => 'Lituanien';

  @override
  String get languageLatvian => 'Letton';

  @override
  String get languageEstonian => 'Estonien';

  @override
  String get languageCroatian => 'Croate';

  @override
  String get languageSerbian => 'Serbe';

  @override
  String get languageGreek => 'Grec';

  @override
  String get languageSpanishMexico => 'Espagnol (Mexique)';

  @override
  String get languageFrenchCanada => 'Français (Canada)';

  @override
  String get languageEnglishUS => 'Anglais (É.-U.)';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get signOutConfirmTitle => 'Se Déconnecter';

  @override
  String get signOutConfirmMessage =>
      'Êtes-vous sûr de vouloir vous déconnecter?';

  @override
  String get lastUpdated => 'Mis à jour';

  @override
  String get summary => 'Résumé';

  @override
  String get peakUv => 'UV Maximum';

  @override
  String get powerUsage => 'Utilisation d\'Énergie';

  @override
  String get noPowerData => 'Aucune donnée d\'énergie pour cette période';

  @override
  String get noWeatherData => 'Aucune donnée météo pour cette période';

  @override
  String get noDataAvailable => 'Aucune donnée disponible';

  @override
  String get loadingStatistics => 'Chargement des statistiques...';

  @override
  String get windHistoryNotAvailable =>
      'L\'historique du vent n\'est pas disponible';

  @override
  String get humidityAvg => 'Humidité (moy)';

  @override
  String get rainTotal => 'Pluie (total)';

  @override
  String get directionN => 'N';

  @override
  String get directionNE => 'NE';

  @override
  String get directionE => 'E';

  @override
  String get directionSE => 'SE';

  @override
  String get directionS => 'S';

  @override
  String get directionSW => 'SO';

  @override
  String get directionW => 'O';

  @override
  String get directionNW => 'NO';

  @override
  String get profile => 'Profil';

  @override
  String get account => 'Compte';

  @override
  String get serverUrl => 'Serveur';

  @override
  String get timezoneLabel => 'Fuseau Horaire';

  @override
  String get timezoneNotSet => 'Non défini';

  @override
  String get powerHistory => 'Historique de Puissance';

  @override
  String get weatherHistory => 'Historique Météo';

  @override
  String get temperatureHistory => 'Historique de Température';

  @override
  String get humidityHistory => 'Historique d\'Humidité';

  @override
  String get pressureHistory => 'Historique de Pression';

  @override
  String get uvHistory => 'Historique UV';

  @override
  String get rainHistory => 'Historique de Pluie';

  @override
  String get solarHistory => 'Historique Solaire';

  @override
  String get voltageHistory => 'Historique de Tension';

  @override
  String get currentHistory => 'Historique de Courant';

  @override
  String get energyHistory => 'Historique d\'Énergie';

  @override
  String get currentPowerUsage => 'Puissance';

  @override
  String get dayMon => 'Lun';

  @override
  String get dayTue => 'Mar';

  @override
  String get dayWed => 'Mer';

  @override
  String get dayThu => 'Jeu';

  @override
  String get dayFri => 'Ven';

  @override
  String get daySat => 'Sam';

  @override
  String get daySun => 'Dim';

  @override
  String get monthJan => 'Jan';

  @override
  String get monthFeb => 'Fév';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Avr';

  @override
  String get monthMay => 'Mai';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Aoû';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Déc';

  @override
  String get monthJanFull => 'Janvier';

  @override
  String get monthFebFull => 'Février';

  @override
  String get monthMarFull => 'Mars';

  @override
  String get monthAprFull => 'Avril';

  @override
  String get monthMayFull => 'Mai';

  @override
  String get monthJunFull => 'Juin';

  @override
  String get monthJulFull => 'Juillet';

  @override
  String get monthAugFull => 'Août';

  @override
  String get monthSepFull => 'Septembre';

  @override
  String get monthOctFull => 'Octobre';

  @override
  String get monthNovFull => 'Novembre';

  @override
  String get monthDecFull => 'Décembre';

  @override
  String get thisWeek => 'Cette Semaine';

  @override
  String get lastWeek => 'Semaine Dernière';

  @override
  String get thisMonth => 'Ce Mois-ci';

  @override
  String get lastMonth => 'Mois Dernier';

  @override
  String get thisYear => 'Cette Année';

  @override
  String get nextYear => 'Année Prochaine';

  @override
  String get selectMonth => 'Sélectionner le Mois';

  @override
  String get selectYear => 'Sélectionner l\'Année';

  @override
  String get solarDark => 'Sombre';

  @override
  String get solarCloudy => 'Nuageux';

  @override
  String get solarPartlySunny => 'Partiellement Ensoleillé';

  @override
  String get solarSunny => 'Ensoleillé';

  @override
  String get solarVerySunny => 'Très Ensoleillé';

  @override
  String get batteryFull => 'Pleine';

  @override
  String get batteryGood => 'Bonne';

  @override
  String get batteryLow => 'Faible';

  @override
  String get batteryCritical => 'Critique';

  @override
  String get updateAvailable => 'Mise à jour disponible';

  @override
  String updateVersion(String version) {
    return 'Version $version';
  }

  @override
  String get updateDownload => 'Télécharger';

  @override
  String get updateDownloading => 'Téléchargement de la mise à jour...';

  @override
  String get updateReady => 'Mise à jour prête';

  @override
  String get updateTapToInstall => 'Touchez pour installer';

  @override
  String get updateInstall => 'Installer';

  @override
  String get updateError => 'Erreur de mise à jour';

  @override
  String get updateClose => 'Fermer';

  @override
  String get schedules => 'Horaires';

  @override
  String get noSchedules => 'Aucun horaire';

  @override
  String get addSchedule => 'Ajouter un Horaire';

  @override
  String get editSchedule => 'Modifier';

  @override
  String get deleteSchedule => 'Supprimer';

  @override
  String get deleteScheduleConfirm =>
      'Êtes-vous sûr de vouloir supprimer cet horaire?';

  @override
  String get scheduleTime => 'Heure';

  @override
  String get scheduleDays => 'Jours';

  @override
  String get scheduleAction => 'Action';

  @override
  String get turnOn => 'Allumer';

  @override
  String get turnOff => 'Éteindre';

  @override
  String get everyDay => 'Tous les jours';

  @override
  String get weekdays => 'Jours de semaine';

  @override
  String get weekends => 'Fins de semaine';

  @override
  String get save => 'Enregistrer';

  @override
  String get activity => 'Activité';

  @override
  String get noActivity => 'Aucune activité récente';

  @override
  String get sourceButton => 'Bouton';

  @override
  String get sourceSchedule => 'Horaire';

  @override
  String get sourceApp => 'App';

  @override
  String get sourceSystem => 'Système';

  @override
  String get sourceUnknown => 'Inconnu';

  @override
  String get justNow => 'À l\'instant';

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count minutes',
      one: 'Il y a 1 minute',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count heures',
      one: 'Il y a 1 heure',
    );
    return '$_temp0';
  }

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get yesterday => 'Hier';

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count jours',
      one: 'Il y a 1 jour',
    );
    return '$_temp0';
  }

  @override
  String get deviceInfo => 'Informations sur l\'Appareil';

  @override
  String get name => 'Nom';

  @override
  String get model => 'Modèle';

  @override
  String get type => 'Type';

  @override
  String get generation => 'Génération';

  @override
  String get deviceId => 'ID de l\'Appareil';

  @override
  String get serial => 'Numéro de Série';

  @override
  String get firmware => 'Micrologiciel';

  @override
  String get room => 'Pièce';

  @override
  String get connection => 'Connexion';

  @override
  String get status => 'Statut';

  @override
  String get wifiNetwork => 'Réseau WiFi';

  @override
  String get ipAddress => 'Adresse IP';

  @override
  String get signalStrength => 'Force du Signal';

  @override
  String get signalExcellent => 'Excellent';

  @override
  String get signalGood => 'Bon';

  @override
  String get signalFair => 'Moyen';

  @override
  String get signalWeak => 'Faible';

  @override
  String get signalUnknown => 'Inconnu';

  @override
  String get uptime => 'Temps de Fonctionnement';

  @override
  String get ramFree => 'RAM Libre';

  @override
  String get deviceOffline => 'L\'appareil est hors ligne';

  @override
  String get tapForHistory => 'Touchez pour l\'historique';

  @override
  String get reorderDevices => 'Réorganiser';

  @override
  String get reorderDevicesDone => 'Terminé';

  @override
  String get dragToReorder => 'Glissez pour réorganiser les appareils';

  @override
  String get scenes => 'Scènes';

  @override
  String get noScenes => 'Aucune scène trouvée';

  @override
  String get noScenesDesc => 'Créez des scènes dans votre compte Shelly Cloud';

  @override
  String get showScenesTab => 'Afficher l\'Onglet Scènes';

  @override
  String get showScenesTabDesc =>
      'Afficher les scènes d\'automatisation dans la navigation';

  @override
  String get sceneEnabled => 'Activée';

  @override
  String get sceneDisabled => 'Désactivée';

  @override
  String get loadingScenes => 'Chargement des scènes...';

  @override
  String get runScene => 'Exécuter';

  @override
  String get sceneRunning => 'En cours d\'exécution...';

  @override
  String get hideFromDashboard => 'Masquer du tableau de bord';

  @override
  String get hideFromDashboardDesc =>
      'L\'appareil n\'apparaîtra que dans l\'onglet Appareils';

  @override
  String get unsupportedDevice => 'Appareil non pris en charge';

  @override
  String unsupportedDeviceDesc(String code) {
    return 'Le type d\'appareil \"$code\" n\'est pas encore pris en charge. Les données brutes sont affichées ci-dessous.';
  }

  @override
  String get deviceData => 'Données de l\'appareil';

  @override
  String get copyJson => 'Copier JSON';

  @override
  String get copiedToClipboard => 'Copié dans le presse-papiers';
}
