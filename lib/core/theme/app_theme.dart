import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Material Design 3 기반 앱 테마
/// Figma Design System과 동기화
class AppTheme {
  AppTheme._();

  // ========== Light Theme ==========

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: AppColors.lightColorScheme,
    textTheme: AppTextStyles.lightTextTheme,
    fontFamily: AppTextStyles.fontFamily,

    // AppBar
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 3,
      backgroundColor: AppColors.surfaceLight,
      foregroundColor: AppColors.onSurfaceLight,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(
        color: AppColors.onSurfaceLight,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.onSurfaceLight,
        size: 24,
      ),
    ),

    // Card
    cardTheme: CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      color: AppColors.surfaceLight,
      surfaceTintColor: AppColors.primaryLight,
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 1,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTextStyles.labelLarge,
        minimumSize: const Size(64, 48),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.onPrimaryLight,
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: const BorderSide(
          color: AppColors.outlineLight,
          width: 1,
        ),
        textStyle: AppTextStyles.labelLarge,
        minimumSize: const Size(64, 48),
        foregroundColor: AppColors.primaryLight,
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTextStyles.labelLarge,
        foregroundColor: AppColors.primaryLight,
      ),
    ),

    // Floating Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: AppColors.primaryLight,
      foregroundColor: AppColors.onPrimaryLight,
    ),

    // Input Decoration (TextField)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariantLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.outlineLight,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.outlineLight,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.primaryLight,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.errorLight,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.errorLight,
          width: 2,
        ),
      ),
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.onSurfaceVariantLight,
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.onSurfaceVariantLight.withOpacity(0.6),
      ),
      errorStyle: AppTextStyles.bodySmall.copyWith(
        color: AppColors.errorLight,
      ),
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceVariantLight,
      deleteIconColor: AppColors.onSurfaceVariantLight,
      disabledColor: AppColors.surfaceVariantLight.withOpacity(0.12),
      selectedColor: AppColors.secondaryContainerLight,
      secondarySelectedColor: AppColors.primaryContainerLight,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: AppTextStyles.labelMedium,
      secondaryLabelStyle: AppTextStyles.labelMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    // Dialog
    dialogTheme: DialogTheme(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      backgroundColor: AppColors.surfaceLight,
      titleTextStyle: AppTextStyles.headlineSmall.copyWith(
        color: AppColors.onSurfaceLight,
      ),
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.onSurfaceVariantLight,
      ),
    ),

    // Bottom Sheet
    bottomSheetTheme: const BottomSheetThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      backgroundColor: AppColors.surfaceLight,
    ),

    // Navigation Bar
    navigationBarTheme: NavigationBarThemeData(
      elevation: 3,
      height: 80,
      backgroundColor: AppColors.surfaceLight,
      indicatorColor: AppColors.secondaryContainerLight,
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppTextStyles.labelMedium.copyWith(
            color: AppColors.onSurfaceLight,
          );
        }
        return AppTextStyles.labelMedium.copyWith(
          color: AppColors.onSurfaceVariantLight,
        );
      }),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(
            color: AppColors.onSecondaryContainerLight,
            size: 24,
          );
        }
        return const IconThemeData(
          color: AppColors.onSurfaceVariantLight,
          size: 24,
        );
      }),
    ),

    // Navigation Drawer
    drawerTheme: const DrawerThemeData(
      elevation: 1,
      backgroundColor: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(16),
        ),
      ),
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.onPrimaryLight;
        }
        return AppColors.outlineLight;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primaryLight;
        }
        return AppColors.surfaceVariantLight;
      }),
    ),

    // Checkbox
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primaryLight;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(AppColors.onPrimaryLight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
      ),
    ),

    // Radio
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primaryLight;
        }
        return AppColors.onSurfaceVariantLight;
      }),
    ),

    // Progress Indicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryLight,
      linearTrackColor: AppColors.surfaceVariantLight,
      circularTrackColor: AppColors.surfaceVariantLight,
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.outlineVariantLight,
      thickness: 1,
      space: 1,
    ),

    // List Tile
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      iconColor: AppColors.onSurfaceVariantLight,
      textColor: AppColors.onSurfaceLight,
      titleTextStyle: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.onSurfaceLight,
      ),
      subtitleTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.onSurfaceVariantLight,
      ),
    ),

    // Badge
    badgeTheme: const BadgeThemeData(
      backgroundColor: AppColors.errorLight,
      textColor: AppColors.onErrorLight,
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    ),

    // Snack Bar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.inverseSurfaceLight,
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.onInverseSurfaceLight,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 3,
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: AppColors.onSurfaceLight,
      size: 24,
    ),

    // Scaffold Background
    scaffoldBackgroundColor: AppColors.backgroundLight,
  );

  // ========== Dark Theme ==========

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: AppColors.darkColorScheme,
    textTheme: AppTextStyles.darkTextTheme,
    fontFamily: AppTextStyles.fontFamily,

    // AppBar
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 3,
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.onSurfaceDark,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(
        color: AppColors.onSurfaceDark,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.onSurfaceDark,
        size: 24,
      ),
    ),

    // Card
    cardTheme: CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      color: AppColors.surfaceDark,
      surfaceTintColor: AppColors.primaryDark,
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 1,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTextStyles.labelLarge,
        minimumSize: const Size(64, 48),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.onPrimaryDark,
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: const BorderSide(
          color: AppColors.outlineDark,
          width: 1,
        ),
        textStyle: AppTextStyles.labelLarge,
        minimumSize: const Size(64, 48),
        foregroundColor: AppColors.primaryDark,
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTextStyles.labelLarge,
        foregroundColor: AppColors.primaryDark,
      ),
    ),

    // Floating Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: AppColors.primaryDark,
      foregroundColor: AppColors.onPrimaryDark,
    ),

    // Input Decoration (TextField)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariantDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.outlineDark,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.outlineDark,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.primaryDark,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.errorDark,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.errorDark,
          width: 2,
        ),
      ),
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.onSurfaceVariantDark,
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.onSurfaceVariantDark.withOpacity(0.6),
      ),
      errorStyle: AppTextStyles.bodySmall.copyWith(
        color: AppColors.errorDark,
      ),
    ),

    // Dialog
    dialogTheme: DialogTheme(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      backgroundColor: AppColors.surfaceDark,
      titleTextStyle: AppTextStyles.headlineSmall.copyWith(
        color: AppColors.onSurfaceDark,
      ),
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.onSurfaceVariantDark,
      ),
    ),

    // Bottom Sheet
    bottomSheetTheme: const BottomSheetThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      backgroundColor: AppColors.surfaceDark,
    ),

    // Scaffold Background
    scaffoldBackgroundColor: AppColors.backgroundDark,

    // Icon Theme
    iconTheme: const IconThemeData(
      color: AppColors.onSurfaceDark,
      size: 24,
    ),
  );
}
