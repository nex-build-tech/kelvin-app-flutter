import 'package:flutter/material.dart';

enum FollowUpStatus {
  overdue,
  dueToday,
  upcoming,
}

enum ContactChannel {
  whatsapp,
  call,
  email,
}

class FollowUpModel {
  final int id;
  final String contact;
  final String company;
  final String topic;
  final String phone;
  final String project;
  final DateTime due;
  final FollowUpStatus status;
  final ContactChannel channel;

  const FollowUpModel({
    required this.id,
    required this.contact,
    required this.company,
    required this.topic,
    required this.phone,
    required this.project,
    required this.due,
    required this.status,
    required this.channel,
  });

  Color get statusColor {
    switch (status) {
      case FollowUpStatus.overdue:
        return const Color(0xFFEF4444);
      case FollowUpStatus.dueToday:
        return const Color(0xFFF59E0B);
      case FollowUpStatus.upcoming:
        return const Color(0xFF64748B);
    }
  }

  Color get statusBackground {
    switch (status) {
      case FollowUpStatus.overdue:
        return const Color(0xFFFEE2E2);
      case FollowUpStatus.dueToday:
        return const Color(0xFFFEF3C7);
      case FollowUpStatus.upcoming:
        return const Color(0xFFF1F5F9);
    }
  }

  String get statusLabel {
    switch (status) {
      case FollowUpStatus.overdue:
        return 'Overdue';
      case FollowUpStatus.dueToday:
        return 'Due Today';
      case FollowUpStatus.upcoming:
        return 'Upcoming';
    }
  }

  Color get channelColor {
    switch (channel) {
      case ContactChannel.whatsapp:
        return const Color(0xFF25D366);
      case ContactChannel.call:
        return const Color(0xFF1A56DB);
      case ContactChannel.email:
        return const Color(0xFF0284C7);
    }
  }

  IconData get channelIcon {
    switch (channel) {
      case ContactChannel.whatsapp:
        return Icons.chat_bubble_rounded;
      case ContactChannel.call:
        return Icons.call_rounded;
      case ContactChannel.email:
        return Icons.mail_outline_rounded;
    }
  }

  String get channelLabel {
    switch (channel) {
      case ContactChannel.whatsapp:
        return 'WhatsApp';
      case ContactChannel.call:
        return 'Call';
      case ContactChannel.email:
        return 'Email';
    }
  }

  FollowUpModel copyWith({
    int? id,
    String? contact,
    String? company,
    String? topic,
    String? phone,
    String? project,
    DateTime? due,
    FollowUpStatus? status,
    ContactChannel? channel,
  }) {
    return FollowUpModel(
      id: id ?? this.id,
      contact: contact ?? this.contact,
      company: company ?? this.company,
      topic: topic ?? this.topic,
      phone: phone ?? this.phone,
      project: project ?? this.project,
      due: due ?? this.due,
      status: status ?? this.status,
      channel: channel ?? this.channel,
    );
  }
}
