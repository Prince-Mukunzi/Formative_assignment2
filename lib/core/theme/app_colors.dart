import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary
  static const primary = Color(0xFF1B2E4B);
  static const primaryLight = Color(0xFF2D4A7A);
  static const primaryDark = Color(0xFF0F1C30);

  // Accent
  static const accent = Color(0xFF3B82F6);
  static const accentLight = Color(0xFFDBEAFE);

  // Status
  static const active = Color(0xFF3B82F6);
  static const resolved = Color(0xFF22C55E);
  static const resolvedLight = Color(0xFFDCFCE7);
  static const inProgress = Color(0xFFF59E0B);
  static const inProgressLight = Color(0xFFFEF3C7);
  static const awaitingApproval = Color(0xFF6B7280);
  static const awaitingApprovalLight = Color(0xFFF3F4F6);

  // Neutrals
  static const background = Color(0xFFF8F9FB);
  static const surface = Color(0xFFFFFFFF);
  static const cardBorder = Color(0xFFE5E7EB);
  static const divider = Color(0xFFF1F3F5);

  // Text
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const textOnPrimary = Color(0xFFFFFFFF);

  // Chip / Tag
  static const chipBackground = Color(0xFFF1F5F9);
  static const chipActiveBackground = primary;
  static const chipActiveText = Color(0xFFFFFFFF);
  static const chipInactiveText = Color(0xFF64748B);

  // Upvote
  static const upvoteIcon = Color(0xFF3B82F6);
  static const upvoteText = Color(0xFF6B7280);

  // Shadows
  static const shadow = Color(0x0A000000);
  static const shadowMedium = Color(0x14000000);
}
