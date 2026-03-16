import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design System — CRP Cursos
/// Identidade visual oficial da CRP Engenharia e Medicina do Trabalho.
/// Paleta extraída de https://www.crpengenharia.com/
class AppColors {
  // ═══════════════════════════════════════
  // BRAND — CRP Engenharia
  // ═══════════════════════════════════════
  static const primary = Color(0xFF262B5D);       // Azul marinho (headings, nav)
  static const primaryLight = Color(0xFF3A4080);   // Azul marinho claro
  static const primaryDark = Color(0xFF1A1E42);    // Azul marinho escuro
  static const secondary = Color(0xFFD15731);      // Laranja CRP (CTAs, destaques)
  static const secondaryLight = Color(0xFFDF6B4A); // Laranja claro
  static const secondaryDark = Color(0xFFB5421F);  // Laranja escuro
  static const accent = Color(0xFFDF4F27);         // Laranja vibrante (hover)

  // ═══════════════════════════════════════
  // SEMANTIC
  // ═══════════════════════════════════════
  static const success = Color(0xFF2E7D32);
  static const error = Color(0xFFC62828);
  static const warning = Color(0xFFF57C00);
  static const info = Color(0xFF1565C0);

  // Status badges
  static const badgeEmAndamento = Color(0xFF2E7D32);
  static const badgeConcluido = Color(0xFF1565C0);
  static const badgeNaoIniciado = Color(0xFFD15731);

  // ═══════════════════════════════════════
  // DARK THEME
  // ═══════════════════════════════════════
  static const darkBg = Color(0xFF0D0F1A);
  static const darkSurface = Color(0xFF151828);
  static const darkCard = Color(0xFF1C2035);
  static const darkDivider = Color(0xFF2A2E45);

  // ═══════════════════════════════════════
  // LIGHT THEME
  // ═══════════════════════════════════════
  static const lightBg = Color(0xFFF8F9FA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightDivider = Color(0xFFE8E8E8);

  // Text colors
  static const textDark = Color(0xFF262B5D);      // Headings (azul marinho)
  static const textBody = Color(0xFF333333);       // Body text
  static const textMuted = Color(0xFF6B7280);      // Muted/secondary text

  // ═══════════════════════════════════════
  // GRADIENTS
  // ═══════════════════════════════════════
  static const gradientStart = Color(0xFF262B5D);
  static const gradientEnd = Color(0xFFD15731);

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );

  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1E42),
      Color(0xFF262B5D),
      Color(0xFF323875),
    ],
  );
}

/// Layout constants
class AppLayout {
  static const double maxContentWidth = 1200;
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double horizontalPadding = 16;

  /// Wrap content in centered ConstrainedBox for consistent layout
  static Widget constrained({required Widget child, double? maxWidth}) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? maxContentWidth),
        child: child,
      ),
    );
  }
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
          onPrimary: Colors.white,
          onSecondary: Colors.white,
        ),
        cardColor: AppColors.darkCard,
        dividerColor: AppColors.darkDivider,
        textTheme: _textTheme(Brightness.dark),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkSurface,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkSurface,
          selectedItemColor: AppColors.secondary,
          unselectedItemColor: Colors.grey,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.secondary,
            side: const BorderSide(color: AppColors.secondary),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.darkCard,
          selectedColor: AppColors.secondary,
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
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
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
          onPrimary: Colors.white,
          onSecondary: Colors.white,
        ),
        cardColor: AppColors.lightCard,
        dividerColor: AppColors.lightDivider,
        textTheme: _textTheme(Brightness.light),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightSurface,
          elevation: 0,
          centerTitle: true,
          foregroundColor: AppColors.textDark,
          titleTextStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.lightSurface,
          selectedItemColor: AppColors.secondary,
          unselectedItemColor: Color(0xFF9CA3AF),
          elevation: 8,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFF0F1F5),
          selectedColor: AppColors.secondary,
          labelStyle: const TextStyle(fontSize: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF0F1F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
        ),
      );

  static TextTheme _textTheme(Brightness brightness) {
    final color =
        brightness == Brightness.dark ? Colors.white : AppColors.textDark;
    final bodyColor =
        brightness == Brightness.dark ? Colors.white : AppColors.textBody;
    return GoogleFonts.montserratTextTheme(
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
        bodyLarge: TextStyle(fontSize: 16, color: bodyColor),
        bodyMedium: TextStyle(fontSize: 14, color: bodyColor),
        bodySmall:
            TextStyle(fontSize: 12, color: bodyColor.withValues(alpha: 0.7)),
        labelLarge: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
