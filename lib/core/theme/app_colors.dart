// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  AppColors._();

  // Core palette
  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF12121A);
  static const Color surfaceElevated = Color(0xFF1A1A26);

  // Glass layers
  static const Color glass = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x26FFFFFF);
  static const Color glassDark = Color(0x0DFFFFFF);

  // Accent — violet-to-cyan aurora gradient
  static const Color accentPrimary = Color(0xFF8B5CF6); // violet
  static const Color accentSecondary = Color(0xFF06B6D4); // cyan
  static const Color accentTertiary = Color(0xFFEC4899); // pink

  // Gradient
  static const List<Color> brandGradient = [
    Color(0xFF8B5CF6),
    Color(0xFF6366F1),
    Color(0xFF06B6D4),
  ];

  static const List<Color> playerGradient = [
    Color(0xFF8B5CF6),
    Color(0xFF0A0A0F),
  ];

  // Text
  static const Color textPrimary = Color(0xFFF8F8FF);
  static const Color textSecondary = Color(0xFF9494AA);
  static const Color textDisabled = Color(0xFF4A4A60);

  // Functional
  static const Color success = Color(0xFF34D399);
  static const Color error = Color(0xFFF87171);
  static const Color warning = Color(0xFFFBBF24);

  // Waveform bars
  static const Color waveformActive = accentPrimary;
  static const Color waveformInactive = Color(0xFF2A2A3E);
}
