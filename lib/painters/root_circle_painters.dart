import 'package:flutter/material.dart';
import '../models/circle.dart';

class RootCirclePainter extends CustomPainter {
  final Circle rootCircle;

  RootCirclePainter(this.rootCircle);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color.fromARGB(30, 0, 0, 0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    drawGoalCircle(rootCircle, canvas, linePaint);
  }

  void drawGoalCircle(Circle circle, Canvas canvas, Paint linePaint) {
    final offset = circle.offset;
    final radius = circle.size / 2;

    // Draw lines to children
    for (var child in circle.children) {
      final childOffset = child.offset;
      canvas.drawLine(
        Offset(offset.dx, offset.dy),
        Offset(childOffset.dx, childOffset.dy),
        linePaint,
      );
      drawGoalCircle(child, canvas, linePaint);
    }

    // Draw the circle itself
    final paint = Paint()
      ..color = circle.isGoal
          ? const Color.fromARGB(255, 67, 111, 70)
          : const Color.fromARGB(255, 100, 150, 100)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(offset, radius, paint);

    // Draw the text in the center of the circle
    final textPainter = TextPainter(
      text: TextSpan(
        text: circle.text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: radius * 2);

    final textOffset = Offset(
      offset.dx - textPainter.width / 2,
      offset.dy - textPainter.height / 2,
    );

    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
