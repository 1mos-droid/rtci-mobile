import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand & Palette Colors
  static const Color systemLightBg = Color(0xFFFAFAFC); // Clean off-white
  static const Color systemDarkBg = Color(0xFF0B0F19);  // Premium obsidian dark
  
  static const Color systemLightGroupedBg = Colors.white;
  static const Color systemDarkGroupedBg = Color(0xFF151B2C); // Deep navy/slate

  static const Color iosPrimaryLight = Color(0xFFA81D32); // Crimson Red
  static const Color iosPrimaryDark = Color(0xFFA81D32);  // Crimson Red
  static const Color accentGold = Color(0xFFD4AF37);      // Warm Gold

  static const Color systemGray = Color(0xFF64748B); // Slate Gray
  static const Color systemGray2 = Color(0xFF94A3B8);
  static const Color systemGray3 = Color(0xFFCBD5E1);
  static const Color systemGray4 = Color(0xFFE2E8F0);
  static const Color systemGray5 = Color(0xFFF1F5F9);
  static const Color systemGray6 = Color(0xFFF8FAFC);

  static const Color systemBlue = Color(0xFF2563EB);
  static const Color systemGreen = Color(0xFF16A34A);
  static const Color systemOrange = Color(0xFFEA580C);
  static const Color systemPink = Color(0xFFDB2777);
  static const Color systemPurple = Color(0xFF7C3AED);
  static const Color systemTeal = Color(0xFF0D9488);
  static const Color systemYellow = Color(0xFFCA8A04);
  static const Color systemRed = Color(0xFFDC2626);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: iosPrimaryLight,
        brightness: Brightness.light,
        primary: iosPrimaryLight,
        secondary: accentGold,
        surface: systemLightGroupedBg,
        surfaceContainerHighest: systemGray5,
        onSurface: const Color(0xFF0F172A),
        error: systemRed,
      ),
      scaffoldBackgroundColor: systemLightBg,
      textTheme: _textTheme(const Color(0xFF0F172A), systemGray),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: systemLightBg.withOpacity(0.9),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: _getTextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
          letterSpacing: -0.4,
        ),
        iconTheme: const IconThemeData(color: iosPrimaryLight),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: systemLightGroupedBg,
      ),
      dividerTheme: DividerThemeData(
        thickness: 1.0,
        color: systemGray4,
        indent: 16,
        endIndent: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: iosPrimaryLight,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          textStyle: _getTextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: iosPrimaryLight,
          side: const BorderSide(color: iosPrimaryLight, width: 1.5),
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          textStyle: _getTextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 0.1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: systemGray3, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: systemGray4, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: iosPrimaryLight, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: systemRed, width: 1.0),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: iosPrimaryDark,
        brightness: Brightness.dark,
        primary: iosPrimaryDark,
        surface: systemDarkGroupedBg,
        surfaceContainerHighest: Color(0xFF2C2C2E),
        onSurface: Colors.white,
        error: const Color(0xFFFF453A),
      ),
      scaffoldBackgroundColor: systemDarkBg,
      textTheme: _textTheme(Colors.white, systemGray),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: systemDarkBg.withOpacity(0.8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: -0.4,
        ),
        iconTheme: const IconThemeData(color: iosPrimaryDark),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: systemDarkGroupedBg,
      ),
      dividerTheme: DividerThemeData(
        thickness: 0.5,
        color: Colors.white.withOpacity(0.15),
        indent: 16,
        endIndent: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: iosPrimaryDark,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            letterSpacing: -0.4,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: iosPrimaryDark,
          side: const BorderSide(color: iosPrimaryDark, width: 1.5),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            letterSpacing: -0.4,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: systemDarkGroupedBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: iosPrimaryDark, width: 1.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(color: systemGray, fontSize: 17),
        hintStyle: TextStyle(color: systemGray2, fontSize: 17),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }

  static TextTheme _textTheme(Color primaryColor, Color secondaryColor) {
    return TextTheme(
      displayLarge: GoogleFonts.inter(
        color: primaryColor,
        fontSize: 34,
        fontWeight: FontWeight.bold,
        letterSpacing: -1.0,
      ),
      displayMedium: GoogleFonts.inter(
        color: primaryColor,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.8,
      ),
      displaySmall: GoogleFonts.inter(
        color: primaryColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.6,
      ),
      headlineMedium: GoogleFonts.inter(
        color: primaryColor,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      titleLarge: GoogleFonts.inter(
        color: primaryColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
      ),
      titleMedium: GoogleFonts.inter(
        color: primaryColor,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
      ),
      bodyLarge: GoogleFonts.inter(
        color: primaryColor,
        fontSize: 17,
        letterSpacing: -0.4,
      ),
      bodyMedium: GoogleFonts.inter(
        color: primaryColor,
        fontSize: 15,
        letterSpacing: -0.2,
      ),
      bodySmall: GoogleFonts.inter(
        color: secondaryColor,
        fontSize: 13,
        letterSpacing: -0.1,
      ),
      labelLarge: GoogleFonts.inter(
        color: primaryColor,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.0,
      ),
    );
  }
}

class AdaptiveColor extends Color {
  final int lightValue;
  final int darkValue;

  const AdaptiveColor(this.lightValue, this.darkValue) : super(lightValue);

  @override
  int get value => ObsidianTheme.isDark ? darkValue : lightValue;
}

class ObsidianTheme {
  static ThemeMode currentThemeMode = ThemeMode.system;

  static bool get isDark {
    if (currentThemeMode == ThemeMode.dark) return true;
    if (currentThemeMode == ThemeMode.light) return false;
    try {
      final binding = WidgetsBinding.instance;
      final brightness = binding.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    } catch (_) {
      return false;
    }
  }

  static Color get backgroundDark => isDark ? const Color(0xFF050505) : const Color(0xFFF2F2F7);
  static Color get surfaceDark => isDark ? const Color(0xFF0F0F11) : const Color(0xFFFFFFFF);
  static Color get primaryCrimson => isDark ? const Color(0xFF8B1E31) : const Color(0xFFC92A3E);
  static Color get secondaryGold => const Color(0xFFEAB308);
  static Color get textVibrant => isDark ? const Color(0xFFF8F9FA) : const Color(0xFF1C1C1E);
  static Color get textMuted => isDark ? const Color(0xFF88888E) : const Color(0xFF6C6C70);
  static Color get borderHairline => isDark ? const Color(0x14FFFFFF) : const Color(0x1F000000);

  // Compatibility Mappings for older code
  static Color get primaryMidnight => primaryCrimson;
  static Color get crimsonSoft => primaryCrimson;
  static Color get backgroundLight => backgroundDark;
  static Color get surfaceWhite => surfaceDark;
  static Color get borderLight => borderHairline;
  static Color get textDark => textVibrant;
  static Color get accentGoldLight => isDark ? const Color(0x14FFFFFF) : const Color(0x25EAB308);
  static Color get accentSage => secondaryGold;
}