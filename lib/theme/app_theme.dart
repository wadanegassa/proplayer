import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Midnight & Neon palette
  static const Color primaryColor = Color(0xFF6366F1); // Indigo 500
  static const Color secondaryColor = Color(0xFFD946EF); // Fuchsia 500
  static const Color accentColor = Color(0xFF06B6D4); // Cyan 500
  static const Color backgroundColor = Color(0xFF020617); // Slate 950 (Deepest Navy)
  static const Color surfaceColor = Color(0xFF0F172A); // Slate 900
  static const Color cardColor = Color(0xFF1E293B); // Slate 800
  static const Color errorColor = Color(0xFFF43F5E); // Rose 500
  static const Color successColor = Color(0xFF10B981); // Emerald 500
  
  // Light theme colors (keeping it clean but modern)
  // Light theme colors ("Morning Mist" aesthetic)
  static const Color lightPrimaryColor = Color(0xFF6366F1); // Indigo 500 (Vibrant)
  static const Color lightSecondaryColor = Color(0xFFEC4899); // Pink 500 (Vibrant)
  static const Color lightBackgroundColor = Color(0xFFF8FAFC); // Slate 50 (Soft White)
  static const Color lightSurfaceColor = Color(0xFFFFFFFF); // Pure White
  static const Color lightTextPrimary = Color(0xFF1E293B); // Slate 800
  static const Color lightTextSecondary = Color(0xFF64748B); // Slate 500
  
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundColor,
    primaryColor: primaryColor,
    iconTheme: const IconThemeData(color: Colors.white),
    primaryIconTheme: const IconThemeData(color: Colors.white),
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ).copyWith(
      bodyMedium: GoogleFonts.outfit(color: Colors.white),
      bodySmall: GoogleFonts.outfit(color: Colors.white70),
      titleMedium: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.outfit(color: Colors.white70),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor.withValues(alpha: 0.8),
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
      prefixIconColor: Colors.white70,
      suffixIconColor: Colors.white70,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: backgroundColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
    ),
  );
  
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackgroundColor,
    primaryColor: lightPrimaryColor,
    iconTheme: const IconThemeData(color: lightTextPrimary),
    primaryIconTheme: const IconThemeData(color: lightTextPrimary),
    colorScheme: const ColorScheme.light(
      primary: lightPrimaryColor,
      secondary: lightSecondaryColor,
      surface: lightSurfaceColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: lightTextPrimary,
      onError: Colors.white,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).apply(
      bodyColor: lightTextPrimary,
      displayColor: lightTextPrimary,
    ).copyWith(
      bodyMedium: GoogleFonts.outfit(color: lightTextPrimary),
      bodySmall: GoogleFonts.outfit(color: lightTextSecondary),
      titleMedium: GoogleFonts.outfit(color: lightTextPrimary, fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.outfit(color: lightTextSecondary),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: lightBackgroundColor.withValues(alpha: 0.8),
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: lightTextPrimary),
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: lightTextPrimary,
        letterSpacing: -0.5,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurfaceColor,
      hintStyle: TextStyle(color: lightTextSecondary.withValues(alpha: 0.6)),
      prefixIconColor: lightTextSecondary,
      suffixIconColor: lightTextSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: lightPrimaryColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightSurfaceColor,
      selectedItemColor: lightPrimaryColor,
      unselectedItemColor: lightTextSecondary,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      elevation: 8,
    ),
    cardTheme: CardThemeData(
      color: lightSurfaceColor,
      elevation: 8,
      shadowColor: const Color(0xFF64748B).withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
  );
  
  // Modern Gradient presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentColor, primaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Colors.white12,
      Colors.white10,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient shimmerGradient = LinearGradient(
    colors: [
      Colors.white.withValues(alpha: 0.05),
      Colors.white.withValues(alpha: 0.1),
      Colors.white.withValues(alpha: 0.05),
    ],
  );

  // New Premium Gradients (Dark Mode)
  static const LinearGradient deepBlueGradient = LinearGradient(
    colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleHazeGradient = LinearGradient(
    colors: [Color(0xFF581C87), Color(0xFF7E22CE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient oceanBreezeGradient = LinearGradient(
    colors: [Color(0xFF0E7490), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // New Premium Gradients (Light Mode)
  static const LinearGradient morningMistGradient = LinearGradient(
    colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)], // Slate 50 -> Slate 200
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softBlueGradient = LinearGradient(
    colors: [Color(0xFFE0E7FF), Color(0xFFC7D2FE)], // Indigo 100 -> Indigo 200
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softPinkGradient = LinearGradient(
    colors: [Color(0xFFFCE7F3), Color(0xFFFBCFE8)], // Pink 100 -> Pink 200
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
