import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextTheme {
  AppTextTheme._();

  static TextTheme lightTextTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),

    headlineMedium: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),

    titleLarge: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),

    bodyLarge: GoogleFonts.poppins(
      fontSize: 16,
      color: AppColors.textPrimary,
    ),

    bodyMedium: GoogleFonts.poppins(
      fontSize: 14,
      color: AppColors.textSecondary,
    ),

    labelLarge: GoogleFonts.poppins(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  );
}