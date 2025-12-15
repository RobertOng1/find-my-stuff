import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class TopWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Modern Mesh Gradient Effect
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF81D4FA), // Lighter Blue
          AppColors.primaryBlue,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.lineTo(0, size.height * 0.7);
    
    // Smooth Bezier Curve
    path.cubicTo(
      size.width * 0.3,
      size.height * 0.9,
      size.width * 0.4,
      size.height * 0.5,
      size.width,
      size.height * 0.6,
    );
    
    path.lineTo(size.width, 0);
    path.close();

    // Soft Shadow/Glow
    canvas.drawShadow(path, AppColors.primaryBlue.withOpacity(0.3), 10, true);
    canvas.drawPath(path, paint);
    
    // Floating Bubble Decoration
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.3), 40, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.2), 20, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          AppColors.primaryBlue,
          AppColors.darkBlue,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.3);
    
    // Wave
    path.cubicTo(
      size.width * 0.25,
      size.height * 0.5,
      size.width * 0.75,
      size.height * 0.1,
      size.width,
      size.height * 0.35,
    );
    
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
