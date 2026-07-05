import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Material 3 Color Palette - exact from designs
  static const Color primary = Color(0xFF00450D);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1B5E20);
  static const Color onPrimaryContainer = Color(0xFF90D689);
  static const Color primaryFixed = Color(0xFFACF4A4);
  static const Color primaryFixedDim = Color(0xFF91D78A);
  static const Color onPrimaryFixed = Color(0xFF002203);
  static const Color onPrimaryFixedVariant = Color(0xFF0C5216);

  static const Color secondary = Color(0xFF7A5649);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFDCDBC);
  static const Color onSecondaryContainer = Color(0xFF795548);
  static const Color secondaryFixed = Color(0xFFFFDBCF);
  static const Color secondaryFixedDim = Color(0xFFEBBCAC);
  static const Color onSecondaryFixed = Color(0xFF2E150B);
  static const Color onSecondaryFixedVariant = Color(0xFF603F33);

  static const Color tertiary = Color(0xFF262F89);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF3F48A1);
  static const Color onTertiaryContainer = Color(0xFFBBC0FF);
  static const Color tertiaryFixed = Color(0xFFE0E0FF);
  static const Color tertiaryFixedDim = Color(0xFFBDC2FF);
  static const Color onTertiaryFixed = Color(0xFF000767);
  static const Color onTertiaryFixedVariant = Color(0xFF343D96);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color background = Color(0xFFF9F9F9);
  static const Color onBackground = Color(0xFF1A1C1C);
  static const Color surface = Color(0xFFF9F9F9);
  static const Color onSurface = Color(0xFF1A1C1C);
  static const Color surfaceVariant = Color(0xFFE2E2E2);
  static const Color onSurfaceVariant = Color(0xFF41493E);
  static const Color surfaceTint = Color(0xFF2A6B2C);

  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F3F3);
  static const Color surfaceContainer = Color(0xFFEEEEEE);
  static const Color surfaceContainerHigh = Color(0xFFE8E8E8);
  static const Color surfaceContainerHighest = Color(0xFFE2E2E2);

  static const Color outline = Color(0xFF717A6D);
  static const Color outlineVariant = Color(0xFFC0C9BB);

  static const Color inverseSurface = Color(0xFF2F3131);
  static const Color inverseOnSurface = Color(0xFFF1F1F1);
  static const Color inversePrimary = Color(0xFF91D78A);

  // Spacing constants
  static const double baseSpacing = 8.0;
  static const double sectionMargin = 32.0;
  static const double containerPadding = 20.0;
  static const double cardGap = 12.0;
  static const double gutter = 16.0;

  // Border Radius
  static const double radiusSm = 4.0;
  static const double radiusLg = 8.0;
  static const double radiusXl = 12.0;
  static const double radius2xl = 16.0;
  static const double radius3xl = 24.0;

  // ─── Dark Mode Colors ──────────────────────────────────────────────────

  static const Color _darkBg = Color(0xFF0D1B0F);
  static const Color _darkSurface = Color(0xFF14231A);
  static const Color _darkCard = Color(0xFF1A2E20);
  static const Color _darkCardHigh = Color(0xFF243828);
  static const Color _darkOnSurface = Color(0xFFE8EDE8);
  static const Color _darkOnSurfaceVariant = Color(0xFF9CAE9C);
  static const Color _darkOutline = Color(0xFF2D4A33);
  static const Color _darkOutlineVariant = Color(0xFF1F3524);
  static const Color _darkWhite = Color(0xFFFFFFFF);

  /// Get theme-aware background color (adapts to light/dark)
  static Color bg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _darkBg : background;

  /// Get theme-aware surface color
  static Color surfaceColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _darkSurface : surface;

  /// Get theme-aware card color
  static Color card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _darkCard : _darkWhite;

  /// Get theme-aware elevated card color
  static Color cardHigh(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _darkCardHigh : surfaceContainerHigh;

  /// Get theme-aware primary text color
  static Color text(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _darkOnSurface : onSurface;

  /// Get theme-aware secondary text color
  static Color subtext(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _darkOnSurfaceVariant : onSurfaceVariant;

  /// Get theme-aware border color
  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _darkOutlineVariant : outlineVariant.withValues(alpha: 0.2);

  /// Get theme-aware strong border color
  static Color borderStrong(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _darkOutline : outlineVariant;

  /// Check if dark mode is active
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Get white in light mode, light text in dark mode
  static Color white(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _darkOnSurface : _darkWhite;

  // Typography
  static TextTheme get textTheme => TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: 57,
          height: 64 / 57,
          letterSpacing: -0.25,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          height: 40 / 32,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 28,
          height: 36 / 28,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 22,
          height: 28 / 22,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          height: 24 / 16,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          height: 20 / 14,
          letterSpacing: 0.25,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          height: 20 / 14,
          letterSpacing: 0.1,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          height: 16 / 11,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w500,
        ),
      );

  // Material 3 ColorScheme
  static ColorScheme get colorScheme => ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
        inverseSurface: inverseSurface,
        onInverseSurface: inverseOnSurface,
        inversePrimary: inversePrimary,
        surfaceContainerLowest: surfaceContainerLowest,
        surfaceContainerLow: surfaceContainerLow,
        surfaceContainer: surfaceContainer,
        surfaceContainerHigh: surfaceContainerHigh,
        surfaceContainerHighest: surfaceContainerHighest,
      );

  // ThemeData
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        textTheme: textTheme,
        scaffoldBackgroundColor: background,
        appBarTheme: AppBarTheme(
          backgroundColor: surface.withValues(alpha: 0.8),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: primary,
          ),
          iconTheme: const IconThemeData(color: onSurfaceVariant),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: primary,
          unselectedItemColor: onSurfaceVariant,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9999),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: outlineVariant),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceContainerLowest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusXl),
            borderSide: const BorderSide(color: outlineVariant, width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusXl),
            borderSide: const BorderSide(color: outlineVariant, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusXl),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            color: outline,
            fontWeight: FontWeight.w500,
          ),
        ),
        cardTheme: CardThemeData(
          color: surfaceContainerLowest,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius2xl),
          ),
          clipBehavior: Clip.antiAlias,
        ),
      );

  // ─── Dark Theme ──────────────────────────────────────────────────────────

  static ColorScheme get _darkColorScheme => ColorScheme(
        brightness: Brightness.dark,
        primary: primaryFixed,
        onPrimary: onPrimaryFixed,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondaryFixed,
        onSecondary: onSecondaryFixed,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiaryFixed,
        onTertiary: onTertiaryFixed,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        surface: _darkSurface,
        onSurface: _darkOnSurface,
        onSurfaceVariant: _darkOnSurfaceVariant,
        outline: _darkOutline,
        outlineVariant: _darkOutlineVariant,
        inverseSurface: const Color(0xFFE8EDE8),
        onInverseSurface: const Color(0xFF0D1B0F),
        inversePrimary: primary,
        surfaceContainerLowest: _darkBg,
        surfaceContainerLow: _darkSurface,
        surfaceContainer: _darkCard,
        surfaceContainerHigh: _darkCardHigh,
        surfaceContainerHighest: _darkCardHigh,
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: _darkColorScheme,
        textTheme: textTheme,
        scaffoldBackgroundColor: _darkBg,
        appBarTheme: AppBarTheme(
          backgroundColor: _darkSurface,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: primaryFixed,
          ),
          iconTheme: const IconThemeData(color: Color(0xFFE8EDE8)),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: _darkSurface,
          selectedItemColor: primaryFixed,
          unselectedItemColor: const Color(0xFF9CAE9C),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryFixed,
            foregroundColor: onPrimaryFixed,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9999),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryFixed,
            side: const BorderSide(color: Color(0xFF2D4A33)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _darkCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusXl),
            borderSide: const BorderSide(color: Color(0xFF2D4A33), width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusXl),
            borderSide: const BorderSide(color: Color(0xFF2D4A33), width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusXl),
            borderSide: const BorderSide(color: primaryFixed, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF9CAE9C),
            fontWeight: FontWeight.w500,
          ),
        ),
        cardTheme: CardThemeData(
          color: _darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius2xl),
          ),
          clipBehavior: Clip.antiAlias,
        ),
      );
}
