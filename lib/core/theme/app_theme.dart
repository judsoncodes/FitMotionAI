import 'package:flutter/material.dart';

/// Clinical yet energetic design system for FitMotionAI.
/// Avoids generic plain blue and neon gamification colors.
class AppTheme {
  // Brand Color Palette
  static const Color primaryTeal = Color(0xFF0D9488);
  static const Color primaryLight = Color(0xFF14B8A6);
  static const Color secondaryMint = Color(0xFF2DD4BF);
  static const Color tertiaryCyan = Color(0xFF06B6D4);
  
  // Neutral Colors - Light Mode (Clinical White / Cool Slate)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightOnBackground = Color(0xFF0F172A);
  static const Color lightOnSurface = Color(0xFF1E293B);

  // Neutral Colors - Dark Mode (Deep Obsidian Slate)
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color darkOnBackground = Color(0xFFF8FAFC);
  static const Color darkOnSurface = Color(0xFFE2E8F0);

  // Status & Functional Colors
  static const Color errorRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningAmber = Color(0xFFF59E0B);

  /// Light Theme Definition
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryTeal,
      brightness: Brightness.light,
      primary: primaryTeal,
      onPrimary: Colors.white,
      secondary: secondaryMint,
      onSecondary: const Color(0xFF0F172A),
      tertiary: tertiaryCyan,
      onTertiary: Colors.white,
      background: lightBackground,
      onBackground: lightOnBackground,
      surface: lightSurface,
      onSurface: lightOnSurface,
      surfaceVariant: lightSurfaceVariant,
      onSurfaceVariant: const Color(0xFF64748B),
      error: errorRed,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: lightBackground,

      // Typography Hierarchy
      textTheme: _textTheme(lightOnBackground, lightOnSurface),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightOnBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: lightOnBackground),
        titleTextStyle: TextStyle(
          color: lightOnBackground,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),

      // Filled Button Theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryTeal,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: primaryTeal, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryTeal, width: 2),
        ),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      ),
    );
  }

  /// Dark Theme Definition
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryLight,
      brightness: Brightness.dark,
      primary: primaryLight,
      onPrimary: const Color(0xFF0F172A),
      secondary: secondaryMint,
      onSecondary: const Color(0xFF0F172A),
      tertiary: tertiaryCyan,
      onTertiary: const Color(0xFF0F172A),
      background: darkBackground,
      onBackground: darkOnBackground,
      surface: darkSurface,
      onSurface: darkOnSurface,
      surfaceVariant: darkSurfaceVariant,
      onSurfaceVariant: const Color(0xFF94A3B8),
      error: errorRed,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBackground,

      // Typography Hierarchy
      textTheme: _textTheme(darkOnBackground, darkOnSurface),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkOnBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: darkOnBackground),
        titleTextStyle: TextStyle(
          color: darkOnBackground,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
      ),

      // Filled Button Theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: const Color(0xFF0F172A),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryLight,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: primaryLight, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
        hintStyle: const TextStyle(color: Color(0xFF64748B)),
      ),
    );
  }

  static TextTheme _textTheme(Color headingColor, Color bodyColor) {
    return TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: headingColor, letterSpacing: -1.0),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: headingColor, letterSpacing: -0.8),
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: headingColor, letterSpacing: -0.5),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: headingColor),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: headingColor),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: bodyColor),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: bodyColor, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: bodyColor, height: 1.4),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: headingColor),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: bodyColor),
    );
  }
}
