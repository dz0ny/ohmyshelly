import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sl.dart';

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
    Locale('en'),
    Locale('sl'),
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
  /// **'Welcome to OhMyShelly'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Control all your Shelly smart home devices from one place'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Monitor Your Home'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Track power usage, weather conditions, and device status in real-time'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Stay in Control'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Turn devices on or off with a single tap, anywhere you are'**
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
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sl':
      return AppLocalizationsSl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
