import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rtc_mobile/theme/app_theme.dart';

class StartupLoaderScreen extends StatelessWidget {
  final String message;

  const StartupLoaderScreen({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Detect if we are running under a widget test
    final isTest = Platform.environment.containsKey('FLUTTER_TEST');

    final bgColor = isDark ? AppTheme.systemDarkBg : AppTheme.systemLightBg;
    final primaryAccent = AppTheme.iosPrimaryLight;
    final secondaryAccent = AppTheme.accentGold;

    // 1. Sweep Ring (Gold)
    Widget sweepRing = SizedBox(
      width: 146,
      height: 146,
      child: CircularProgressIndicator(
        strokeWidth: 4.5,
        value: isTest ? 0.75 : null,
        valueColor: AlwaysStoppedAnimation<Color>(secondaryAccent),
        backgroundColor: Colors.transparent,
      ),
    );
    if (!isTest) {
      sweepRing = sweepRing
          .animate(onPlay: (controller) => controller.repeat())
          .rotate(duration: 1.5.seconds);
    }

    // 2. Opposite Ring (Crimson)
    Widget crimsonRing = SizedBox(
      width: 136,
      height: 136,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        value: isTest ? 0.35 : null,
        valueColor: AlwaysStoppedAnimation<Color>(primaryAccent),
        backgroundColor: Colors.transparent,
      ),
    );
    if (!isTest) {
      crimsonRing = crimsonRing
          .animate(onPlay: (controller) => controller.repeat())
          .rotate(duration: 2.seconds, begin: 1.0, end: 0.0);
    }

    // 3. Central Logo Container
    Widget logoContainer = Container(
      width: 110,
      height: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151B2C) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: secondaryAccent.withOpacity(0.2),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          'assets/church_logo.png',
          fit: BoxFit.contain,
        ),
      ),
    );
    if (!isTest) {
      logoContainer = logoContainer
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scaleXY(
            begin: 0.96,
            end: 1.04,
            duration: 1.2.seconds,
            curve: Curves.easeInOut,
          );
    }

    // 4. Welcome text widgets
    Widget primaryText = Text(
      "REDEEMED TRANSFORMATION",
      style: GoogleFonts.cinzel(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
        color: isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF0F172A),
      ),
    );
    if (!isTest) {
      primaryText = primaryText.animate().fadeIn(duration: 600.ms);
    }

    Widget secondaryText = Text(
      "CHAPEL INTERNATIONAL",
      style: GoogleFonts.cinzel(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        color: secondaryAccent,
      ),
    );
    if (!isTest) {
      secondaryText = secondaryText.animate().fadeIn(delay: 200.ms, duration: 600.ms);
    }

    // 5. Dynamic loading message
    Widget messageWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151B2C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Text(
        message.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: primaryAccent,
        ),
      ),
    );
    if (!isTest) {
      messageWidget = messageWidget
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .fadeIn(duration: 1.seconds);
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring track
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF151B2C).withOpacity(0.5) : Colors.black.withOpacity(0.01),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02),
                      width: 1.0,
                    ),
                  ),
                ),

                // Inset circle
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F1423) : Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                ),

                sweepRing,
                crimsonRing,
                logoContainer,
              ],
            ),
            const SizedBox(height: 48),

            primaryText,
            const SizedBox(height: 6),
            secondaryText,
            