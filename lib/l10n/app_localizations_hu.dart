// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get appName => 'OhMyShelly';

  @override
  String get appTagline => 'Okosotthon Egyszerűen';

  @override
  String get onboardingTitle1 => 'Az Ön Okosotthon Vezérlőpultja';

  @override
  String get onboardingDesc1 =>
      'Lássa az összes eszközt egy pillantással. Figyelje a fogyasztást, az időjárási adatokat és az eszközök állapotát valós időben. Rendezze szobák szerint.';

  @override
  String get onboardingTitle2 => 'Részletes Statisztikák';

  @override
  String get onboardingDesc2 =>
      'Tekintse meg az áramfogyasztás és időjárás előzménygrafikon jait. Kövesse nyomon a trendeket nap, hét, hónap vagy év szerint gyönyörű grafikonokkal.';

  @override
  String get onboardingTitle3 => 'Ütemezések és Automatizálás';

  @override
  String get onboardingDesc3 =>
      'Hozzon létre ütemezéseket az eszközök automatikus be- vagy kikapcsolásához. Állítson be időpontokat, válasszon napokat, és hagyja, hogy otthona önmagától működjön.';

  @override
  String get getStarted => 'Kezdjük';

  @override
  String get skip => 'Kihagyás';

  @override
  String get next => 'Következő';

  @override
  String get signIn => 'Bejelentkezés';

  @override
  String get email => 'Email';

  @override
  String get password => 'Jelszó';

  @override
  String get emailHint => 'Adja meg Shelly Cloud emailjét';

  @override
  String get passwordHint => 'Adja meg jelszavát';

  @override
  String get signingIn => 'Bejelentkezés...';

  @override
  String get signOut => 'Kijelentkezés';

  @override
  String get invalidCredentials => 'Helytelen email vagy jelszó';

  @override
  String get connectionError =>
      'Nem lehet csatlakozni. Ellenőrizze az internetet.';

  @override
  String get devices => 'Eszközök';

  @override
  String get dashboard => 'Vezérlőpult';

  @override
  String get myDevices => 'Eszközeim';

  @override
  String get noDevices => 'Nem található eszköz';

  @override
  String get noDevicesDesc => 'Adjon hozzá eszközöket a Shelly Cloud fiókjában';

  @override
  String get smartPlug => 'Okos Aljzat';

  @override
  String get weatherStation => 'Időjárás-állomás';

  @override
  String get gatewayDevice => 'Átjáró';

  @override
  String get unknownDevice => 'Eszköz';

  @override
  String get otherDevices => 'Egyéb';

  @override
  String get online => 'Csatlakozva';

  @override
  String get offline => 'Offline';

  @override
  String get on => 'Be';

  @override
  String get off => 'Ki';

  @override
  String get power => 'Teljesítmény';

  @override
  String get voltage => 'Feszültség';

  @override
  String get current => 'Áram';

  @override
  String get temperature => 'Hőmérséklet';

  @override
  String get feelsLike => 'Hőérzet';

  @override
  String get totalEnergy => 'Összes Energia';

  @override
  String get humidity => 'Páratartalom';

  @override
  String get pressure => 'Légnyomás';

  @override
  String get uvIndex => 'UV Index';

  @override
  String get windSpeed => 'Szél';

  @override
  String get windGust => 'Széllökések';

  @override
  String get windDirection => 'Irány';

  @override
  String get rain => 'Eső';

  @override
  String get rainToday => 'Ma';

  @override
  String get illumination => 'Megvilágítás';

  @override
  String get solar => 'Napfény';

  @override
  String get battery => 'Akkumulátor';

  @override
  String get uvLow => 'Alacsony';

  @override
  String get uvModerate => 'Mérsékelt';

  @override
  String get uvHigh => 'Magas';

  @override
  String get uvVeryHigh => 'Nagyon Magas';

  @override
  String get uvExtreme => 'Extrém';

  @override
  String get pressureRising => 'Emelkedő';

  @override
  String get pressureFalling => 'Csökkenő';

  @override
  String get pressureStable => 'Stabil';

  @override
  String get totalDevices => 'Összes Eszköz';

  @override
  String get activeDevices => 'Aktív';

  @override
  String get totalPower => 'Összes Teljesítmény';

  @override
  String get currentWeather => 'Aktuális Időjárás';

  @override
  String get statistics => 'Statisztikák';

  @override
  String get viewHistory => 'Előzmények Megtekintése';

  @override
  String get hour => 'Óra';

  @override
  String get day => 'Nap';

  @override
  String get week => 'Hét';

  @override
  String get month => 'Hónap';

  @override
  String get year => 'Év';

  @override
  String get average => 'Átlag';

  @override
  String get peak => 'Csúcs';

  @override
  String get total => 'Összesen';

  @override
  String get min => 'Min';

  @override
  String get max => 'Max';

  @override
  String get errorGeneric => 'Valami hiba történt';

  @override
  String get errorNetwork => 'Ellenőrizze az internetkapcsolatot';

  @override
  String get retry => 'Újra';

  @override
  String get pullToRefresh => 'Húzza le a frissítéshez';

  @override
  String get loadingDevices => 'Eszközök betöltése...';

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
  String get settings => 'Beállítások';

  @override
  String get appearance => 'Megjelenés';

  @override
  String get theme => 'Téma';

  @override
  String get themeSystem => 'Rendszer';

  @override
  String get themeLight => 'Világos';

  @override
  String get themeDark => 'Sötét';

  @override
  String get showDevicesTab => 'Eszközök Fül Megjelenítése';

  @override
  String get showDevicesTabDesc =>
      'Ha ki van kapcsolva, csak a Vezérlőpult jelenik meg';

  @override
  String get language => 'Nyelv';

  @override
  String get languageSystem => 'Rendszer Alapértelmezett';

  @override
  String get languageEnglish => 'Angol';

  @override
  String get languageSlovenian => 'Szlovén';

  @override
  String get languageGerman => 'Német';

  @override
  String get languageFrench => 'Francia';

  @override
  String get languageSpanish => 'Spanyol';

  @override
  String get languagePortuguese => 'Portugál';

  @override
  String get languageItalian => 'Olasz';

  @override
  String get languageDutch => 'Holland';

  @override
  String get languageCatalan => 'Katalán';

  @override
  String get languageSwedish => 'Svéd';

  @override
  String get languageNorwegian => 'Norvég';

  @override
  String get languageDanish => 'Dán';

  @override
  String get languageFinnish => 'Finn';

  @override
  String get languageIcelandic => 'Izlandi';

  @override
  String get languagePolish => 'Lengyel';

  @override
  String get languageCzech => 'Cseh';

  @override
  String get languageSlovak => 'Szlovák';

  @override
  String get languageHungarian => 'Magyar';

  @override
  String get languageRomanian => 'Román';

  @override
  String get languageBulgarian => 'Bolgár';

  @override
  String get languageUkrainian => 'Ukrán';

  @override
  String get languageRussian => 'Orosz';

  @override
  String get languageLithuanian => 'Litván';

  @override
  String get languageLatvian => 'Lett';

  @override
  String get languageEstonian => 'Észt';

  @override
  String get languageCroatian => 'Horvát';

  @override
  String get languageSerbian => 'Szerb';

  @override
  String get languageGreek => 'Görög';

  @override
  String get languageSpanishMexico => 'Spanyol (Mexikó)';

  @override
  String get languageFrenchCanada => 'Francia (Kanada)';

  @override
  String get languageEnglishUS => 'Angol (USA)';

  @override
  String get cancel => 'Mégse';

  @override
  String get confirm => 'Megerősítés';

  @override
  String get signOutConfirmTitle => 'Kijelentkezés';

  @override
  String get signOutConfirmMessage => 'Biztosan ki szeretne jelentkezni?';

  @override
  String get lastUpdated => 'Frissítve';

  @override
  String get summary => 'Összefoglaló';

  @override
  String get peakUv => 'Csúcs UV';

  @override
  String get powerUsage => 'Áramfogyasztás';

  @override
  String get noPowerData => 'Nincs teljesítményadat erre az időszakra';

  @override
  String get noWeatherData => 'Nincs időjárási adat erre az időszakra';

  @override
  String get noDataAvailable => 'Nincs elérhető adat';

  @override
  String get loadingStatistics => 'Statisztikák betöltése...';

  @override
  String get windHistoryNotAvailable => 'A szél előzményei nem érhetők el';

  @override
  String get humidityAvg => 'Páratartalom (átlag)';

  @override
  String get rainTotal => 'Eső (összesen)';

  @override
  String get directionN => 'É';

  @override
  String get directionNE => 'ÉK';

  @override
  String get directionE => 'K';

  @override
  String get directionSE => 'DK';

  @override
  String get directionS => 'D';

  @override
  String get directionSW => 'DNY';

  @override
  String get directionW => 'NY';

  @override
  String get directionNW => 'ÉNY';

  @override
  String get profile => 'Profil';

  @override
  String get account => 'Fiók';

  @override
  String get serverUrl => 'Szerver';

  @override
  String get timezoneLabel => 'Időzóna';

  @override
  String get timezoneNotSet => 'Nincs beállítva';

  @override
  String get powerHistory => 'Teljesítmény Előzmények';

  @override
  String get weatherHistory => 'Időjárás Előzmények';

  @override
  String get temperatureHistory => 'Hőmérséklet Előzmények';

  @override
  String get humidityHistory => 'Páratartalom Előzmények';

  @override
  String get pressureHistory => 'Légnyomás Előzmények';

  @override
  String get uvHistory => 'UV Előzmények';

  @override
  String get rainHistory => 'Eső Előzmények';

  @override
  String get solarHistory => 'Napfény Előzmények';

  @override
  String get voltageHistory => 'Feszültség Előzmények';

  @override
  String get currentHistory => 'Áram Előzmények';

  @override
  String get energyHistory => 'Energia Előzmények';

  @override
  String get currentPowerUsage => 'Teljesítmény';

  @override
  String get dayMon => 'H';

  @override
  String get dayTue => 'K';

  @override
  String get dayWed => 'Sze';

  @override
  String get dayThu => 'Cs';

  @override
  String get dayFri => 'P';

  @override
  String get daySat => 'Szo';

  @override
  String get daySun => 'V';

  @override
  String get monthJan => 'Jan';

  @override
  String get monthFeb => 'Feb';

  @override
  String get monthMar => 'Már';

  @override
  String get monthApr => 'Ápr';

  @override
  String get monthMay => 'Máj';

  @override
  String get monthJun => 'Jún';

  @override
  String get monthJul => 'Júl';

  @override
  String get monthAug => 'Aug';

  @override
  String get monthSep => 'Szep';

  @override
  String get monthOct => 'Okt';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Dec';

  @override
  String get monthJanFull => 'Január';

  @override
  String get monthFebFull => 'Február';

  @override
  String get monthMarFull => 'Március';

  @override
  String get monthAprFull => 'Április';

  @override
  String get monthMayFull => 'Május';

  @override
  String get monthJunFull => 'Június';

  @override
  String get monthJulFull => 'Július';

  @override
  String get monthAugFull => 'Augusztus';

  @override
  String get monthSepFull => 'Szeptember';

  @override
  String get monthOctFull => 'Október';

  @override
  String get monthNovFull => 'November';

  @override
  String get monthDecFull => 'December';

  @override
  String get thisWeek => 'Ez a Hét';

  @override
  String get lastWeek => 'Múlt Hét';

  @override
  String get thisMonth => 'Ez a Hónap';

  @override
  String get lastMonth => 'Múlt Hónap';

  @override
  String get thisYear => 'Ez az Év';

  @override
  String get nextYear => 'Következő Év';

  @override
  String get selectMonth => 'Hónap Kiválasztása';

  @override
  String get selectYear => 'Év Kiválasztása';

  @override
  String get solarDark => 'Sötét';

  @override
  String get solarCloudy => 'Felhős';

  @override
  String get solarPartlySunny => 'Részben Napos';

  @override
  String get solarSunny => 'Napos';

  @override
  String get solarVerySunny => 'Nagyon Napos';

  @override
  String get batteryFull => 'Tele';

  @override
  String get batteryGood => 'Jó';

  @override
  String get batteryLow => 'Alacsony';

  @override
  String get batteryCritical => 'Kritikus';

  @override
  String get updateAvailable => 'Elérhető frissítés';

  @override
  String updateVersion(String version) {
    return 'Verzió $version';
  }

  @override
  String get updateDownload => 'Letöltés';

  @override
  String get updateDownloading => 'Frissítés letöltése...';

  @override
  String get updateReady => 'Frissítés kész';

  @override
  String get updateTapToInstall => 'Érintse meg a telepítéshez';

  @override
  String get updateInstall => 'Telepítés';

  @override
  String get updateError => 'Frissítési hiba';

  @override
  String get updateClose => 'Bezárás';

  @override
  String get schedules => 'Ütemezések';

  @override
  String get noSchedules => 'Nincsenek ütemezések';

  @override
  String get addSchedule => 'Ütemezés Hozzáadása';

  @override
  String get editSchedule => 'Szerkesztés';

  @override
  String get deleteSchedule => 'Törlés';

  @override
  String get deleteScheduleConfirm =>
      'Biztosan törölni szeretné ezt az ütemezést?';

  @override
  String get scheduleTime => 'Idő';

  @override
  String get scheduleDays => 'Napok';

  @override
  String get scheduleAction => 'Művelet';

  @override
  String get turnOn => 'Bekapcsolás';

  @override
  String get turnOff => 'Kikapcsolás';

  @override
  String get everyDay => 'Minden nap';

  @override
  String get weekdays => 'Hétköznapok';

  @override
  String get weekends => 'Hétvégék';

  @override
  String get save => 'Mentés';

  @override
  String get activity => 'Tevékenység';

  @override
  String get noActivity => 'Nincs közelmúltbeli tevékenység';

  @override
  String get sourceButton => 'Gomb';

  @override
  String get sourceSchedule => 'Ütemezés';

  @override
  String get sourceApp => 'Alkalmazás';

  @override
  String get sourceSystem => 'Rendszer';

  @override
  String get sourceUnknown => 'Ismeretlen';

  @override
  String get justNow => 'Éppen most';

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count perce',
      one: '1 perce',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count órája',
      one: '1 órája',
    );
    return '$_temp0';
  }

  @override
  String get today => 'Ma';

  @override
  String get yesterday => 'Tegnap';

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count napja',
      one: '1 napja',
    );
    return '$_temp0';
  }

  @override
  String get deviceInfo => 'Eszköz Információk';

  @override
  String get name => 'Név';

  @override
  String get model => 'Modell';

  @override
  String get type => 'Típus';

  @override
  String get generation => 'Generáció';

  @override
  String get deviceId => 'Eszköz Azonosító';

  @override
  String get serial => 'Sorozatszám';

  @override
  String get firmware => 'Firmware';

  @override
  String get room => 'Szoba';

  @override
  String get connection => 'Kapcsolat';

  @override
  String get status => 'Állapot';

  @override
  String get wifiNetwork => 'WiFi Hálózat';

  @override
  String get ipAddress => 'IP Cím';

  @override
  String get signalStrength => 'Jelerősség';

  @override
  String get signalExcellent => 'Kiváló';

  @override
  String get signalGood => 'Jó';

  @override
  String get signalFair => 'Közepes';

  @override
  String get signalWeak => 'Gyenge';

  @override
  String get signalUnknown => 'Ismeretlen';

  @override
  String get uptime => 'Üzemidő';

  @override
  String get ramFree => 'Szabad RAM';

  @override
  String get deviceOffline => 'Az eszköz offline';

  @override
  String get tapForHistory => 'Érintse meg az előzményekhez';

  @override
  String get reorderDevices => 'Átrendezés';

  @override
  String get reorderDevicesDone => 'Kész';

  @override
  String get dragToReorder => 'Húzza az eszközök átrendezéséhez';

  @override
  String get scenes => 'Jelenetek';

  @override
  String get noScenes => 'Nem található jelenet';

  @override
  String get noScenesDesc =>
      'Hozzon létre jeleneteket a Shelly Cloud fiókjában';

  @override
  String get showScenesTab => 'Jelenetek Fül Megjelenítése';

  @override
  String get showScenesTabDesc =>
      'Automatizálási jelenetek megjelenítése a navigációban';

  @override
  String get sceneEnabled => 'Engedélyezve';

  @override
  String get sceneDisabled => 'Letiltva';

  @override
  String get loadingScenes => 'Jelenetek betöltése...';

  @override
  String get runScene => 'Futtatás';

  @override
  String get sceneRunning => 'Futtatás...';

  @override
  String get hideFromDashboard => 'Elrejtés az irányítópultról';

  @override
  String get hideFromDashboardDesc =>
      'Az eszköz csak az Eszközök fülön jelenik meg';

  @override
  String get unsupportedDevice => 'Nem támogatott eszköz';

  @override
  String unsupportedDeviceDesc(String code) {
    return 'A(z) \"$code\" eszköztípus még nem támogatott. A nyers adatok alább láthatók.';
  }

  @override
  String get deviceData => 'Eszközadatok';

  @override
  String get copyJson => 'JSON másolása';

  @override
  String get copiedToClipboard => 'Vágólapra másolva';
}
