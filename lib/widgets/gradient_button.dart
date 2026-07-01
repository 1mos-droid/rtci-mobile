import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum GradientButtonType { crimson, gold, outline }

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final GradientButtonType type;
  final IconData? icon;
  final double? width;
  final double height;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.type = GradientButtonType.crimson,
    this.icon,
    this.width,
    this.height = 52, // Standard iOS Button Height
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    bool isEnabled = widget.onPressed != null && !widget.isLoading;
    
    Gradient gradient;
    Color borderCol = Colors.transparent;
    Color textCol = Colors.white;
    
    switch (widget.type) {
      case GradientButtonType.gold:
        gradient = const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        textCol = Colors.black;
        break;
      case GradientButtonType.outline:
        gradient = const LinearGradient(colors: [Colors.transparent, Colors.transparent]);
        borderCol = colorScheme.primary.withOpacity(isDark ? 0.5 : 0.8);
        textCol = colorScheme.primary;
        break;
      case GradientButtonType.crimson:
        gradient = LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
        textCol = Colors.white;
        break;
    }

    if (!isEnabled) {
      glowCol = Colors.transparent;
      borderCol = Colors.transparent;
    }

    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(textCol),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: 16, color: textCol),
          const SizedBox(width: 8),
        ],
        Text(
          widget.text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: textCol,
          ),
        ),
      ],
    );

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onPanEnd: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: isEnabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderCol, width: borderCol != Colors.transparent ? 1.0 : 0.0),
            boxShadow: isEnabled && widget.type != GradientButtonType.outline
                ? [
                    BoxShadow(
                      color: glowCol,
                      blurRadius: _isPressed ? 8 : 15,
                      offset: const Offset(0, 5),
                    )
                  ]
                : [],
          ),
          child: Center(child: content),
        ),
      ),
    );
  }
}
