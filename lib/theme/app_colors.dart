import 'package:flutter/material.dart';

/// Centralized color palette for the Zelyo app.
/// Keeping colors here means every screen we build stays visually consistent.
///
/// Tuned to a premium fintech dark theme: deep navy background, electric
/// blue accent gradient, and soft navy-tinted surfaces for cards so
/// everything reads as one cohesive system rather than "dark mode
/// slapped on a light design."
class AppColors {
  AppColors._();

  // Electric blue accent gradient — #2563FF -> #3B82F6.
  static const Color primaryBlue = Color(0xFF2563FF);
  static const Color primaryBlueLight = Color(0xFF3B82F6);
  static const Color primaryBlueDark = Color(0xFF1E40C7);

  // Deep navy background, #0B0F1A.
  static const Color background = Color(0xFF0B0F1A);
  static const Color surface = Color(0xFF141926);
  static const Color surfaceElevated = Color(0xFF1A2233);

  static const Color textPrimary = Color(0xFFF5F7FA);
  static const Color textSecondary = Color(0xFFAAB2C5);
  static const Color textMuted = Color(0xFF8891A5);

  static const Color dotInactive = Color(0xFF232A3B);
  static const Color outlineBorder = Color(0xFF232A3B);

  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);
}