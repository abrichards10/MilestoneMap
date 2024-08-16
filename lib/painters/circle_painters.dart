import 'package:flutter/material.dart';
import '../models/circle.dart';

class CirclePainter extends CustomPainter {
  final Circle rootCircle;

  CirclePainter(this.rootCircle);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    drawCircle(rootCircle, canvas, linePaint);
  }

  void drawCircle(Circle circle, Canvas canvas, Paint linePaint) {
    final offset = circle.offset;
    final radius = 50.0; // Adjust as needed for circle size

    // Draw lines to children
    for (var child in circle.children) {
      final childOffset = child.offset;
      canvas.drawLine(
        Offset(offset.dx, offset.dy),
        Offset(childOffset.dx, childOffset.dy),
        linePaint,
      );
      drawCircle(child, canvas, linePaint);
    }

    // Draw the circle itself
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(offset, radius, paint);

    // Draw the text in the center of the circle
    final textPainter = TextPainter(
      text: TextSpan(
        text: circle.text,
        style: TextStyle(color: Colors.white, fontSize: 16.0),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 100); // Adjust maxWidth as needed

    final textOffset = Offset(
      offset.dx - textPainter.width / 2,
      offset.dy - textPainter.height / 2,
    );

    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
