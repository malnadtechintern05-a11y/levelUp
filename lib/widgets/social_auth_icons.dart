import 'package:flutter/material.dart';

class GoogleLogoIcon extends StatelessWidget {
  final double size;
  const GoogleLogoIcon({super.key, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    // Paints
    final redPaint = Paint()..color = const Color(0xFFEA4335)..style = PaintingStyle.fill;
    final bluePaint = Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.fill;
    final yellowPaint = Paint()..color = const Color(0xFFFBBC05)..style = PaintingStyle.fill;
    final greenPaint = Paint()..color = const Color(0xFF34A853)..style = PaintingStyle.fill;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final innerRect = Rect.fromCircle(center: center, radius: radius * 0.58);

    // Blue section (Right & Center Bar)
    final bluePath = Path()
      ..moveTo(center.dx, center.dy - radius * 0.22)
      ..lineTo(w * 0.98, center.dy - radius * 0.22)
      ..arcTo(rect, -0.2, 1.2, false)
      ..lineTo(center.dx + radius * 0.45, center.dy + radius * 0.4)
      ..arcTo(innerRect, 1.0, -0.9, false)
      ..lineTo(center.dx, center.dy + radius * 0.22)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    // Green section (Bottom)
    final greenPath = Path()
      ..arcTo(rect, 0.78, 1.35, false)
      ..lineTo(center.dx - radius * 0.45, center.dy + radius * 0.35)
      ..arcTo(innerRect, 2.13, -1.35, false)
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    // Yellow section (Left)
    final yellowPath = Path()
      ..arcTo(rect, 2.13, 1.15, false)
      ..lineTo(center.dx - radius * 0.45, center.dy - radius * 0.35)
      ..arcTo(innerRect, 3.28, -1.15, false)
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // Red section (Top)
    final redPath = Path()
      ..arcTo(rect, 3.28, 1.3, false)
      ..lineTo(center.dx + radius * 0.45, center.dy - radius * 0.35)
      ..arcTo(innerRect, 4.58, -1.3, false)
      ..close();
    canvas.drawPath(redPath, redPaint);

    // Middle horizontal bar for Blue G
    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(center.dx - radius * 0.05, center.dy - radius * 0.2, radius * 1.02, radius * 0.4),
      Radius.circular(radius * 0.05),
    );
    canvas.drawRRect(barRect, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AppleLogoIcon extends StatelessWidget {
  final double size;
  final Color color;
  const AppleLogoIcon({super.key, this.size = 22, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.apple, size: size * 1.25, color: color);
  }
}

class MicrosoftLogoIcon extends StatelessWidget {
  final double size;
  const MicrosoftLogoIcon({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    final gap = size * 0.12;
    final tileSize = (size - gap) / 2;

    return SizedBox(
      width: size,
      height: size,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: tileSize, height: tileSize, color: const Color(0xFFF25022)), // Red
              SizedBox(width: gap),
              Container(width: tileSize, height: tileSize, color: const Color(0xFF7FBA00)), // Green
            ],
          ),
          SizedBox(height: gap),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: tileSize, height: tileSize, color: const Color(0xFF00A4EF)), // Blue
              SizedBox(width: gap),
              Container(width: tileSize, height: tileSize, color: const Color(0xFFFFB900)), // Yellow
            ],
          ),
        ],
      ),
    );
  }
}
