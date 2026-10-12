import 'package:flutter/material.dart';

enum EnquirySource {
  whatsapp,
  email,
  referral,
  direct,
}

enum EnquiryStatus {
  newLead,
  contacted,
  siteVisit,
  quoted,
}

class EnquiryModel {
  final int id;
  final String ref;
  final String client;
  final String scope;
  final String value;
  final EnquirySource source;
  final DateTime received;
  final EnquiryStatus status;
  final String priority;
  final String? assignedTo;

  const EnquiryModel({
    required this.id,
    required this.ref,
    required this.client,
    required this.scope,
    required this.value,
    required this.source,
    required this.received,
    required this.status,
    required this.priority,
    this.assignedTo,
  });

  Color get statusColor {
    switch (status) {
      case EnquiryStatus.newLead:
        return const Color(0xFFEF4444);
      case EnquiryStatus.contacted:
        return const Color(0xFFF59E0B);
      case EnquiryStatus.siteVisit:
        return const Color(0xFF1A56DB);
      case EnquiryStatus.quoted:
        return const Color(0xFF10B981);
    }
  }

  String get statusLabel {
    switch (status) {
      case EnquiryStatus.newLead:
        return 'new';
      case EnquiryStatus.contacted:
        return 'contacted';
      case EnquiryStatus.siteVisit:
        return 'site visit';
      case EnquiryStatus.quoted:
        return 'quoted';
    }
  }

  IconData get sourceIcon {
    switch (source) {
      case EnquirySource.whatsapp:
        return Icons.chat_bubble_rounded;
      case EnquirySource.email:
        return Icons.mail_outline_rounded;
      case EnquirySource.referral:
        return Icons.people_outline_rounded;
      case EnquirySource.direct:
        return Icons.call_outlined;
    }
  }

  String get sourceLabel {
    switch (source) {
      case EnquirySource.whatsapp:
        return 'whatsapp';
      case EnquirySource.email:
        return 'email';
      case EnquirySource.referral:
        return 'referral';
      case EnquirySource.direct:
        return 'direct';
    }
  }

  EnquiryModel copyWith({
    int? id,
    String? ref,
    String? client,
    String? scope,
    String? value,
    EnquirySource? source,
    DateTime? received,
    EnquiryStatus? status,
    String? priority,
    String? assignedTo,
  }) {
    return EnquiryModel(
      id: id ?? this.id,
      ref: ref ?? this.ref,
      client: client ?? this.client,
      scope: scope ?? this.scope,
      value: value ?? this.value,
      source: source ?? this.source,
      received: received ?? this.received,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }
}
