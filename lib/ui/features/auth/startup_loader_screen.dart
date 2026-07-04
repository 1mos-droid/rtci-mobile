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
