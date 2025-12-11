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
import '../../widgets/common/update_banner.dart';
import 'devices_tab.dart';
import 'dashboard_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  int _tapCount = 0;
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
    // Increment tap counter
    _tapCount++;

    // Reset timer on each tap
    _tapResetTimer?.cancel();
    _tapResetTimer = Timer(const Duration(seconds: 2), () {
      _tapCount = 0;
    });

    // Check for 5 taps
    if (_tapCount >= 5) {
      _tapCount = 0;
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

    // Set credentials for providers
    deviceProvider.setCredentials(authProvider.apiUrl, authProvider.token);
    scheduleProvider.setCredentials(authProvider.apiUrl, authProvider.token);

    // Connect dashboard to device provider
    dashboardProvider.setDeviceProvider(deviceProvider);

    // Fetch initial data
    deviceProvider.fetchDevices();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showDevicesTab = context.watch<SettingsProvider>().showDevicesTab;

    // Reset to dashboard if devices tab is hidden and currently selected
    if (!showDevicesTab && _currentIndex == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _currentIndex = 0);
        }
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          // Only show DashboardTab if devices tab is hidden
          if (showDevicesTab)
            IndexedStack(
              index: _currentIndex,
              children: const [
                DashboardTab(),
                DevicesTab(),
              ],
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
      // Hide bottom navigation bar when devices tab is disabled
      bottomNavigationBar: showDevicesTab
          ? NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _handleNavTap,
              destinations: [
                NavigationDestination(
                  icon: const Icon(AppIcons.dashboard),
                  selectedIcon: const Icon(AppIcons.dashboard),
                  label: l10n.dashboard,
                ),
                NavigationDestination(
                  icon: const Icon(AppIcons.devices),
                  selectedIcon: const Icon(AppIcons.devices),
                  label: l10n.devices,
                ),
              ],
            )
          : null,
    );
  }
}
