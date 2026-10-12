import 'dart:math';
import 'package:flutter/material.dart';
import '../core/services/notification_service.dart';

class NotificationBell extends StatefulWidget {
  final VoidCallback onTap;
  final Color iconColor;

  const NotificationBell({
    super.key,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> with SingleTickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  late AnimationController _wiggleController;
  late Animation<double> _wiggleAnimation;
  int _prevUnreadCount = 0;

  @override
  void initState() {
    super.initState();
    _prevUnreadCount = _notificationService.unreadCount;

    _wiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _wiggleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _wiggleController, curve: Curves.easeInOut),
    );

    _notificationService.addListener(_handleNotificationUpdate);
  }

  void _handleNotificationUpdate() {
    final currentCount = _notificationService.unreadCount;
    if (currentCount > _prevUnreadCount) {
      _wiggleController.forward(from: 0.0);
    }
    _prevUnreadCount = currentCount;
  }

  @override
  void dispose() {
    _notificationService.removeListener(_handleNotificationUpdate);
    _wiggleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _notificationService,
      builder: (context, _) {
        final unread = _notificationService.unreadCount;

        return InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _wiggleAnimation,
                  builder: (context, child) {
                    final angle = sin(_wiggleAnimation.value * pi * 4) * 0.22 * (1.0 - _wiggleAnimation.value);
                    return Transform.rotate(
                      angle: angle,
                      child: child,
                    );
                  },
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: 26,
                    color: widget.iconColor,
                  ),
                ),
                if (unread > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          unread > 99 ? '99+' : '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
