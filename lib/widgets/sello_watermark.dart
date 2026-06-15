import 'package:flutter/material.dart';

/// Diagonal repeated SELLO watermark for share cards.
class SelloWatermark extends StatelessWidget {
  const SelloWatermark({super.key, required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _SelloWatermarkPainter(),
        size: size,
      ),
    );
  }
}

class _SelloWatermarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const text = 'SELLO';
    final textStyle = TextStyle(
      fontSize: 52,
      fontWeight: FontWeight.w900,
      color: Colors.black.withValues(alpha: 0.08),
      letterSpacing: 8,
    );
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(size.width * 0.5, size.height * 0.5);
    canvas.rotate(-0.35);

    const cols = 4;
    const rows = 5;
    const xGap = 220.0;
    const yGap = 140.0;
    final startX = -((cols - 1) * xGap) / 2;
    final startY = -((rows - 1) * yGap) / 2;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        textPainter.paint(
          canvas,
          Offset(startX + col * xGap, startY + row * yGap),
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
