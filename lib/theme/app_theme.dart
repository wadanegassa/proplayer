import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Minimal “Slate & Sky” — cool neutrals, one crisp accent, simple surfaces.
abstract final class AppTheme {
  // —— Brand ————————————————————————————————————————————————
  static const Color brand = Color(0xFF38BDF8);
  static const Color brandMuted = Color(0xFF7DD3FC);
  static const Color brandDeep = Color(0xFF0EA5E9);

  /// Legacy names (older screens) map to brand.
  static const Color coral = brand;
  static const Color coralDeep = brandDeep;
  static const Color teal = Color(0xFF34D399);
  static const Color tealDeep = Color(0xFF10B981);
  static const Color violet = Color(0xFFA78BFA);
  static const Color amber = Color(0xFFFBBF24);

  // —— Dark surfaces —————————————————————————————————————————
  static const Color slate950 = Color(0xFF020617);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate600 = Color(0xFF475569);

  static const Color ink0 = slate950;
  static const Color ink1 = slate900;
  static const Color ink2 = slate800;
  static const Color ink3 = slate700;

  // —— Light surfaces ————————————————————————————————————————
  static const Color cloud = Color(0xFFF8FAFC);
  static const Color paper = Color(0xFFFFFFFF);
  static const Color line = Color(0xFFE2E8F0);
  static const Color lineStrong = Color(0xFFCBD5E1);

  static const Color canvas = cloud;
  static const Color inkBody = Color(0xFF0F172A);
  static const Color inkMuted = Color(0xFF64748B);

