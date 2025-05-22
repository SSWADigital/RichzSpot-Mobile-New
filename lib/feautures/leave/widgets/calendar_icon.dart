import 'package:flutter/material.dart';
import 'package:richzspot/core/constant/app_colors.dart';

class CalendarIcon extends StatelessWidget {
  const CalendarIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: CalendarPainter(),
    );
  }
}

class CalendarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.iconColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25;

    // Draw calendar frame
    final RRect frame = RRect.fromRectAndRadius(
      Rect.fromLTWH(1.875, 3.125, 16.25, 15),
      const Radius.circular(1.875),
    );
    canvas.drawRRect(frame, paint);

    // Draw top line
    canvas.drawLine(
      const Offset(1.875, 6.25),
      const Offset(18.125, 6.25),
      paint,
    );

    // Draw calendar dots
    paint.style = PaintingStyle.fill;
    final List<Offset> dotPositions = [
      const Offset(11.5625, 9.0625),
      const Offset(14.6875, 9.0625),
      const Offset(11.5625, 12.1875),
      const Offset(14.6875, 12.1875),
      const Offset(5.3125, 12.1875),
      const Offset(8.4375, 12.1875),
      const Offset(5.3125, 15.3125),
      const Offset(8.4375, 15.3125),
      const Offset(11.5625, 15.3125),
    ];

    for (final Offset position in dotPositions) {
      canvas.drawCircle(position, 0.9375, paint);
    }

    // Draw calendar hangers
    _drawHanger(canvas, paint, 5.0);
    _drawHanger(canvas, paint, 15.0);
  }

  void _drawHanger(Canvas canvas, Paint paint, double x) {
    final Path path = Path()
      ..moveTo(x - 0.625, 3.125)
      ..lineTo(x, 3.125)
      ..lineTo(x, 1.875)
      ..lineTo(x - 0.625, 1.875)
      ..lineTo(x - 1.25, 1.875)
      ..lineTo(x - 1.25, 3.125)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
