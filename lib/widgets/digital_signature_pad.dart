import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class DigitalSignaturePad extends StatefulWidget {
  final Function(List<Offset?>) onSignatureChanged;

  const DigitalSignaturePad({super.key, required this.onSignatureChanged});

  @override
  State<DigitalSignaturePad> createState() => _DigitalSignaturePadState();
}

class _DigitalSignaturePadState extends State<DigitalSignaturePad> {
  List<Offset?> _points = <Offset?>[];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mutedText = colorScheme.onSurface.withValues(alpha: 0.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "DIGITAL SIGNATURE",
              style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.secondary,
                    letterSpacing: 1.0,
                  ),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() => _points.clear());
                widget.onSignatureChanged(_points);
              },
              icon: Icon(CupertinoIcons.clear, size: 14, color: colorScheme.primary),
              label: Text(
                "CLEAR",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1), width: 1.0),
          ),
          child: GestureDetector(
            onPanUpdate: (DragUpdateDetails details) {
              setState(() {
                RenderBox object = context.findRenderObject() as RenderBox;
                Offset localPosition = object.globalToLocal(details.globalPosition);
                _points = List.from(_points)..add(localPosition);
              });
              widget.onSignatureChanged(_points);
            },
            onPanEnd: (DragEndDetails details) {
              _points.add(null);
              widget.onSignatureChanged(_points);
            },
            child: CustomPaint(
              painter: SignaturePainter(points: _points, strokeColor: colorScheme.primary),
              size: Size.infinite,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Use your finger to sign within the designated area above.",
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11, color: mutedText),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  final Color strokeColor;

  SignaturePainter({required this.points, required this.strokeColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => oldDelegate.points != points || oldDelegate.strokeColor != strokeColor;
}
