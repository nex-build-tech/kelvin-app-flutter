import 'dart:async';
import 'package:flutter/material.dart';
import '../../components/notification_bell.dart';
import '../../core/services/kelvin_ops_service.dart';
import '../../models/feed_activity_model.dart';
import '../../models/hvac_project_model.dart';
import '../../models/hvac_task_model.dart';
import '../auth/auth_service.dart';
import '../notifications/notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  final AuthService authService;
  final ValueChanged<int>? onNavigateTab;
  final VoidCallback onLogout;
  final VoidCallback? onOpenDrawer;
  final VoidCallback? onOpenNotifications;

  const DashboardScreen({
    super.key,
    required this.authService,
    this.onNavigateTab,
    required this.onLogout,
    this.onOpenDrawer,
    this.onOpenNotifications,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  final KelvinOpsService _opsService = KelvinOpsService();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Pulsing green dot for Live Activity
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formatDate() {
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  void _openNotificationsScreen() {
    if (widget.onOpenNotifications != null) {
      widget.onOpenNotifications!();
    } else {
      Navigator.of(context).pushNamed(NotificationsScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = widget.authService.currentUser;
    final firstName = user != null ? user.name.split(' ').first : 'Suresh';
    final avatarInitials = user != null && user.name.isNotEmpty
        ? user.name.split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join()
        : 'SI';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A1128) : const Color(0xFFF8FAFC),
      body: ListenableBuilder(
        listenable: _opsService,
        builder: (context, _) {
          final pendingTasks = _opsService.myTasks.where((t) => !t.isDone).toList();
          final overdueTasks = pendingTasks.where((t) => t.due.isBefore(DateTime.now().subtract(const Duration(hours: 12)))).toList();
          final projects = _opsService.projects;
          final activities = _opsService.activityFeed;

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 700));
            },
            color: const Color(0xFF1A56DB),
            child: CustomScrollView(
              slivers: [
                // Header App Bar
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 12,
                      left: 20,
                      right: 20,
                      bottom: 20,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0B1F68),
                      gradient: LinearGradient(
                        colors: [Color(0xFF071448), Color(0xFF0D2B8F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              if (widget.onOpenDrawer != null) ...[
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.menu_rounded, color: Colors.white),
                                  onPressed: widget.onOpenDrawer,
                                ),
                                const SizedBox(width: 14),
                              ],
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_getGreeting()}, $firstName 👋',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatDate(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.65),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Actions: Notification Bell + Avatar
                        Row(
                          children: [
                            NotificationBell(
                              onTap: _openNotificationsScreen,
                              iconColor: Colors.white,
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () {
                                if (widget.onNavigateTab != null) {
                                  // Tab 4 is Profile tab
                                  widget.onNavigateTab!(4);
                                }
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 19,
                                    backgroundColor: const Color(0xFF1A56DB),
                                    child: Text(
                                      avatarInitials,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 11,
                                      height: 11,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: const Color(0xFF0D2B8F), width: 2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Alert Banner: Overdue Tasks
                      if (overdueTasks.isNotEmpty) ...[
                        InkWell(
                          onTap: () {
                            if (widget.onNavigateTab != null) widget.onNavigateTab!(1); // Go to follow-ups
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFCA5A5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${overdueTasks.length} overdue task${overdueTasks.length > 1 ? 's' : ''} — tap to view',
                                    style: const TextStyle(
                                      color: Color(0xFFB91C1C),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded, color: Color(0xFFEF4444), size: 18),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // SLA Breach Strip
                      if (_opsService.kpiBreaches > 1) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF9EC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF59E0B),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${_opsService.kpiBreaches} active SLA breaches • ${_opsService.kpiApprovals} approvals pending',
                                  style: const TextStyle(
                                    color: Color(0xFF92400E),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Live KPI Horizontal Cards
                      SizedBox(
                        height: 114,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildLiveKpiCard(
                              label: 'Tasks Today',
                              value: _opsService.kpiTasks,
                              icon: Icons.check_circle_outline_rounded,
                              color: const Color(0xFF1A56DB),
                              bgColor: const Color(0xFFEFF6FF),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 10),
                            _buildLiveKpiCard(
                              label: 'SLA Breaches',
                              value: _opsService.kpiBreaches,
                              icon: Icons.warning_amber_rounded,
                              color: const Color(0xFFEF4444),
                              bgColor: const Color(0xFFFEF2F2),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 10),
                            _buildLiveKpiCard(
                              label: 'Approvals Due',
                              value: _opsService.kpiApprovals,
                              icon: Icons.access_time_rounded,
                              color: const Color(0xFFF59E0B),
                              bgColor: const Color(0xFFFEF3C7),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 10),
                            _buildLiveKpiCard(
                              label: 'Open Enquiries',
                              value: _opsService.kpiEnquiries,
                              icon: Icons.mail_outline_rounded,
                              color: const Color(0xFF10B981),
                              bgColor: const Color(0xFFF0FDF4),
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // My Tasks Today Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My Tasks Today',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (widget.onNavigateTab != null) widget.onNavigateTab!(1);
                            },
                            child: const Text(
                              'See all',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A56DB),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF111D3C) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? const Color(0xFF1E2D54) : const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pendingTasks.take(4).length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            indent: 44,
                            color: isDark ? const Color(0xFF1E2D54) : const Color(0xFFF1F5F9),
                          ),
                          itemBuilder: (context, index) {
                            final task = pendingTasks[index];
                            return _buildTaskRow(task, isDark);
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Project Pulse Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Project Pulse',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            '${projects.length} active',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      ...projects.take(5).map((p) => _buildProjectCard(p, isDark)),
                      const SizedBox(height: 24),

                      // Live Activity Feed Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, _) {
                                  return Opacity(
                                    opacity: _pulseAnimation.value,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF10B981),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Live Activity',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'updating live',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF111D3C) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? const Color(0xFF1E2D54) : const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: activities.take(7).length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            indent: 44,
                            color: isDark ? const Color(0xFF1E2D54) : const Color(0xFFF1F5F9),
                          ),
                          itemBuilder: (context, index) {
                            final act = activities[index];
                            return _buildActivityRow(act, isDark);
                          },
                        ),
                      ),
                      const SizedBox(height: 80),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiveKpiCard({
    required String label,
    required int value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required bool isDark,
  }) {
    return Container(
      width: 124,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111D3C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF1E2D54) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? color.withOpacity(0.18) : bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: color,
                  height: 1.1,
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
        ],
      ),
    );
  }

  Widget _buildTaskRow(HvacTaskModel task, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          InkWell(
            onTap: () => _opsService.toggleTask(task.id),
            borderRadius: BorderRadius.circular(8),
            child: Icon(
              task.isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
              size: 22,
              color: task.isDone ? const Color(0xFF10B981) : Colors.grey[400],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                    color: task.isDone ? Colors.grey : (isDark ? Colors.white : const Color(0xFF0F172A)),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(task.typeIcon, size: 11, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      task.project,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: task.priorityColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              task.priority,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: task.priorityColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(HvacProjectModel p, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111D3C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF1E2D54) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${p.phase} • ${p.value}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: p.statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(width: 5, height: 5, decoration: BoxDecoration(color: p.statusColor, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text(
                      p.statusLabel,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: p.statusColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress Track
          Container(
            height: 5,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(99),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (p.pct / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: p.statusColor,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),

          Text(
            '${p.pct.toStringAsFixed(0)}% complete • ${p.client}',
            style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(FeedActivityModel act, bool isDark) {
    return Container(
      color: act.isNew ? (isDark ? const Color(0xFF14244E) : const Color(0xFFEFF6FF)) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(act.iconEmoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  act.text,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[200] : const Color(0xFF334155),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Just now',
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          if (act.isNew)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1A56DB),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'NEW',
                style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900),
              ),
            ),
        ],
      ),
    );
  }
}
