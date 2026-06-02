import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rtc_mobile/theme/app_theme.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "DIGITAL SIGNATURE",
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: ObsidianTheme.secondaryGold,
                    letterSpacing: 1.0,
                  ),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() => _points.clear());
                widget.onSignatureChanged(_points);
              },
              icon: const Icon(Icons.clear, size: 14, color: ObsidianTheme.primaryCrimson),
              label: Text(
                "CLEAR",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: ObsidianTheme.primaryCrimson,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: ObsidianTheme.surfaceDark.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ObsidianTheme.borderHairline, width: 1.0),
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
              painter: SignaturePainter(points: _points),
              size: Size.infinite,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Use your finger to sign within the designated area above.",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class SignaturePainter extends CustomPainter {
  List<Offset?> points;

  SignaturePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = ObsidianTheme.primaryCrimson
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => oldDelegate.points != points;
}
