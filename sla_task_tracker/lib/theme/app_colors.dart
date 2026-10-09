import 'package:flutter/material.dart';

/// Central color palette, matched to the team's Figma prototype.
/// Keeping every color in one place makes it trivial to re-theme the
/// app and keeps widgets free of magic hex values.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFFF5F6F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE6E8EC);

  static const Color primaryDark = Color(0xFF141A2E);
  static const Color textPrimary = Color(0xFF141A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // SLA status colors — used consistently across badges, charts & cards.
  static const Color onTrack = Color(0xFF22C55E);
  static const Color onTrackBg = Color(0xFFE7F9EF);
  static const Color atRisk = Color(0xFFF59E0B);
  static const Color atRiskBg = Color(0xFFFFF4E0);
  static const Color overdue = Color(0xFFEF4444);
  static const Color overdueBg = Color(0xFFFDECEC);
  static const Color completed = Color(0xFF2563EB);
  static const Color completedBg = Color(0xFFE8EEFE);

  /// Soft palette cycled through for generated avatar backgrounds.
  static const List<Color> avatarPalette = [
    Color(0xFFFFC9B9),
    Color(0xFFB8C4FF),
    Color(0xFFBFE3FF),
    Color(0xFFC9EFC2),
    Color(0xFFFFE0A3),
    Color(0xFFE6C6FF),
  ];

  static Color avatarColorFor(String seed) {
    final idx = seed.codeUnits.fold<int>(0, (a, b) => a + b) %
        avatarPalette.length;
    return avatarPalette[idx];
  }
}
