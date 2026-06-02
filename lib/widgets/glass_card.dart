import 'dart:ui';
import 'package:flutter/material.dart';

enum GlassBorderType { normal, gold, crimson }

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final GlassBorderType borderType;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24.0,
    this.padding = const EdgeInsets.all(24.0),
    this.onTap,
    this.borderType = GlassBorderType.normal,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    switch (borderType) {
      case GlassBorderType.gold:
        borderColor = const Color(0xFFEAB308).withValues(alpha: 0.3);
        break;
      case GlassBorderType.crimson:
        borderColor = const Color(0xFF8B1E31).withValues(alpha: 0.3);
        break;
      default:
        borderColor = const Color(0x14FFFFFF);
    }

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                )
              ]
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
