import 'package:flutter/material.dart';
import 'package:rtc_mobile/theme/app_theme.dart';

class MeshGradientBackground extends StatelessWidget {
  final Widget child;

  const MeshGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // Base Background
        Container(
          color: theme.scaffoldBackgroundColor,
        ),
        // Crimson Orb (Top Left)
        Positioned(
          top: -150,
          left: -150,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  ObsidianTheme.primaryCrimson.withValues(alpha: isDark ? 0.15 : 0.06),
                  Colors.transparent,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
        // Gold Orb (Bottom Right)
        Positioned(
          bottom: -200,
          right: -150,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  ObsidianTheme.secondaryGold.withValues(alpha: isDark ? 0.08 : 0.03),
                  Colors.transparent,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
        // Faded Church Logo watermark
        Positioned.fill(
          child: Opacity(
            opacity: isDark ? 0.05 : 0.02,
            child: Center(
              child: Image.asset(
                'assets/church_logo.png',
                width: MediaQuery.of(context).size.width * 0.65,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        // Overlay for depth
        Container(
          color: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.05 : 0.1),
        ),
        // Content
        SafeArea(
          bottom: false,
          child: child,
        ),
      ],
    );
  }
}
