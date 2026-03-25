import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Studio Aurora — warm coral typography accents, deep ink surfaces, teal highlights.
abstract final class AppTheme {
  // —— Core palette ————————————————————————————————————————————
  static const Color coral = Color(0xFFFF5E3A);
  static const Color coralDeep = Color(0xFFE03E1F);
  static const Color amber = Color(0xFFFFB35C);
  static const Color teal = Color(0xFF00C9B7);
  static const Color tealDeep = Color(0xFF009688);
  static const Color violet = Color(0xFF9D7BFF);

  static const Color ink0 = Color(0xFF050607);
  static const Color ink1 = Color(0xFF0C0F14);
  static const Color ink2 = Color(0xFF151A22);
  static const Color ink3 = Color(0xFF1E2530);

  static const Color canvas = Color(0xFFF4F1EC);
  static const Color paper = Color(0xFFFFFFFF);
  static const Color inkMuted = Color(0xFF5C6570);
  static const Color inkBody = Color(0xFF1B2329);

  /// Legacy alias — use [coral] for branding accents.
  static const Color primaryColor = coral;

  // —— Gradients ————————————————————————————————————————————————
  static const LinearGradient accentGradient = LinearGradient(
    colors: [coral, amber],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [teal, Color(0xFF00E5D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient violetCoral = LinearGradient(
    colors: [violet, coral],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Dark-mode full-page backdrop
  static const LinearGradient pageDark = LinearGradient(
    colors: [ink1, Color(0xFF0A1210), ink0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.45, 1.0],
  );

  /// Light-mode full-page backdrop
  static const LinearGradient pageLight = LinearGradient(
    colors: [Color(0xFFFFFBF7), canvas, Color(0xFFE8F5F3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient morningMistGradient = pageLight;

  /// Browse category tiles (dark)
  static const LinearGradient categorySunset = LinearGradient(
    colors: [Color(0xFFFF5E3A), Color(0xFFFF8A5C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient categoryOcean = LinearGradient(
    colors: [Color(0xFF008C8C), teal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient categoryViolet = LinearGradient(
    colors: [Color(0xFF6B4EE6), violet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Browse category tiles (light — soft)
  static const LinearGradient categorySunsetSoft = LinearGradient(
    colors: [Color(0xFFFFE4D6), Color(0xFFFFD0B8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient categoryOceanSoft = LinearGradient(
    colors: [Color(0xFFCFF5F0), Color(0xFFB8EBE5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient categoryVioletSoft = LinearGradient(
    colors: [Color(0xFFE8E0FF), Color(0xFFD9CCFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = accentGradient;

  static const LinearGradient deepBlueGradient = categoryViolet;
  static const LinearGradient purpleHazeGradient = categoryViolet;
  static const LinearGradient oceanBreezeGradient = categoryOcean;
  static const LinearGradient softBlueGradient = categoryOceanSoft;
  static const LinearGradient softPinkGradient = categoryVioletSoft;

  static LinearGradient glassSheen(Brightness b) => LinearGradient(
        colors: b == Brightness.dark
            ? [Colors.white.withValues(alpha: 0.14), Colors.white.withValues(alpha: 0.04)]
            : [Colors.white.withValues(alpha: 0.95), Colors.white.withValues(alpha: 0.65)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static TextTheme _darkText(TextTheme base) {
    final dm = GoogleFonts.dmSansTextTheme(base);
    return dm.copyWith(
      displaySmall: GoogleFonts.sora(textStyle: dm.displaySmall, fontWeight: FontWeight.w700, letterSpacing: -1.2),
      headlineMedium: GoogleFonts.sora(textStyle: dm.headlineMedium, fontWeight: FontWeight.w700, letterSpacing: -0.8),
      headlineSmall: GoogleFonts.sora(textStyle: dm.headlineSmall, fontWeight: FontWeight.w600, letterSpacing: -0.5),
      titleLarge: GoogleFonts.sora(textStyle: dm.titleLarge, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.dmSans(textStyle: dm.titleMedium, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.dmSans(textStyle: dm.bodyLarge, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.dmSans(textStyle: dm.bodyMedium, fontWeight: FontWeight.w500),
      bodySmall: GoogleFonts.dmSans(textStyle: dm.bodySmall, color: Colors.white70),
      labelLarge: GoogleFonts.dmSans(textStyle: dm.labelLarge, fontWeight: FontWeight.w600, letterSpacing: 0.2),
    );
  }

  static TextTheme _lightText(TextTheme base) {
    final dm = GoogleFonts.dmSansTextTheme(base);
    return dm.copyWith(
      displaySmall: GoogleFonts.sora(textStyle: dm.displaySmall, fontWeight: FontWeight.w700, letterSpacing: -1.2, color: inkBody),
      headlineMedium: GoogleFonts.sora(textStyle: dm.headlineMedium, fontWeight: FontWeight.w700, letterSpacing: -0.8, color: inkBody),
      headlineSmall: GoogleFonts.sora(textStyle: dm.headlineSmall, fontWeight: FontWeight.w600, letterSpacing: -0.5, color: inkBody),
      titleLarge: GoogleFonts.sora(textStyle: dm.titleLarge, fontWeight: FontWeight.w600, color: inkBody),
      titleMedium: GoogleFonts.dmSans(textStyle: dm.titleMedium, fontWeight: FontWeight.w600, color: inkBody),
      bodyLarge: GoogleFonts.dmSans(textStyle: dm.bodyLarge, color: inkBody),
      bodyMedium: GoogleFonts.dmSans(textStyle: dm.bodyMedium, color: inkBody),
      bodySmall: GoogleFonts.dmSans(textStyle: dm.bodySmall, color: inkMuted),
      labelLarge: GoogleFonts.dmSans(textStyle: dm.labelLarge, fontWeight: FontWeight.w600, letterSpacing: 0.2),
    );
  }

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ink0,
    canvasColor: ink1,
    primaryColor: coral,
    visualDensity: VisualDensity.standard,
    colorScheme: ColorScheme.fromSeed(
      seedColor: coral,
      brightness: Brightness.dark,
    ).copyWith(
      primary: coral,
      onPrimary: Colors.white,
      primaryContainer: coralDeep,
      onPrimaryContainer: Colors.white,
      secondary: teal,
      onSecondary: ink0,
      secondaryContainer: ink3,
      onSecondaryContainer: Colors.white,
      tertiary: amber,
      onTertiary: ink0,
      tertiaryContainer: const Color(0xFF3D3118),
      onTertiaryContainer: amber,
      error: const Color(0xFFFF6B8A),
      onError: Colors.white,
      surface: ink2,
      onSurface: Colors.white,
      onSurfaceVariant: const Color(0xFFB8C0CC),
      surfaceContainerHighest: ink3,
      surfaceContainerHigh: ink3.withValues(alpha: 0.85),
      outline: Colors.white.withValues(alpha: 0.12),
      outlineVariant: Colors.white.withValues(alpha: 0.06),
      shadow: Colors.black.withValues(alpha: 0.45),
    ),
    textTheme: _darkText(ThemeData(brightness: Brightness.dark).textTheme),
    iconTheme: IconThemeData(color: Colors.white.withValues(alpha: 0.92)),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white.withValues(alpha: 0.95)),
      titleTextStyle: GoogleFonts.sora(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: CardThemeData(
      color: ink2,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ink3.withValues(alpha: 0.65),
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.38)),
      prefixIconColor: teal,
      suffixIconColor: Colors.white60,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: coral, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: coral,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: coral,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: ink3,
      contentTextStyle: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: ink2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      titleTextStyle: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),
      contentTextStyle: GoogleFonts.dmSans(color: Colors.white.withValues(alpha: 0.85), fontSize: 15),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: coral, linearTrackColor: Color(0xFF2A303C)),
    dividerTheme: DividerThemeData(color: Colors.white.withValues(alpha: 0.08)),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: ink2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: canvas,
    canvasColor: canvas,
    primaryColor: coral,
    visualDensity: VisualDensity.standard,
    colorScheme: ColorScheme.fromSeed(
      seedColor: coral,
      brightness: Brightness.light,
    ).copyWith(
      primary: coral,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFFFD4C8),
      onPrimaryContainer: const Color(0xFF5C1A0A),
      secondary: tealDeep,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFB8EBE5),
      onSecondaryContainer: const Color(0xFF003D38),
      tertiary: const Color(0xFFD97706),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFFFE7C2),
      onTertiaryContainer: const Color(0xFF5C3D00),
      error: const Color(0xFFDC2626),
      onError: Colors.white,
      surface: paper,
      onSurface: inkBody,
      onSurfaceVariant: inkMuted,
      surfaceContainerHighest: const Color(0xFFEAE6E0),
      outline: const Color(0xFFD4CEC4),
      outlineVariant: const Color(0xFFEBE7E1),
      shadow: Colors.black.withValues(alpha: 0.08),
    ),
    textTheme: _lightText(ThemeData(brightness: Brightness.light).textTheme),
    iconTheme: IconThemeData(color: inkBody.withValues(alpha: 0.88)),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: inkBody),
      titleTextStyle: GoogleFonts.sora(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: inkBody,
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: CardThemeData(
      color: paper,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: const Color(0xFFE5E0D8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: paper,
      hintStyle: TextStyle(color: inkMuted.withValues(alpha: 0.65)),
      prefixIconColor: coral,
      suffixIconColor: inkMuted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: const Color(0xFFE1DCD4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: const Color(0xFFE1DCD4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: coral, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: coral,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: coral,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: inkBody,
      contentTextStyle: GoogleFonts.dmSans(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: paper,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: GoogleFonts.sora(color: inkBody, fontWeight: FontWeight.w600, fontSize: 20),
      contentTextStyle: GoogleFonts.dmSans(color: inkMuted, fontSize: 15),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: coral, linearTrackColor: Color(0xFFE8E3DC)),
    dividerTheme: DividerThemeData(color: inkBody.withValues(alpha: 0.08)),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
  );
}

