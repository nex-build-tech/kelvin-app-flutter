import 'package:flutter/material.dart';

class HvacTaskModel {
  final int id;
  final String title;
  final String project;
  final DateTime due;
  final String priority; // 'high', 'medium', 'low'
  final bool isDone;
  final String type; // 'followup', 'approval', 'task', 'visit', 'update'

  const HvacTaskModel({
    required this.id,
    required this.title,
    required this.project,
    required this.due,
    required this.priority,
    required this.isDone,
    required this.type,
  });

  Color get priorityColor {
    switch (priority) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'low':
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData get typeIcon {
    switch (type) {
      case 'followup':
        return Icons.call_outlined;
      case 'approval':
        return Icons.check_circle_outline_rounded;
      case 'task':
        return Icons.check_box_outlined;
      case 'visit':
        return Icons.location_on_outlined;
      case 'update':
      default:
        return Icons.refresh_rounded;
    }
  }

  HvacTaskModel copyWith({
    int? id,
    String? title,
    String? project,
    DateTime? due,
    String? priority,
    bool? isDone,
    String? type,
  }) {
    return HvacTaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      project: project ?? this.project,
      due: due ?? this.due,
      priority: priority ?? this.priority,
      isDone: isDone ?? this.isDone,
      type: type ?? this.type,
    );
  }
}
