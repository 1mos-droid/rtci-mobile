import 'package:flutter/material.dart';

class LogoBackground extends StatelessWidget {
  final Widget child;

  const LogoBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Stack(
      children: [
        // Background Base with subtle gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark 
                  ? [colorScheme.surface, const Color(0xFF050303)]
                  : [colorScheme.surface, const Color(0xFFFFF5F5)],
              ),
            ),
          ),
        ),
        
        // Church Emblem - Large & Subliminal
        Positioned(
          top: -100,
          right: -100,
          child: Opacity(
            opacity: isDark ? 0.1 : 0.02,
            child: Icon(
