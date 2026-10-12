import 'package:flutter/material.dart';
import '../../core/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  static const String routeName = '/notifications';

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'SLA', 'Approvals', 'Enquiries', 'System'];

  bool _matchesFilter(AppNotification n) {
    if (_selectedFilter == 'All') return true;
    final lower = '${n.title} ${n.message}'.toLowerCase();
    switch (_selectedFilter) {
      case 'SLA':
        return lower.contains('sla') || lower.contains('breach');
      case 'Approvals':
        return lower.contains('approval') || lower.contains('po-') || lower.contains('approved');
      case 'Enquiries':
        return lower.contains('enquiry') || lower.contains('enq-') || lower.contains('client');
      case 'System':
        return lower.contains('system') || lower.contains('telemetry') || lower.contains('milestone') || lower.contains('member');
      default:
        return true;
    }
  }

  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('This will remove all notifications. Continue?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _notificationService.clearAll();
            },
            child: const Text('Clear All'),
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
      backgroundColor: isDark ? const Color(0xFF0A1128) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: isDark ? const Color(0xFF0F1A3A) : Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : const Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: ListenableBuilder(
          listenable: _notificationService,
          builder: (context, _) {
            final unread = _notificationService.unreadCount;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                if (unread > 0)
                  Text(
                    '$unread unread alerts',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A56DB),
                    ),
                  ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Mark All as Read',
            icon: const Icon(Icons.done_all_rounded, color: Color(0xFF1A56DB)),
            onPressed: () => _notificationService.markAllAsRead(),
          ),
          IconButton(
            tooltip: 'Clear All',
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
            onPressed: _confirmClearAll,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F1A3A) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF1E2D54) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;

                return ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[700]),
                  ),
                  selectedColor: const Color(0xFF1A56DB),
                  backgroundColor: isDark ? const Color(0xFF17244B) : const Color(0xFFF1F5F9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF1A56DB) : Colors.transparent,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedFilter = filter);
                  },
                );
              },
            ),
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: _notificationService,
        builder: (context, _) {
          final all = _notificationService.notifications;
          final filtered = all.where(_matchesFilter).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF142045) : const Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_off_outlined,
                      size: 48,
                      color: isDark ? Colors.grey[500] : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications here',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You are all caught up with alerts.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 600));
            },
            color: const Color(0xFF1A56DB),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = filtered[index];
                return _buildNotificationCard(item, isDark);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification item, bool isDark) {
    return InkWell(
      onTap: () => _notificationService.markAsRead(item.id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.isRead
              ? (isDark ? const Color(0xFF111D3C) : Colors.white)
              : (isDark ? const Color(0xFF142654) : const Color(0xFFEFF6FF)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isRead
                ? (isDark ? const Color(0xFF1D2C52) : const Color(0xFFE2E8F0))
                : const Color(0xFF1A56DB).withOpacity(0.35),
            width: item.isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread Dot Indicator
            if (!item.isRead) ...[
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(top: 14, right: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A56DB),
                  shape: BoxShape.circle,
                ),
              ),
            ],

            // Icon Wrap
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: item.color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(item.icon, size: 20, color: item.color),
              ),
            ),
            const SizedBox(width: 12),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.message,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.timeFormatted,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            // Read Action Checkmark
            if (!item.isRead) ...[
              IconButton(
                icon: const Icon(Icons.check_circle_outline_rounded, size: 20, color: Color(0xFF1A56DB)),
                onPressed: () => _notificationService.markAsRead(item.id),
                tooltip: 'Mark as read',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
