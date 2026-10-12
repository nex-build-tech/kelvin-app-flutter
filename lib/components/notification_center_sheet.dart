import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/services/notification_service.dart';

/// Interactive modal sheet displaying active notifications and controls.
class NotificationCenterSheet extends StatelessWidget {
  const NotificationCenterSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const NotificationCenterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final notificationService = NotificationService();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.notifications_rounded, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Notifications',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => notificationService.markAllAsRead(),
                      child: const Text('Mark all read', style: TextStyle(fontSize: 12)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_rounded, size: 20),
                      tooltip: 'Clear all',
                      onPressed: () => notificationService.clearAll(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Action bar to test push notifications
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add_alert_rounded, size: 18),
              label: const Text('Dispatch Test Push Notification', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                notificationService.sendNotification(
                  context: context,
                  title: 'Real-Time Alert',
                  message: 'Automated telemetry threshold check executed with optimal metrics.',
                  type: NotificationType.info,
                );
              },
            ),
          ),

          // List of notifications
          Expanded(
            child: ListenableBuilder(
              listenable: notificationService,
              builder: (ctx, _) {
                final list = notificationService.notifications;
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 56,
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No active notifications',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap the button above to test real-time push',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? Colors.grey[600] : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (ctx, idx) => const SizedBox(height: 10),
                  itemBuilder: (ctx, idx) {
                    final item = list[idx];
                    return InkWell(
                      onTap: () => notificationService.markAsRead(item.id),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? (item.isRead ? const Color(0xFF1E293B) : const Color(0xFF1E293B).withOpacity(0.8))
                              : (item.isRead ? const Color(0xFFF8FAFC) : const Color(0xFFEFF6FF)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: item.isRead
                                ? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
                                : AppColors.primary.withOpacity(0.4),
                            width: item.isRead ? 1 : 1.5,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: item.color.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(item.icon, color: item.color, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          item.title,
                                          style: TextStyle(
                                            fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        item.timeFormatted,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.message,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!item.isRead) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(top: 4),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
