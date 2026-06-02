import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rtc_mobile/theme/app_theme.dart';

enum GradientButtonType { crimson, gold, outline }

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final GradientButtonType type;
  final IconData? icon;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = GradientButtonType.crimson,
    this.icon,
    this.isLoading = false,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    bool isEnabled = widget.onPressed != null && !widget.isLoading;
    
    Gradient gradient;
    Color borderCol = Colors.transparent;
    Color textCol = ObsidianTheme.textVibrant;
    Color glowCol = Colors.transparent;
    
    switch (widget.type) {
      case GradientButtonType.gold:
        gradient = const LinearGradient(
          colors: [ObsidianTheme.secondaryGold, Color(0xFFAA843B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        glowCol = ObsidianTheme.secondaryGold.withValues(alpha: 0.2);
        textCol = ObsidianTheme.backgroundDark;
        break;
      case GradientButtonType.outline:
        gradient = const LinearGradient(colors: [Colors.transparent, Colors.transparent]);
        borderCol = ObsidianTheme.borderHairline;
        textCol = ObsidianTheme.textVibrant;
        break;
      case GradientButtonType.crimson:
        gradient = const LinearGradient(
          colors: [ObsidianTheme.primaryCrimson, Color(0xFF6B1724)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        glowCol = ObsidianTheme.primaryCrimson.withValues(alpha: 0.18);
        textCol = Colors.white;
        break;
    }

    if (!isEnabled) {
      gradient = const LinearGradient(colors: [Color(0xFF222222), Color(0xFF111111)]);
      textCol = ObsidianTheme.textMuted;
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
