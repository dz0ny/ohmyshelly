import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bg.dart';
import 'app_localizations_ca.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_et.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hr.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_is.dart';
import 'app_localizations_it.dart';
import 'app_localizations_lt.dart';
import 'app_localizations_lv.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_no.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sk.dart';
import 'app_localizations_sl.dart';
import 'app_localizations_sr.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bg'),
    Locale('ca'),
    Locale('cs'),
    Locale('da'),
    Locale('de'),
    Locale('el'),
    Locale('en'),
    Locale('en', 'US'),
    Locale('es'),
    Locale('es', 'MX'),
    Locale('et'),
    Locale('fi'),
    Locale('fr'),
    Locale('fr', 'CA'),
    Locale('hr'),
    Locale('hu'),
    Locale('is'),
    Locale('it'),
    Locale('lt'),
    Locale('lv'),
    Locale('nl'),
    Locale('no'),
    Locale('pl'),
    Locale('pt'),
    Locale('ro'),
    Locale('ru'),
    Locale('sk'),
    Locale('sl'),
    Locale('sr'),
    Locale('sv'),
    Locale('uk'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'OhMyShelly'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Smart Home Made Simple'**
  String get appTagline;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Your Smart Home Dashboard'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'See all your devices at a glance. Monitor power consumption, weather data, and device status in real-time. Organize by rooms.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Detailed Statistics'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'View historical charts for power usage and weather. Track trends by day, week, month, or year with beautiful graphs.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Schedules & Automation'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Create schedules to turn devices on or off automatically. Set times, pick days, and let your home run itself.'**
  String get onboardingDesc3;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your Shelly Cloud email'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signingIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password'**
  String get invalidCredentials;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect. Check your internet.'**
  String get connectionError;

  /// No description provided for @devices.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devices;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @myDevices.
  ///
  /// In en, this message translates to:
  /// **'My Devices'**
  String get myDevices;

  /// No description provided for @noDevices.
  ///
  /// In en, this message translates to:
  /// **'No devices found'**
  String get noDevices;

  /// No description provided for @noDevicesDesc.
  ///
  /// In en, this message translates to:
  /// **'Add devices in your Shelly Cloud account'**
  String get noDevicesDesc;

  /// No description provided for @smartPlug.
  ///
  /// In en, this message translates to:
  /// **'Smart Plug'**
  String get smartPlug;

  /// No description provided for @weatherStation.
  ///
  /// In en, this message translates to:
  /// **'Weather Station'**
  String get weatherStation;

  /// No description provided for @gatewayDevice.
  ///
  /// In en, this message translates to:
  /// **'Gateway'**
  String get gatewayDevice;

  /// No description provided for @unknownDevice.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get unknownDevice;

  /// No description provided for @otherDevices.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherDevices;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @power.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get power;

  /// No description provided for @voltage.
  ///
  /// In en, this message translates to:
  /// **'Voltage'**
  String get voltage;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @feelsLike.
  ///
  /// In en, this message translates to:
  /// **'Feels like'**
  String get feelsLike;

  /// No description provided for @totalEnergy.
  ///
  /// In en, this message translates to:
  /// **'Total Energy'**
  String get totalEnergy;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @pressure.
  ///
  /// In en, this message translates to:
  /// **'Pressure'**
  String get pressure;

  /// No description provided for @uvIndex.
  ///
  /// In en, this message translates to:
  /// **'UV Index'**
  String get uvIndex;

  /// No description provided for @windSpeed.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get windSpeed;

  /// No description provided for @windGust.
  ///
  /// In en, this message translates to:
  /// **'Gusts'**
  String get windGust;

  /// No description provided for @windDirection.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get windDirection;

  /// No description provided for @rain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get rain;

  /// No description provided for @rainToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get rainToday;

  /// No description provided for @illumination.
  ///
  /// In en, this message translates to:
  /// **'Illumination'**
  String get illumination;

  /// No description provided for @solar.
  ///
  /// In en, this message translates to:
  /// **'Solar'**
  String get solar;

  /// No description provided for @battery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get battery;

  /// No description provided for @uvLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get uvLow;

  /// No description provided for @uvModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get uvModerate;

  /// No description provided for @uvHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get uvHigh;

  /// No description provided for @uvVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very High'**
  String get uvVeryHigh;

  /// No description provided for @uvExtreme.
  ///
  /// In en, this message translates to:
  /// **'Extreme'**
  String get uvExtreme;

  /// No description provided for @pressureRising.
  ///
  /// In en, this message translates to:
  /// **'Rising'**
  String get pressureRising;

  /// No description provided for @pressureFalling.
  ///
  /// In en, this message translates to:
  /// **'Falling'**
  String get pressureFalling;

  /// No description provided for @pressureStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get pressureStable;

  /// No description provided for @totalDevices.
  ///
  /// In en, this message translates to:
  /// **'Total Devices'**
  String get totalDevices;

  /// No description provided for @activeDevices.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeDevices;

  /// No description provided for @totalPower.
  ///
  /// In en, this message translates to:
  /// **'Total Power'**
  String get totalPower;

  /// No description provided for @currentWeather.
  ///
  /// In en, this message translates to:
  /// **'Current Weather'**
  String get currentWeather;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @viewHistory.
  ///
  /// In en, this message translates to:
  /// **'View History'**
  String get viewHistory;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get hour;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @peak.
  ///
  /// In en, this message translates to:
  /// **'Peak'**
  String get peak;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get min;

  /// No description provided for @max.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get max;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection'**
  String get errorNetwork;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @pullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get pullToRefresh;

  /// No description provided for @loadingDevices.
  ///
  /// In en, this message translates to:
  /// **'Loading devices...'**
  String get loadingDevices;

  /// No description provided for @watts.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get watts;

  /// No description provided for @kilowattHours.
  ///
  /// In en, this message translates to:
  /// **'kWh'**
  String get kilowattHours;

  /// No description provided for @volts.
  ///
  /// In en, this message translates to:
  /// **'V'**
  String get volts;

  /// No description provided for @amps.
  ///
  /// In en, this message translates to:
  /// **'A'**
  String get amps;

  /// No description provided for @celsius.
  ///
  /// In en, this message translates to:
  /// **'°C'**
  String get celsius;

  /// No description provided for @percent.
  ///
  /// In en, this message translates to:
  /// **'%'**
  String get percent;

  /// No description provided for @hectopascals.
  ///
  /// In en, this message translates to:
  /// **'hPa'**
  String get hectopascals;

  /// No description provided for @kmPerHour.
  ///
  /// In en, this message translates to:
  /// **'km/h'**
  String get kmPerHour;

  /// No description provided for @millimeters.
  ///
  /// In en, this message translates to:
  /// **'mm'**
  String get millimeters;

  /// No description provided for @lux.
  ///
  /// In en, this message translates to:
  /// **'lux'**
  String get lux;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @showDevicesTab.
  ///
  /// In en, this message translates to:
  /// **'Show Devices Tab'**
  String get showDevicesTab;

  /// No description provided for @showDevicesTabDesc.
  ///
  /// In en, this message translates to:
  /// **'When disabled, only the Dashboard is shown'**
  String get showDevicesTabDesc;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSlovenian.
  ///
  /// In en, this message translates to:
  /// **'Slovenian'**
  String get languageSlovenian;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageGerman;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get languagePortuguese;

  /// No description provided for @languageItalian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get languageItalian;

  /// No description provided for @languageDutch.
  ///
  /// In en, this message translates to:
  /// **'Dutch'**
  String get languageDutch;

  /// No description provided for @languageCatalan.
  ///
  /// In en, this message translates to:
  /// **'Catalan'**
  String get languageCatalan;

  /// No description provided for @languageSwedish.
  ///
  /// In en, this message translates to:
  /// **'Swedish'**
  String get languageSwedish;

  /// No description provided for @languageNorwegian.
  ///
  /// In en, this message translates to:
  /// **'Norwegian'**
  String get languageNorwegian;

  /// No description provided for @languageDanish.
  ///
  /// In en, this message translates to:
  /// **'Danish'**
  String get languageDanish;

  /// No description provided for @languageFinnish.
  ///
  /// In en, this message translates to:
  /// **'Finnish'**
  String get languageFinnish;

  /// No description provided for @languageIcelandic.
  ///
  /// In en, this message translates to:
  /// **'Icelandic'**
  String get languageIcelandic;

  /// No description provided for @languagePolish.
  ///
  /// In en, this message translates to:
  /// **'Polish'**
  String get languagePolish;

  /// No description provided for @languageCzech.
  ///
  /// In en, this message translates to:
  /// **'Czech'**
  String get languageCzech;

  /// No description provided for @languageSlovak.
  ///
  /// In en, this message translates to:
  /// **'Slovak'**
  String get languageSlovak;

  /// No description provided for @languageHungarian.
  ///
  /// In en, this message translates to:
  /// **'Hungarian'**
  String get languageHungarian;

  /// No description provided for @languageRomanian.
  ///
  /// In en, this message translates to:
  /// **'Romanian'**
  String get languageRomanian;

  /// No description provided for @languageBulgarian.
  ///
  /// In en, this message translates to:
  /// **'Bulgarian'**
  String get languageBulgarian;

  /// No description provided for @languageUkrainian.
  ///
  /// In en, this message translates to:
  /// **'Ukrainian'**
  String get languageUkrainian;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get languageRussian;

  /// No description provided for @languageLithuanian.
  ///
  /// In en, this message translates to:
  /// **'Lithuanian'**
  String get languageLithuanian;

  /// No description provided for @languageLatvian.
  ///
  /// In en, this message translates to:
  /// **'Latvian'**
  String get languageLatvian;

  /// No description provided for @languageEstonian.
  ///
  /// In en, this message translates to:
  /// **'Estonian'**
  String get languageEstonian;

  /// No description provided for @languageCroatian.
  ///
  /// In en, this message translates to:
  /// **'Croatian'**
  String get languageCroatian;

  /// No description provided for @languageSerbian.
  ///
  /// In en, this message translates to:
  /// **'Serbian'**
  String get languageSerbian;

  /// No description provided for @languageGreek.
  ///
  /// In en, this message translates to:
  /// **'Greek'**
  String get languageGreek;

  /// No description provided for @languageSpanishMexico.
  ///
  /// In en, this message translates to:
  /// **'Spanish (Mexico)'**
  String get languageSpanishMexico;

  /// No description provided for @languageFrenchCanada.
  ///
  /// In en, this message translates to:
  /// **'French (Canada)'**
  String get languageFrenchCanada;

  /// No description provided for @languageEnglishUS.
  ///
  /// In en, this message translates to:
  /// **'English (US)'**
  String get languageEnglishUS;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmMessage;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get lastUpdated;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @peakUv.
  ///
  /// In en, this message translates to:
  /// **'Peak UV'**
  String get peakUv;

  /// No description provided for @powerUsage.
  ///
  /// In en, this message translates to:
  /// **'Power Usage'**
  String get powerUsage;

  /// No description provided for @noPowerData.
  ///
  /// In en, this message translates to:
  /// **'No power data for this period'**
  String get noPowerData;

  /// No description provided for @noWeatherData.
  ///
  /// In en, this message translates to:
  /// **'No weather data for this period'**
  String get noWeatherData;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @loadingStatistics.
  ///
  /// In en, this message translates to:
  /// **'Loading statistics...'**
  String get loadingStatistics;

  /// No description provided for @windHistoryNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Wind history is not available'**
  String get windHistoryNotAvailable;

  /// No description provided for @humidityAvg.
  ///
  /// In en, this message translates to:
  /// **'Humidity (avg)'**
  String get humidityAvg;

  /// No description provided for @rainTotal.
  ///
  /// In en, this message translates to:
  /// **'Rain (total)'**
  String get rainTotal;

  /// No description provided for @directionN.
  ///
  /// In en, this message translates to:
  /// **'N'**
  String get directionN;

  /// No description provided for @directionNE.
  ///
  /// In en, this message translates to:
  /// **'NE'**
  String get directionNE;

  /// No description provided for @directionE.
  ///
  /// In en, this message translates to:
  /// **'E'**
  String get directionE;

  /// No description provided for @directionSE.
  ///
  /// In en, this message translates to:
  /// **'SE'**
  String get directionSE;

  /// No description provided for @directionS.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get directionS;

  /// No description provided for @directionSW.
  ///
  /// In en, this message translates to:
  /// **'SW'**
  String get directionSW;

  /// No description provided for @directionW.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get directionW;

  /// No description provided for @directionNW.
  ///
  /// In en, this message translates to:
  /// **'NW'**
  String get directionNW;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @serverUrl.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get serverUrl;

  /// No description provided for @timezoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get timezoneLabel;

  /// No description provided for @timezoneNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get timezoneNotSet;

  /// No description provided for @powerHistory.
  ///
  /// In en, this message translates to:
  /// **'Power History'**
  String get powerHistory;

  /// No description provided for @weatherHistory.
  ///
  /// In en, this message translates to:
  /// **'Weather History'**
  String get weatherHistory;

  /// No description provided for @temperatureHistory.
  ///
  /// In en, this message translates to:
  /// **'Temperature History'**
  String get temperatureHistory;

  /// No description provided for @humidityHistory.
  ///
  /// In en, this message translates to:
  /// **'Humidity History'**
  String get humidityHistory;

  /// No description provided for @pressureHistory.
  ///
  /// In en, this message translates to:
  /// **'Pressure History'**
  String get pressureHistory;

  /// No description provided for @uvHistory.
  ///
  /// In en, this message translates to:
  /// **'UV History'**
  String get uvHistory;

  /// No description provided for @rainHistory.
  ///
  /// In en, this message translates to:
  /// **'Rain History'**
  String get rainHistory;

  /// No description provided for @solarHistory.
  ///
  /// In en, this message translates to:
  /// **'Solar History'**
  String get solarHistory;

  /// No description provided for @voltageHistory.
  ///
  /// In en, this message translates to:
  /// **'Voltage History'**
  String get voltageHistory;

  /// No description provided for @currentHistory.
  ///
  /// In en, this message translates to:
  /// **'Current History'**
  String get currentHistory;

  /// No description provided for @energyHistory.
  ///
  /// In en, this message translates to:
  /// **'Energy History'**
  String get energyHistory;

  /// No description provided for @currentPowerUsage.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get currentPowerUsage;

  /// No description provided for @dayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get daySat;

  /// No description provided for @daySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get daySun;

  /// No description provided for @monthJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthDec;

  /// No description provided for @monthJanFull.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthJanFull;

  /// No description provided for @monthFebFull.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthFebFull;

  /// No description provided for @monthMarFull.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthMarFull;

  /// No description provided for @monthAprFull.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthAprFull;

  /// No description provided for @monthMayFull.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMayFull;

  /// No description provided for @monthJunFull.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthJunFull;

  /// No description provided for @monthJulFull.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthJulFull;

  /// No description provided for @monthAugFull.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthAugFull;

  /// No description provided for @monthSepFull.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get monthSepFull;

  /// No description provided for @monthOctFull.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get monthOctFull;

  /// No description provided for @monthNovFull.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get monthNovFull;

  /// No description provided for @monthDecFull.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get monthDecFull;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get lastWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// No description provided for @nextYear.
  ///
  /// In en, this message translates to:
  /// **'Next Year'**
  String get nextYear;

  /// No description provided for @selectMonth.
  ///
  /// In en, this message translates to:
  /// **'Select Month'**
  String get selectMonth;

  /// No description provided for @selectYear.
  ///
  /// In en, this message translates to:
  /// **'Select Year'**
  String get selectYear;

  /// No description provided for @solarDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get solarDark;

  /// No description provided for @solarCloudy.
  ///
  /// In en, this message translates to:
  /// **'Cloudy'**
  String get solarCloudy;

  /// No description provided for @solarPartlySunny.
  ///
  /// In en, this message translates to:
  /// **'Partly Sunny'**
  String get solarPartlySunny;

  /// No description provided for @solarSunny.
  ///
  /// In en, this message translates to:
  /// **'Sunny'**
  String get solarSunny;

  /// No description provided for @solarVerySunny.
  ///
  /// In en, this message translates to:
  /// **'Very Sunny'**
  String get solarVerySunny;

  /// No description provided for @batteryFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get batteryFull;

  /// No description provided for @batteryGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get batteryGood;

  /// No description provided for @batteryLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get batteryLow;

  /// No description provided for @batteryCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get batteryCritical;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailable;

  /// No description provided for @updateVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String updateVersion(String version);

  /// No description provided for @updateDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get updateDownload;

  /// No description provided for @updateDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading update...'**
  String get updateDownloading;

  /// No description provided for @updateReady.
  ///
  /// In en, this message translates to:
  /// **'Update ready'**
  String get updateReady;

  /// No description provided for @updateTapToInstall.
  ///
  /// In en, this message translates to:
  /// **'Tap to install'**
  String get updateTapToInstall;

  /// No description provided for @updateInstall.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get updateInstall;

  /// No description provided for @updateError.
  ///
  /// In en, this message translates to:
  /// **'Update error'**
  String get updateError;

  /// No description provided for @updateClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get updateClose;

  /// No description provided for @schedules.
  ///
  /// In en, this message translates to:
  /// **'Schedules'**
  String get schedules;

  /// No description provided for @noSchedules.
  ///
  /// In en, this message translates to:
  /// **'No schedules'**
  String get noSchedules;

  /// No description provided for @addSchedule.
  ///
  /// In en, this message translates to:
  /// **'Add Schedule'**
  String get addSchedule;

  /// No description provided for @editSchedule.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editSchedule;

  /// No description provided for @deleteSchedule.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteSchedule;

  /// No description provided for @deleteScheduleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this schedule?'**
  String get deleteScheduleConfirm;

  /// No description provided for @scheduleTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get scheduleTime;

  /// No description provided for @scheduleDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get scheduleDays;

  /// No description provided for @scheduleAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get scheduleAction;

  /// No description provided for @turnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn On'**
  String get turnOn;

  /// No description provided for @turnOff.
  ///
  /// In en, this message translates to:
  /// **'Turn Off'**
  String get turnOff;

  /// No description provided for @everyDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get everyDay;

  /// No description provided for @weekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get weekdays;

  /// No description provided for @weekends.
  ///
  /// In en, this message translates to:
  /// **'Weekends'**
  String get weekends;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @noActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity'**
  String get noActivity;

  /// No description provided for @sourceButton.
  ///
  /// In en, this message translates to:
  /// **'Button'**
  String get sourceButton;

  /// No description provided for @sourceSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get sourceSchedule;

  /// No description provided for @sourceApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get sourceApp;

  /// No description provided for @sourceSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get sourceSystem;

  /// No description provided for @sourceUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get sourceUnknown;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute ago} other{{count} minutes ago}}'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String hoursAgo(int count);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String daysAgo(int count);

  /// No description provided for @deviceInfo.
  ///
  /// In en, this message translates to:
  /// **'Device Information'**
  String get deviceInfo;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @generation.
  ///
  /// In en, this message translates to:
  /// **'Generation'**
  String get generation;

  /// No description provided for @deviceId.
  ///
  /// In en, this message translates to:
  /// **'Device ID'**
  String get deviceId;

  /// No description provided for @serial.
  ///
  /// In en, this message translates to:
  /// **'Serial'**
  String get serial;

  /// No description provided for @firmware.
  ///
  /// In en, this message translates to:
  /// **'Firmware'**
  String get firmware;

  /// No description provided for @room.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get room;

  /// No description provided for @connection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get connection;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @wifiNetwork.
  ///
  /// In en, this message translates to:
  /// **'WiFi Network'**
  String get wifiNetwork;

  /// No description provided for @ipAddress.
  ///
  /// In en, this message translates to:
  /// **'IP Address'**
  String get ipAddress;

  /// No description provided for @signalStrength.
  ///
  /// In en, this message translates to:
  /// **'Signal Strength'**
  String get signalStrength;

  /// No description provided for @signalExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get signalExcellent;

  /// No description provided for @signalGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get signalGood;

  /// No description provided for @signalFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get signalFair;

  /// No description provided for @signalWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get signalWeak;

  /// No description provided for @signalUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get signalUnknown;

  /// No description provided for @uptime.
  ///
  /// In en, this message translates to:
  /// **'Uptime'**
  String get uptime;

  /// No description provided for @ramFree.
  ///
  /// In en, this message translates to:
  /// **'RAM Free'**
  String get ramFree;

  /// No description provided for @deviceOffline.
  ///
  /// In en, this message translates to:
  /// **'Device is offline'**
  String get deviceOffline;

  /// No description provided for @tapForHistory.
  ///
  /// In en, this message translates to:
  /// **'Tap for history'**
  String get tapForHistory;

  /// No description provided for @reorderDevices.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorderDevices;

  /// No description provided for @reorderDevicesDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get reorderDevicesDone;

  /// No description provided for @dragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder devices'**
  String get dragToReorder;

  /// No description provided for @scenes.
  ///
  /// In en, this message translates to:
  /// **'Scenes'**
  String get scenes;

  /// No description provided for @noScenes.
  ///
  /// In en, this message translates to:
  /// **'No scenes found'**
  String get noScenes;

  /// No description provided for @noScenesDesc.
  ///
  /// In en, this message translates to:
  /// **'Create scenes in your Shelly Cloud account'**
  String get noScenesDesc;

  /// No description provided for @showScenesTab.
  ///
  /// In en, this message translates to:
  /// **'Show Scenes Tab'**
  String get showScenesTab;

  /// No description provided for @showScenesTabDesc.
  ///
  /// In en, this message translates to:
  /// **'Display automation scenes in navigation'**
  String get showScenesTabDesc;

  /// No description provided for @sceneEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get sceneEnabled;

  /// No description provided for @sceneDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get sceneDisabled;

  /// No description provided for @loadingScenes.
  ///
  /// In en, this message translates to:
  /// **'Loading scenes...'**
  String get loadingScenes;

  /// No description provided for @runScene.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get runScene;

  /// No description provided for @sceneRunning.
  ///
  /// In en, this message translates to:
  /// **'Running...'**
  String get sceneRunning;

  /// No description provided for @hideFromDashboard.
  ///
  /// In en, this message translates to:
  /// **'Hide from Dashboard'**
  String get hideFromDashboard;

  /// No description provided for @hideFromDashboardDesc.
  ///
  /// In en, this message translates to:
  /// **'Device will only appear in the Devices tab'**
  String get hideFromDashboardDesc;

  /// No description provided for @unsupportedDevice.
  ///
  /// In en, this message translates to:
  /// **'Unsupported Device'**
  String get unsupportedDevice;

  /// No description provided for @unsupportedDeviceDesc.
  ///
  /// In en, this message translates to:
  /// **'Device type \"{code}\" is not yet supported. The raw data is shown below.'**
  String unsupportedDeviceDesc(String code);

  /// No description provided for @deviceData.
  ///
  /// In en, this message translates to:
  /// **'Device Data'**
  String get deviceData;

  /// No description provided for @copyJson.
  ///
  /// In en, this message translates to:
  /// **'Copy JSON'**
  String get copyJson;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'bg',
    'ca',
    'cs',
    'da',
    'de',
    'el',
    'en',
    'es',
    'et',
    'fi',
    'fr',
    'hr',
    'hu',
    'is',
    'it',
    'lt',
    'lv',
    'nl',
    'no',
    'pl',
    'pt',
    'ro',
    'ru',
    'sk',
    'sl',
    'sr',
    'sv',
    'uk',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'US':
            return AppLocalizationsEnUs();
        }
        break;
      }
    case 'es':
      {
        switch (locale.countryCode) {
          case 'MX':
            return AppLocalizationsEsMx();
        }
        break;
      }
    case 'fr':
      {
        switch (locale.countryCode) {
          case 'CA':
            return AppLocalizationsFrCa();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bg':
      return AppLocalizationsBg();
    case 'ca':
      return AppLocalizationsCa();
    case 'cs':
      return AppLocalizationsCs();
    case 'da':
      return AppLocalizationsDa();
    case 'de':
      return AppLocalizationsDe();
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'et':
      return AppLocalizationsEt();
    case 'fi':
      return AppLocalizationsFi();
    case 'fr':
      return AppLocalizationsFr();
    case 'hr':
      return AppLocalizationsHr();
    case 'hu':
      return AppLocalizationsHu();
    case 'is':
      return AppLocalizationsIs();
    case 'it':
      return AppLocalizationsIt();
    case 'lt':
      return AppLocalizationsLt();
    case 'lv':
      return AppLocalizationsLv();
    case 'nl':
      return AppLocalizationsNl();
    case 'no':
      return AppLocalizationsNo();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
    case 'ru':
      return AppLocalizationsRu();
    case 'sk':
      return AppLocalizationsSk();
    case 'sl':
      return AppLocalizationsSl();
    case 'sr':
      return AppLocalizationsSr();
    case 'sv':
      return AppLocalizationsSv();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
