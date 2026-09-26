import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDimensions {
  AppDimensions._();

  // Spacing scale (4-point grid)
  static const double space2 = 2;
  static const double space4 = 4;
  static const double space6 = 6;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  static const double space64 = 64;

  // Radius
  static const double radius8 = 8;
  static const double radius12 = 12;
  static const double radius16 = 16;
  static const double radius20 = 20;
  static const double radius24 = 24;
  static const double radius32 = 32;
  static const double radiusPill = 999;

  // Elevation shadows
  static const List<BoxShadow> shadowSm = [
    BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(color: AppColors.shadow, blurRadius: 24, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> shadowFloatingNav = [
    BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  // Touch targets (WCAG minimum 44dp)
  static const double minTouchTarget = 48;

  // App bar
  static const double appBarHeight = 56;

  // Bottom nav
  static const double bottomNavHeight = 68;
  static const double bottomNavMargin = 16;

  // Product card
  static const double productCardAspectRatio = 0.68; // width/height

  // Common paddings
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: space20);
  static const EdgeInsets pagePaddingVertical =
      EdgeInsets.symmetric(horizontal: space20, vertical: space16);
}
