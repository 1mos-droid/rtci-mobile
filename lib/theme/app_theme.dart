import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ObsidianTheme {
  static const Color backgroundDark = Color(0xFF050505);
  static const Color surfaceDark = Color(0xFF0F0F11);
  static const Color primaryCrimson = Color(0xFF8B1E31);
  static const Color secondaryGold = Color(0xFFEAB308);
  static const Color textVibrant = Color(0xFFF8F9FA);
  static const Color textMuted = Color(0xFF88888E);
  static const Color borderHairline = Color(0x14FFFFFF); // rgba(255,255,255,0.08)

  // Compatibility Mappings for older code
  static const Color primaryMidnight = primaryCrimson;
  static const Color crimsonSoft = primaryCrimson;
  static const Color backgroundLight = backgroundDark;
  static const Color surfaceWhite = surfaceDark;
  static const Color borderLight = borderHairline;
  static const Color textDark = textVibrant;
  static const Color accentGoldLight = Color(0x25EAB308);
  static const Color accentSage = secondaryGold;

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
