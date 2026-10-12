import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../components/app_button.dart';
import '../../components/app_text_field.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/kelvin_ops_service.dart';
import '../../core/utils/validators.dart';
import '../../data/mock_data.dart';
import '../../models/user_model.dart';
import '../../navigation/app_router.dart';
import '../auth/auth_service.dart';

/// User Profile Screen displaying user information with local state editing.
class ProfileScreen extends StatelessWidget {
  final AuthService authService;
  final VoidCallback? onOpenDrawer;

  const ProfileScreen({
    super.key,
    required this.authService,
    this.onOpenDrawer,
  });

  void _openEditProfileModal(BuildContext context, UserModel user) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditProfileBottomSheet(
        user: user,
        onSave: (updated) {
          authService.updateProfile(
            name: updated.name,
            email: updated.email,
            role: updated.role,
            phone: updated.phone,
            department: updated.department,
          );
          Navigator.of(ctx).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  SizedBox(width: AppDimensions.sm),
                  Text(AppStrings.profileUpdatedSuccess),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 3),
            ),
          );
        },
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
        title: const Text(AppStrings.profileTitle),
        actions: [
          IconButton(
            tooltip: 'Edit Details',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              final user = authService.currentUser ?? MockData.defaultUser;
              _openEditProfileModal(context, user);
            },
          ),
          const SizedBox(width: AppDimensions.xs),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: authService,
          builder: (context, _) {
            final user = authService.currentUser ?? MockData.defaultUser;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                children: [
                  // --- 1. Executive Hero Header Card ---
                  _buildProfileHeroCard(context, user, isDark, theme),
                  const SizedBox(height: AppDimensions.md),

                  // --- 2. Operational Performance Stats ---
                  _buildPerformanceStats(isDark),
                  const SizedBox(height: AppDimensions.md),

                  // --- 3. Contact & Organization Details Card ---
                  _buildContactCard(user, isDark, theme),
                  const SizedBox(height: AppDimensions.md),

                  // --- 4. Notification Preferences Card ---
                  _buildNotificationPreferencesCard(isDark),
                  const SizedBox(height: AppDimensions.md),

                  // --- 5. Security Clearance & Session Metadata Card ---
                  _buildClearanceCard(user, isDark, theme),
                  const SizedBox(height: AppDimensions.md),

                  // --- 6. App Settings Link ---
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF131B2E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.settings_rounded, color: AppColors.primary, size: 20),
                      ),
                      title: const Text(
                        'App Settings & Theme',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                      ),
                      subtitle: Text(
                        'Appearance, push alerts, and diagnostics',
                        style: TextStyle(fontSize: 11.5, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      onTap: () => Navigator.of(context).pushNamed(AppRouter.settingsRoute),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),

                  // --- 7. Prominent Sign Out Button ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.error.withOpacity(0.4), width: 1.5),
                        backgroundColor: AppColors.error.withOpacity(isDark ? 0.15 : 0.08),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                      label: const Text(
                        'Sign Out',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () => _showSignOutDialog(context),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // Footer
                  Text(
                    'Kelvin Mech Ops · v1.0.0 MVP · Powered by Ayu Ventures',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeroCard(
    BuildContext context,
    UserModel user,
    bool isDark,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131B2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Decorative Gradient Banner Top
          Container(
            height: 90,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E3A8A), const Color(0xFF0F172A)]
                    : [const Color(0xFF0284C7), const Color(0xFF06B6D4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Overlapping Avatar & Content
          Transform.translate(
            offset: const Offset(0, -45),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? const Color(0xFF131B2E) : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 38,
                          backgroundColor: AppColors.primaryContainer,
                          child: Text(
                            _getInitials(user.name),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _openEditProfileModal(context, user),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? const Color(0xFF131B2E) : Colors.white,
                              width: 2.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          user.name,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.verified_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primaryLight.withOpacity(0.15)
                          : AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.role,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.department,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: AppStrings.editProfile,
                    icon: Icons.edit_note_rounded,
                    variant: AppButtonVariant.secondary,
                    height: 42,
                    onPressed: () => _openEditProfileModal(context, user),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceStats(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            label: 'Tasks Done',
            value: '47',
            color: const Color(0xFF10B981),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricCard(
            label: 'POs Approved',
            value: '23',
            color: const Color(0xFF1A56DB),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricCard(
            label: 'SLA Score',
            value: '94%',
            color: const Color(0xFFF59E0B),
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131B2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationPreferencesCard(bool isDark) {
    final opsService = KelvinOpsService();
    return ListenableBuilder(
      listenable: opsService,
      builder: (context, _) {
        final prefs = opsService.notificationPrefs;

        final settings = [
          ('SLA Breach Alerts', 'Immediate push for any breach', 'sla'),
          ('PO Approval Requests', 'When someone requests sign-off', 'approval'),
          ('Follow-up Reminders', '30 min before due time', 'followup'),
          ('New Enquiries', 'When new lead or enquiry arrives', 'enquiry'),
          ('Project Updates', 'Daily project digest and milestones', 'project'),
          ('Weekly SLA Report', 'Every Monday morning summary', 'report'),
        ];

        return Container(
          padding: const EdgeInsets.all(AppDimensions.lg),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131B2E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notification Preferences',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              ...settings.map((s) {
                final isEnabled = prefs[s.$3] ?? false;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.$1,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              s.$2,
                              style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isEnabled,
                        activeColor: const Color(0xFF1A56DB),
                        onChanged: (_) => opsService.toggleNotificationPref(s.$3),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactCard(UserModel user, bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131B2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          _buildInfoRow(
            icon: Icons.email_outlined,
            label: AppStrings.emailLabel,
            value: user.email,
            color: const Color(0xFF3B82F6),
            isDark: isDark,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: AppStrings.phoneLabel,
            value: user.phone,
            color: const Color(0xFF10B981),
            isDark: isDark,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.apartment_rounded,
            label: AppStrings.departmentLabel,
            value: user.department,
            color: const Color(0xFF8B5CF6),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildClearanceCard(UserModel user, bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131B2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Operational Clearance',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          _buildInfoRow(
            icon: Icons.badge_outlined,
            label: 'Employee ID',
            value: user.id.toUpperCase(),
            color: const Color(0xFFF59E0B),
            isDark: isDark,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.security_rounded,
            label: 'System Access Tier',
            value: 'Level 3 - Operations Administrator',
            color: const Color(0xFF06B6D4),
            isDark: isDark,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Service Period',
            value: AppStrings.memberSince,
            color: const Color(0xFF64748B),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.2 : 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 19,
            color: color,
          ),
        ),
        const SizedBox(width: AppDimensions.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'C';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  void _showSignOutDialog(BuildContext context) {
    HapticFeedback.mediumImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF131B2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 22),
            ),
            const SizedBox(width: 12),
            const Text(
              'Sign Out',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to end your current Kelvin Mech session? You will need to log back in.',
          style: TextStyle(fontSize: 13.5, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              authService.logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRouter.loginRoute,
                (route) => false,
              );
            },
            child: const Text(
              'Yes, Sign Out',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileBottomSheet extends StatefulWidget {
  final UserModel user;
  final ValueChanged<UserModel> onSave;

  const _EditProfileBottomSheet({
    required this.user,
    required this.onSave,
  });

  @override
  State<_EditProfileBottomSheet> createState() =>
      _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<_EditProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _roleController;
  late final TextEditingController _phoneController;
  late final TextEditingController _deptController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _roleController = TextEditingController(text: widget.user.role);
    _phoneController = TextEditingController(text: widget.user.phone);
    _deptController = TextEditingController(text: widget.user.department);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    _phoneController.dispose();
    _deptController.dispose();
    super.dispose();
  }

  void _handleSave() {
    HapticFeedback.mediumImpact();
    if (!_formKey.currentState!.validate()) return;

    final updated = widget.user.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      role: _roleController.text.trim(),
      phone: _phoneController.text.trim(),
      department: _deptController.text.trim(),
    );

    widget.onSave(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        top: AppDimensions.lg,
        left: AppDimensions.lg,
        right: AppDimensions.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDimensions.lg,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131B2E) : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.md),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.editProfile,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.md),

              AppTextField(
                controller: _nameController,
                label: AppStrings.nameLabel,
                validator: (val) =>
                    AppValidators.validateRequired(val, 'full name'),
              ),
              const SizedBox(height: AppDimensions.md),

              AppTextField(
                controller: _emailController,
                label: AppStrings.emailLabel,
                keyboardType: TextInputType.emailAddress,
                validator: AppValidators.validateEmail,
              ),
              const SizedBox(height: AppDimensions.md),

              AppTextField(
                controller: _roleController,
                label: AppStrings.roleLabel,
                validator: (val) =>
                    AppValidators.validateRequired(val, 'role'),
              ),
              const SizedBox(height: AppDimensions.md),

              AppTextField(
                controller: _phoneController,
                label: AppStrings.phoneLabel,
                keyboardType: TextInputType.phone,
                validator: (val) =>
                    AppValidators.validateRequired(val, 'phone number'),
              ),
              const SizedBox(height: AppDimensions.md),

              AppTextField(
                controller: _deptController,
                label: AppStrings.departmentLabel,
                validator: (val) =>
                    AppValidators.validateRequired(val, 'department'),
              ),
              const SizedBox(height: AppDimensions.lg),

              AppButton(
                text: AppStrings.saveChanges,
                icon: Icons.check_rounded,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
