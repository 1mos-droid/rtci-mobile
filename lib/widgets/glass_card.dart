import 'package:flutter/material.dart';

enum GlassBorderType { normal, gold, crimson }

/// Solid, legible surface. Legacy arguments keep feature screens compatible.
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
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.borderType = GlassBorderType.normal,
    this.blur = 0,
    this.opacity = 1,
    this.color,
  });
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: color ?? scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(
          color: borderType == GlassBorderType.normal
              ? scheme.outlineVariant.withValues(alpha: .45)
              : (borderType == GlassBorderType.gold
                        ? scheme.secondary
                        : scheme.primary)
                    .withValues(alpha: .4),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
