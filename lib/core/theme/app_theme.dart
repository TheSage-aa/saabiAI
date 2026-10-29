import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Saabi's design-system colors.
///
/// NOTE: This file did not exist anywhere in the project when this review
/// was done -- `lib/main.dart`, `lib/navigation/app_router.dart`, and every
/// screen under `lib/features/` imported `core/theme/app_theme.dart` and
/// referenced `SaabiColors` / `SaabiSpacing` / `SaabiRadius` / `SaabiTheme`,
/// but none of it was ever defined, so the app could not compile. These
/// values were reconstructed from how the existing screens already use
/// them (hex literals like `Color(0xFFE5E7EB)` scattered through
/// home_screen.dart, profile_screen.dart, etc.) so the whole app reads as
/// one consistent system instead of introducing a second, different look.
abstract class SaabiColors {
  // Brand
  static const primary = Color(0xFF4F46E5);
  static const primaryLight = Color(0xFFEEF2FF);

  // Surfaces
  static const background = Color(0xFFF9FAFB);
  static const surface = Color(0xFFFFFFFF);

  // Text
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textHint = Color(0xFF9CA3AF);

  // Status
  static const error = Color(0xFFDC2626);
  static const green = Color(0xFF10B981);
  static const greenLight = Color(0xFFD1FAE5);
  static const gold = Color(0xFFF59E0B);
  static const goldLight = Color(0xFFFEF3C7);
  static const orangeLight = Color(0xFFFFEDD5);

  // Topic accents (home screen topic grid / icons)
  static const topicHiv = Color(0xFFFCE7E7);
  static const topicReproductive = Color(0xFFDCFCE7);
  static const topicMentalHealth = Color(0xFFEDE9FE);
  static const topicNutrition = Color(0xFFD1FAE5);

  // Chat screen
  static const disclaimerBg = Color(0xFFFFFBEB);
  static const disclaimerText = Color(0xFF92400E);
  static const userBubble = Color(0xFF4F46E5);
  static const userBubbleText = Color(0xFFFFFFFF);
  static const aiBubble = Color(0xFFF3F4F6);
  static const aiBubbleText = Color(0xFF111827);
}

/// Spacing scale used throughout the app instead of magic numbers.
abstract class SaabiSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

/// Corner-radius scale.
abstract class SaabiRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 28.0;
  static const full = 999.0;
}

/// The app's single `ThemeData`. Built once and reused by `MaterialApp`.
abstract class SaabiTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: SaabiColors.primary,
        brightness: Brightness.light,
        primary: SaabiColors.primary,
        surface: SaabiColors.surface,
        error: SaabiColors.error,
      ),
      scaffoldBackgroundColor: SaabiColors.background,
      fontFamily: GoogleFonts.inter().fontFamily,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        headlineLarge: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: SaabiColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: SaabiColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: SaabiColors.textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: SaabiColors.textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: SaabiColors.textPrimary,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: SaabiColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: SaabiColors.textPrimary),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: SaabiColors.textPrimary),
        bodySmall: GoogleFonts.inter(fontSize: 12, color: SaabiColors.textSecondary),
        labelSmall: GoogleFonts.inter(fontSize: 11, color: SaabiColors.textSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: SaabiColors.background,
        foregroundColor: SaabiColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SaabiColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: SaabiSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SaabiRadius.xxl),
          ),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SaabiRadius.xxl),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SaabiColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SaabiSpacing.md,
          vertical: SaabiSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SaabiRadius.lg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SaabiRadius.lg),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SaabiRadius.lg),
          borderSide: const BorderSide(color: SaabiColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SaabiRadius.lg),
          borderSide: const BorderSide(color: SaabiColors.error),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFE5E7EB), thickness: 1),
    );
  }
}
