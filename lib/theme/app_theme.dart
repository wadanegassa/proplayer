import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  // —— Colors —————————————————————————————————————————————————
  static const Color primary = Color(0xFFFBDD08); // Vibrant Yellow
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  static const Color textMainLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textMainDark = Colors.white;
  static const Color textSecondaryDark = Colors.white70;

  // —— Page backgrounds ———————————————————————————————————————
  static const Color pageLight = backgroundLight;
  static const Color pageDark = backgroundDark;

  static TextTheme _textTheme(TextTheme base, Color textColor, Color secondaryColor) {
    final t = GoogleFonts.outfitTextTheme(base);
    return t.copyWith(
      displayLarge: GoogleFonts.outfit(
        textStyle: t.displayLarge,
        fontWeight: FontWeight.w800,
        color: textColor,
      ),
      displayMedium: GoogleFonts.outfit(
        textStyle: t.displayMedium,
        fontWeight: FontWeight.w800,
        color: textColor,
      ),
      displaySmall: GoogleFonts.outfit(
        textStyle: t.displaySmall,
        fontWeight: FontWeight.w800,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.outfit(
        textStyle: t.headlineMedium,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      titleLarge: GoogleFonts.outfit(
        textStyle: t.titleLarge,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      titleMedium: GoogleFonts.outfit(
        textStyle: t.titleMedium,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.outfit(
        textStyle: t.bodyLarge,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.outfit(
        textStyle: t.bodyMedium,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      labelLarge: GoogleFonts.outfit(
        textStyle: t.labelLarge,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundLight,
    canvasColor: backgroundLight,
    primaryColor: primary,
    colorScheme: const ColorScheme.light(
      primary: primary,
      onPrimary: Colors.black,
      surface: surfaceLight,
      onSurface: textMainLight,
      onSurfaceVariant: textSecondaryLight,
    ),
    textTheme: _textTheme(ThemeData.light().textTheme, textMainLight, textSecondaryLight),
    iconTheme: const IconThemeData(color: textMainLight),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(color: textMainLight, fontWeight: FontWeight.bold, fontSize: 18),
      iconTheme: IconThemeData(color: textMainLight),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    canvasColor: backgroundDark,
    primaryColor: primary,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      onPrimary: Colors.black,
      surface: surfaceDark,
      onSurface: textMainDark,
      onSurfaceVariant: textSecondaryDark,
    ),
    textTheme: _textTheme(ThemeData.dark().textTheme, textMainDark, textSecondaryDark),
    iconTheme: const IconThemeData(color: textMainDark),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(color: textMainDark, fontWeight: FontWeight.bold, fontSize: 18),
      iconTheme: IconThemeData(color: textMainDark),
    ),
  );
}
