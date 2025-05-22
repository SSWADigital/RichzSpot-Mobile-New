import 'package:flutter/material.dart';

class DownloadButton extends StatelessWidget {
  const DownloadButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Handle download functionality
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 14,
              height: 13,
              child: CustomPaint(
                painter: DownloadIconPainter(),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Download PDF',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                height: 1.5,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DownloadIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path path = Path()
      ..moveTo(10.1406, 0.875)
      ..lineTo(11.7031, 0.875)
      ..lineTo(13.2656, 2.4375)
      ..lineTo(13.2656, 10.5625)
      ..lineTo(12.808, 11.6674)
      ..lineTo(11.7031, 12.125)
      ..lineTo(2.32812, 12.125)
      ..lineTo(1.22327, 11.6674)
      ..lineTo(0.765625, 10.5625)
      ..lineTo(0.765625, 2.4375)
      ..lineTo(1.22327, 1.33265)
      ..lineTo(2.32812, 0.875)
      ..lineTo(3.89062, 0.875);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
