import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors (Original)
  static const Color primaryBlue = Color(0xFF2D9CDB); // Original Primary
  static const Color darkBlue = Color(0xFF0E3F6C);    // Original Secondary/Dark
  static const Color primaryLight = Color(0xFF56CCF2); // Lighter variation for gradients

  // Secondary/Accent
  static const Color secondaryCoral = Color(0xFFFF6B6B); // Modern Alert/Action
  static const Color accentGold = Color(0xFFC5A059); // Original Gold
  
  // Status Colors
  static const Color successGreen = Color(0xFF27AE60); // Original Green
  static const Color errorRed = Color(0xFFEB5757);     // Original Red
  static const Color warningOrange = Color(0xFFFFB74D);

  // Backgrounds
  static const Color backgroundWhite = Color(0xFFF8F9FD); // Keeps the modern off-white
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color inputBackground = Color(0xFFF0F3F8);

  // Text
  static const Color textDark = Color(0xFF333333); // Original Dark Text
  static const Color textGrey = Color(0xFF828282); // Original Grey
  static const Color textLight = Color(0xFFFFFFFF);

  // Shadows
  static Color shadowColor = const Color(0xFF2D9CDB).withOpacity(0.15);
}
