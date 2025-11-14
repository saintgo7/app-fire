import 'package:flutter/material.dart';

/// 소방 안전 점검 앱 색상 스킴
/// Material Design 3 기반
/// Figma에서 생성된 색상 토큰과 동기화
class AppColors {
  AppColors._();

  // ========== Light Theme Colors ==========

  /// Primary: 소방차 빨강 (Fire Engine Red)
  /// 주요 액션, 중요한 버튼, 앱 브랜딩
  static const Color primaryLight = Color(0xFFD32F2F); // Material Red 700
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color primaryContainerLight = Color(0xFFFFCDD2); // Red 100
  static const Color onPrimaryContainerLight = Color(0xFF410002);

  /// Secondary: 안전 파랑 (Safety Blue)
  /// 보조 액션, 정보 표시
  static const Color secondaryLight = Color(0xFF1976D2); // Material Blue 700
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color secondaryContainerLight = Color(0xFFBBDEFB); // Blue 100
  static const Color onSecondaryContainerLight = Color(0xFF001D36);

  /// Tertiary: 경고 주황 (Warning Orange)
  /// 주의, 경고 메시지
  static const Color tertiaryLight = Color(0xFFFF6F00); // Material Orange 900
  static const Color onTertiaryLight = Color(0xFFFFFFFF);
  static const Color tertiaryContainerLight = Color(0xFFFFE0B2); // Orange 100
  static const Color onTertiaryContainerLight = Color(0xFF2A1800);

  /// Error: 에러 빨강
  static const Color errorLight = Color(0xFFBA1A1A);
  static const Color onErrorLight = Color(0xFFFFFFFF);
  static const Color errorContainerLight = Color(0xFFFFDAD6);
  static const Color onErrorContainerLight = Color(0xFF410002);

  /// Background & Surface
  static const Color backgroundLight = Color(0xFFFFFBFE);
  static const Color onBackgroundLight = Color(0xFF1C1B1F);
  static const Color surfaceLight = Color(0xFFFFFBFE);
  static const Color onSurfaceLight = Color(0xFF1C1B1F);
  static const Color surfaceVariantLight = Color(0xFFE7E0EC);
  static const Color onSurfaceVariantLight = Color(0xFF49454F);

  /// Outline & Shadow
  static const Color outlineLight = Color(0xFF79747E);
  static const Color outlineVariantLight = Color(0xFFCAC4D0);
  static const Color shadowLight = Color(0xFF000000);
  static const Color scrimLight = Color(0xFF000000);

  /// Inverse Colors
  static const Color inverseSurfaceLight = Color(0xFF313033);
  static const Color onInverseSurfaceLight = Color(0xFFF4EFF4);
  static const Color inversePrimaryLight = Color(0xFFFFB4AB);

  // ========== Dark Theme Colors ==========

  /// Primary (Dark)
  static const Color primaryDark = Color(0xFFFFB4AB);
  static const Color onPrimaryDark = Color(0xFF690005);
  static const Color primaryContainerDark = Color(0xFF93000A);
  static const Color onPrimaryContainerDark = Color(0xFFFFDAD6);

  /// Secondary (Dark)
  static const Color secondaryDark = Color(0xFF90CAF9); // Blue 200
  static const Color onSecondaryDark = Color(0xFF00344F);
  static const Color secondaryContainerDark = Color(0xFF004B73);
  static const Color onSecondaryContainerDark = Color(0xFFCBE6FF);

  /// Tertiary (Dark)
  static const Color tertiaryDark = Color(0xFFFFCC80); // Orange 200
  static const Color onTertiaryDark = Color(0xFF4A2800);
  static const Color tertiaryContainerDark = Color(0xFF6A3C00);
  static const Color onTertiaryContainerDark = Color(0xFFFFDDB3);

  /// Error (Dark)
  static const Color errorDark = Color(0xFFFFB4AB);
  static const Color onErrorDark = Color(0xFF690005);
  static const Color errorContainerDark = Color(0xFF93000A);
  static const Color onErrorContainerDark = Color(0xFFFFDAD6);

  /// Background & Surface (Dark)
  static const Color backgroundDark = Color(0xFF1C1B1F);
  static const Color onBackgroundDark = Color(0xFFE6E1E5);
  static const Color surfaceDark = Color(0xFF1C1B1F);
  static const Color onSurfaceDark = Color(0xFFE6E1E5);
  static const Color surfaceVariantDark = Color(0xFF49454F);
  static const Color onSurfaceVariantDark = Color(0xFFCAC4D0);

  /// Outline & Shadow (Dark)
  static const Color outlineDark = Color(0xFF938F99);
  static const Color outlineVariantDark = Color(0xFF49454F);
  static const Color shadowDark = Color(0xFF000000);
  static const Color scrimDark = Color(0xFF000000);

