import 'package:flutter/material.dart';

/// A quiet placeholder that follows the local theme and motion preference.
class SkeletonContainer extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  const SkeletonContainer({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
  });
  @override
  State<SkeletonContainer> createState() => _SkeletonContainerState();
}

class _SkeletonContainerState extends State<SkeletonContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) || !TickerMode.of(context)) {
      _pulse.stop();
      _pulse.value = 0;
    } else {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, _) => DecoratedBox(
          decoration: BoxDecoration(
            color: Color.lerp(
              scheme.surfaceContainerHighest,
              scheme.surfaceContainerLow,
              _pulse.value,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: SizedBox(width: widget.width, height: widget.height),
        ),
      ),
    );
  }
}
