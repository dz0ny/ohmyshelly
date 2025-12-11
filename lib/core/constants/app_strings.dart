class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'OhMyShelly';
  static const String appTagline = 'Smart Home Made Simple';

  // Onboarding
  static const String onboardingTitle1 = 'Welcome to OhMyShelly';
  static const String onboardingDesc1 =
      'Control all your Shelly smart home devices from one place';
  static const String onboardingTitle2 = 'Monitor Your Home';
  static const String onboardingDesc2 =
      'Track power usage, weather conditions, and device status in real-time';
  static const String onboardingTitle3 = 'Stay in Control';
  static const String onboardingDesc3 =
      'Turn devices on or off with a single tap, anywhere you are';
  static const String getStarted = 'Get Started';
  static const String skip = 'Skip';
  static const String next = 'Next';

  // Auth
  static const String signIn = 'Sign In';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String emailHint = 'Enter your Shelly Cloud email';
  static const String passwordHint = 'Enter your password';
  static const String signingIn = 'Signing in...';
  static const String signOut = 'Sign Out';
  static const String invalidCredentials = 'Incorrect email or password';
  static const String connectionError = 'Unable to connect. Check your internet.';

  // Navigation
  static const String devices = 'Devices';
  static const String dashboard = 'Dashboard';

  // Devices
  static const String myDevices = 'My Devices';
  static const String noDevices = 'No devices found';
  static const String noDevicesDesc = 'Add devices in your Shelly Cloud account';
  static const String smartPlug = 'Smart Plug';
  static const String weatherStation = 'Weather Station';
  static const String gatewayDevice = 'Gateway';
  static const String unknownDevice = 'Device';
  static const String online = 'Connected';
  static const String offline = 'Offline';
  static const String on = 'On';
  static const String off = 'Off';

  // Power metrics (user-friendly names)
  static const String power = 'Power';
  static const String voltage = 'Voltage';
  static const String current = 'Current';
  static const String temperature = 'Temperature';
  static const String totalEnergy = 'Total Energy';

  // Weather metrics (user-friendly names)
  static const String humidity = 'Humidity';
  static const String pressure = 'Pressure';
  static const String uvIndex = 'UV Index';
  static const String windSpeed = 'Wind';
  static const String windGust = 'Gusts';
  static const String windDirection = 'Direction';
  static const String rain = 'Rain';
  static const String rainToday = 'Today';
  static const String illumination = 'Illumination';
  static const String solar = 'Solar';
  static const String battery = 'Battery';

  // UV danger levels
  static const String uvLow = 'Low';
  static const String uvModerate = 'Moderate';
  static const String uvHigh = 'High';
  static const String uvVeryHigh = 'Very High';
  static const String uvExtreme = 'Extreme';

  // Pressure trends
  static const String pressureRising = 'Rising';
  static const String pressureFalling = 'Falling';
  static const String pressureStable = 'Stable';

  // Dashboard
  static const String totalDevices = 'Total Devices';
  static const String activeDevices = 'Active';
  static const String totalPower = 'Total Power';
  static const String currentWeather = 'Current Weather';

  // Statistics
  static const String statistics = 'Statistics';
  static const String viewHistory = 'View History';
  static const String hour = 'Hour';
  static const String day = 'Day';
  static const String month = 'Month';
  static const String year = 'Year';
  static const String average = 'Average';
  static const String peak = 'Peak';
  static const String total = 'Total';
  static const String min = 'Min';
  static const String max = 'Max';

  // Errors
  static const String errorGeneric = 'Something went wrong';
  static const String errorNetwork = 'Check your internet connection';
  static const String retry = 'Retry';
  static const String pullToRefresh = 'Pull to refresh';

  // Units
  static const String watts = 'W';
  static const String kilowattHours = 'kWh';
  static const String volts = 'V';
  static const String amps = 'A';
  static const String celsius = '\u00B0C';
  static const String percent = '%';
  static const String hectopascals = 'hPa';
  static const String kmPerHour = 'km/h';
  static const String millimeters = 'mm';
  static const String lux = 'lux';
}
