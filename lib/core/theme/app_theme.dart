import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design System — CRP Cursos
/// Cores, tipografia e tokens visuais do aplicativo.
class AppColors {
  // Brand
  static const primary = Color(0xFF5B6ABF);
  static const primaryLight = Color(0xFF7C8AE0);
  static const primaryDark = Color(0xFF3F4D9E);
  static const secondary = Color(0xFFE8A838);
  static const secondaryLight = Color(0xFFF0C060);
  static const secondaryDark = Color(0xFFD09020);

  // Semantic
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFD32F2F);
  static const warning = Color(0xFFFFA726);
  static const info = Color(0xFF29B6F6);

  // Status badges
  static const badgeEmAndamento = Color(0xFF4CAF50);
  static const badgeConcluido = Color(0xFF2196F3);
  static const badgeNaoIniciado = Color(0xFFE53935);

  // Dark theme
  static const darkBg = Color(0xFF0F0F0F);
  static const darkSurface = Color(0xFF1A1A1A);
  static const darkCard = Color(0xFF222222);
  static const darkDivider = Color(0xFF333333);

  // Light theme
  static const lightBg = Color(0xFFF5F5F7);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);

  // Gradient (brand header)
  static const gradientStart = Color(0xFF5B8DD9);
  static const gradientEnd = Color(0xFFE8A838);

  static const brandGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
  );
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.darkSurface,
          error: AppColors.error,
        ),
        cardColor: AppColors.darkCard,
        dividerColor: AppColors.darkDivider,
        textTheme: _textTheme(Brightness.dark),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkSurface,
          elevation: 0,
          centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkSurface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.darkCard,
          selectedColor: AppColors.primary,
          labelStyle: const TextStyle(fontSize: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          side: const BorderSide(color: AppColors.darkDivider),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBg,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.lightSurface,
          error: AppColors.error,
        ),
        cardColor: AppColors.lightCard,
        textTheme: _textTheme(Brightness.light),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightSurface,
          elevation: 0,
          centerTitle: true,
          foregroundColor: Colors.black87,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.lightSurface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.grey[100],
          selectedColor: AppColors.primary,
          labelStyle: const TextStyle(fontSize: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );

  static TextTheme _textTheme(Brightness brightness) {
    final color =
        brightness == Brightness.dark ? Colors.white : Colors.black87;
    return GoogleFonts.interTextTheme(
      TextTheme(
        headlineLarge:
            TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
        headlineMedium:
            TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
        headlineSmall:
            TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color),
        titleLarge:
            TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color),
        titleMedium:
            TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
        bodyLarge: TextStyle(fontSize: 16, color: color),
        bodyMedium: TextStyle(fontSize: 14, color: color),
        bodySmall:
            TextStyle(fontSize: 12, color: color.withValues(alpha: 0.7)),
        labelLarge: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
