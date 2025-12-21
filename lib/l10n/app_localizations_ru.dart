// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'OhMyShelly';

  @override
  String get appTagline => 'Умный Дом Упрощен';

  @override
  String get onboardingTitle1 => 'Ваша Панель Управления';

  @override
  String get onboardingDesc1 =>
      'Просматривайте все устройства с первого взгляда. Отслеживайте потребление электроэнергии, погодные данные и состояние устройств в реальном времени. Организуйте по комнатам.';

  @override
  String get onboardingTitle2 => 'Детальная Статистика';

  @override
  String get onboardingDesc2 =>
      'Просматривайте исторические графики потребления энергии и погоды. Отслеживайте тенденции по дням, неделям, месяцам или годам с красивыми графиками.';

  @override
  String get onboardingTitle3 => 'Расписания и Автоматизация';

  @override
  String get onboardingDesc3 =>
      'Создавайте расписания для автоматического включения или выключения устройств. Устанавливайте время, выбирайте дни и позвольте вашему дому работать самостоятельно.';

  @override
  String get getStarted => 'Начать';

  @override
  String get skip => 'Пропустить';

  @override
  String get next => 'Далее';

  @override
  String get signIn => 'Войти';

  @override
  String get email => 'Email';

  @override
  String get password => 'Пароль';

  @override
  String get emailHint => 'Введите ваш Shelly Cloud email';

  @override
  String get passwordHint => 'Введите ваш пароль';

  @override
  String get signingIn => 'Вход...';

  @override
  String get signOut => 'Выйти';

  @override
  String get invalidCredentials => 'Неправильный email или пароль';

  @override
  String get connectionError => 'Не удается подключиться. Проверьте интернет.';

  @override
  String get loginHint =>
      'Sign in with your Shelly Cloud account (control.shelly.cloud)';

  @override
  String get devices => 'Устройства';

  @override
  String get dashboard => 'Панель';

  @override
  String get myDevices => 'Мои Устройства';

  @override
  String get noDevices => 'Устройств не найдено';

  @override
  String get noDevicesDesc =>
      'Добавьте устройства в вашем аккаунте Shelly Cloud';

  @override
  String get smartPlug => 'Умная Розетка';

  @override
  String get weatherStation => 'Метеостанция';

  @override
  String get gatewayDevice => 'Шлюз';

  @override
  String get unknownDevice => 'Устройство';

  @override
  String get otherDevices => 'Другие';

  @override
  String get online => 'Подключено';

  @override
  String get offline => 'Офлайн';

  @override
  String get on => 'Вкл';

  @override
  String get off => 'Выкл';

  @override
  String get power => 'Мощность';

  @override
  String get voltage => 'Напряжение';

  @override
  String get current => 'Ток';

  @override
  String get temperature => 'Температура';

  @override
  String get feelsLike => 'Ощущается как';

  @override
  String get dewPoint => 'Точка росы';

  @override
  String get totalEnergy => 'Общая Энергия';

  @override
  String get humidity => 'Влажность';

  @override
  String get pressure => 'Давление';

  @override
  String get uvIndex => 'UV Индекс';

  @override
  String get windSpeed => 'Ветер';

  @override
  String get windGust => 'Порывы';

  @override
  String get windDirection => 'Направление';

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
  String get rain => 'Дождь';

  @override
  String get rainToday => 'Сегодня';

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
  String get illumination => 'Освещение';

  @override
  String get solar => 'Солнечная';

  @override
  String get battery => 'Батарея';

  @override
  String get uvLow => 'Низкий';

  @override
  String get uvModerate => 'Умеренный';

  @override
  String get uvHigh => 'Высокий';

  @override
  String get uvVeryHigh => 'Очень Высокий';

  @override
  String get uvExtreme => 'Экстремальный';

  @override
  String get pressureRising => 'Растет';

  @override
  String get pressureFalling => 'Падает';

  @override
  String get pressureStable => 'Стабильное';

  @override
  String get totalDevices => 'Всего Устройств';

  @override
  String get activeDevices => 'Активные';

  @override
  String get totalPower => 'Общая Мощность';

  @override
  String get currentWeather => 'Текущая Погода';

  @override
  String get statistics => 'Статистика';

  @override
  String get viewHistory => 'Посмотреть Историю';

  @override
  String get hour => 'Час';

  @override
  String get day => 'День';

  @override
  String get week => 'Неделя';

  @override
  String get month => 'Месяц';

  @override
  String get year => 'Год';

  @override
  String get average => 'Среднее';

  @override
  String get peak => 'Пик';

  @override
  String get total => 'Всего';

  @override
  String get min => 'Мин';

  @override
  String get max => 'Макс';

  @override
  String get errorGeneric => 'Что-то пошло не так';

  @override
  String get errorNetwork => 'Проверьте подключение к интернету';

  @override
  String get retry => 'Повторить';

  @override
  String get pullToRefresh => 'Потяните для обновления';

  @override
  String get loadingDevices => 'Загрузка устройств...';

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
  String get settings => 'Настройки';

  @override
  String get appearance => 'Внешний Вид';

  @override
  String get theme => 'Тема';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Темная';

  @override
  String get showDevicesTab => 'Показать Вкладку Устройства';

  @override
  String get showDevicesTabDesc =>
      'Когда отключено, показывается только Панель';

  @override
  String get language => 'Язык';

  @override
  String get languageSystem => 'Системный по Умолчанию';

  @override
  String get languageEnglish => 'Английский';

  @override
  String get languageSlovenian => 'Словенский';

  @override
  String get languageGerman => 'Немецкий';

  @override
  String get languageFrench => 'Французский';

  @override
  String get languageSpanish => 'Испанский';

  @override
  String get languagePortuguese => 'Португальский';

  @override
  String get languageItalian => 'Итальянский';

  @override
  String get languageDutch => 'Голландский';

  @override
  String get languageCatalan => 'Каталанский';

  @override
  String get languageSwedish => 'Шведский';

  @override
  String get languageNorwegian => 'Норвежский';

  @override
  String get languageDanish => 'Датский';

  @override
  String get languageFinnish => 'Финский';

  @override
  String get languageIcelandic => 'Исландский';

  @override
  String get languagePolish => 'Польский';

  @override
  String get languageCzech => 'Чешский';

  @override
  String get languageSlovak => 'Словацкий';

  @override
  String get languageHungarian => 'Венгерский';

  @override
  String get languageRomanian => 'Румынский';

  @override
  String get languageBulgarian => 'Болгарский';

  @override
  String get languageUkrainian => 'Украинский';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageLithuanian => 'Литовский';

  @override
  String get languageLatvian => 'Латвийский';

  @override
  String get languageEstonian => 'Эстонский';

  @override
  String get languageCroatian => 'Хорватский';

  @override
  String get languageSerbian => 'Сербский';

  @override
  String get languageGreek => 'Греческий';

  @override
  String get cancel => 'Отмена';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get signOutConfirmTitle => 'Выйти';

  @override
  String get signOutConfirmMessage => 'Вы уверены, что хотите выйти?';

  @override
  String get lastUpdated => 'Обновлено';

  @override
  String get summary => 'Итог';

  @override
  String get peakUv => 'Пик UV';

  @override
  String get powerUsage => 'Потребление Энергии';

  @override
  String get noPowerData => 'Нет данных об энергии за этот период';

  @override
  String get noWeatherData => 'Нет погодных данных за этот период';

  @override
  String get noDataAvailable => 'Данные недоступны';

  @override
  String get loadingStatistics => 'Загрузка статистики...';

  @override
  String get windHistoryNotAvailable => 'История ветра недоступна';

  @override
  String get humidityAvg => 'Влажность (средняя)';

  @override
  String get rainTotal => 'Дождь (всего)';

  @override
  String get directionN => 'С';

  @override
  String get directionNE => 'СВ';

  @override
  String get directionE => 'В';

  @override
  String get directionSE => 'ЮВ';

  @override
  String get directionS => 'Ю';

  @override
  String get directionSW => 'ЮЗ';

  @override
  String get directionW => 'З';

  @override
  String get directionNW => 'СЗ';

  @override
  String get profile => 'Профиль';

  @override
  String get account => 'Аккаунт';

  @override
  String get serverUrl => 'Сервер';

  @override
  String get timezoneLabel => 'Часовой Пояс';

  @override
  String get timezoneNotSet => 'Не установлен';

  @override
  String get powerHistory => 'История Энергии';

  @override
  String get weatherHistory => 'История Погоды';

  @override
  String get temperatureHistory => 'История Температуры';

  @override
  String get humidityHistory => 'История Влажности';

  @override
  String get pressureHistory => 'История Давления';

  @override
  String get uvHistory => 'История UV';

  @override
  String get rainHistory => 'История Дождя';

  @override
  String get solarHistory => 'История Солнечной';

  @override
  String get voltageHistory => 'История Напряжения';

  @override
  String get currentHistory => 'История Тока';

  @override
  String get energyHistory => 'История Энергии';

  @override
  String get currentPowerUsage => 'Мощность';

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
  String get daySun => 'Вс';

  @override
  String get monthJan => 'Янв';

  @override
  String get monthFeb => 'Фев';

  @override
  String get monthMar => 'Мар';

  @override
  String get monthApr => 'Апр';

  @override
  String get monthMay => 'Май';

  @override
  String get monthJun => 'Июн';

  @override
  String get monthJul => 'Июл';

  @override
  String get monthAug => 'Авг';

  @override
  String get monthSep => 'Сен';

  @override
  String get monthOct => 'Окт';

  @override
  String get monthNov => 'Ноя';

  @override
  String get monthDec => 'Дек';

  @override
  String get monthJanFull => 'Январь';

  @override
  String get monthFebFull => 'Февраль';

  @override
  String get monthMarFull => 'Март';

  @override
  String get monthAprFull => 'Апрель';

  @override
  String get monthMayFull => 'Май';

  @override
  String get monthJunFull => 'Июнь';

  @override
  String get monthJulFull => 'Июль';

  @override
  String get monthAugFull => 'Август';

  @override
  String get monthSepFull => 'Сентябрь';

  @override
  String get monthOctFull => 'Октябрь';

  @override
  String get monthNovFull => 'Ноябрь';

  @override
  String get monthDecFull => 'Декабрь';

  @override
  String get thisWeek => 'Эта Неделя';

  @override
  String get lastWeek => 'Прошлая Неделя';

  @override
  String get thisMonth => 'Этот Месяц';

  @override
  String get lastMonth => 'Прошлый Месяц';

  @override
  String get thisYear => 'Этот Год';

  @override
  String get nextYear => 'Следующий Год';

  @override
  String get selectMonth => 'Выберите Месяц';

  @override
  String get selectYear => 'Выберите Год';

  @override
  String get solarDark => 'Темно';

  @override
  String get solarCloudy => 'Облачно';

  @override
  String get solarPartlySunny => 'Частично Солнечно';

  @override
  String get solarSunny => 'Солнечно';

  @override
  String get solarVerySunny => 'Очень Солнечно';

  @override
  String get batteryFull => 'Полная';

  @override
  String get batteryGood => 'Хорошая';

  @override
  String get batteryLow => 'Низкая';

  @override
  String get batteryCritical => 'Критическая';

  @override
  String get updateAvailable => 'Доступно обновление';

  @override
  String updateVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get updateDownload => 'Загрузить';

  @override
  String get updateDownloading => 'Загрузка обновления...';

  @override
  String get updateReady => 'Обновление готово';

  @override
  String get updateTapToInstall => 'Нажмите для установки';

  @override
  String get updateInstall => 'Установить';

  @override
  String get updateError => 'Ошибка обновления';

  @override
  String get updateClose => 'Закрыть';

  @override
  String get schedules => 'Расписания';

  @override
  String get noSchedules => 'Нет расписаний';

  @override
  String get addSchedule => 'Добавить Расписание';

  @override
  String get editSchedule => 'Редактировать';

  @override
  String get deleteSchedule => 'Удалить';

  @override
  String get deleteScheduleConfirm =>
      'Вы уверены, что хотите удалить это расписание?';

  @override
  String get scheduleTime => 'Время';

  @override
  String get scheduleDays => 'Дни';

  @override
  String get scheduleAction => 'Действие';

  @override
  String get turnOn => 'Включить';

  @override
  String get turnOff => 'Выключить';

  @override
  String get everyDay => 'Каждый день';

  @override
  String get weekdays => 'Будни';

  @override
  String get weekends => 'Выходные';

  @override
  String get save => 'Сохранить';

  @override
  String get autoUpdateSchedule => 'Автообновление';

  @override
  String get autoUpdateScheduleDesc => 'Обновления прошивки в полночь';

  @override
  String get addAutoUpdateSchedule => 'Добавить автообновление';

  @override
  String get editAutoUpdateSchedule => 'Редактировать автообновление';

  @override
  String get autoUpdateScheduleHint =>
      'Расписание когда устройство проверяет обновления прошивки';

  @override
  String get systemSchedule => 'Система';

  @override
  String get userSchedules => 'Пользовательские расписания';

  @override
  String get activity => 'Активность';

  @override
  String get noActivity => 'Нет недавней активности';

  @override
  String get recentActivity => 'Недавняя активность';

  @override
  String get noRecentActivity => 'Нет недавней активности';

  @override
  String get turnedOn => 'Включено';

  @override
  String get turnedOff => 'Выключено';

  @override
  String get sourceButton => 'Кнопка';

  @override
  String get sourceSchedule => 'Расписание';

  @override
  String get sourceApp => 'Приложение';

  @override
  String get sourceSystem => 'Система';

  @override
  String get sourceUnknown => 'Неизвестно';

  @override
  String get justNow => 'Только что';

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count минуты назад',
      many: '$count минут назад',
      few: '$count минуты назад',
      one: '1 минуту назад',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count часа назад',
      many: '$count часов назад',
      few: '$count часа назад',
      one: '1 час назад',
    );
    return '$_temp0';
  }

  @override
  String get today => 'Сегодня';

  @override
  String get yesterday => 'Вчера';

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня назад',
      many: '$count дней назад',
      few: '$count дня назад',
      one: '1 день назад',
    );
    return '$_temp0';
  }

  @override
  String get deviceInfo => 'Информация об Устройстве';

  @override
  String get name => 'Название';

  @override
  String get model => 'Модель';

  @override
  String get type => 'Тип';

  @override
  String get generation => 'Поколение';

  @override
  String get deviceId => 'ID Устройства';

  @override
  String get serial => 'Серийный номер';

  @override
  String get firmware => 'Прошивка';

  @override
  String get room => 'Комната';

  @override
  String get connection => 'Соединение';

  @override
  String get status => 'Статус';

  @override
  String get wifiNetwork => 'WiFi Сеть';

  @override
  String get ipAddress => 'IP Адрес';

  @override
  String get signalStrength => 'Сила Сигнала';

  @override
  String get signalExcellent => 'Отличный';

  @override
  String get signalGood => 'Хороший';

  @override
  String get signalFair => 'Удовлетворительный';

  @override
  String get signalWeak => 'Слабый';

  @override
  String get signalUnknown => 'Неизвестный';

  @override
  String get uptime => 'Время работы';

  @override
  String get ramFree => 'Свободная RAM';

  @override
  String get deviceOffline => 'Устройство офлайн';

  @override
  String get tapForHistory => 'Нажмите для истории';

  @override
  String get reorderDevices => 'Упорядочить';

  @override
  String get reorderDevicesDone => 'Готово';

  @override
  String get dragToReorder => 'Перетащите для упорядочивания устройств';

  @override
  String get scenes => 'Сцены';

  @override
  String get noScenes => 'Сцен не найдено';

  @override
  String get noScenesDesc => 'Создайте сцены в вашем аккаунте Shelly Cloud';

  @override
  String get showScenesTab => 'Показать Вкладку Сцены';

  @override
  String get showScenesTabDesc =>
      'Отображать автоматизированные сцены в навигации';

  @override
  String get showDeviceInfoButton => 'Показать кнопку информации';

  @override
  String get showDeviceInfoButtonDesc =>
      'Показывать кнопку информации на экране устройства';

  @override
  String get showScheduleButton => 'Показать кнопку расписания';

  @override
  String get showScheduleButtonDesc =>
      'Показывать кнопку расписания для энергетических устройств';

  @override
  String get showActionsButton => 'Показать кнопку действий';

  @override
  String get showActionsButtonDesc =>
      'Показывать кнопку действий на экране устройства';

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
  String get sceneEnabled => 'Включено';

  @override
  String get sceneDisabled => 'Отключено';

  @override
  String get loadingScenes => 'Загрузка сцен...';

  @override
  String get runScene => 'Запустить';

  @override
  String get sceneRunning => 'Выполняется...';

  @override
  String get hideFromDashboard => 'Скрыть с панели';

  @override
  String get hideFromDashboardDesc =>
      'Устройство будет отображаться только на вкладке Устройства';

  @override
  String get backupSettings => 'Резервная копия';

  @override
  String get backupSettingsDesc => 'Сохранить расписания и действия локально';

  @override
  String get backupCreate => 'Создать копию';

  @override
  String get backupRestore => 'Восстановить копию';

  @override
  String get backupDelete => 'Удалить копию';

  @override
  String get backupCreated => 'Резервная копия создана';

  @override
  String get backupRestored => 'Резервная копия восстановлена';

  @override
  String get backupDeleted => 'Резервная копия удалена';

  @override
  String get backupNotFound => 'Резервная копия не найдена';

  @override
  String get backupRestoreConfirm =>
      'Это заменит текущие расписания и действия резервной копией. Продолжить?';

  @override
  String get backupDeleteConfirm =>
      'Удалить резервную копию для этого устройства?';

  @override
  String backupInfo(String date) {
    return 'Последняя копия: $date';
  }

  @override
  String get backupNoBackup => 'Нет резервной копии';

  @override
  String get unsupportedDevice => 'Неподдерживаемое устройство';

  @override
  String unsupportedDeviceDesc(String code) {
    return 'Тип устройства \"$code\" пока не поддерживается. Необработанные данные показаны ниже.';
  }

  @override
  String get deviceData => 'Данные устройства';

  @override
  String get copyJson => 'Копировать JSON';

  @override
  String get copiedToClipboard => 'Скопировано в буфер обмена';

  @override
  String get webhooks => 'Действия';

  @override
  String get noWebhooks => 'Нет действий';

  @override
  String get noWebhooksDesc =>
      'Создайте действия для запуска других устройств при возникновении событий';

  @override
  String get addWebhook => 'Добавить действие';

  @override
  String get editWebhook => 'Редактировать';

  @override
  String get deleteWebhook => 'Удалить';

  @override
  String get deleteWebhookConfirm =>
      'Вы уверены, что хотите удалить это действие?';

  @override
  String get webhookNoName => 'Действие без названия';

  @override
  String get webhookName => 'Название';

  @override
  String get webhookNameHint => 'напр., Включить свет';

  @override
  String get webhookEvent => 'Событие триггера';

  @override
  String get webhookUrls => 'Целевые URL';

  @override
  String get webhookUrlHint => 'http://192.168.1.x/rpc/...';

  @override
  String get webhookAddUrl => 'Добавить URL';

  @override
  String get webhookRemoveUrl => 'Удалить';

  @override
  String get webhookRepeatPeriod => 'Пауза повторения';

  @override
  String get webhookRepeatNone => 'Без паузы';

  @override
  String get webhookRepeat5s => '5 секунд';

  @override
  String get webhookRepeat15s => '15 секунд';

  @override
  String get webhookRepeat30s => '30 секунд';

  @override
  String get webhookRepeat1min => '1 минута';

  @override
  String get webhookRepeat5min => '5 минут';

  @override
  String get webhookRepeat15min => '15 минут';

  @override
  String get webhookRepeat1hour => '1 час';

  @override
  String get webhookModeDevice => 'Устройство';

  @override
  String get webhookModeCustom => 'Пользовательский URL';

  @override
  String get webhookTargetDevice => 'Целевое устройство';

  @override
  String get webhookSelectDevice => 'Выберите устройство';

  @override
  String get webhookNoDevices => 'Нет других доступных устройств';

  @override
  String get webhookToggle => 'Переключить';

  @override
  String get webhookToggleAfter => 'Автоматически вернуть после';

  @override
  String get webhookToggleAfterNone => 'Не возвращать';

  @override
  String get webhookToggleAfter30s => '30 секунд';

  @override
  String get webhookToggleAfter1min => '1 минута';

  @override
  String get webhookToggleAfter5min => '5 минут';

  @override
  String get webhookToggleAfter10min => '10 минут';

  @override
  String get webhookToggleAfter30min => '30 минут';

  @override
  String get webhookToggleAfter1hour => '1 час';

  @override
  String get webhookToggleAfterNotAvailable =>
      'Автоматический возврат недоступен для действия переключения';

  @override
  String get phoneOffline => 'Вы офлайн';

  @override
  String get phoneOfflineDesc =>
      'Проверьте подключение к интернету. Ваши устройства продолжают работать.';

  @override
  String get phoneOnCellular => 'Используется мобильная сеть';

  @override
  String get phoneOnCellularDesc =>
      'Подключитесь к WiFi для прямого управления устройствами';

  @override
  String get phoneDifferentWifi => 'Другая сеть WiFi';

  @override
  String phoneDifferentWifiDesc(Object network) {
    return 'Ваши устройства в сети $network. Используется облачное подключение.';
  }
}
