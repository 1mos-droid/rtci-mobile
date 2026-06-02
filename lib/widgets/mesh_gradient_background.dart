import 'package:flutter/material.dart';

class MeshGradientBackground extends StatelessWidget {
  final Widget child;

  const MeshGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base OLED Background
        Container(
          color: const Color(0xFF050505),
        ),
        // Crimson Orb (Top Left)
        Positioned(
          top: -150,
          left: -150,
          child: Container(
            width: 400,
            height: 400,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color(0x258B1E31), // Deep Crimson 15%
                  Colors.transparent,
                ],
                stops: [0.0, 1.0],
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
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color(0x15EAB308), // Pale Gold 8%
                  Colors.transparent,
                ],
                stops: [0.0, 1.0],
              ),
            ),
          ),
        ),
        // Noise Texture Overlay (Optional, using a semi-transparent black for depth if no image is available)
        Container(
          color: Colors.black.withValues(alpha: 0.1),
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
