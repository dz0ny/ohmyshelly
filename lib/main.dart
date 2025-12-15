import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'data/services/api_service.dart';
import 'data/services/storage_service.dart';
import 'data/services/update_service.dart';
import 'data/services/websocket_service.dart';
import 'data/services/local_device_service.dart';
import 'data/services/mdns_discovery_service.dart';
import 'data/services/connection_manager.dart';
import 'data/services/device_service.dart';
import 'data/services/network_monitor_service.dart';
import 'providers/auth_provider.dart';
import 'providers/device_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/statistics_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/scene_provider.dart';
import 'providers/webhook_provider.dart';
import 'data/services/scene_service.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize storage service
  final storageService = StorageService();
  await storageService.init();

  // Create API service
  final apiService = ApiService();

  // Create WebSocket service for real-time updates
  final webSocketService = WebSocketService();

  // Create local connection services
  final localDeviceService = LocalDeviceService();
  final mdnsService = MdnsDiscoveryService();
  final networkMonitor = NetworkMonitorService();
  final connectionManager = ConnectionManager(
    localService: localDeviceService,
    cloudService: DeviceService(apiService),
    mdnsService: mdnsService,
    storageService: storageService,
    networkMonitor: networkMonitor,
  );

  // Create settings provider and initialize
  final settingsProvider = SettingsProvider(storageService: storageService);
  await settingsProvider.init();

  // Create auth provider (single source of truth for credentials)
  final authProvider = AuthProvider(
    storageService: storageService,
    apiService: apiService,
  );

  // Initialize update service (Android only)
  if (Platform.isAndroid) {
    await UpdateService().init();
  }

  runApp(
    OhMyShellyApp(
      storageService: storageService,
      apiService: apiService,
      webSocketService: webSocketService,
      connectionManager: connectionManager,
      settingsProvider: settingsProvider,
      authProvider: authProvider,
    ),
  );
}

class OhMyShellyApp extends StatelessWidget {
  final StorageService storageService;
  final ApiService apiService;
  final WebSocketService webSocketService;
  final ConnectionManager connectionManager;
  final SettingsProvider settingsProvider;
  final AuthProvider authProvider;

  const OhMyShellyApp({
    super.key,
    required this.storageService,
    required this.apiService,
    required this.webSocketService,
    required this.connectionManager,
    required this.settingsProvider,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<StorageService>.value(value: storageService),
        Provider<ApiService>.value(value: apiService),

        // Settings provider
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),

        // Auth provider (single source of truth for credentials)
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),

        // Device provider with WebSocket and local connection support
        ChangeNotifierProvider<DeviceProvider>(
          create: (context) => DeviceProvider(
            authProvider: authProvider,
            apiService: apiService,
            webSocketService: webSocketService,
            connectionManager: connectionManager,
            storageService: storageService,
          ),
        ),

        // Dashboard provider
        ChangeNotifierProvider<DashboardProvider>(
          create: (context) => DashboardProvider(),
        ),

        // Statistics provider
        ChangeNotifierProvider<StatisticsProvider>(
          create: (context) => StatisticsProvider(
            authProvider: authProvider,
            apiService: apiService,
          ),
        ),

        // Schedule provider with WebSocket and API support
        ChangeNotifierProvider<ScheduleProvider>(
          create: (context) => ScheduleProvider(
            authProvider: authProvider,
            webSocketService: webSocketService,
            apiService: apiService,
          ),
        ),

        // Webhook provider with WebSocket support
        ChangeNotifierProvider<WebhookProvider>(
          create: (context) => WebhookProvider(
            webSocketService: webSocketService,
          ),
        ),

        // Scene provider
        ChangeNotifierProvider<SceneProvider>(
          create: (context) => SceneProvider(
            authProvider: authProvider,
            sceneService: SceneService(apiService),
          ),
        ),

        // Update service (Android only)
        ChangeNotifierProvider<UpdateService>.value(value: UpdateService()),
      ],
      child: const _AppWithRouter(),
    );
  }
}

class _AppWithRouter extends StatefulWidget {
  const _AppWithRouter();

  @override
  State<_AppWithRouter> createState() => _AppWithRouterState();
}

class _AppWithRouterState extends State<_AppWithRouter> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(context.read<AuthProvider>());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp.router(
          title: 'OhMyShelly',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          routerConfig: _appRouter.router,
          locale: settings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
}
