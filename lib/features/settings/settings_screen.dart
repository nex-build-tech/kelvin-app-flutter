import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/theme_controller.dart';
import '../auth/auth_service.dart';

/// Settings Screen providing appearance customization, notifications, app info, and logout.
class SettingsScreen extends StatelessWidget {
  final ThemeController themeController;
  final AuthService authService;
  final VoidCallback onLogout;
  final VoidCallback? onOpenDrawer;

  const SettingsScreen({
    super.key,
    required this.themeController,
    required this.authService,
    required this.onLogout,
    this.onOpenDrawer,
  });

  void _showLogoutDialog(BuildContext context) {
    HapticFeedback.mediumImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF131B2E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          ),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.error,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                AppStrings.logoutConfirmTitle,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          AppStrings.logoutConfirmMessage,
          style: TextStyle(fontSize: 13.5, height: 1.45),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              authService.logout();
              onLogout();
            },
            child: const Text(
              'Yes, Log Out',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D16) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: onOpenDrawer != null
            ? IconButton(
                icon: const Icon(Icons.menu_rounded),
                tooltip: 'Open Menu',
                onPressed: onOpenDrawer,
              )
            : null,
        title: const Text(AppStrings.settingsTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: ListenableBuilder(
            listenable: themeController,
            builder: (context, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Section 1: Appearance ---
                  _buildSectionHeader(
                    title: AppStrings.appearanceSection,
                    icon: Icons.palette_outlined,
                    theme: theme,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  _buildSettingsCard(
                    isDark: isDark,
                    children: [
                      SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.md,
                          vertical: AppDimensions.xs,
                        ),
                        title: const Text(
                          AppStrings.darkMode,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                        subtitle: Text(
                          AppStrings.darkModeSubtitle,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        secondary: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: (isDark ? const Color(0xFFFBBF24) : AppColors.primary).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDark
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            size: 20,
                            color: isDark
                                ? const Color(0xFFFBBF24)
                                : AppColors.primary,
                          ),
                        ),
                        value: themeController.isDarkMode,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          HapticFeedback.selectionClick();
                          themeController.toggleTheme(val);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.lg),

                  // --- Section 2: Notifications & Alerts ---
                  _buildSectionHeader(
                    title: AppStrings.notificationsSection,
                    icon: Icons.notifications_none_rounded,
                    theme: theme,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  _buildSettingsCard(
                    isDark: isDark,
                    children: [
                      SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.md,
                          vertical: AppDimensions.xs,
                        ),
                        title: const Text(
                          AppStrings.pushNotifications,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                        subtitle: Text(
                          AppStrings.pushNotificationsSubtitle,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        secondary: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_active_outlined,
                            size: 20,
                            color: AppColors.accent,
                          ),
                        ),
                        value: themeController.pushNotificationsEnabled,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          HapticFeedback.selectionClick();
                          themeController.togglePushNotifications(val);
                          if (val) {
                            NotificationService().sendNotification(
                              context: context,
                              title: 'Push Notifications Enabled',
                              message: 'You will now receive high-priority telemetry and security updates.',
                              type: NotificationType.success,
                            );
                          }
                        },
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.md,
                          vertical: AppDimensions.xs,
                        ),
                        title: const Text(
                          AppStrings.maintenanceAlerts,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                        subtitle: Text(
                          AppStrings.maintenanceAlertsSubtitle,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        secondary: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.build_circle_outlined,
                            size: 20,
                            color: AppColors.warning,
                          ),
                        ),
                        value: themeController.maintenanceAlertsEnabled,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          HapticFeedback.selectionClick();
                          themeController.toggleMaintenanceAlerts(val);
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.md,
                          vertical: AppDimensions.xs,
                        ),
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.send_to_mobile_rounded,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                        title: const Text(
                          'Send Test Push Notification',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                        subtitle: Text(
                          'Dispatch an instant real-time banner & haptic alert',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                        onTap: () {
                          NotificationService().sendNotification(
                            context: context,
                            title: 'Settings Test Alert',
                            message: 'Push notification engine is operational and responding at ${TimeOfDay.now().format(context)}.',
                            type: NotificationType.info,
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.lg),

                  // --- Section 3: App Information ---
                  _buildSectionHeader(
                    title: AppStrings.aboutSection,
                    icon: Icons.info_outline_rounded,
                    theme: theme,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  _buildSettingsCard(
                    isDark: isDark,
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.md,
                          vertical: AppDimensions.xs,
                        ),
                        title: const Text(
                          AppStrings.appName,
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                        ),
                        subtitle: const Text(
                          'Production Boilerplate Platform',
                          style: TextStyle(fontSize: 11.5),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(isDark ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            AppStrings.appVersion,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      const ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.md,
                          vertical: AppDimensions.xs,
                        ),
                        title: Text(
                          'Session Persistence',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                        ),
                        subtitle: Text(
                          'Encrypted Local Storage (Active)',
                          style: TextStyle(fontSize: 11.5),
                        ),
                        trailing: Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 20,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.xl),

                  // --- Section 4: Account & Session ---
                  _buildSectionHeader(
                    title: 'Account & Authentication',
                    icon: Icons.account_circle_outlined,
                    theme: theme,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  _buildSettingsCard(
                    isDark: isDark,
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.md,
                          vertical: AppDimensions.sm,
                        ),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1A56DB), Color(0xFF0EA5E9)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              (authService.currentUser?.name.isNotEmpty == true)
                                  ? authService.currentUser!.name.substring(0, 1).toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          authService.currentUser?.name ?? 'Authenticated User',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Text(
                              authService.currentUser?.email ?? 'operations@kelvinmech.com',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(isDark ? 0.25 : 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                authService.currentUser?.role ?? 'MEP Operations',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.lg),

                  // Prominent High-Contrast Logout Button
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.error.withOpacity(isDark ? 0.25 : 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error.withOpacity(isDark ? 0.18 : 0.08),
                        foregroundColor: AppColors.error,
                        elevation: 0,
                        side: BorderSide(
                          color: AppColors.error.withOpacity(0.4),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: const Text(
                        'Log Out from Kelvin Mech',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                          letterSpacing: 0.2,
                        ),
                      ),
                      onPressed: () => _showLogoutDialog(context),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.xl),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.primary,
        ),
        const SizedBox(width: AppDimensions.xs),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard({
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131B2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}
