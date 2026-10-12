import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/api_service.dart';
import '../../data/mock_data.dart';
import '../../models/user_model.dart';

/// Authentication Service with persistent local session caching and MySQL backend sync.
class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _rememberMe = true;
  bool _isLoading = false;

  // --- Getters ---
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get rememberMe => _rememberMe;
  bool get isLoading => _isLoading;

  /// Restores persistent user session from local storage on app startup.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isAuth = prefs.getBool('is_authenticated') ?? false;

      if (isAuth) {
        final email = prefs.getString('user_email') ?? MockData.demoEmail;
        final name = prefs.getString('user_name') ?? 'Alex Morgan';
        final role = prefs.getString('user_role') ?? 'Lead Operations Administrator';
        final phone = prefs.getString('user_phone') ?? '+1 (555) 019-2834';
        final department = prefs.getString('user_dept') ?? 'Central Operations';
        final id = prefs.getString('user_id') ?? 'usr_core_01';

        _currentUser = UserModel(
          id: id,
          name: name,
          email: email,
          role: role,
          phone: phone,
          department: department,
        );
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (_) {
      // Graceful fallback for non-persistent environments / mock tests
    }
  }

  /// Authenticates credentials and saves session to persistent storage.
  /// First checks the local MySQL backend, falling back to cached/demo users if offline.
  Future<String?> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    _isLoading = true;
    notifyListeners();

    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = password.trim();

    // 1. Attempt authentication with local MySQL REST API
    UserModel? matchedUser = await ApiService.instance.login(normalizedEmail, normalizedPassword);

    // 2. Fallback to local demo accounts if MySQL backend is offline or returned null
    if (matchedUser == null) {
      if (normalizedEmail == 'suresh@kelvinmech.com' && normalizedPassword == 'kelvin123') {
        matchedUser = const UserModel(
          id: 'u_suresh',
          name: 'Suresh Iyer',
          email: 'suresh@kelvinmech.com',
          role: 'Procurement Manager',
          phone: '+91 98201 23456',
          department: 'MEP Procurement',
        );
    } else if (normalizedEmail == 'priya@kelvinmech.com' && normalizedPassword == 'kelvin123') {
      matchedUser = const UserModel(
        id: 'u_priya',
        name: 'Priya Shah',
        email: 'priya@kelvinmech.com',
        role: 'Project Manager',
        phone: '+91 98202 34567',
        department: 'MEP Operations',
      );
    } else if (normalizedEmail == 'admin@kelvinmech.com' && normalizedPassword == 'admin123') {
      matchedUser = const UserModel(
        id: 'u_admin',
        name: 'Sachin G',
        email: 'admin@kelvinmech.com',
        role: 'Admin / Architect',
        phone: '+91 98203 45678',
        department: 'Engineering & Architecture',
      );
    } else if (normalizedEmail == 'demo@kelvinmech.com' && normalizedPassword == 'demo') {
      matchedUser = const UserModel(
        id: 'u_demo',
        name: 'Demo User',
        email: 'demo@kelvinmech.com',
        role: 'Viewer',
        phone: '+91 98204 56789',
        department: 'Field Operations',
      );
    } else if (normalizedEmail == MockData.demoEmail && normalizedPassword == MockData.demoPassword) {
      matchedUser = MockData.defaultUser;
    } else if (normalizedEmail == MockData.adminEmail && normalizedPassword == MockData.adminPassword) {
      matchedUser = MockData.defaultUser.copyWith(
        id: 'usr_core_admin',
        name: 'Admin Supervisor',
        email: MockData.adminEmail,
        role: 'Chief Operations Officer',
      );
    }
  }

  if (matchedUser != null) {
      _rememberMe = rememberMe;
      _currentUser = matchedUser;
      _isAuthenticated = true;
      _isLoading = false;

      // Persist session to local storage asynchronously
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('is_authenticated', true);
        prefs.setString('user_id', _currentUser!.id);
        prefs.setString('user_name', _currentUser!.name);
        prefs.setString('user_email', _currentUser!.email);
        prefs.setString('user_role', _currentUser!.role);
        prefs.setString('user_phone', _currentUser!.phone);
        prefs.setString('user_dept', _currentUser!.department);
      }).catchError((_) {});

      notifyListeners();
      return null;
    } else {
      _isLoading = false;
      notifyListeners();
      return AppStrings.invalidCredentialsError;
    }
  }

  /// 1-click Google OAuth bypass simulation
  Future<void> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _currentUser = const UserModel(
      id: 'g_suresh',
      name: 'Suresh Iyer',
      email: 'suresh@kelvinmech.com',
      role: 'Procurement Manager',
      phone: '+91 98201 23456',
      department: 'MEP Procurement',
    );
    _isAuthenticated = true;
    _isLoading = false;

    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('is_authenticated', true);
      prefs.setString('user_id', _currentUser!.id);
      prefs.setString('user_name', _currentUser!.name);
      prefs.setString('user_email', _currentUser!.email);
      prefs.setString('user_role', _currentUser!.role);
      prefs.setString('user_phone', _currentUser!.phone);
      prefs.setString('user_dept', _currentUser!.department);
    }).catchError((_) {});

    notifyListeners();
  }

  /// Terminates the current session and clears persistent storage.
  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    _isLoading = false;

    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('is_authenticated');
      prefs.remove('user_id');
      prefs.remove('user_name');
      prefs.remove('user_email');
      prefs.remove('user_role');
      prefs.remove('user_phone');
      prefs.remove('user_dept');
    }).catchError((_) {});

    notifyListeners();
  }

  /// Updates user profile fields in local state and persistent storage.
  void updateProfile({
    String? name,
    String? email,
    String? role,
    String? phone,
    String? department,
  }) {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      name: name,
      email: email,
      role: role,
      phone: phone,
      department: department,
    );

    SharedPreferences.getInstance().then((prefs) {
      if (name != null) prefs.setString('user_name', name);
      if (email != null) prefs.setString('user_email', email);
      if (role != null) prefs.setString('user_role', role);
      if (phone != null) prefs.setString('user_phone', phone);
      if (department != null) prefs.setString('user_dept', department);
    }).catchError((_) {});

    notifyListeners();
  }
}
