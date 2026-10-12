import 'package:flutter/material.dart';

/// Centralized color palette for the application.
/// 
/// Reusable Design Token Guide:
/// Change these primary and accent values to instantly rebrand the entire application.
class AppColors {
  // Prevent instantiation
  AppColors._();

  // --- Brand Colors (Kelvin Mech MEP Palette) ---
  /// Primary brand color - Kelvin Mech Blue
  static const Color primary = Color(0xFF1A56DB);
  /// Darker variant of primary for active states and headers
  static const Color primaryDark = Color(0xFF0B1F68);
  /// Lighter variant of primary for highlights and badges
  static const Color primaryLight = Color(0xFF38BDF8);
  /// Secondary cyan accent for status and interactive indicators
  static const Color accent = Color(0xFF06B6D4);
  /// Subtle tint for selected items or badges
  static const Color primaryContainer = Color(0xFFEFF6FF);
  static const Color onPrimaryContainer = Color(0xFF1A56DB);

  // --- Neutral Colors (Light Mode) ---
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // --- Neutral Colors (Dark Mode) ---
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceVariantDark = Color(0xFF334155);
  static const Color borderDark = Color(0xFF334155);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // --- Status & Feedback Colors ---
  static const Color success = Color(0xFF10B981);
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoContainer = Color(0xFFDBEAFE);

  // --- Utility ---
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;
}
