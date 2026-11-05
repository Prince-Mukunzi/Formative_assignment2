import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Geist',
    splashFactory: NoSplash.splashFactory,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.brand,
      surface: AppColors.surface,
      error: Color(0xFFEF4444),
      onPrimary: AppColors.textOnPrimary,
      onSecondary: AppColors.textOnPrimary,
      onSurface: AppColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: TextStyle(
        fontFamily: 'Geist',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.cardBorder, width: 0.5),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      hintStyle: const TextStyle(
        fontFamily: 'Geist',
        fontSize: 14,
        color: AppColors.textTertiary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        textStyle: const TextStyle(
          fontFamily: 'Geist',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
