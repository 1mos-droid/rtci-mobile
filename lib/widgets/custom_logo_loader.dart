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
