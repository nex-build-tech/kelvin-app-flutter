import 'package:flutter/material.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/auth_service.dart';
import 'navigation/app_router.dart';

/// Root Application Widget.
///
/// Listens to [ThemeController] for instant theme switching and delegates
/// routing to [AppRouter].
class CoreApp extends StatelessWidget {
  final AuthService authService;
  final ThemeController themeController;

  const CoreApp({
    super.key,
    required this.authService,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        return MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          initialRoute: AppRouter.rootRoute,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaleFactor: mediaQuery.textScaleFactor.clamp(0.85, 1.0),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
          onGenerateRoute: (settings) => AppRouter.generateRoute(
            settings: settings,
            authService: authService,
            themeController: themeController,
          ),
        );
      },
    );
  }
}
