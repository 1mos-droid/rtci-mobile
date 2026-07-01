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
      gradient = LinearGradient(
        colors: isDark 
          ? [const Color(0xFF2C2C2E), const Color(0xFF1C1C1E)]
          : [const Color(0xFFE5E5EA), const Color(0xFFD1D1D6)],
      );
      textCol = isDark ? Colors.white24 : Colors.black26;
      borderCol = Colors.transparent;
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: textCol.withOpacity(0.8),
              ),
            ),
          )
        else if (widget.icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(widget.icon, size: 20, color: textCol),
          ),
        Text(
          widget.text,
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: textCol,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );


    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
        onTap: widget.isLoading ? null : widget.onPressed,
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
            border: borderCol != Colors.transparent ? Border.all(color: borderCol, width: 1.5) : null,
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
