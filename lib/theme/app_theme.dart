import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // iOS HIG System Colors
  static const Color systemLightBg = Color(0xFFF2F2F7);
  static const Color systemDarkBg = Color(0xFF000000);
  
  static const Color systemLightGroupedBg = Color(0xFFFFFFFF);
  static const Color systemDarkGroupedBg = Color(0xFF1C1C1E);

  // Vibrant iOS-style Tints
  static const Color iosPrimaryLight = Color(0xFFC92A3E); // Brand Crimson
  static const Color iosPrimaryDark = Color(0xFFFF453A);  // Vibrant Apple-style Red

  static const Color systemGray = Color(0xFF8E8E93);
  static const Color systemGray2 = Color(0xFFAEAEB2);
  static const Color systemGray3 = Color(0xFFC7C7CC);
  static const Color systemGray4 = Color(0xFFD1D1D6);
  static const Color systemGray5 = Color(0xFFE5E5EA);
  static const Color systemGray6 = Color(0xFFF2F2F7);

  static const Color systemBlue = Color(0xFF007AFF);
  static const Color systemGreen = Color(0xFF34C759);
  static const Color systemOrange = Color(0xFFFF9500);
  static const Color systemPink = Color(0xFFFF2D55);
  static const Color systemPurple = Color(0xFFAF52DE);
  static const Color systemTeal = Color(0xFF5AC8FA);
  static const Color systemYellow = Color(0xFFFFCC00);
  static const Color systemRed = Color(0xFFFF3B30);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: iosPrimaryLight,
        brightness: Brightness.light,
        primary: iosPrimaryLight,
        surface: systemLightGroupedBg,
        surfaceContainerHighest: systemGray6,
        onSurface: Colors.black,
        error: const Color(0xFFFF3B30),
      ),
      scaffoldBackgroundColor: systemLightBg,
      textTheme: _textTheme(Colors.black, systemGray),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: systemLightBg.withOpacity(0.8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Colors.black,
          letterSpacing: -0.4,
        ),
        iconTheme: const IconThemeData(color: iosPrimaryLight),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: systemLightGroupedBg,
      ),
      dividerTheme: DividerThemeData(
        thickness: 0.5,
        color: systemGray3.withOpacity(0.5),
        indent: 16,
        endIndent: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: iosPrimaryLight,
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
          foregroundColor: iosPrimaryLight,
          side: const BorderSide(color: iosPrimaryLight, width: 1.5),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            letterSpacing: -0.4,
          ),

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: primaryCrimson,
      colorScheme: const ColorScheme.dark(
        primary: primaryCrimson,
        secondary: secondaryGold,
        surface: backgroundDark,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: textVibrant,
      ),
      dividerColor: borderHairline,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cinzel(
          color: textVibrant,
          fontSize: 48,
          fontWeight: FontWeight.w400,
          letterSpacing: 2.0,
        ),
        displayMedium: GoogleFonts.cinzel(
          color: textVibrant,
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.5,
        ),
        displaySmall: GoogleFonts.cinzel(
          color: textVibrant,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          color: textVibrant,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          color: textVibrant,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.3,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          color: textVibrant,
          fontSize: 16,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          color: textMuted,
          fontSize: 14,
          height: 1.6,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          color: textVibrant,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textVibrant),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: primaryCrimson,
        unselectedItemColor: textMuted,
        selectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCrimson,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textVibrant,
          side: const BorderSide(color: borderHairline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: borderHairline, width: 1),
        ),
      ),
    );
  }
}
