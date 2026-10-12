import 'package:flutter/material.dart';
import '../core/theme/theme_controller.dart';
import '../features/auth/auth_service.dart';
import '../features/auth/login_screen.dart';
import '../features/main_wrapper.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/splash/splash_screen.dart';

/// Centralized application router and navigation coordinator.
class AppRouter {
  AppRouter._();

  // Route Names
  static const String rootRoute = '/';
  static const String loginRoute = '/login';
  static const String mainRoute = '/main';
  static const String notificationsRoute = '/notifications';
  static const String settingsRoute = '/settings';

  /// Generates routes dynamically while enforcing authentication protection.
  static Route<dynamic> generateRoute({
    required RouteSettings settings,
    required AuthService authService,
    required ThemeController themeController,
  }) {
    // Determine destination
    final routeName = settings.name;

    if (routeName == settingsRoute) {
      return MaterialPageRoute(
        builder: (context) => SettingsScreen(
          themeController: themeController,
          authService: authService,
          onLogout: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              loginRoute,
              (route) => false,
            );
          },
        ),
        settings: const RouteSettings(name: settingsRoute),
      );
    }

    if (routeName == notificationsRoute) {
      return MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
        settings: const RouteSettings(name: notificationsRoute),
      );
    }

    if (routeName == rootRoute) {
      return MaterialPageRoute(
        builder: (context) => SplashScreen(authService: authService),
        settings: const RouteSettings(name: rootRoute),
      );
    }

    if (routeName == loginRoute) {
      return MaterialPageRoute(
        builder: (context) => LoginScreen(
          authService: authService,
          onLoginSuccess: () {
            // Completely clear the backstack so pressing back never shows login again
            Navigator.of(context).pushNamedAndRemoveUntil(
              mainRoute,
              (route) => false,
            );
          },
        ),
        settings: const RouteSettings(name: loginRoute),
      );
    }

    if (routeName == mainRoute ||
        (routeName == rootRoute && authService.isAuthenticated)) {
      // Protected route guard: Redirect to Login if unauthenticated
      if (!authService.isAuthenticated) {
        return MaterialPageRoute(
          builder: (context) => LoginScreen(
            authService: authService,
            onLoginSuccess: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                mainRoute,
                (route) => false,
              );
            },
          ),
          settings: const RouteSettings(name: loginRoute),
        );
      }

      return MaterialPageRoute(
        builder: (context) => MainWrapper(
          authService: authService,
          themeController: themeController,
          onLogout: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              loginRoute,
              (route) => false,
            );
          },
        ),
        settings: const RouteSettings(name: mainRoute),
      );
    }

    // Fallback handler
    return MaterialPageRoute(
      builder: (context) => authService.isAuthenticated
          ? MainWrapper(
              authService: authService,
              themeController: themeController,
              onLogout: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                  (route) => false,
                );
              },
            )
          : LoginScreen(
              authService: authService,
              onLoginSuccess: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  mainRoute,
                  (route) => false,
                );
              },
            ),
      settings: settings,
    );
  }
}
