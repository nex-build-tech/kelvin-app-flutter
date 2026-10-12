import 'package:flutter/material.dart';
import 'app.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize and restore persistent user session
  final authService = AuthService();
  await authService.init();

  final themeController = ThemeController();

  runApp(
    CoreApp(
      authService: authService,
      themeController: themeController,
    ),
  );
}
