import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: AppColors.backgroundWhite,
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: AppColors.primaryBlue,
        secondary: AppColors.darkBlue,
        tertiary: AppColors.accentGold,
      ),
      useMaterial3: true,
    );
  }
}
