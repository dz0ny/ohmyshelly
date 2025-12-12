// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appName => 'OhMyShelly';

  @override
  String get appTagline => 'Розумний Дім Зроблено Просто';

  @override
  String get onboardingTitle1 => 'Ваша Панель Керування';

  @override
  String get onboardingDesc1 =>
      'Перегляньте всі пристрої з першого погляду. Відстежуйте споживання електроенергії, погодні дані та стан пристроїв у реальному часі. Організуйте за кімнатами.';

  @override
  String get onboardingTitle2 => 'Детальна Статистика';

  @override
  String get onboardingDesc2 =>
      'Переглядайте історичні графіки споживання енергії та погоди. Відстежуйте тенденції за день, тиждень, місяць або рік з красивими графіками.';

  @override
  String get onboardingTitle3 => 'Розклади та Автоматизація';

  @override
  String get onboardingDesc3 =>
      'Створюйте розклади для автоматичного увімкнення або вимкнення пристроїв. Встановлюйте час, вибирайте дні та дозвольте вашому дому працювати самостійно.';

  @override
  String get getStarted => 'Почати';

  @override
  String get skip => 'Пропустити';

  @override
  String get next => 'Далі';

  @override
  String get signIn => 'Увійти';

  @override
  String get email => 'Email';

  @override
  String get password => 'Пароль';

  @override
  String get emailHint => 'Введіть ваш Shelly Cloud email';

  @override
  String get passwordHint => 'Введіть ваш пароль';

  @override
  String get signingIn => 'Вхід...';

  @override
  String get signOut => 'Вийти';

  @override
  String get invalidCredentials => 'Неправильний email або пароль';

  @override
  String get connectionError => 'Не вдається підключитися. Перевірте інтернет.';

  @override
  String get devices => 'Пристрої';

  @override
  String get dashboard => 'Панель';

  @override
  String get myDevices => 'Мої Пристрої';

  @override
  String get noDevices => 'Пристроїв не знайдено';

  @override
  String get noDevicesDesc =>
      'Додайте пристрої у вашому обліковому записі Shelly Cloud';

  @override
  String get smartPlug => 'Розумна Розетка';

  @override
  String get weatherStation => 'Метеостанція';

  @override
  String get gatewayDevice => 'Шлюз';

  @override
  String get unknownDevice => 'Пристрій';

  @override
  String get otherDevices => 'Інші';

  @override
  String get online => 'Підключено';

  @override
  String get offline => 'Офлайн';

  @override
  String get on => 'Увімк';

  @override
  String get off => 'Вимк';

  @override
  String get power => 'Потужність';

  @override
  String get voltage => 'Напруга';

  @override
  String get current => 'Струм';

  @override
  String get temperature => 'Температура';

  @override
  String get feelsLike => 'Відчувається як';

  @override
  String get totalEnergy => 'Загальна Енергія';

  @override
  String get humidity => 'Вологість';

  @override
  String get pressure => 'Тиск';

  @override
  String get uvIndex => 'UV Індекс';

  @override
  String get windSpeed => 'Вітер';

  @override
  String get windGust => 'Пориви';

  @override
  String get windDirection => 'Напрямок';

  @override
  String get rain => 'Дощ';

  @override
  String get rainToday => 'Сьогодні';

  @override
  String get illumination => 'Освітлення';

  @override
  String get solar => 'Сонячна';

  @override
  String get battery => 'Батарея';

  @override
  String get uvLow => 'Низький';

  @override
  String get uvModerate => 'Помірний';

  @override
  String get uvHigh => 'Високий';

  @override
  String get uvVeryHigh => 'Дуже Високий';

  @override
  String get uvExtreme => 'Екстремальний';

  @override
  String get pressureRising => 'Зростає';

  @override
  String get pressureFalling => 'Падає';

  @override
  String get pressureStable => 'Стабільний';

  @override
  String get totalDevices => 'Всього Пристроїв';

  @override
  String get activeDevices => 'Активні';

  @override
  String get totalPower => 'Загальна Потужність';

  @override
  String get currentWeather => 'Поточна Погода';

  @override
  String get statistics => 'Статистика';

  @override
  String get viewHistory => 'Переглянути Історію';

  @override
  String get hour => 'Година';

  @override
  String get day => 'День';

  @override
  String get week => 'Тиждень';

  @override
  String get month => 'Місяць';

  @override
  String get year => 'Рік';

  @override
  String get average => 'Середнє';

  @override
  String get peak => 'Пік';

  @override
  String get total => 'Всього';

  @override
  String get min => 'Мін';

  @override
  String get max => 'Макс';

  @override
  String get errorGeneric => 'Щось пішло не так';

  @override
  String get errorNetwork => 'Перевірте підключення до інтернету';

  @override
  String get retry => 'Повторити';

  @override
  String get pullToRefresh => 'Потягніть для оновлення';

  @override
  String get loadingDevices => 'Завантаження пристроїв...';

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
  String get settings => 'Налаштування';

  @override
  String get appearance => 'Зовнішній Вигляд';

  @override
  String get theme => 'Тема';

  @override
  String get themeSystem => 'Системна';

  @override
  String get themeLight => 'Світла';

  @override
  String get themeDark => 'Темна';

  @override
  String get showDevicesTab => 'Показати Вкладку Пристрої';

  @override
  String get showDevicesTabDesc => 'Коли вимкнено, показується лише Панель';

  @override
  String get language => 'Мова';

  @override
  String get languageSystem => 'Системна за Замовчуванням';

  @override
  String get languageEnglish => 'Англійська';

  @override
  String get languageSlovenian => 'Словенська';

  @override
  String get languageGerman => 'Німецька';

  @override
  String get languageFrench => 'Французька';

  @override
  String get languageSpanish => 'Іспанська';

  @override
  String get languagePortuguese => 'Португальська';

  @override
  String get languageItalian => 'Італійська';

  @override
  String get languageDutch => 'Голландська';

  @override
  String get languageCatalan => 'Каталанська';

  @override
  String get languageSwedish => 'Шведська';

  @override
  String get languageNorwegian => 'Норвезька';

  @override
  String get languageDanish => 'Данська';

  @override
  String get languageFinnish => 'Фінська';

  @override
  String get languageIcelandic => 'Ісландська';

  @override
  String get languagePolish => 'Польська';

  @override
  String get languageCzech => 'Чеська';

  @override
  String get languageSlovak => 'Словацька';

  @override
  String get languageHungarian => 'Угорська';

  @override
  String get languageRomanian => 'Румунська';

  @override
  String get languageBulgarian => 'Болгарська';

  @override
  String get languageUkrainian => 'Українська';

  @override
  String get languageRussian => 'Російська';

  @override
  String get languageLithuanian => 'Литовська';

  @override
  String get languageLatvian => 'Латвійська';

  @override
  String get languageEstonian => 'Естонська';

  @override
  String get languageCroatian => 'Хорватська';

  @override
  String get languageSerbian => 'Сербська';

  @override
  String get languageGreek => 'Грецька';

  @override
  String get languageSpanishMexico => 'Іспанська (Мексика)';

  @override
  String get languageFrenchCanada => 'Французька (Канада)';

  @override
  String get languageEnglishUS => 'Англійська (США)';

  @override
  String get cancel => 'Скасувати';

  @override
  String get confirm => 'Підтвердити';

  @override
  String get signOutConfirmTitle => 'Вийти';

  @override
  String get signOutConfirmMessage => 'Ви впевнені, що хочете вийти?';

  @override
  String get lastUpdated => 'Оновлено';

  @override
  String get summary => 'Підсумок';

  @override
  String get peakUv => 'Пік UV';

  @override
  String get powerUsage => 'Споживання Енергії';

  @override
  String get noPowerData => 'Немає даних про енергію за цей період';

  @override
  String get noWeatherData => 'Немає погодних даних за цей період';

  @override
  String get noDataAvailable => 'Дані недоступні';

  @override
  String get loadingStatistics => 'Завантаження статистики...';

  @override
  String get windHistoryNotAvailable => 'Історія вітру недоступна';

  @override
  String get humidityAvg => 'Вологість (середня)';

  @override
  String get rainTotal => 'Дощ (всього)';

  @override
  String get directionN => 'Пн';

  @override
  String get directionNE => 'ПнС';

  @override
  String get directionE => 'Сх';

  @override
  String get directionSE => 'ПдС';

  @override
  String get directionS => 'Пд';

  @override
  String get directionSW => 'ПдЗ';

  @override
  String get directionW => 'Зх';

  @override
  String get directionNW => 'ПнЗ';

  @override
  String get profile => 'Профіль';

  @override
  String get account => 'Обліковий Запис';

  @override
  String get serverUrl => 'Сервер';

  @override
  String get timezoneLabel => 'Часовий Пояс';

  @override
  String get timezoneNotSet => 'Не встановлено';

  @override
  String get powerHistory => 'Історія Енергії';

  @override
  String get weatherHistory => 'Історія Погоди';

  @override
  String get temperatureHistory => 'Історія Температури';

  @override
  String get humidityHistory => 'Історія Вологості';

  @override
  String get pressureHistory => 'Історія Тиску';

  @override
  String get uvHistory => 'Історія UV';

  @override
  String get rainHistory => 'Історія Дощу';

  @override
  String get solarHistory => 'Історія Сонячної';

  @override
  String get voltageHistory => 'Історія Напруги';

  @override
  String get currentHistory => 'Історія Струму';

  @override
  String get energyHistory => 'Історія Енергії';

  @override
  String get currentPowerUsage => 'Потужність';

  @override
  String get dayMon => 'Пн';

  @override
  String get dayTue => 'Вт';

  @override
  String get dayWed => 'Ср';

  @override
  String get dayThu => 'Чт';

  @override
  String get dayFri => 'Пт';

  @override
  String get daySat => 'Сб';

  @override
  String get daySun => 'Нд';

  @override
  String get monthJan => 'Січ';

  @override
  String get monthFeb => 'Лют';

  @override
  String get monthMar => 'Бер';

  @override
  String get monthApr => 'Квіт';

  @override
  String get monthMay => 'Трав';

  @override
  String get monthJun => 'Черв';

  @override
  String get monthJul => 'Лип';

  @override
  String get monthAug => 'Серп';

  @override
  String get monthSep => 'Вер';

  @override
  String get monthOct => 'Жовт';

  @override
  String get monthNov => 'Лист';

  @override
  String get monthDec => 'Груд';

  @override
  String get monthJanFull => 'Січень';

  @override
  String get monthFebFull => 'Лютий';

  @override
  String get monthMarFull => 'Березень';

  @override
  String get monthAprFull => 'Квітень';

  @override
  String get monthMayFull => 'Травень';

  @override
  String get monthJunFull => 'Червень';

  @override
  String get monthJulFull => 'Липень';

  @override
  String get monthAugFull => 'Серпень';

  @override
  String get monthSepFull => 'Вересень';

  @override
  String get monthOctFull => 'Жовтень';

  @override
  String get monthNovFull => 'Листопад';

  @override
  String get monthDecFull => 'Грудень';

  @override
  String get thisWeek => 'Цей Тиждень';

  @override
  String get lastWeek => 'Минулий Тиждень';

  @override
  String get thisMonth => 'Цей Місяць';

  @override
  String get lastMonth => 'Минулий Місяць';

  @override
  String get thisYear => 'Цей Рік';

  @override
  String get nextYear => 'Наступний Рік';

  @override
  String get selectMonth => 'Виберіть Місяць';

  @override
  String get selectYear => 'Виберіть Рік';

  @override
  String get solarDark => 'Темно';

  @override
  String get solarCloudy => 'Хмарно';

  @override
  String get solarPartlySunny => 'Частково Сонячно';

  @override
  String get solarSunny => 'Сонячно';

  @override
  String get solarVerySunny => 'Дуже Сонячно';

  @override
  String get batteryFull => 'Повна';

  @override
  String get batteryGood => 'Добра';

  @override
  String get batteryLow => 'Низька';

  @override
  String get batteryCritical => 'Критична';

  @override
  String get updateAvailable => 'Доступне оновлення';

  @override
  String updateVersion(String version) {
    return 'Версія $version';
  }

  @override
  String get updateDownload => 'Завантажити';

  @override
  String get updateDownloading => 'Завантаження оновлення...';

  @override
  String get updateReady => 'Оновлення готове';

  @override
  String get updateTapToInstall => 'Натисніть для встановлення';

  @override
  String get updateInstall => 'Встановити';

  @override
  String get updateError => 'Помилка оновлення';

  @override
  String get updateClose => 'Закрити';

  @override
  String get schedules => 'Розклади';

  @override
  String get noSchedules => 'Немає розкладів';

  @override
  String get addSchedule => 'Додати Розклад';

  @override
  String get editSchedule => 'Редагувати';

  @override
  String get deleteSchedule => 'Видалити';

  @override
  String get deleteScheduleConfirm =>
      'Ви впевнені, що хочете видалити цей розклад?';

  @override
  String get scheduleTime => 'Час';

  @override
  String get scheduleDays => 'Дні';

  @override
  String get scheduleAction => 'Дія';

  @override
  String get turnOn => 'Увімкнути';

  @override
  String get turnOff => 'Вимкнути';

  @override
  String get everyDay => 'Щодня';

  @override
  String get weekdays => 'Будні';

  @override
  String get weekends => 'Вихідні';

  @override
  String get save => 'Зберегти';

  @override
  String get activity => 'Активність';

  @override
  String get noActivity => 'Немає недавньої активності';

  @override
  String get sourceButton => 'Кнопка';

  @override
  String get sourceSchedule => 'Розклад';

  @override
  String get sourceApp => 'Додаток';

  @override
  String get sourceSystem => 'Система';

  @override
  String get sourceUnknown => 'Невідомо';

  @override
  String get justNow => 'Щойно';

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count хвилини тому',
      many: '$count хвилин тому',
      few: '$count хвилини тому',
      one: '1 хвилину тому',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count години тому',
      many: '$count годин тому',
      few: '$count години тому',
      one: '1 годину тому',
    );
    return '$_temp0';
  }

  @override
  String get today => 'Сьогодні';

  @override
  String get yesterday => 'Вчора';

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня тому',
      many: '$count днів тому',
      few: '$count дні тому',
      one: '1 день тому',
    );
    return '$_temp0';
  }

  @override
  String get deviceInfo => 'Інформація про Пристрій';

  @override
  String get name => 'Назва';

  @override
  String get model => 'Модель';

  @override
  String get type => 'Тип';

  @override
  String get generation => 'Покоління';

  @override
  String get deviceId => 'ID Пристрою';

  @override
  String get serial => 'Серійний номер';

  @override
  String get firmware => 'Прошивка';

  @override
  String get room => 'Кімната';

  @override
  String get connection => 'З\'єднання';

  @override
  String get status => 'Статус';

  @override
  String get wifiNetwork => 'WiFi Мережа';

  @override
  String get ipAddress => 'IP Адреса';

  @override
  String get signalStrength => 'Сила Сигналу';

  @override
  String get signalExcellent => 'Відмінний';

  @override
  String get signalGood => 'Добрий';

  @override
  String get signalFair => 'Задовільний';

  @override
  String get signalWeak => 'Слабкий';

  @override
  String get signalUnknown => 'Невідомий';

  @override
  String get uptime => 'Час роботи';

  @override
  String get ramFree => 'Вільна RAM';

  @override
  String get deviceOffline => 'Пристрій офлайн';

  @override
  String get tapForHistory => 'Натисніть для історії';

  @override
  String get reorderDevices => 'Впорядкувати';

  @override
  String get reorderDevicesDone => 'Готово';

  @override
  String get dragToReorder => 'Перетягніть для впорядкування пристроїв';

  @override
  String get scenes => 'Сцени';

  @override
  String get noScenes => 'Сцен не знайдено';

  @override
  String get noScenesDesc =>
      'Створіть сцени у вашому обліковому записі Shelly Cloud';

  @override
  String get showScenesTab => 'Показати Вкладку Сцени';

  @override
  String get showScenesTabDesc =>
      'Відображати автоматизовані сцени в навігації';

  @override
  String get sceneEnabled => 'Увімкнено';

  @override
  String get sceneDisabled => 'Вимкнено';

  @override
  String get loadingScenes => 'Завантаження сцен...';

  @override
  String get runScene => 'Запустити';

  @override
  String get sceneRunning => 'Виконується...';
}
