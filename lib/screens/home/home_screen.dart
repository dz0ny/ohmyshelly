import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_icons.dart';
import '../../data/services/update_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/device_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/scene_provider.dart';
import '../../widgets/common/update_banner.dart';
import 'devices_tab.dart';
import 'dashboard_tab.dart';
import 'scenes_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  int _tapCount = 0;
  int? _lastTappedIndex;
  Timer? _tapResetTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Defer to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
      // Check for updates on Android
      if (Platform.isAndroid) {
        context.read<UpdateService>().checkForUpdate();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tapResetTimer?.cancel();
    super.dispose();
  }

  void _handleNavTap(int index) {
    // Reset counter if different tab is tapped
    if (_lastTappedIndex != index) {
      _tapCount = 0;
      _tapResetTimer?.cancel();
    }
    _lastTappedIndex = index;

    // Increment tap counter
    _tapCount++;

    // Reset timer on each tap
    _tapResetTimer?.cancel();
    _tapResetTimer = Timer(const Duration(seconds: 2), () {
      _tapCount = 0;
      _lastTappedIndex = null;
    });

    // Check for 5 taps on same tab
    if (_tapCount >= 5) {
      _tapCount = 0;
      _lastTappedIndex = null;
      _tapResetTimer?.cancel();
      _triggerOnboardingRestart();
      return;
    }

    // Normal tab switch
    setState(() => _currentIndex = index);
  }

  Future<void> _triggerOnboardingRestart() async {
    await context.read<AuthProvider>().resetOnboarding();
    if (mounted) {
      context.go('/onboarding');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final deviceProvider = context.read<DeviceProvider>();
    if (state == AppLifecycleState.paused) {
      deviceProvider.pauseAutoRefresh();
    } else if (state == AppLifecycleState.resumed) {
      deviceProvider.resumeAutoRefresh();
    }
  }

  void _initializeData() {
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final deviceProvider = context.read<DeviceProvider>();
    final dashboardProvider = context.read<DashboardProvider>();
    final scheduleProvider = context.read<ScheduleProvider>();
    final sceneProvider = context.read<SceneProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    // Set credentials for providers
    deviceProvider.setCredentials(authProvider.apiUrl, authProvider.token);
    scheduleProvider.setCredentials(authProvider.apiUrl, authProvider.token);
    sceneProvider.setCredentials(authProvider.apiUrl, authProvider.token);

    // Connect dashboard to device provider
    dashboardProvider.setDeviceProvider(deviceProvider);

    // Fetch initial data
    deviceProvider.fetchDevices();

    // Fetch scenes if tab is enabled
    if (settingsProvider.showScenesTab) {
      sceneProvider.fetchScenes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
    final showDevicesTab = settings.showDevicesTab;
    final showScenesTab = settings.showScenesTab;

    // Build dynamic tab list
    final tabs = <Widget>[
      const DashboardTab(),
      if (showDevicesTab) const DevicesTab(),
      if (showScenesTab) const ScenesTab(),
    ];

    // Build dynamic navigation destinations
    final destinations = <NavigationDestination>[
      NavigationDestination(
        icon: const Icon(AppIcons.dashboard),
        selectedIcon: const Icon(AppIcons.dashboard),
        label: l10n.dashboard,
      ),
      if (showDevicesTab)
        NavigationDestination(
          icon: const Icon(AppIcons.devices),
          selectedIcon: const Icon(AppIcons.devices),
          label: l10n.devices,
        ),
      if (showScenesTab)
        NavigationDestination(
          icon: const Icon(AppIcons.scenes),
          selectedIcon: const Icon(AppIcons.scenes),
          label: l10n.scenes,
        ),
    ];

    // Clamp current index to valid range when tabs change
    final maxIndex = tabs.length - 1;
    if (_currentIndex > maxIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _currentIndex = 0);
        }
      });
    }

    // Fetch scenes when tab becomes visible
    if (showScenesTab) {
      final sceneProvider = context.read<SceneProvider>();
      if (sceneProvider.state == SceneLoadState.initial) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final authProvider = context.read<AuthProvider>();
          sceneProvider.setCredentials(authProvider.apiUrl, authProvider.token);
          sceneProvider.fetchScenes();
        });
      }
    }

    final hasMultipleTabs = tabs.length > 1;

    return Scaffold(
      body: Stack(
        children: [
          // Show tabs or just dashboard
          if (hasMultipleTabs)
            IndexedStack(
              index: _currentIndex.clamp(0, maxIndex),
              children: tabs,
            )
          else
            const DashboardTab(),
          // Update banner overlay (Android only)
          if (Platform.isAndroid)
            UpdateBanner(
              updateService: context.read<UpdateService>(),
            ),
        ],
      ),
      // Show bottom navigation bar when there are multiple tabs
      bottomNavigationBar: hasMultipleTabs
          ? NavigationBar(
              selectedIndex: _currentIndex.clamp(0, maxIndex),
              onDestinationSelected: _handleNavTap,
              destinations: destinations,
            )
          : null,
    );
  }
}
