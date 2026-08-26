import 'package:flutter/material.dart';

/// Gym3D brand colors — dark fitness aesthetic with vibrant accents
class AppColors {
  AppColors._();

  // Primary brand
  static const primary = Color(0xFF6C5CE7);
  static const primaryLight = Color(0xFF8B7BF7);
  static const primaryDark = Color(0xFF5A4BD6);

  // Accent / energy color
  static const accent = Color(0xFF00E5FF);
  static const accentGlow = Color(0x3300E5FF);

  // Success / progress
  static const success = Color(0xFF00E676);
  static const successDark = Color(0xFF00C853);

  // Warning
  static const warning = Color(0xFFFFAB40);

  // Error / danger
  static const error = Color(0xFFFF5252);

  // Dark theme surfaces
  static const backgroundDark = Color(0xFF0A0A0F);
  static const surfaceDark = Color(0xFF12121A);
  static const surfaceElevatedDark = Color(0xFF1A1A28);
  static const surfaceHighDark = Color(0xFF242436);
  static const borderDark = Color(0xFF2A2A3E);

  // Light theme surfaces
  static const backgroundLight = Color(0xFFF5F5FA);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceElevatedLight = Color(0xFFF0F0F8);
  static const surfaceHighLight = Color(0xFFE8E8F0);
  static const borderLight = Color(0xFFD8D8E8);

  // Text colors
  static const textPrimaryDark = Color(0xFFF0F0F8);
  static const textSecondaryDark = Color(0xFF9898B0);
  static const textTertiaryDark = Color(0xFF6868A0);

  static const textPrimaryLight = Color(0xFF1A1A28);
  static const textSecondaryLight = Color(0xFF5A5A78);
  static const textTertiaryLight = Color(0xFF8888A8);

  // Muscle groups (for highlighting)
  static const muscleChest = Color(0xFFFF6B6B);
  static const muscleBack = Color(0xFF4ECDC4);
  static const muscleLegs = Color(0xFF45B7D1);
  static const muscleShoulders = Color(0xFFF9CA24);
  static const muscleArms = Color(0xFFFF9FF3);
  static const muscleCore = Color(0xFF6C5CE7);

  // Gradient presets
  static const gradientPrimary = LinearGradient(
    colors: [primary, Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientAccent = LinearGradient(
    colors: [accent, Color(0xFF00B4D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientDarkSurface = LinearGradient(
    colors: [surfaceDark, surfaceElevatedDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
