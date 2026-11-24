import 'package:flutter/material.dart';

/// Quiet canvas shared by the feature screens.
class MeshGradientBackground extends StatelessWidget {
  final Widget child;
  const MeshGradientBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: SafeArea(bottom: false, child: child),
  );
}
