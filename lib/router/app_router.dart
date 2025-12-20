import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/device_detail/device_detail_screen.dart';
import '../screens/device_settings/device_settings_screen.dart';
import '../screens/schedules/schedules_screen.dart';
import '../screens/webhooks/webhooks_screen.dart';
import '../screens/statistics/statistics_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/room/room_screen.dart';

class AppRouter {
  final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  late final GoRouter router;

  AppRouter(AuthProvider authProvider) {
    // Determine initial location based on auth state
    String initialLocation;
    if (authProvider.isFirstLaunch) {
      initialLocation = '/onboarding';
    } else if (authProvider.isAuthenticated) {
      initialLocation = '/home';
    } else {
      initialLocation = '/login';
    }

    router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: initialLocation,
      debugLogDiagnostics: true,
      refreshListenable: authProvider,
      redirect: (context, state) {
        final auth = context.read<AuthProvider>();
        final isAuthenticated = auth.isAuthenticated;

        final currentPath = state.matchedLocation;
        final isOnOnboarding = currentPath == '/onboarding';
        final isOnLogin = currentPath == '/login';

        // If first launch, show onboarding (even if authenticated - for restart feature)
        if (auth.isFirstLaunch) {
          if (isOnOnboarding) return null;
          return '/onboarding';
        }

        // If not authenticated, redirect to login
        if (!isAuthenticated) {
          if (isOnLogin) return null;
          return '/login';
        }

        // If authenticated but on auth pages, redirect to home
        if (isAuthenticated && (isOnOnboarding || isOnLogin)) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/device/:id',
          builder: (context, state) {
            final deviceId = state.pathParameters['id']!;
            return DeviceDetailScreen(deviceId: deviceId);
          },
        ),
        GoRoute(
          path: '/device/:id/settings',
          builder: (context, state) {
            final deviceId = state.pathParameters['id']!;
            return DeviceSettingsScreen(deviceId: deviceId);
          },
        ),
        GoRoute(
          path: '/device/:id/schedules',
          builder: (context, state) {
            final deviceId = state.pathParameters['id']!;
            return SchedulesScreen(deviceId: deviceId);
          },
        ),
        GoRoute(
          path: '/device/:id/webhooks',
          builder: (context, state) {
            final deviceId = state.pathParameters['id']!;
            return WebhooksScreen(deviceId: deviceId);
          },
        ),
        GoRoute(
          path: '/statistics/:id',
          builder: (context, state) {
            final deviceId = state.pathParameters['id']!;
            final deviceType = state.uri.queryParameters['type'] ?? 'power';
            final metric = state.uri.queryParameters['metric'];
            return StatisticsScreen(
              deviceId: deviceId,
              deviceType: deviceType,
              metric: metric,
            );
          },
        ),
        GoRoute(
          path: '/room/:name',
          builder: (context, state) {
            final roomName = Uri.decodeComponent(state.pathParameters['name']!);
            return RoomScreen(roomName: roomName);
          },
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(state.matchedLocation),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
