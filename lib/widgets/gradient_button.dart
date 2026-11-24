import 'package:flutter/material.dart';
import 'package:rtc_mobile/widgets/modern_widgets.dart';

// Retained for existing feature screens; all actions use the shared button system.
enum GradientButtonType { crimson, gold, outline }

class GradientButton extends StatelessWidget {
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
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final child = type == GradientButtonType.outline
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              children: [
                if (isLoading)
                  const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (icon != null)
                  Icon(icon, size: 20),
                Text(text, textAlign: TextAlign.center),
              ],
            ),
          )
        : CustomPrimaryButton(
            text: text,
            onPressed: onPressed,
            isLoading: isLoading,
            icon: icon,
            backgroundColor: type == GradientButtonType.gold
                ? scheme.secondary
                : null,
            textColor: type == GradientButtonType.gold
                ? scheme.onSecondary
                : null,
          );
    return Semantics(
      liveRegion: isLoading,
      label: isLoading ? 'Please wait' : null,
      child: SizedBox(
        width: width ?? double.infinity,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: height < 48 ? 48 : height),
          child: child,
        ),
      ),
    );
  }
}
