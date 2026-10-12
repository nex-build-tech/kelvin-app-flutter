import 'package:flutter_test/flutter_test.dart';
import 'package:core_app/core/constants/app_strings.dart';
import 'package:core_app/data/mock_data.dart';
import 'package:core_app/features/auth/auth_service.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('Initial state is unauthenticated with no user', () {
      expect(authService.isAuthenticated, isFalse);
      expect(authService.currentUser, isNull);
      expect(authService.isLoading, isFalse);
    });

    test('Successful login with demo credentials authenticates user', () async {
      final error = await authService.login(
        email: MockData.demoEmail,
        password: MockData.demoPassword,
        rememberMe: true,
      );

      expect(error, isNull);
      expect(authService.isAuthenticated, isTrue);
      expect(authService.currentUser, isNotNull);
      expect(authService.currentUser!.email, equals(MockData.demoEmail));
      expect(authService.currentUser!.name, equals(MockData.defaultUser.name));
      expect(authService.rememberMe, isTrue);
    });

    test('Successful login with admin credentials sets admin user', () async {
      final error = await authService.login(
        email: MockData.adminEmail,
        password: MockData.adminPassword,
      );

      expect(error, isNull);
      expect(authService.isAuthenticated, isTrue);
      expect(authService.currentUser!.email, equals(MockData.adminEmail));
      expect(authService.currentUser!.id, equals('usr_core_admin'));
    });

    test('Login with invalid credentials fails and returns error message', () async {
      final error = await authService.login(
        email: 'invalid@user.com',
        password: 'wrongpassword',
      );

      expect(error, equals(AppStrings.invalidCredentialsError));
      expect(authService.isAuthenticated, isFalse);
      expect(authService.currentUser, isNull);
    });

    test('updateProfile updates user fields in memory and triggers notification', () async {
      // First log in
      await authService.login(
        email: MockData.demoEmail,
        password: MockData.demoPassword,
      );

      bool notificationReceived = false;
      authService.addListener(() {
        notificationReceived = true;
      });

      authService.updateProfile(
        name: 'Taylor Reed',
        role: 'Senior Product Manager',
        phone: '+1 (555) 987-6543',
      );

      expect(notificationReceived, isTrue);
      expect(authService.currentUser!.name, equals('Taylor Reed'));
      expect(authService.currentUser!.role, equals('Senior Product Manager'));
      expect(authService.currentUser!.phone, equals('+1 (555) 987-6543'));
      // Email and department should remain unchanged if not provided
      expect(authService.currentUser!.email, equals(MockData.demoEmail));
    });

    test('logout resets user session to null and marks unauthenticated', () async {
      await authService.login(
        email: MockData.demoEmail,
        password: MockData.demoPassword,
      );
      expect(authService.isAuthenticated, isTrue);

      authService.logout();
      expect(authService.isAuthenticated, isFalse);
      expect(authService.currentUser, isNull);
    });
  });
}
