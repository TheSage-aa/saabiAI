import 'package:flutter/material.dart';

/// Saabi colour palette — extracted from Figma design.
abstract class SaabiColors {
  // Primary brand — deep navy blue (buttons, active nav, headers)
  static const primary = Color(0xFF1B3A8C);
  static const primaryLight = Color(0xFF3D52A0);
  static const primaryDark = Color(0xFF102465);

  // Green — success states, completed lessons, level badge
  static const green = Color(0xFF4CAF50);
  static const greenLight = Color(0xFFE8F5E9);

  // Orange — streaks, fire emoji accent
  static const orange = Color(0xFFFF9800);
  static const orangeLight = Color(0xFFFFF3E0);

  // Gold / Accent — XP stars, awards
  static const gold = Color(0xFFF5A623);
  static const goldLight = Color(0xFFFFF8E1);
  static const accent = gold;

  // Background — very light blue-grey (screens bg)
  static const background = Color(0xFFF0F2F8);

  // Surface — pure white (cards, inputs)
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF5F5F5);

  // Text
  static const textPrimary = Color(0xFF1A1A3E);
  static const textSecondary = Color(0xFF6B7280);
  static const textHint = Color(0xFF9CA3AF);

  // Semantic
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);

  // Chat bubbles
  static const userBubble = Color(0xFF1B3A8C);
  static const userBubbleText = Color(0xFFFFFFFF);
  static const aiBubble = Color(0xFFF3F4F6);
  static const aiBubbleText = Color(0xFF1A1A3E);

  // Disclaimer banner
  static const disclaimerBg = Color(0xFFFEF9C3);
  static const disclaimerText = Color(0xFF78716C);

  // Topic category pastel backgrounds
  static const topicHiv = Color(0xFFFFE4E6);         // pink
  static const topicHivIcon = Color(0xFFEF4444);
  static const topicReproductive = Color(0xFFDBEAFE); // blue
  static const topicReproductiveIcon = Color(0xFF3B82F6);
  static const topicMentalHealth = Color(0xFFEDE9FE);  // purple
  static const topicMentalHealthIcon = Color(0xFF8B5CF6);
  static const topicNutrition = Color(0xFFD1FAE5);    // green
  static const topicNutritionIcon = Color(0xFF10B981);
  static const topicDefault = Color(0xFFE0E7FF);
  static const topicDefaultIcon = Color(0xFF6366F1);
}

/// Spacing scale
abstract class SaabiSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Border radii
abstract class SaabiRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double full = 100;
}

/// The app's MaterialTheme based on the Figma design.
class SaabiTheme {
  SaabiTheme._();

  static ThemeData get light {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: SaabiColors.primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFDDE3F8),
      onPrimaryContainer: SaabiColors.primaryDark,
      secondary: SaabiColors.green,
      onSecondary: Colors.white,
      secondaryContainer: SaabiColors.greenLight,
      onSecondaryContainer: Color(0xFF1B5E20),
      error: SaabiColors.error,
      onError: Colors.white,
      surface: SaabiColors.surface,
      onSurface: SaabiColors.textPrimary,
      surfaceContainerHighest: SaabiColors.surfaceVariant,
      onSurfaceVariant: SaabiColors.textSecondary,
      outline: Color(0xFFE5E7EB),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: SaabiColors.background,
      fontFamily: 'Nunito',
      textTheme: _textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: SaabiColors.background,
        foregroundColor: SaabiColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: SaabiColors.textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SaabiColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SaabiRadius.xxl),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SaabiColors.primary,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SaabiRadius.xxl),
          ),
          side: const BorderSide(color: SaabiColors.primary, width: 1.5),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: SaabiColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SaabiRadius.xl),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SaabiColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SaabiRadius.xl),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SaabiRadius.xl),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SaabiRadius.xl),
          borderSide: const BorderSide(color: SaabiColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SaabiSpacing.md,
          vertical: SaabiSpacing.md,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Nunito',
          color: SaabiColors.textHint,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: SaabiColors.surface,
        selectedItemColor: SaabiColors.primary,
        unselectedItemColor: SaabiColors.textHint,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 12,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return SaabiColors.green;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: SaabiColors.primary,
        linearTrackColor: Color(0xFFE5E7EB),
      ),
    );
  }

  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: SaabiColors.textPrimary, height: 1.2),
    displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: SaabiColors.textPrimary, height: 1.25),
    headlineLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: SaabiColors.textPrimary, height: 1.3),
    headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: SaabiColors.textPrimary, height: 1.3),
    headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: SaabiColors.textPrimary, height: 1.4),
    titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: SaabiColors.textPrimary),
    titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SaabiColors.textPrimary),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SaabiColors.textSecondary),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: SaabiColors.textPrimary, height: 1.6),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: SaabiColors.textPrimary, height: 1.6),
    bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: SaabiColors.textSecondary, height: 1.5),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SaabiColors.textPrimary),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: SaabiColors.textSecondary, letterSpacing: 0.8),
  );
}