  // —— Gradients (subtle — use sparingly) ——————————————————————
  static const LinearGradient accentGradient = LinearGradient(
    colors: [brandDeep, brand],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), brand],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient violetCoral = LinearGradient(
    colors: [violet, brand],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient pageDark = LinearGradient(
    colors: [slate950, slate900],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient pageLight = LinearGradient(
    colors: [paper, cloud],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient morningMistGradient = pageLight;

  // Browse tiles — flat-friendly base + slight depth
  static const LinearGradient categorySunset = LinearGradient(
    colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient categoryOcean = LinearGradient(
    colors: [Color(0xFF0F766E), teal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient categoryViolet = LinearGradient(
    colors: [Color(0xFF5B21B6), violet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient categorySunsetSoft = LinearGradient(
    colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient categoryOceanSoft = LinearGradient(
    colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient categoryVioletSoft = LinearGradient(
    colors: [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
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
            ? [slate800.withValues(alpha: 0.9), slate900.withValues(alpha: 0.95)]
            : [paper, cloud],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static TextTheme _textDark(TextTheme base) {
    final t = GoogleFonts.plusJakartaSansTextTheme(base);
    const on = Color(0xFFF1F5F9);
    const dim = Color(0xFF94A3B8);
    return t.copyWith(
      displaySmall: GoogleFonts.plusJakartaSans(
        textStyle: t.displaySmall,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
        color: on,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        textStyle: t.headlineMedium,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: on,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        textStyle: t.headlineSmall,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        color: on,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        textStyle: t.titleLarge,
        fontWeight: FontWeight.w600,
        color: on,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(textStyle: t.titleMedium, fontWeight: FontWeight.w600, color: on),
      bodyLarge: GoogleFonts.plusJakartaSans(textStyle: t.bodyLarge, fontWeight: FontWeight.w500, color: on),
      bodyMedium: GoogleFonts.plusJakartaSans(textStyle: t.bodyMedium, fontWeight: FontWeight.w500, color: on),
      bodySmall: GoogleFonts.plusJakartaSans(textStyle: t.bodySmall, color: dim),
      labelLarge: GoogleFonts.plusJakartaSans(
        textStyle: t.labelLarge,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: on,
      ),
    );
  }

  static TextTheme _textLight(TextTheme base) {
    final t = GoogleFonts.plusJakartaSansTextTheme(base);
    return t.copyWith(
      displaySmall: GoogleFonts.plusJakartaSans(
        textStyle: t.displaySmall,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
        color: inkBody,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        textStyle: t.headlineMedium,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: inkBody,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        textStyle: t.headlineSmall,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        color: inkBody,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        textStyle: t.titleLarge,
        fontWeight: FontWeight.w600,
        color: inkBody,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(textStyle: t.titleMedium, fontWeight: FontWeight.w600, color: inkBody),
      bodyLarge: GoogleFonts.plusJakartaSans(textStyle: t.bodyLarge, color: inkBody),
      bodyMedium: GoogleFonts.plusJakartaSans(textStyle: t.bodyMedium, color: inkBody),
      bodySmall: GoogleFonts.plusJakartaSans(textStyle: t.bodySmall, color: inkMuted),
      labelLarge: GoogleFonts.plusJakartaSans(
        textStyle: t.labelLarge,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: inkBody,
      ),
    );
  }

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: slate950,
    canvasColor: slate900,
    primaryColor: brand,
    visualDensity: VisualDensity.standard,
    colorScheme: ColorScheme.dark(
      primary: brand,
      onPrimary: slate950,
      primaryContainer: slate800,
      onPrimaryContainer: brandMuted,
      secondary: teal,
      onSecondary: slate950,
      secondaryContainer: slate800,
      onSecondaryContainer: teal,
      tertiary: violet,
      onTertiary: Colors.white,
      error: const Color(0xFFF87171),
      onError: slate950,
      surface: slate900,
      onSurface: const Color(0xFFF1F5F9),
      onSurfaceVariant: const Color(0xFF94A3B8),
      surfaceContainerHighest: slate800,
      surfaceContainerHigh: slate800,
      outline: slate600.withValues(alpha: 0.5),
      outlineVariant: slate700,
      shadow: Colors.black.withValues(alpha: 0.4),
    ),
    textTheme: _textDark(ThemeData(brightness: Brightness.dark).textTheme),
    iconTheme: const IconThemeData(color: Color(0xFFCBD5E1)),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFF1F5F9),
        letterSpacing: -0.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: slate800,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: slate700.withValues(alpha: 0.8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: slate800,
      hintStyle: const TextStyle(color: Color(0xFF64748B)),
      prefixIconColor: brand,
      suffixIconColor: const Color(0xFF94A3B8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: slate700.withValues(alpha: 0.9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: brand, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: brand,
        foregroundColor: slate950,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: brand,
        foregroundColor: slate950,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: brandMuted,
        side: BorderSide(color: slate600.withValues(alpha: 0.8)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: slate800,
      contentTextStyle: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: slate800,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: slate700.withValues(alpha: 0.9)),
      ),
      titleTextStyle: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
      contentTextStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFFCBD5E1), fontSize: 14),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: brand,
      linearTrackColor: slate700,
    ),
    dividerTheme: DividerThemeData(color: slate700.withValues(alpha: 0.6)),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: slate900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: cloud,
    canvasColor: cloud,
    primaryColor: brand,
    visualDensity: VisualDensity.standard,
    colorScheme: ColorScheme.light(
      primary: brandDeep,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFE0F2FE),
      onPrimaryContainer: const Color(0xFF0C4A6E),
      secondary: tealDeep,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFD1FAE5),
      onSecondaryContainer: const Color(0xFF064E3B),
      tertiary: violet,
      onTertiary: Colors.white,
      error: const Color(0xFFDC2626),
      onError: Colors.white,
      surface: paper,
      onSurface: inkBody,
      onSurfaceVariant: inkMuted,
      surfaceContainerHighest: const Color(0xFFF1F5F9),
      outline: line,
      outlineVariant: lineStrong,
      shadow: Colors.black.withValues(alpha: 0.06),
    ),
    textTheme: _textLight(ThemeData(brightness: Brightness.light).textTheme),
    iconTheme: IconThemeData(color: inkBody.withValues(alpha: 0.85)),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: inkBody),
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: inkBody,
        letterSpacing: -0.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: paper,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: line),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: paper,
      hintStyle: TextStyle(color: inkMuted.withValues(alpha: 0.7)),
      prefixIconColor: brandDeep,
      suffixIconColor: inkMuted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: brandDeep, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: brandDeep,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: brandDeep,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: inkBody,
      contentTextStyle: GoogleFonts.plusJakartaSans(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: paper,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: GoogleFonts.plusJakartaSans(color: inkBody, fontWeight: FontWeight.w600, fontSize: 18),
      contentTextStyle: GoogleFonts.plusJakartaSans(color: inkMuted, fontSize: 14),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: brandDeep,
      linearTrackColor: Color(0xFFE2E8F0),
    ),
    dividerTheme: DividerThemeData(color: inkBody.withValues(alpha: 0.08)),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
  );
}
