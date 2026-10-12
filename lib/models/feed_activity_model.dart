import 'package:flutter/material.dart';

class FeedActivityModel {
  final String id;
  final String iconEmoji;
  final String text;
  final DateTime timestamp;
  final String colorTag; // 'success', 'danger', 'primary', 'warning', 'info'
  final bool isNew;

  const FeedActivityModel({
    required this.id,
    required this.iconEmoji,
    required this.text,
    required this.timestamp,
    required this.colorTag,
    this.isNew = false,
  });

  Color get color {
    switch (colorTag) {
      case 'success':
        return const Color(0xFF10B981);
      case 'danger':
        return const Color(0xFFEF4444);
      case 'warning':
        return const Color(0xFFF59E0B);
      case 'info':
        return const Color(0xFF0284C7);
      case 'primary':
      default:
        return const Color(0xFF1A56DB);
    }
  }

  FeedActivityModel copyWith({
    String? id,
    String? iconEmoji,
    String? text,
    DateTime? timestamp,
    String? colorTag,
    bool? isNew,
  }) {
    return FeedActivityModel(
      id: id ?? this.id,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      colorTag: colorTag ?? this.colorTag,
      isNew: isNew ?? this.isNew,
    );
  }
}
