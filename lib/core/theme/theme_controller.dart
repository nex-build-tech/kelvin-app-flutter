import 'package:flutter/material.dart';

/// Lightweight controller for app-wide theme and basic preferences.
///
/// Uses standard [ChangeNotifier] for simple, zero-dependency state management.
class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _pushNotificationsEnabled = true;
  bool _maintenanceAlertsEnabled = true;

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;
  bool get maintenanceAlertsEnabled => _maintenanceAlertsEnabled;

  /// Toggles theme between Light and Dark
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Sets specific theme mode
  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  /// Updates push notifications preference
  void togglePushNotifications(bool value) {
    _pushNotificationsEnabled = value;
    notifyListeners();
  }

  /// Updates maintenance alert preference
  void toggleMaintenanceAlerts(bool value) {
    _maintenanceAlertsEnabled = value;
    notifyListeners();
  }
}
