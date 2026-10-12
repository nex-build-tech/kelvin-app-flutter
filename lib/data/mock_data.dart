import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/activity_model.dart';
import '../models/stat_model.dart';
import '../models/user_model.dart';

/// Central repository of mock data for demo purposes.
/// 
/// Reusability:
/// Modify the values in this file to change the sample data showcased
/// on the Dashboard, Profile, and Login screens.
class MockData {
  MockData._();

  // --- Predefined Demo Credentials ---
  static const String demoEmail = 'demo@coreapp.com';
  static const String demoPassword = 'password123';

  static const String adminEmail = 'admin@coreapp.com';
  static const String adminPassword = 'admin123';

  // --- Default Demo User ---
  static const UserModel defaultUser = UserModel(
    id: 'usr_core_01',
    name: 'Alex Morgan',
    email: demoEmail,
    role: 'Senior Project Lead',
    phone: '+1 (555) 234-5678',
    department: 'Product Operations',
  );

  // --- Sample Generic Dashboard Statistics ---
  static const List<StatModel> dashboardStats = [
    StatModel(
      id: 'stat_1',
      title: 'Active Projects',
      value: '18 / 20',
      subtitle: '90% on target schedule',
      icon: Icons.folder_open_rounded,
      trend: '+4 this month',
      isPositive: true,
      customColor: AppColors.primary,
    ),
    StatModel(
      id: 'stat_2',
      title: 'Workflow Efficiency',
      value: '96.4%',
      subtitle: 'Across operational streams',
      icon: Icons.speed_rounded,
      trend: '+2.8% MoM',
      isPositive: true,
      customColor: AppColors.accent,
    ),
    StatModel(
      id: 'stat_3',
      title: 'Pending Reviews',
      value: '5 Items',
      subtitle: 'Scheduled this cycle',
      icon: Icons.assignment_outlined,
      trend: 'On Track',
      isPositive: true,
      customColor: AppColors.warning,
    ),
    StatModel(
      id: 'stat_4',
      title: 'Quality Score',
      value: '98.2%',
      subtitle: 'Benchmark target met',
      icon: Icons.insights_rounded,
      trend: 'Optimal',
      isPositive: true,
      customColor: AppColors.success,
    ),
  ];

  // --- Sample Generic Recent Activity ---
  static const List<ActivityModel> recentActivities = [
    ActivityModel(
      id: 'act_1',
      title: 'Sprint Planning Finalized',
      subtitle: 'Deliverables aligned for Q3 roadmap and milestones',
      timestamp: '15 mins ago',
      icon: Icons.task_alt_rounded,
      statusBadge: 'Completed',
      statusColor: AppColors.success,
    ),
    ActivityModel(
      id: 'act_2',
      title: 'Client Proposal Approved',
      subtitle: 'Executive sign-off received for Phase 2 expansion',
      timestamp: '2 hours ago',
      icon: Icons.verified_outlined,
      statusBadge: 'Approved',
      statusColor: AppColors.info,
    ),
    ActivityModel(
      id: 'act_3',
      title: 'Security Compliance Check',
      subtitle: 'Routine access permissions and key audit verified',
      timestamp: 'Yesterday',
      icon: Icons.shield_outlined,
      statusBadge: 'Routine',
      statusColor: AppColors.primary,
    ),
    ActivityModel(
      id: 'act_4',
      title: 'Quarterly Summary Exported',
      subtitle: 'Financial and operations summary published',
      timestamp: '3 days ago',
      icon: Icons.analytics_outlined,
      statusBadge: 'Published',
      statusColor: AppColors.success,
    ),
  ];
}
