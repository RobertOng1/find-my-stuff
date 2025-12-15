import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class TopWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryBlue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.lineTo(0, size.height * 0.7);
    
    // First curve
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.8,
      size.width * 0.5,
      size.height * 0.6,
    );
    
    // Second curve
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.4,
      size.width,
      size.height * 0.5,
    );
    
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
    
    // Darker accent wave
    final paint2 = Paint()
      ..color = AppColors.primaryBlue.withOpacity(0.2)
      ..style = PaintingStyle.fill;
      
    final path2 = Path();
    path2.lineTo(0, size.height * 0.5);
    path2.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.8,
      size.width,
      size.height * 0.4,
    );
    path2.lineTo(size.width, 0);
    path2.close();
    
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryBlue
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.4);
    
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.1,
      size.width * 0.5,
      size.height * 0.4,
    );
    
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.7,
      size.width,
      size.height * 0.5,
    );
    
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
