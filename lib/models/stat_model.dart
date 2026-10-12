import 'package:flutter/material.dart';

/// Model representing a statistic card metric on the Dashboard.
class StatModel {
  final String id;
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final String? trend;
  final bool isPositive;
  final Color? customColor;

  const StatModel({
    required this.id,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.trend,
    this.isPositive = true,
    this.customColor,
  });
}
