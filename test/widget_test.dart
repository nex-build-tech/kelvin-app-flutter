import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core_app/app.dart';
import 'package:core_app/core/services/kelvin_ops_service.dart';
import 'package:core_app/core/theme/theme_controller.dart';
import 'package:core_app/features/auth/auth_service.dart';

void main() {
  testWidgets('Kelvin Mech mobile app navigation and core flow test', (WidgetTester tester) async {
    final authService = AuthService();
    final themeController = ThemeController();

    // Set screen size to mobile resolution (420 x 920)
    tester.view.physicalSize = const Size(420, 920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      KelvinOpsService().stopSimulation();
      tester.view.resetPhysicalSize();
    });

    // 1. Pump the root application widget
    await tester.pumpWidget(
      CoreApp(
        authService: authService,
        themeController: themeController,
      ),
    );

    // Advance past Splash Screen (2.6s)
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 1700));
    await tester.pump(const Duration(milliseconds: 300));

    // 2. Verify Login Screen is displayed
    expect(find.text('Kelvin Mech'), findsWidgets);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Use a demo account'), findsOneWidget);

    // 3. Test Google 1-click Sign In bypass
    await tester.tap(find.text('Sign in with Google'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 400));

    // 4. Verify navigation to Home Dashboard
    expect(find.text('Tasks Today'), findsOneWidget);
    expect(find.text('Project Pulse'), findsOneWidget);
    expect(find.text('My Tasks Today'), findsOneWidget);

    // 5. Navigate to Follow-ups tab
    await tester.tap(find.text('Follow-ups'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Search contact, company, or topic...'), findsOneWidget);

    // 6. Navigate to Quick Actions (Center Tab)
    await tester.tap(find.byIcon(Icons.flash_on_rounded).first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Approvals'), findsOneWidget);

    // 7. Navigate to Reminders tab
    await tester.tap(find.text('Reminders'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Reminders'), findsWidgets);

    // 8. Navigate to Profile tab
    await tester.tap(find.text('Profile'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Notification Preferences'), findsOneWidget);
    expect(find.text('Tasks Done'), findsOneWidget);

    // 9. Open Settings from Profile
    await tester.ensureVisible(find.text('App Settings & Theme'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('App Settings & Theme'), findsOneWidget);
    await tester.tap(find.text('App Settings & Theme'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    // 10. Verify Settings Screen and prominent Logout Button
    expect(find.text('Settings'), findsOneWidget);
    await tester.ensureVisible(find.text('Log Out from Kelvin Mech'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Account & Authentication'), findsOneWidget);
    expect(find.text('Log Out from Kelvin Mech'), findsOneWidget);

    // 11. Tap Logout button and confirm dialog
    await tester.tap(find.text('Log Out from Kelvin Mech'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Yes, Log Out'), findsOneWidget);
    await tester.tap(find.text('Yes, Log Out'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    // 12. Verify cleanly returned to Login Screen
    expect(find.text('Welcome back'), findsOneWidget);

    KelvinOpsService().stopSimulation();
  });
}
