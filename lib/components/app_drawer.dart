import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/services/notification_service.dart';
import '../core/theme/theme_controller.dart';
import '../features/auth/auth_service.dart';
import '../navigation/app_router.dart';

/// Modern Navigation Drawer (Hamburger Menu) for CoreApp.
class AppDrawer extends StatelessWidget {
  final AuthService authService;
  final ThemeController themeController;
  final ValueChanged<int> onNavigateTab;
  final VoidCallback onOpenNotifications;
  final VoidCallback onLogout;

  const AppDrawer({
    super.key,
    required this.authService,
    required this.themeController,
    required this.onNavigateTab,
    required this.onOpenNotifications,
    required this.onLogout,
  });

  void _showAnalyticsDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.analytics_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            const Text('System Analytics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Real-Time Telemetry Summary',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Avg System Latency', '14 ms', AppColors.success),
            _buildStatRow('Server Uptime', '99.98%', AppColors.primary),
            _buildStatRow('Active Connections', '1,420 nodes', AppColors.accent),
            _buildStatRow('Data Encryption', 'TLS 1.3 / AES-256', AppColors.info),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
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
    final user = authService.currentUser;
    final notificationService = NotificationService();

    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 24,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                    : [AppColors.primaryDark, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, _, __) => const Icon(
                          Icons.dashboard_customize_rounded,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.25)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: Color(0xFF10B981), size: 8),
                          SizedBox(width: 5),
                          Text(
                            'ONLINE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'Alex Morgan',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? 'demo@coreapp.com',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),

          // Drawer Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                ListTile(
                  leading: const Icon(Icons.home_rounded, color: AppColors.primary),
                  title: const Text('Home Dashboard', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.of(context).pop();
                    onNavigateTab(0);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.call_rounded, color: Color(0xFF0284C7)),
                  title: const Text('Follow-ups', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.of(context).pop();
                    onNavigateTab(1);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.flash_on_rounded, color: Color(0xFFF59E0B)),
                  title: const Text('Quick Actions (Approvals)', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.of(context).pop();
                    onNavigateTab(2);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.alarm_rounded, color: Color(0xFF10B981)),
                  title: const Text('Reminders', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.of(context).pop();
                    onNavigateTab(3);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_rounded, color: Color(0xFF8B5CF6)),
                  title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.of(context).pop();
                    onNavigateTab(4);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings_rounded, color: AppColors.accent),
                  title: const Text('App Settings', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed(AppRouter.settingsRoute);
                  },
                ),
                const Divider(indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.notifications_active_rounded, color: AppColors.warning),
                  title: const Text('Notification Center', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: ListenableBuilder(
                    listenable: notificationService,
                    builder: (ctx, _) {
                      final count = notificationService.unreadCount;
                      if (count == 0) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    onOpenNotifications();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.analytics_rounded, color: Color(0xFF8B5CF6)),
                  title: const Text('System Analytics', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showAnalyticsDialog(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.send_to_mobile_rounded, color: Color(0xFF059669)),
                  title: const Text('Send Test Push', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Trigger instant push notification', style: TextStyle(fontSize: 11)),
                  onTap: () {
                    Navigator.of(context).pop();
                    notificationService.sendNotification(
                      context: context,
                      title: 'Live Alert Received',
                      message: 'Real-time telemetry event processed successfully at ${TimeOfDay.now().format(context)}.',
                      type: NotificationType.success,
                    );
                  },
                ),
                const Divider(indent: 16, endIndent: 16),
                // Theme Toggle Switch in Drawer
                ListenableBuilder(
                  listenable: themeController,
                  builder: (ctx, _) {
                    return SwitchListTile(
                      secondary: Icon(
                        themeController.isDarkMode
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: themeController.isDarkMode
                            ? const Color(0xFFFBBF24)
                            : const Color(0xFFF59E0B),
                      ),
                      title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                      value: themeController.isDarkMode,
                      onChanged: (val) => themeController.toggleTheme(val),
                    );
                  },
                ),
              ],
            ),
          ),

          // Drawer Footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                  title: const Text(
                    'Sign Out',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    onLogout();
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppStrings.appName} • v1.0.0 Production',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
