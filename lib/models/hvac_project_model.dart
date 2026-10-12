import 'package:flutter/material.dart';

enum ProjectStatus {
  onTrack,
  atRisk,
  delayed,
}

class HvacProjectModel {
  final int id;
  final String name;
  final double pct; // 0.0 to 100.0
  final ProjectStatus status;
  final String phase;
  final String value;
  final String client;

  const HvacProjectModel({
    required this.id,
    required this.name,
    required this.pct,
    required this.status,
    required this.phase,
    required this.value,
    required this.client,
  });

  Color get statusColor {
    switch (status) {
      case ProjectStatus.onTrack:
        return const Color(0xFF10B981);
      case ProjectStatus.atRisk:
        return const Color(0xFFF59E0B);
      case ProjectStatus.delayed:
        return const Color(0xFFEF4444);
    }
  }

  String get statusLabel {
    switch (status) {
      case ProjectStatus.onTrack:
        return 'on track';
      case ProjectStatus.atRisk:
        return 'at risk';
      case ProjectStatus.delayed:
        return 'delayed';
    }
  }

  HvacProjectModel copyWith({
    int? id,
    String? name,
    double? pct,
    ProjectStatus? status,
    String? phase,
    String? value,
    String? client,
  }) {
    return HvacProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      pct: pct ?? this.pct,
      status: status ?? this.status,
      phase: phase ?? this.phase,
      value: value ?? this.value,
      client: client ?? this.client,
    );
  }
}
