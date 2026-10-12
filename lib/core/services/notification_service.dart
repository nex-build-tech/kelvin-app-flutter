import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum NotificationType { info, success, warning, alert }

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.type = NotificationType.info,
    this.isRead = false,
  });

  IconData get icon {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle_rounded;
      case NotificationType.warning:
        return Icons.warning_rounded;
      case NotificationType.alert:
        return Icons.error_rounded;
      case NotificationType.info:
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.success:
        return const Color(0xFF10B981);
      case NotificationType.warning:
        return const Color(0xFFF59E0B);
      case NotificationType.alert:
        return const Color(0xFFEF4444);
      case NotificationType.info:
      default:
        return const Color(0xFF2563EB);
    }
  }

  String get timeFormatted {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

/// Centralized notification service managing state, dispatching, and in-app banners.
class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal() {
    _initDefaultNotifications();
  }

  final List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void _initDefaultNotifications() {
    _notifications.addAll([
      AppNotification(
        id: '1',
        title: 'CoreApp Initialized',
        message: 'System runtime initialized with all core modules active.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        type: NotificationType.success,
        isRead: false,
      ),
      AppNotification(
        id: '2',
        title: 'Telemetry Node Verified',
        message: 'All sensor nodes and telemetry feeds are operating within optimal parameters.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 42)),
        type: NotificationType.info,
        isRead: false,
      ),
      AppNotification(
        id: '3',
        title: 'Security Sync Completed',
        message: 'Encrypted token session refreshed with Zero-Trust compliance.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: NotificationType.success,
        isRead: true,
      ),
    ]);
  }

  /// Dispatches an active push notification with haptics and overlay banner.
  void sendNotification({
    required BuildContext context,
    required String title,
    required String message,
    NotificationType type = NotificationType.info,
  }) {
    // 1. Trigger phone vibration / haptics
    HapticFeedback.heavyImpact();

    // 2. Add to active notification queue
    final newNotification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
      isRead: false,
    );

    _notifications.insert(0, newNotification);
    notifyListeners();

    // 3. Show top-sliding interactive push banner
    _showInAppPushBanner(context, newNotification);
  }

  /// Dispatches a notification directly into the queue without overlay requirement.
  void pushNotification({
    required String title,
    required String message,
    NotificationType type = NotificationType.info,
  }) {
    final newNotification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
      isRead: false,
    );

    _notifications.insert(0, newNotification);
    if (_notifications.length > 30) {
      _notifications.removeLast();
    }
    notifyListeners();
  }

  void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void markAsRead(String id) {
    final item = _notifications.firstWhere(
      (n) => n.id == id,
      orElse: () => _notifications.first,
    );
    item.isRead = true;
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  /// Displays an ultra-polished floating push notification banner from top.
  void _showInAppPushBanner(BuildContext context, AppNotification notification) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => _PushBannerWidget(
        notification: notification,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);

    // Auto dismiss after 4 seconds
    Timer(const Duration(seconds: 4), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }
}

class _PushBannerWidget extends StatefulWidget {
  final AppNotification notification;
  final VoidCallback onDismiss;

  const _PushBannerWidget({
    required this.notification,
    required this.onDismiss,
  });

  @override
  State<_PushBannerWidget> createState() => _PushBannerWidgetState();
}

class _PushBannerWidgetState extends State<_PushBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta! < -4) {
                _dismiss();
              }
            },
            onTap: _dismiss,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.notification.color.withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: widget.notification.color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.notification.icon,
                      color: widget.notification.color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.notification.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Just now',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.notification.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: _dismiss,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
