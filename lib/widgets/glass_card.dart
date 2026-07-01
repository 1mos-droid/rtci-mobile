import 'dart:ui';
import 'package:flutter/material.dart';

enum GlassBorderType { normal, gold, crimson }

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final GlassBorderType borderType;
  final double blur;
  final double opacity;
  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 12.0, // Standard iOS Card Radius
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
    this.borderType = GlassBorderType.normal,
    this.blur = 20.0, // iOS System Material Blur
    this.opacity = 0.08,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color borderColor;
    switch (borderType) {
      case GlassBorderType.gold:
        borderColor = const Color(0xFFEAB308).withOpacity(0.4);
        break;
      case GlassBorderType.crimson:
        borderColor = theme.colorScheme.primary.withOpacity(0.4);
        break;
      default:
        borderColor = isDark 
            ? Colors.white.withOpacity(0.12) 
            : Colors.black.withOpacity(0.08);
    }

    final cardColor = color ?? (isDark 
        ? const Color(0xFF1C1C1E).withOpacity(0.7) // iOS Thick Material Dark
        : Colors.white.withOpacity(0.6)); // iOS Thick Material Light

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor,
                width: 0.5, // Hairline border characteristic of iOS
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