  /// Inverse Colors (Dark)
  static const Color inverseSurfaceDark = Color(0xFFE6E1E5);
  static const Color onInverseSurfaceDark = Color(0xFF313033);
  static const Color inversePrimaryDark = Color(0xFFD32F2F);

  // ========== Semantic Colors (앱 특화 색상) ==========

  /// 점검 상태 색상
  static const Color statusGood = Color(0xFF4CAF50); // Green 500 - 양호
  static const Color statusWarning = Color(0xFFFF9800); // Orange 500 - 주의
  static const Color statusDefective = Color(0xFFF44336); // Red 500 - 불량
  static const Color statusPending = Color(0xFF9E9E9E); // Grey 500 - 대기

  /// 점검 우선순위 색상
  static const Color priorityHigh = Color(0xFFE53935); // Red 600
  static const Color priorityMedium = Color(0xFFFB8C00); // Orange 600
  static const Color priorityLow = Color(0xFF43A047); // Green 600

  /// 소방 시설 타입 색상
  static const Color equipmentSprinkler = Color(0xFF0288D1); // Light Blue 700
  static const Color equipmentHydrant = Color(0xFFD32F2F); // Red 700
  static const Color equipmentAlarm = Color(0xFFFF6F00); // Orange 900
  static const Color equipmentExtinguisher = Color(0xFF7B1FA2); // Purple 700

  /// 차트 색상 (데이터 시각화)
  static const List<Color> chartColors = [
    Color(0xFFD32F2F), // Red
    Color(0xFF1976D2), // Blue
    Color(0xFFFF6F00), // Orange
    Color(0xFF388E3C), // Green
    Color(0xFF7B1FA2), // Purple
    Color(0xFF0097A7), // Cyan
    Color(0xFFFBC02D), // Yellow
    Color(0xFF5D4037), // Brown
  ];

  // ========== ColorScheme Factories ==========

  /// Light ColorScheme
  static ColorScheme lightColorScheme = const ColorScheme(
    brightness: Brightness.light,
    primary: primaryLight,
    onPrimary: onPrimaryLight,
    primaryContainer: primaryContainerLight,
    onPrimaryContainer: onPrimaryContainerLight,
    secondary: secondaryLight,
    onSecondary: onSecondaryLight,
    secondaryContainer: secondaryContainerLight,
    onSecondaryContainer: onSecondaryContainerLight,
    tertiary: tertiaryLight,
    onTertiary: onTertiaryLight,
    tertiaryContainer: tertiaryContainerLight,
    onTertiaryContainer: onTertiaryContainerLight,
    error: errorLight,
    onError: onErrorLight,
    errorContainer: errorContainerLight,
    onErrorContainer: onErrorContainerLight,
    background: backgroundLight,
    onBackground: onBackgroundLight,
    surface: surfaceLight,
    onSurface: onSurfaceLight,
    surfaceVariant: surfaceVariantLight,
    onSurfaceVariant: onSurfaceVariantLight,
    outline: outlineLight,
    outlineVariant: outlineVariantLight,
    shadow: shadowLight,
    scrim: scrimLight,
    inverseSurface: inverseSurfaceLight,
    onInverseSurface: onInverseSurfaceLight,
    inversePrimary: inversePrimaryLight,
  );

  /// Dark ColorScheme
  static ColorScheme darkColorScheme = const ColorScheme(
    brightness: Brightness.dark,
    primary: primaryDark,
    onPrimary: onPrimaryDark,
    primaryContainer: primaryContainerDark,
    onPrimaryContainer: onPrimaryContainerDark,
    secondary: secondaryDark,
    onSecondary: onSecondaryDark,
    secondaryContainer: secondaryContainerDark,
    onSecondaryContainer: onSecondaryContainerDark,
    tertiary: tertiaryDark,
    onTertiary: onTertiaryDark,
    tertiaryContainer: tertiaryContainerDark,
    onTertiaryContainer: onTertiaryContainerDark,
    error: errorDark,
    onError: onErrorDark,
    errorContainer: errorContainerDark,
    onErrorContainer: onErrorContainerDark,
    background: backgroundDark,
    onBackground: onBackgroundDark,
    surface: surfaceDark,
    onSurface: onSurfaceDark,
    surfaceVariant: surfaceVariantDark,
    onSurfaceVariant: onSurfaceVariantDark,
    outline: outlineDark,
    outlineVariant: outlineVariantDark,
    shadow: shadowDark,
    scrim: scrimDark,
    inverseSurface: inverseSurfaceDark,
    onInverseSurface: onInverseSurfaceDark,
    inversePrimary: inversePrimaryDark,
  );
}
