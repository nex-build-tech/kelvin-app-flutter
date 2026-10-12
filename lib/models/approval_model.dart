import 'package:flutter/material.dart';

enum ApprovalUrgency {
  high,
  medium,
  low,
}

enum ApprovalStatus {
  pending,
  approved,
  rejected,
}

class ApprovalModel {
  final int id;
  final String po;
  final String vendor;
  final String item;
  final String amount;
  final double amountInLakhs;
  final int days;
  final ApprovalUrgency urgency;
  final ApprovalStatus status;
  final String requestedBy;
  final String? note;

  const ApprovalModel({
    required this.id,
    required this.po,
    required this.vendor,
    required this.item,
    required this.amount,
    required this.amountInLakhs,
    required this.days,
    required this.urgency,
    required this.status,
    required this.requestedBy,
    this.note,
  });

  Color get urgencyColor {
    switch (urgency) {
      case ApprovalUrgency.high:
        return const Color(0xFFEF4444);
      case ApprovalUrgency.medium:
        return const Color(0xFFF59E0B);
      case ApprovalUrgency.low:
        return const Color(0xFF10B981);
    }
  }

  double get urgencyPercent {
    switch (urgency) {
      case ApprovalUrgency.high:
        return 0.85;
      case ApprovalUrgency.medium:
        return 0.55;
      case ApprovalUrgency.low:
        return 0.25;
    }
  }

  String get urgencyLabel {
    switch (urgency) {
      case ApprovalUrgency.high:
        return 'high';
      case ApprovalUrgency.medium:
        return 'medium';
      case ApprovalUrgency.low:
        return 'low';
    }
  }

  ApprovalModel copyWith({
    int? id,
    String? po,
    String? vendor,
    String? item,
    String? amount,
    double? amountInLakhs,
    int? days,
    ApprovalUrgency? urgency,
    ApprovalStatus? status,
    String? requestedBy,
    String? note,
  }) {
    return ApprovalModel(
      id: id ?? this.id,
      po: po ?? this.po,
      vendor: vendor ?? this.vendor,
      item: item ?? this.item,
      amount: amount ?? this.amount,
      amountInLakhs: amountInLakhs ?? this.amountInLakhs,
      days: days ?? this.days,
      urgency: urgency ?? this.urgency,
      status: status ?? this.status,
      requestedBy: requestedBy ?? this.requestedBy,
      note: note ?? this.note,
    );
  }
}
