import 'package:flutter/material.dart';
import 'package:bellabox/core/theme/app_colors.dart';
import 'package:bellabox/core/theme/app_dimensions.dart';
import 'package:bellabox/core/theme/app_text_styles.dart';

enum BellaSnackType { info, success, error }

class BellaSnackbar {
  BellaSnackbar._();

  static void show(
    BuildContext context,
    String message, {
    BellaSnackType type = BellaSnackType.info,
  }) {
    final color = switch (type) {
      BellaSnackType.success => AppColors.success,
      BellaSnackType.error => AppColors.error,
      BellaSnackType.info => AppColors.primary,
    };
    final icon = switch (type) {
      BellaSnackType.success => Icons.check_circle_rounded,
      BellaSnackType.error => Icons.error_rounded,
      BellaSnackType.info => Icons.info_rounded,
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius16),
          ),
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
