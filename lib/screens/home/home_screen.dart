import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_icons.dart';
import '../../data/services/update_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/device_provider.dart';
import '../../providers/dashboard_provider.dart';
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
    super.dispose();
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

    // Set credentials for device provider
    deviceProvider.setCredentials(authProvider.apiUrl, authProvider.token);

    // Connect dashboard to device provider
    dashboardProvider.setDeviceProvider(deviceProvider);

    // Fetch initial data
    deviceProvider.fetchDevices();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: const [
              DashboardTab(),
              DevicesTab(),
            ],
          ),
          // Update banner overlay (Android only)
          if (Platform.isAndroid)
            UpdateBanner(
              updateService: context.read<UpdateService>(),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
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
      ),
    );
  }
}
