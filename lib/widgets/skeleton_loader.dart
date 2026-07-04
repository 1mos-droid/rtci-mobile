import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rtc_mobile/theme/app_theme.dart';

class SkeletonContainer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonContainer({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF2E3142) : const Color(0xFFD8DEE9);
    final highlightColor = isDark ? const Color(0xFF3B4056) : const Color(0xFFE5E9F0);

    // Disable shimmer timers in test environments to avoid pending timer assertions
    final isTest = Platform.environment.containsKey('FLUTTER_TEST');

    Widget container = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),