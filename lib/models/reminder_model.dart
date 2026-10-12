import 'package:flutter/material.dart';

class ReminderModel {
  final int id;
  final String title;
  final DateTime time;
  final String type; // 'call', 'report', 'approval', 'visit', 'task'
  final String priority; // 'high', 'medium', 'low'
  final String repeat; // 'none', 'daily', 'weekly', 'monthly'
  final bool isDone;

  const ReminderModel({
    required this.id,
    required this.title,
    required this.time,
    required this.type,
    required this.priority,
    required this.repeat,
    required this.isDone,
  });

  IconData get typeIcon {
    switch (type) {
      case 'call':
        return Icons.call_outlined;
      case 'report':
        return Icons.description_outlined;
      case 'approval':
        return Icons.check_circle_outline_rounded;
      case 'visit':
        return Icons.location_on_outlined;
      case 'task':
      default:
        return Icons.check_box_outlined;
    }
  }

  Color get typeColor {
    switch (type) {
      case 'call':
        return const Color(0xFF1A56DB);
      case 'report':
        return const Color(0xFF0284C7);
      case 'approval':
        return const Color(0xFFF59E0B);
      case 'visit':
        return const Color(0xFF10B981);
      case 'task':
      default:
        return const Color(0xFF64748B);
    }
  }

  Color get priorityColor {
    switch (priority) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'low':
      default:
        return const Color(0xFF94A3B8);
    }
  }

  String get repeatLabel {
    switch (repeat) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      case 'none':
      default:
        return 'Once';
    }
  }

  ReminderModel copyWith({
    int? id,
    String? title,
    DateTime? time,
    String? type,
    String? priority,
    String? repeat,
    bool? isDone,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      repeat: repeat ?? this.repeat,
      isDone: isDone ?? this.isDone,
    );
  }
}
