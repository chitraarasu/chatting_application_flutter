import 'package:flutter/material.dart';

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint0 = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;

    // Border paint
    Paint borderPaint = Paint()
      ..color = Color(0xFF86898f)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    Path path0 = Path();
    path0.moveTo(0, size.height * 0.1500000);
    path0.cubicTo(
        size.width * 0.0000714,
        size.height * 0.0493600,
        size.width * 0.0370143,
        size.height * -0.0002600,
        size.width * 0.1071429,
        0);
    path0.cubicTo(size.width * 0.2857143, 0, size.width * 0.7142857, 0,
        size.width * 0.8928571, 0);
    path0.cubicTo(
        size.width * 0.9634143,
        size.height * -0.0000800,
        size.width * 1.0005857,
        size.height * 0.0487600,
        size.width,
        size.height * 0.1500000);
    path0.cubicTo(size.width, size.height * 0.2750000, size.width * 1.0013857,
        size.height * 0.5853400, size.width, size.height * 0.7603400);
    path0.cubicTo(
        size.width * 1.0014714,
        size.height * 0.8204600,
        size.width * 0.9713143,
        size.height * 0.8595800,
        size.width * 0.9287429,
        size.height * 0.8596400);
    path0.cubicTo(
        size.width * 0.8394571,
        size.height * 0.8596400,
        size.width * 0.6966571,
        size.height * 0.8598800,
        size.width * 0.6073714,
        size.height * 0.8598800);
    path0.quadraticBezierTo(size.width * 0.5504429, size.height * 0.8602600,
        size.width * 0.5001143, size.height);
    path0.quadraticBezierTo(size.width * 0.4504857, size.height * 0.8604600,
        size.width * 0.3933429, size.height * 0.8601600);
    path0.cubicTo(
        size.width * 0.3040571,
        size.height * 0.8601600,
        size.width * 0.1614286,
        size.height * 0.8614000,
        size.width * 0.0721429,
        size.height * 0.8614000);
    path0.cubicTo(
        size.width * 0.0291143,
        size.height * 0.8612800,
        size.width * -0.0017429,
        size.height * 0.8168800,
        0,
        size.height * 0.7569600);
    path0.cubicTo(size.width * -0.0017429, size.height * 0.5819600, 0,
        size.height * 0.6250000, 0, size.height * 0.1500000);
    path0.close();
  
    canvas.drawShadow(path0, Colors.grey.withOpacity(0.2), 3, false);
    canvas.drawPath(path0, paint0);
    // canvas.drawShadow(path0, Colors.grey.withAlpha(50), 4.0, false);
    canvas.drawPath(path0, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
