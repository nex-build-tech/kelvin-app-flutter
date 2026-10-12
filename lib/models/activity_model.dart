import 'package:flutter/material.dart';

/// Model representing a recent log / activity item on the Dashboard.
class ActivityModel {
  final String id;
  final String title;
  final String subtitle;
  final String timestamp;
  final IconData icon;
  final String statusBadge;
  final Color statusColor;

  const ActivityModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.icon,
    required this.statusBadge,
    required this.statusColor,
  });
}
