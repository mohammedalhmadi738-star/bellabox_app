import 'package:flutter/material.dart';

/// Locked brand tokens. Do NOT introduce new colors without design approval.
class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFF1F1B1A); // Dark Cocoa
  static const Color secondary = Color(0xFFDCAE96); // Bella Pink Dark
  static const Color background = Color(0xFFFAF6F0); // Cream
  static const Color surface = Color(0xFFFFFFFF);

  // Secondary shades
  static const Color secondaryLight = Color(0xFFEBCFBD);
  static const Color secondaryDark = Color(0xFFBF8E75);
  static const Color primaryLight = Color(0xFF3D3634);

  // Text
  static const Color textPrimary = Color(0xFF1F1B1A);
  static const Color textSecondary = Color(0xFF6B6359); // Olive Gray
  static const Color textTertiary = Color(0xFF9C948A);
  static const Color textOnDark = Color(0xFFFAF6F0);
  static const Color textOnSecondary = Color(0xFF1F1B1A);

  // Semantic
  static const Color success = Color(0xFF4A7C59);
  static const Color error = Color(0xFFB85450);
  static const Color warning = Color(0xFFD4A574);
  static const Color info = Color(0xFF6B8E9F);

  // Subtle
  static const Color divider = Color(0xFFEDE7DD);
  static const Color scaffoldOverlay = Color(0xFFF4EEE4);
  static const Color shimmerBase = Color(0xFFEDE7DD);
  static const Color shimmerHighlight = Color(0xFFF7F2EA);
  static const Color shadow = Color(0x0F1F1B1A);
  static const Color overlay = Color(0x80000000);

  // Ratings
  static const Color ratingActive = Color(0xFFE8A857);
  static const Color ratingInactive = Color(0xFFE0D6C7);

  // Gradients (used sparingly for luxury feel)
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEBCFBD), Color(0xFFDCAE96)],
  );

  static const LinearGradient cocoaGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3D3634), Color(0xFF1F1B1A)],
  );
}
