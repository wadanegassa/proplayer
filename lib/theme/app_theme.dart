import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Neumorphic "Soft UI" — deep charcoal surfaces, 3D shadows, vibrant orange accents.
abstract final class AppTheme {
  // —— Neumorphic Colors ——————————————————————————————————————
  static const Color background = Color(0xFF18191B);
  static const Color lightShadow = Color(0xFF222327);
  static const Color darkShadow = Color(0xFF0E0E10);
  
  static const Color brand = Color(0xFFFF5F2E); // Vibrant Orange
  static const Color brandSecondary = Color(0xFFF53C11); // Deep Orange

  // —— Gradients —————————————————————————————————————————————
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF5F2E), Color(0xFFF53C11)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient playingItemGradient = LinearGradient(
    colors: [Color(0xFF222327), Color(0xFF18191B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // —— Neumorphic Shadow Tokens ————————————————————————————————
  static List<BoxShadow> elevated({double distance = 8, double blur = 16}) => [
    BoxShadow(
      color: lightShadow,
      offset: Offset(-distance, -distance),
      blurRadius: blur,
    ),
    BoxShadow(
      color: darkShadow,
      offset: Offset(distance, distance),
      blurRadius: blur,
    ),
  ];

  // Page backgrounds for AppShellBackground support
  static const Color pageDark = background;
  static const Color pageLight = Color(0xFFF0F0F3); // Soft white for light mode support if needed

  // Helper for inner shadows since Flutter's BoxShadow doesn't natively support 'inset' 
  // without a package or custom painter. We'll use custom containers for recessed looks.

  static TextTheme _textTheme(TextTheme base, Color textColor) {
    final t = GoogleFonts.interTextTheme(base);
    return t.copyWith(
      displaySmall: GoogleFonts.inter(
        textStyle: t.displaySmall,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.inter(
        textStyle: t.headlineMedium,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: textColor,
      ),
      titleLarge: GoogleFonts.inter(
        textStyle: t.titleLarge,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      titleMedium: GoogleFonts.inter(
        textStyle: t.titleMedium,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.inter(
        textStyle: t.bodyLarge,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.inter(
        textStyle: t.bodyMedium,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelLarge: GoogleFonts.inter(
        textStyle: t.labelLarge,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
    );
  }

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    canvasColor: background,
    primaryColor: brand,
    colorScheme: ColorScheme.dark(
      primary: brand,
      secondary: brandSecondary,
      surface: background,
      onSurface: Colors.white,
      onSurfaceVariant: Colors.white70,
    ),
    textTheme: _textTheme(ThemeData.dark().textTheme, Colors.white),
    iconTheme: const IconThemeData(color: Colors.white70),
    sliderTheme: SliderThemeData(
      activeTrackColor: brand,
      inactiveTrackColor: darkShadow,
      thumbColor: brand,
      overlayColor: brand.withValues(alpha: 0.2),
      trackHeight: 4,
    ),
  );
}
