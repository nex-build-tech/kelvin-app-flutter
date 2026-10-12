/// Centralized text constants and strings for CoreApp.
/// 
/// Reusability Guide:
/// Update the strings below to rebrand the app for any business or project.
class AppStrings {
  AppStrings._();

  // --- App Branding ---
  static const String appName = 'Kelvin Mech';
  static const String appTagline = 'MEP Operations Platform';
  static const String companyName = 'Kelvin Mech';
  static const String appVersion = 'v1.0.0 (MEP Ops MVP)';

  // --- Authentication Screen ---
  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Sign in to access your dashboard and workspace';
  static const String emailLabel = 'Email Address';
  static const String emailHint = 'e.g. demo@coreapp.com';
  static const String passwordLabel = 'Password';
  static const String passwordHint = 'Enter your password';
  static const String rememberMe = 'Remember me';
  static const String signInButton = 'Sign In';
  static const String demoCredentialsBanner = 'Demo Credentials: demo@coreapp.com / password123';
  static const String fillDemoCredentials = 'Use Demo Credentials';
  static const String invalidCredentialsError = 'Invalid email or password. Please use the demo credentials.';
  static const String mockAuthDisclaimer =
      'Demo Notice: Mock authentication is active for demonstration only. Replace with a secure backend before production.';

  // --- Validation Errors ---
  static const String emailRequired = 'Please enter your email address.';
  static const String emailInvalid = 'Please enter a valid email address.';
  static const String passwordRequired = 'Please enter your password.';
  static const String passwordTooShort = 'Password must be at least 6 characters.';

  // --- Dashboard ---
  static const String dashboardTitle = 'Dashboard';
  static const String welcomeBack = 'Welcome back,';
  static const String systemStatusOptimal = 'All Systems Operational';
  static const String systemsStatusSubtitle = 'Everything is running smoothly';
  static const String quickStatsSection = 'Key Metrics';
  static const String systemOverviewSection = 'Performance Summary';
  static const String recentActivitySection = 'Recent Activity';
  static const String viewAll = 'View All';

  // --- Profile ---
  static const String profileTitle = 'My Profile';
  static const String editProfile = 'Edit Profile';
  static const String nameLabel = 'Full Name';
  static const String roleLabel = 'Role / Position';
  static const String phoneLabel = 'Phone Number';
  static const String departmentLabel = 'Department / Team';
  static const String saveChanges = 'Save Changes';
  static const String profileUpdatedSuccess = 'Profile updated successfully!';
  static const String memberSince = 'Member Since: January 2024';

  // --- Settings ---
  static const String settingsTitle = 'Settings';
  static const String appearanceSection = 'Appearance';
  static const String darkMode = 'Dark Mode';
  static const String darkModeSubtitle = 'Switch between light and dark visual themes';
  static const String notificationsSection = 'Notifications & Alerts';
  static const String pushNotifications = 'Push Notifications';
  static const String pushNotificationsSubtitle = 'Receive alerts for operational events and updates';
  static const String maintenanceAlerts = 'System Notifications';
  static const String maintenanceAlertsSubtitle = 'Get notified about scheduled updates and milestones';
  static const String aboutSection = 'About This App';
  static const String boilerplateNote = 'Reusable Flutter Starter Boilerplate';
  static const String boilerplateDescription =
      'A modular, clean mobile starter template designed for rapid customization across different businesses and domains.';

  // --- General & Actions ---
  static const String logout = 'Sign Out';
  static const String logoutConfirmTitle = 'Confirm Sign Out';
  static const String logoutConfirmMessage = 'Are you sure you want to end your current demo session?';
  static const String cancel = 'Cancel';
  static const String confirm = 'Yes, Sign Out';
}
