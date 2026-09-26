import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system.
/// - Tajawal: Arabic + fallback Latin body
/// - Playfair Display: luxury English display/headers
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _tajawal({
    required double size,
    required FontWeight weight,
    Color color = AppColors.textPrimary,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.tajawal(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle _playfair({
    required double size,
    required FontWeight weight,
    Color color = AppColors.textPrimary,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.playfairDisplay(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // Display (luxury, splash, big hero)
  static TextStyle get displayLarge => _playfair(
        size: 40,
        weight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => _playfair(
        size: 32,
        weight: FontWeight.w700,
        height: 1.2,
      );

  static TextStyle get displaySmall => _playfair(
        size: 24,
        weight: FontWeight.w600,
        height: 1.25,
      );

  // Headings (AR-first, uses Tajawal)
  static TextStyle get h1 => _tajawal(size: 26, weight: FontWeight.w700, height: 1.3);
  static TextStyle get h2 => _tajawal(size: 22, weight: FontWeight.w700, height: 1.3);
  static TextStyle get h3 => _tajawal(size: 18, weight: FontWeight.w700, height: 1.35);
  static TextStyle get h4 => _tajawal(size: 16, weight: FontWeight.w700, height: 1.4);

  // Body
  static TextStyle get bodyLarge => _tajawal(size: 16, weight: FontWeight.w400, height: 1.5);
  static TextStyle get bodyMedium => _tajawal(size: 14, weight: FontWeight.w400, height: 1.5);
  static TextStyle get bodySmall =>
      _tajawal(size: 12, weight: FontWeight.w400, height: 1.5, color: AppColors.textSecondary);

  // Label
  static TextStyle get labelLarge => _tajawal(size: 14, weight: FontWeight.w600, height: 1.4);
  static TextStyle get labelMedium => _tajawal(size: 12, weight: FontWeight.w600, height: 1.4);
  static TextStyle get labelSmall => _tajawal(
        size: 11,
        weight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.5,
      );

  // Button
  static TextStyle get buttonLarge =>
      _tajawal(size: 16, weight: FontWeight.w600, letterSpacing: 0.25);
  static TextStyle get buttonMedium =>
      _tajawal(size: 14, weight: FontWeight.w600, letterSpacing: 0.25);

  // Price
  static TextStyle get priceLarge => _tajawal(size: 22, weight: FontWeight.w700);
  static TextStyle get priceMedium => _tajawal(size: 16, weight: FontWeight.w700);
  static TextStyle get priceOld => _tajawal(
        size: 13,
        weight: FontWeight.w400,
        color: AppColors.textTertiary,
      ).copyWith(decoration: TextDecoration.lineThrough);

  // Caption / helper
  static TextStyle get caption =>
      _tajawal(size: 11, weight: FontWeight.w400, color: AppColors.textTertiary);
}
