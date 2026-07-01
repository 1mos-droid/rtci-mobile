import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CustomLogoLoader extends StatelessWidget {
  final double size;
  final String? message;

  const CustomLogoLoader({
    super.key,
    this.size = 80,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Spinning glow ring
              Container(
                width: size + 20,
                height: size + 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      colorScheme.primary.withOpacity(0),
                      colorScheme.secondary,
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0),
                    ],
                  ),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: 2.seconds),

              // Blurred mask for the ring
              Container(
                width: size + 16,
                height: size + 16,
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  shape: BoxShape.circle,
                ),
              ),

              // The Logo
              Container(
                width: size,
                height: size,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/church_logo.png',
                  fit: BoxFit.contain,
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scaleXY(begin: 0.9, end: 1.05, duration: 1.seconds, curve: Curves.easeInOut),
            ],
          ),
          if (message != null) ...[
            const SizedBox(height: 24),
            Text(
              message!.toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                letterSpacing: 3.0,
                fontWeight: FontWeight.w900,
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .fadeIn(duration: 1.seconds),
          ],
        ],
      ),
    );
  }
}
