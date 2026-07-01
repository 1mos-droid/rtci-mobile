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
              Icons.home_rounded,
              size: 400,
              color: isDark ? Colors.white : colorScheme.primary,
            ),
          ),
        ),
        
        // Faded Logo - Center
        Positioned.fill(
          child: Opacity(
            opacity: isDark ? 0.08 : 0.04,
            child: Center(
              child: Image.asset(
                'assets/church_logo.png',
                width: MediaQuery.of(context).size.width * 0.7,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        
        // Content
        child,
      ],
    );
  }
}

