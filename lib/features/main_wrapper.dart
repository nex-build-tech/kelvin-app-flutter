import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/app_drawer.dart';
import '../core/theme/theme_controller.dart';
import 'auth/auth_service.dart';
import 'dashboard/dashboard_screen.dart';
import 'followups/followups_screen.dart';
import 'notifications/notifications_screen.dart';
import 'profile/profile_screen.dart';
import 'quick_actions/quick_actions_screen.dart';
import 'reminders/reminders_screen.dart';

/// Main shell wrapper hosting the 5 Kelvin Mech bottom navigation tabs,
/// center elevated Quick Action trigger, Drawer, and backstack protection.
class MainWrapper extends StatefulWidget {
  final AuthService authService;
  final ThemeController themeController;
  final VoidCallback onLogout;

  const MainWrapper({
    super.key,
    required this.authService,
    required this.themeController,
    required this.onLogout,
  });

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  DateTime? _lastBackPressTime;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _openNotifications() {
    Navigator.of(context).pushNamed(NotificationsScreen.routeName);
  }

  Future<bool> _onWillPop() async {
    // 1. If drawer is open, close it
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
      return false;
    }

    // 2. If not on Dashboard tab, navigate back to Dashboard
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return false;
    }

    // 3. Double-back to exit on Dashboard
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Press back again to exit Kelvin Mech'),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return false;
    }

    // Exit application completely
    await SystemNavigator.pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final screens = [
      DashboardScreen(
        authService: widget.authService,
        onNavigateTab: _onTabSelected,
        onLogout: widget.onLogout,
        onOpenDrawer: _openDrawer,
        onOpenNotifications: _openNotifications,
      ),
      FollowUpsScreen(
        onOpenDrawer: _openDrawer,
      ),
      QuickActionsScreen(
        onOpenDrawer: _openDrawer,
      ),
      RemindersScreen(
        onOpenDrawer: _openDrawer,
      ),
      ProfileScreen(
        authService: widget.authService,
        onOpenDrawer: _openDrawer,
      ),
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: AppDrawer(
          authService: widget.authService,
          themeController: widget.themeController,
          onNavigateTab: _onTabSelected,
          onOpenNotifications: _openNotifications,
          onLogout: widget.onLogout,
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F1A3A) : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? const Color(0xFF1E2D54) : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 64,
              child: Row(
                children: [
                  // Tab 0: Home
                  _buildNavItem(
                    index: 0,
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'Home',
                    isDark: isDark,
                  ),

                  // Tab 1: Follow-ups
                  _buildNavItem(
                    index: 1,
                    icon: Icons.call_outlined,
                    activeIcon: Icons.call_rounded,
                    label: 'Follow-ups',
                    isDark: isDark,
                  ),

                  // Tab 2: Elevated Center Action Button (Flash)
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          _onTabSelected(2);
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F3BB8), Color(0xFF1A56DB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1A56DB).withOpacity(0.45),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: _currentIndex == 2 ? Colors.white : Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.flash_on_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Tab 3: Reminders
                  _buildNavItem(
                    index: 3,
                    icon: Icons.alarm_outlined,
                    activeIcon: Icons.alarm_rounded,
                    label: 'Reminders',
                    isDark: isDark,
                  ),

                  // Tab 4: Profile
                  _buildNavItem(
                    index: 4,
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: 'Profile',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;
    const activeColor = Color(0xFF1A56DB);
    final inactiveColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          _onTabSelected(index);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
