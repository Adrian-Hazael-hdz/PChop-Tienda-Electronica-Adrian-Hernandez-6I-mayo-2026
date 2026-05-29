import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.nunitoTextTheme().copyWith(
      displayLarge: GoogleFonts.quicksand(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.onBackground,
      ),
      displayMedium: GoogleFonts.quicksand(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.onBackground,
      ),
      headlineMedium: GoogleFonts.quicksand(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.onBackground,
      ),
      titleMedium: GoogleFonts.quicksand(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.onBackground,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.onBackground,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.onSurface,
      ),
      bodySmall: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.onSurface.withValues(alpha: 0.7),
      ),
      labelLarge: GoogleFonts.quicksand(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.onPrimary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onBackground,
        error: AppColors.error,
        onError: AppColors.onBackground,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
      ),
      textTheme: baseTextTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.onPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.kBorderRadiusButton),
          ),
          textStyle: baseTextTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.all(AppConstants.kSpaceMD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.kBorderRadiusInput),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.kBorderRadiusInput),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.kBorderRadiusInput),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.kBorderRadiusInput),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.kBorderRadiusInput),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: baseTextTheme.bodyMedium,
        errorStyle: baseTextTheme.bodySmall?.copyWith(color: AppColors.error),
      ),
      dividerColor: AppColors.divider,
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
    );
  }
}
