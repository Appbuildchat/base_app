import 'package:flutter/material.dart';
import 'color_theme.dart';
import 'app_typography.dart';
import 'app_dimensions.dart';
import 'app_spacing.dart';

/// Common colors used throughout the app
class AppCommonColors {
  AppCommonColors._();

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Semantic colors
  static const Color green = Color(0xFF4CAF50);
  static const Color red = Color(0xFFF44336);
  static const Color orange = Color(0xFFFF9800);
  static const Color purple = Color(0xFF9C27B0);

  // Grey shades
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Default grey (for backwards compatibility)
  static const Color grey = grey500;
}

/// Application theme configuration
/// Centralizes all theme-related settings for better maintainability
class AppTheme {
  AppTheme._(); // Private constructor to prevent instantiation

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),

      // Typography using Google Fonts
      textTheme: TextTheme(
        displayLarge: AppTypography.display,
        headlineLarge: AppTypography.headline1,
        headlineMedium: AppTypography.headline2,
        headlineSmall: AppTypography.headline3,
        titleLarge: AppTypography.title1,
        titleMedium: AppTypography.title2,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyRegular,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.button,
        labelSmall: AppTypography.caption,
      ),

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppCommonColors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headline3,
        iconTheme: IconThemeData(color: AppColors.text),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppCommonColors.white,
          elevation: 2,
          shape: AppDimensions.roundedRectangleBorderL,
          padding: AppSpacing.buttonPadding,
          textStyle: AppTypography.button,
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusL,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusL,
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: AppSpacing.textFieldPadding,
        labelStyle: AppTypography.bodyRegular.copyWith(
          color: AppColors.secondary,
        ),
        hintStyle: AppTypography.bodyRegular.copyWith(
          color: AppColors.secondary.withValues(alpha: 0.6),
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: AppCommonColors.black.withValues(alpha: 0.1),
        shape: AppDimensions.roundedRectangleBorderL,
        margin: AppSpacing.paddingVerticalS,
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppCommonColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.secondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  /// Dark theme configuration
  /// TODO: Implement dark theme when needed
  static ThemeData get darkTheme {
    return lightTheme; // Placeholder - implement dark theme later
  }
}
