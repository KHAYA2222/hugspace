// lib/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Core pink palette
  static const Color blush = Color(0xFFFDE8EF);
  static const Color roseMist = Color(0xFFF7C5D5);
  static const Color softRose = Color(0xFFEF9DB0);
  static const Color deepRose = Color(0xFFD4607A);
  static const Color warmCoral = Color(0xFFE8806A);

  // Neutrals
  static const Color creamWhite = Color(0xFFFFF8F9);
  static const Color warmGray = Color(0xFF8A7070);
  static const Color softCharcoal = Color(0xFF3D2C2C);
  static const Color mutedTaupe = Color(0xFFB09090);

  // Accents
  static const Color lavenderBlush = Color(0xFFF0E6F6);
  static const Color peach = Color(0xFFFDD5C0);
  static const Color mintWhisper = Color(0xFFD8F0E8);

  // Hug colors (used in animations)
  static const List<Color> hugColors = [
    Color(0xFFFFB3C6),
    Color(0xFFFF85A1),
    Color(0xFFFF4D6D),
    Color(0xFFC9184A),
    Color(0xFFFFCCD5),
  ];
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.deepRose,
        onPrimary: Colors.white,
        secondary: AppColors.warmCoral,
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        background: AppColors.creamWhite,
        onBackground: AppColors.softCharcoal,
        surface: Colors.white,
        onSurface: AppColors.softCharcoal,
      ),
      scaffoldBackgroundColor: AppColors.creamWhite,
      textTheme: TextTheme(
        // Display - Playfair for elegance
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: AppColors.softCharcoal,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColors.softCharcoal,
        ),
        displaySmall: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.softCharcoal,
        ),
        // Body - Nunito for warmth and readability
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.softCharcoal,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.warmGray,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.mutedTaupe,
        ),
        labelLarge: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.softCharcoal,
          letterSpacing: 0.3,
        ),
        labelMedium: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.warmGray,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.blush,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.softRose, width: 2),
        ),
        hintStyle: GoogleFonts.nunito(
          color: AppColors.mutedTaupe,
          fontSize: 15,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }
}
