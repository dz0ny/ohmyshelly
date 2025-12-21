// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class AppLocalizationsHr extends AppLocalizations {
  AppLocalizationsHr([String locale = 'hr']) : super(locale);

  @override
  String get appName => 'OhMyShelly';

  @override
  String get appTagline => 'Pametni dom učinjen jednostavnim';

  @override
  String get onboardingTitle1 => 'Vaša nadzorna ploča pametnog doma';

  @override
  String get onboardingDesc1 =>
      'Pogledajte sve svoje uređaje na jedan pogled. Pratite potrošnju energije, vremenske podatke i status uređaja u stvarnom vremenu. Organizirajte po sobama.';

  @override
  String get onboardingTitle2 => 'Detaljne statistike';

  @override
  String get onboardingDesc2 =>
      'Pregledajte povijesne grafikone za potrošnju energije i vrijeme. Pratite trendove po danu, tjednu, mjesecu ili godini s prekrasnim grafovima.';

  @override
  String get onboardingTitle3 => 'Raspored i automatizacija';

  @override
  String get onboardingDesc3 =>
      'Stvarajte rasporede za automatsko uključivanje ili isključivanje uređaja. Postavite vremena, odaberite dane i pustite da vaš dom radi sam.';

  @override
  String get getStarted => 'Započni';

  @override
  String get skip => 'Preskoči';

  @override
  String get next => 'Sljedeće';

  @override
  String get signIn => 'Prijava';

  @override
  String get email => 'Email';

  @override
  String get password => 'Lozinka';

  @override
  String get emailHint => 'Unesite svoj Shelly Cloud email';

  @override
  String get passwordHint => 'Unesite svoju lozinku';

  @override
  String get signingIn => 'Prijavljivanje...';

  @override
  String get signOut => 'Odjava';

  @override
  String get invalidCredentials => 'Netočan email ili lozinka';

  @override
  String get connectionError =>
      'Nije moguće povezati se. Provjerite internet vezu.';

  @override
  String get loginHint =>
      'Sign in with your Shelly Cloud account (control.shelly.cloud)';

  @override
  String get devices => 'Uređaji';

  @override
  String get dashboard => 'Nadzorna ploča';

  @override
  String get myDevices => 'Moji uređaji';

  @override
  String get noDevices => 'Nema pronađenih uređaja';

  @override
  String get noDevicesDesc => 'Dodajte uređaje u svoj Shelly Cloud račun';

  @override
  String get smartPlug => 'Pametna utičnica';

  @override
  String get weatherStation => 'Vremenska stanica';

  @override
  String get gatewayDevice => 'Pristupnik';

  @override
  String get unknownDevice => 'Uređaj';

  @override
  String get otherDevices => 'Ostalo';

  @override
  String get online => 'Povezano';

  @override
  String get offline => 'Nije povezano';

  @override
  String get on => 'Uključeno';

  @override
  String get off => 'Isključeno';

  @override
  String get power => 'Snaga';

  @override
  String get voltage => 'Napon';

  @override
  String get current => 'Struja';

  @override
  String get temperature => 'Temperatura';

  @override
  String get feelsLike => 'Osjeća se kao';

  @override
  String get dewPoint => 'Točka rose';

  @override
  String get totalEnergy => 'Ukupna energija';

  @override
  String get humidity => 'Vlažnost';

  @override
  String get pressure => 'Tlak';

  @override
  String get uvIndex => 'UV indeks';

  @override
  String get windSpeed => 'Vjetar';

  @override
  String get windGust => 'Udari';

  @override
  String get windDirection => 'Smjer';

  @override
  String get windCalm => 'Calm';

  @override
  String get windLight => 'Light Breeze';

  @override
  String get windModerate => 'Moderate';

  @override
  String get windStrong => 'Strong';

  @override
  String get windGale => 'Gale';

  @override
  String get windStorm => 'Storm';

  @override
  String get rain => 'Kiša';

  @override
  String get rainToday => 'Danas';

  @override
  String get rainDew => 'Dew';

  @override
  String get rainDrizzle => 'Drizzle';

  @override
  String get rainLight => 'Light Rain';

  @override
  String get rainModerate => 'Rain';

  @override
  String get rainHeavy => 'Heavy Rain';

  @override
  String get rainDownpour => 'Downpour';

  @override
  String get illumination => 'Osvjetljenje';

  @override
  String get solar => 'Sunčevo zračenje';

  @override
  String get battery => 'Baterija';

  @override
  String get uvLow => 'Nizak';

  @override
  String get uvModerate => 'Umjeren';

  @override
  String get uvHigh => 'Visok';

  @override
  String get uvVeryHigh => 'Vrlo visok';

  @override
  String get uvExtreme => 'Ekstremno';

  @override
  String get pressureRising => 'Raste';

  @override
  String get pressureFalling => 'Pada';

  @override
  String get pressureStable => 'Stabilan';

  @override
  String get totalDevices => 'Ukupno uređaja';

  @override
  String get activeDevices => 'Aktivno';

  @override
  String get totalPower => 'Ukupna snaga';

  @override
  String get currentWeather => 'Trenutno vrijeme';

  @override
  String get statistics => 'Statistika';

  @override
  String get viewHistory => 'Pogledaj povijest';

  @override
  String get hour => 'Sat';

  @override
  String get day => 'Dan';

  @override
  String get week => 'Tjedan';

  @override
  String get month => 'Mjesec';

  @override
  String get year => 'Godina';

  @override
  String get average => 'Prosjek';

  @override
  String get peak => 'Vrhunac';

  @override
  String get total => 'Ukupno';

  @override
  String get min => 'Min';

  @override
  String get max => 'Maks';

  @override
  String get errorGeneric => 'Nešto je pošlo po zlu';

  @override
  String get errorNetwork => 'Provjerite internet vezu';

  @override
  String get retry => 'Pokušaj ponovo';

  @override
  String get pullToRefresh => 'Povucite za osvježavanje';

  @override
  String get loadingDevices => 'Učitavanje uređaja...';

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
  String get settings => 'Postavke';

  @override
  String get appearance => 'Izgled';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sustav';

  @override
  String get themeLight => 'Svijetla';

  @override
  String get themeDark => 'Tamna';

  @override
  String get showDevicesTab => 'Prikaži karticu uređaja';

  @override
  String get showDevicesTabDesc =>
      'Kada je onemogućeno, prikazuje se samo nadzorna ploča';

  @override
  String get language => 'Jezik';

  @override
  String get languageSystem => 'Zadano sustava';

  @override
  String get languageEnglish => 'Engleski';

  @override
  String get languageSlovenian => 'Slovenski';

  @override
  String get languageGerman => 'Njemački';

  @override
  String get languageFrench => 'Francuski';

  @override
  String get languageSpanish => 'Španjolski';

  @override
  String get languagePortuguese => 'Portugalski';

  @override
  String get languageItalian => 'Talijanski';

  @override
  String get languageDutch => 'Nizozemski';

  @override
  String get languageCatalan => 'Katalonski';

  @override
  String get languageSwedish => 'Švedski';

  @override
  String get languageNorwegian => 'Norveški';

  @override
  String get languageDanish => 'Danski';

  @override
  String get languageFinnish => 'Finski';

  @override
  String get languageIcelandic => 'Islandski';

  @override
  String get languagePolish => 'Poljski';

  @override
  String get languageCzech => 'Češki';

  @override
  String get languageSlovak => 'Slovački';

  @override
  String get languageHungarian => 'Mađarski';

  @override
  String get languageRomanian => 'Rumunjski';

  @override
  String get languageBulgarian => 'Bugarski';

  @override
  String get languageUkrainian => 'Ukrajinski';

  @override
  String get languageRussian => 'Ruski';

  @override
  String get languageLithuanian => 'Litavski';

  @override
  String get languageLatvian => 'Latvijski';

  @override
  String get languageEstonian => 'Estonski';

  @override
  String get languageCroatian => 'Hrvatski';

  @override
  String get languageSerbian => 'Srpski';

  @override
  String get languageGreek => 'Grčki';

  @override
  String get cancel => 'Odustani';

  @override
  String get confirm => 'Potvrdi';

  @override
  String get signOutConfirmTitle => 'Odjava';

  @override
  String get signOutConfirmMessage => 'Jeste li sigurni da se želite odjaviti?';

  @override
  String get lastUpdated => 'Ažurirano';

  @override
  String get summary => 'Sažetak';

  @override
  String get peakUv => 'Vrhunac UV';

  @override
  String get powerUsage => 'Potrošnja energije';

  @override
  String get noPowerData => 'Nema podataka o energiji za ovo razdoblje';

  @override
  String get noWeatherData => 'Nema vremenskih podataka za ovo razdoblje';

  @override
  String get noDataAvailable => 'Nema dostupnih podataka';

  @override
  String get loadingStatistics => 'Učitavanje statistike...';

  @override
  String get windHistoryNotAvailable => 'Povijest vjetra nije dostupna';

  @override
  String get humidityAvg => 'Vlažnost (prosjek)';

  @override
  String get rainTotal => 'Kiša (ukupno)';

  @override
  String get directionN => 'S';

  @override
  String get directionNE => 'SI';

  @override
  String get directionE => 'I';

  @override
  String get directionSE => 'JI';

  @override
  String get directionS => 'J';

  @override
  String get directionSW => 'JZ';

  @override
  String get directionW => 'Z';

  @override
  String get directionNW => 'SZ';

  @override
  String get profile => 'Profil';

  @override
  String get account => 'Račun';

  @override
  String get serverUrl => 'Poslužitelj';

  @override
  String get timezoneLabel => 'Vremenska zona';

  @override
  String get timezoneNotSet => 'Nije postavljeno';

  @override
  String get powerHistory => 'Povijest snage';

  @override
  String get weatherHistory => 'Povijest vremena';

  @override
  String get temperatureHistory => 'Povijest temperature';

  @override
  String get humidityHistory => 'Povijest vlažnosti';

  @override
  String get pressureHistory => 'Povijest tlaka';

  @override
  String get uvHistory => 'Povijest UV';

  @override
  String get rainHistory => 'Povijest kiše';

  @override
  String get solarHistory => 'Povijest sunčevog zračenja';

  @override
  String get voltageHistory => 'Povijest napona';

  @override
  String get currentHistory => 'Povijest struje';

  @override
  String get energyHistory => 'Povijest energije';

  @override
  String get currentPowerUsage => 'Snaga';

  @override
  String get dayMon => 'Pon';

  @override
  String get dayTue => 'Uto';

  @override
  String get dayWed => 'Sri';

  @override
  String get dayThu => 'Čet';

  @override
  String get dayFri => 'Pet';

  @override
  String get daySat => 'Sub';

  @override
  String get daySun => 'Ned';

  @override
  String get monthJan => 'Sij';

  @override
  String get monthFeb => 'Velj';

  @override
  String get monthMar => 'Ožu';

  @override
  String get monthApr => 'Tra';

  @override
  String get monthMay => 'Svi';

  @override
  String get monthJun => 'Lip';

  @override
  String get monthJul => 'Srp';

  @override
  String get monthAug => 'Kol';

  @override
  String get monthSep => 'Ruj';

  @override
  String get monthOct => 'Lis';

  @override
  String get monthNov => 'Stu';

  @override
  String get monthDec => 'Pro';

  @override
  String get monthJanFull => 'Siječanj';

  @override
  String get monthFebFull => 'Veljača';

  @override
  String get monthMarFull => 'Ožujak';

  @override
  String get monthAprFull => 'Travanj';

  @override
  String get monthMayFull => 'Svibanj';

  @override
  String get monthJunFull => 'Lipanj';

  @override
  String get monthJulFull => 'Srpanj';

  @override
  String get monthAugFull => 'Kolovoz';

  @override
  String get monthSepFull => 'Rujan';

  @override
  String get monthOctFull => 'Listopad';

  @override
  String get monthNovFull => 'Studeni';

  @override
  String get monthDecFull => 'Prosinac';

  @override
  String get thisWeek => 'Ovaj tjedan';

  @override
  String get lastWeek => 'Prošli tjedan';

  @override
  String get thisMonth => 'Ovaj mjesec';

  @override
  String get lastMonth => 'Prošli mjesec';

  @override
  String get thisYear => 'Ova godina';

  @override
  String get nextYear => 'Sljedeća godina';

  @override
  String get selectMonth => 'Odaberi mjesec';

  @override
  String get selectYear => 'Odaberi godinu';

  @override
  String get solarDark => 'Tmurno';

  @override
  String get solarCloudy => 'Oblačno';

  @override
  String get solarPartlySunny => 'Djelomično sunčano';

  @override
  String get solarSunny => 'Sunčano';

  @override
  String get solarVerySunny => 'Vrlo sunčano';

  @override
  String get batteryFull => 'Puna';

  @override
  String get batteryGood => 'Dobra';

  @override
  String get batteryLow => 'Niska';

  @override
  String get batteryCritical => 'Kritična';

  @override
  String get updateAvailable => 'Dostupno ažuriranje';

  @override
  String updateVersion(String version) {
    return 'Verzija $version';
  }

  @override
  String get updateDownload => 'Preuzmi';

  @override
  String get updateDownloading => 'Preuzimanje ažuriranja...';

  @override
  String get updateReady => 'Ažuriranje spremno';

  @override
  String get updateTapToInstall => 'Dodirnite za instalaciju';

  @override
  String get updateInstall => 'Instaliraj';

  @override
  String get updateError => 'Greška ažuriranja';

  @override
  String get updateClose => 'Zatvori';

  @override
  String get schedules => 'Raspored';

  @override
  String get noSchedules => 'Nema rasporeda';

  @override
  String get addSchedule => 'Dodaj raspored';

  @override
  String get editSchedule => 'Uredi';

  @override
  String get deleteSchedule => 'Obriši';

  @override
  String get deleteScheduleConfirm =>
      'Jeste li sigurni da želite obrisati ovaj raspored?';

  @override
  String get scheduleTime => 'Vrijeme';

  @override
  String get scheduleDays => 'Dani';

  @override
  String get scheduleAction => 'Akcija';

  @override
  String get turnOn => 'Uključi';

  @override
  String get turnOff => 'Isključi';

  @override
  String get everyDay => 'Svaki dan';

  @override
  String get weekdays => 'Radni dani';

  @override
  String get weekends => 'Vikendi';

  @override
  String get save => 'Spremi';

  @override
  String get autoUpdateSchedule => 'Automatsko ažuriranje';

  @override
  String get autoUpdateScheduleDesc => 'Ažuriranja firmvera u ponoć';

  @override
  String get addAutoUpdateSchedule => 'Dodaj auto-ažuriranje';

  @override
  String get editAutoUpdateSchedule => 'Uredi auto-ažuriranje';

  @override
  String get autoUpdateScheduleHint =>
      'Rasporedi kada uređaj provjerava ažuriranja firmvera';

  @override
  String get systemSchedule => 'Sustav';

  @override
  String get userSchedules => 'Korisnički rasporedi';

  @override
  String get activity => 'Aktivnost';

  @override
  String get noActivity => 'Nema nedavne aktivnosti';

  @override
  String get recentActivity => 'Nedavna aktivnost';

  @override
  String get noRecentActivity => 'Nema nedavne aktivnosti';

  @override
  String get turnedOn => 'Uključeno';

  @override
  String get turnedOff => 'Isključeno';

  @override
  String get sourceButton => 'Gumb';

  @override
  String get sourceSchedule => 'Raspored';

  @override
  String get sourceApp => 'Aplikacija';

  @override
  String get sourceSystem => 'Sustav';

  @override
  String get sourceUnknown => 'Nepoznato';

  @override
  String get justNow => 'Upravo sada';

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'prije $count minuta',
      many: 'prije $count minuta',
      few: 'prije $count minute',
      one: 'prije 1 minutu',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'prije $count sati',
      many: 'prije $count sati',
      few: 'prije $count sata',
      one: 'prije 1 sat',
    );
    return '$_temp0';
  }

  @override
  String get today => 'Danas';

  @override
  String get yesterday => 'Jučer';

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'prije $count dana',
      many: 'prije $count dana',
      few: 'prije $count dana',
      one: 'prije 1 dan',
    );
    return '$_temp0';
  }

  @override
  String get deviceInfo => 'Informacije o uređaju';

  @override
  String get name => 'Naziv';

  @override
  String get model => 'Model';

  @override
  String get type => 'Tip';

  @override
  String get generation => 'Generacija';

  @override
  String get deviceId => 'ID uređaja';

  @override
  String get serial => 'Serijski broj';

  @override
  String get firmware => 'Firmware';

  @override
  String get room => 'Soba';

  @override
  String get connection => 'Veza';

  @override
  String get status => 'Status';

  @override
  String get wifiNetwork => 'WiFi mreža';

  @override
  String get ipAddress => 'IP adresa';

  @override
  String get signalStrength => 'Jačina signala';

  @override
  String get signalExcellent => 'Izvrsna';

  @override
  String get signalGood => 'Dobra';

  @override
  String get signalFair => 'Osrednja';

  @override
  String get signalWeak => 'Slaba';

  @override
  String get signalUnknown => 'Nepoznata';

  @override
  String get uptime => 'Vrijeme rada';

  @override
  String get ramFree => 'Slobodni RAM';

  @override
  String get deviceOffline => 'Uređaj nije povezan';

  @override
  String get tapForHistory => 'Dodirnite za povijest';

  @override
  String get reorderDevices => 'Presloži';

  @override
  String get reorderDevicesDone => 'Gotovo';

  @override
  String get dragToReorder => 'Povucite za preslažanje uređaja';

  @override
  String get scenes => 'Scene';

  @override
  String get noScenes => 'Nema pronađenih scena';

  @override
  String get noScenesDesc => 'Stvorite scene u svom Shelly Cloud računu';

  @override
  String get showScenesTab => 'Prikaži karticu scena';

  @override
  String get showScenesTabDesc => 'Prikaži automatizacijske scene u navigaciji';

  @override
  String get showDeviceInfoButton => 'Prikaži gumb informacija';

  @override
  String get showDeviceInfoButtonDesc =>
      'Prikaži gumb informacija na zaslonu uređaja';

  @override
  String get showScheduleButton => 'Prikaži gumb rasporeda';

  @override
  String get showScheduleButtonDesc =>
      'Prikaži gumb rasporeda za energetske uređaje';

  @override
  String get showActionsButton => 'Prikaži gumb akcija';

  @override
  String get showActionsButtonDesc => 'Prikaži gumb akcija na zaslonu uređaja';

  @override
  String get groupByRoom => 'Group by Room';

  @override
  String get groupByRoomDesc => 'Organize dashboard devices into room folders';

  @override
  String devicesInRoom(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count devices',
      one: '1 device',
    );
    return '$_temp0';
  }

  @override
  String activeInRoom(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active',
      one: '1 active',
    );
    return '$_temp0';
  }

  @override
  String get otherRoom => 'Other';

  @override
  String get sceneEnabled => 'Omogućeno';

  @override
  String get sceneDisabled => 'Onemogućeno';

  @override
  String get loadingScenes => 'Učitavanje scena...';

  @override
  String get runScene => 'Pokreni';

  @override
  String get sceneRunning => 'Pokretanje...';

  @override
  String get hideFromDashboard => 'Sakrij s nadzorne ploče';

  @override
  String get hideFromDashboardDesc =>
      'Uređaj će se prikazivati samo na kartici Uređaji';

  @override
  String get backupSettings => 'Sigurnosna kopija';

  @override
  String get backupSettingsDesc => 'Spremi rasporede i akcije lokalno';

  @override
  String get backupCreate => 'Stvori sigurnosnu kopiju';

  @override
  String get backupRestore => 'Vrati sigurnosnu kopiju';

  @override
  String get backupDelete => 'Obriši sigurnosnu kopiju';

  @override
  String get backupCreated => 'Sigurnosna kopija stvorena';

  @override
  String get backupRestored => 'Sigurnosna kopija vraćena';

  @override
  String get backupDeleted => 'Sigurnosna kopija obrisana';

  @override
  String get backupNotFound => 'Sigurnosna kopija nije pronađena';

  @override
  String get backupRestoreConfirm =>
      'Ovo će zamijeniti trenutne rasporede i akcije sigurnosnom kopijom. Nastaviti?';

  @override
  String get backupDeleteConfirm =>
      'Obrisati sigurnosnu kopiju za ovaj uređaj?';

  @override
  String backupInfo(String date) {
    return 'Zadnja sigurnosna kopija: $date';
  }

  @override
  String get backupNoBackup => 'Nema sigurnosne kopije';

  @override
  String get unsupportedDevice => 'Nepodržani uređaj';

  @override
  String unsupportedDeviceDesc(String code) {
    return 'Vrsta uređaja \"$code\" još nije podržana. Neobrađeni podaci prikazani su ispod.';
  }

  @override
  String get deviceData => 'Podaci uređaja';

  @override
  String get copyJson => 'Kopiraj JSON';

  @override
  String get copiedToClipboard => 'Kopirano u međuspremnik';

  @override
  String get webhooks => 'Akcije';

  @override
  String get noWebhooks => 'Nema akcija';

  @override
  String get noWebhooksDesc =>
      'Stvorite akcije za pokretanje drugih uređaja kada se dogode događaji';

  @override
  String get addWebhook => 'Dodaj akciju';

  @override
  String get editWebhook => 'Uredi';

  @override
  String get deleteWebhook => 'Obriši';

  @override
  String get deleteWebhookConfirm =>
      'Jeste li sigurni da želite obrisati ovu akciju?';

  @override
  String get webhookNoName => 'Akcija bez naziva';

  @override
  String get webhookName => 'Naziv';

  @override
  String get webhookNameHint => 'npr., Upali svjetla';

  @override
  String get webhookEvent => 'Događaj okidača';

  @override
  String get webhookUrls => 'Ciljni URL-ovi';

  @override
  String get webhookUrlHint => 'http://192.168.1.x/rpc/...';

  @override
  String get webhookAddUrl => 'Dodaj URL';

  @override
  String get webhookRemoveUrl => 'Ukloni';

  @override
  String get webhookRepeatPeriod => 'Pauza ponavljanja';

  @override
  String get webhookRepeatNone => 'Bez pauze';

  @override
  String get webhookRepeat5s => '5 sekundi';

  @override
  String get webhookRepeat15s => '15 sekundi';

  @override
  String get webhookRepeat30s => '30 sekundi';

  @override
  String get webhookRepeat1min => '1 minuta';

  @override
  String get webhookRepeat5min => '5 minuta';

  @override
  String get webhookRepeat15min => '15 minuta';

  @override
  String get webhookRepeat1hour => '1 sat';

  @override
  String get webhookModeDevice => 'Uređaj';

  @override
  String get webhookModeCustom => 'Prilagođeni URL';

  @override
  String get webhookTargetDevice => 'Ciljni uređaj';

  @override
  String get webhookSelectDevice => 'Odaberite uređaj';

  @override
  String get webhookNoDevices => 'Nema drugih dostupnih uređaja';

  @override
  String get webhookToggle => 'Prebaci';

  @override
  String get webhookToggleAfter => 'Automatski vrati nakon';

  @override
  String get webhookToggleAfterNone => 'Ne vraćaj';

  @override
  String get webhookToggleAfter30s => '30 sekundi';

  @override
  String get webhookToggleAfter1min => '1 minuta';

  @override
  String get webhookToggleAfter5min => '5 minuta';

  @override
  String get webhookToggleAfter10min => '10 minuta';

  @override
  String get webhookToggleAfter30min => '30 minuta';

  @override
  String get webhookToggleAfter1hour => '1 sat';

  @override
  String get webhookToggleAfterNotAvailable =>
      'Automatsko vraćanje nije dostupno za akciju prebacivanja';

  @override
  String get phoneOffline => 'Niste povezani';

  @override
  String get phoneOfflineDesc =>
      'Provjerite internetsku vezu. Vaši uređaji i dalje rade.';

  @override
  String get phoneOnCellular => 'Koristite mobilne podatke';

  @override
  String get phoneOnCellularDesc =>
      'Povežite se na WiFi za izravnu kontrolu uređaja';

  @override
  String get phoneDifferentWifi => 'Druga WiFi mreža';

  @override
  String phoneDifferentWifiDesc(Object network) {
    return 'Vaši uređaji su na mreži $network. Koristi se oblak veza.';
  }
}
