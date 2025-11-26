// 한국어 주석: 앱 전체에서 사용하는 색상 상수 정의
/// App-wide color constants following Material Design 3 guidelines

import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary colors - Premium Red
  static const Color primary = Color(0xFFD32F2F); // Standard Red 700
  static const Color primaryLight = Color(0xFFFF6659);
  static const Color primaryDark = Color(0xFF9A0007);

  // Secondary colors - Deep Teal/Blue Grey for contrast
  static const Color secondary = Color(0xFF00695C); // Teal 800
  static const Color secondaryLight = Color(0xFF439889);
  static const Color secondaryDark = Color(0xFF003D33);

  // Surface colors - Clean and Modern
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F7FA); // Cool Grey
  static const Color background = Color(0xFFF0F2F5); // Light Blue Grey tint

  // Status colors - Vibrant
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFB8C00);
  static const Color success = Color(0xFF43A047);
  static const Color info = Color(0xFF1E88E5);

  // Text colors - High Contrast
  static const Color textPrimary = Color(0xFF1A1C1E); // Almost Black
  static const Color textSecondary = Color(0xFF424242); // Dark Grey
  static const Color textDisabled = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // Border and divider colors
  static const Color divider = Color(0xFFEEEEEE);
  static const Color border = Color(0xFFE0E0E0);

  // Inspection status colors
  static const Color statusNormal = Color(0xFF4CAF50); // Green
  static const Color statusDefective = Color(0xFFE53935); // Red
  static const Color statusNotApplicable = Color(0xFF9E9E9E); // Grey
  static const Color statusInProgress = Color(0xFFFB8C00); // Orange
  static const Color statusNotInspected = Color(0xFFBDBDBD); // Light Grey
}

