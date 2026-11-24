import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A single orbit around the church seal; static when reduced motion is enabled.
class CustomLogoLoader extends StatefulWidget {
  final double size;
  final String? message;
  const CustomLogoLoader({super.key, this.size = 80, this.message});
  @override
  State<CustomLogoLoader> createState() => _CustomLogoLoaderState();
}

class _CustomLogoLoaderState extends State<CustomLogoLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbit = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) || !TickerMode.of(context)) {
      _orbit.stop();
    } else {
      _orbit.repeat();
    }
  }

  @override
  void dispose() {
    _orbit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: widget.message ?? 'Loading',
      liveRegion: true,
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: widget.size + 32,
            height: widget.size + 32,
            child: AnimatedBuilder(
              animation: _orbit,
              builder: (context, child) => CustomPaint(
                painter: _OrbitPainter(
                  _orbit.value,
                  theme.colorScheme.primary,
                  theme.colorScheme.outlineVariant,
                ),
                child: child,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/church_logo.png',
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 24),
            Text(
              widget.message!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  final double progress;
  final Color color, track;
  _OrbitPainter(this.progress, this.color, this.track);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(3);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawOval(rect, paint..color = track.withValues(alpha: .5));
    canvas.drawArc(
      rect,
      progress * math.pi * 2 - math.pi / 2,
      math.pi * .55,
      false,
      paint
        ..color = color
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_OrbitPainter old) =>
      old.progress != progress || old.color != color || old.track != track;
}
