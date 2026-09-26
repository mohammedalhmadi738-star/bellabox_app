import 'package:flutter/material.dart';
import 'package:bellabox/core/localization/app_localizations.dart';
import 'package:bellabox/core/theme/app_colors.dart';
import 'package:bellabox/core/theme/app_text_styles.dart';
import 'package:bellabox/shared/widgets/buttons/bella_secondary_button.dart';

class ErrorStateView extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorStateView({
    super.key,
    this.title,
    this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              title ?? context.tr('errors.generic'),
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              BellaSecondaryButton(
                label: context.tr('common.retry'),
                onPressed: onRetry,
                icon: Icons.refresh_rounded,
                expanded: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
