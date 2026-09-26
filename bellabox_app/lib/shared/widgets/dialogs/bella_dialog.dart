import 'package:flutter/material.dart';
import 'package:bellabox/core/localization/app_localizations.dart';
import 'package:bellabox/core/theme/app_colors.dart';
import 'package:bellabox/core/theme/app_text_styles.dart';
import 'package:bellabox/shared/widgets/buttons/bella_primary_button.dart';
import 'package:bellabox/shared/widgets/buttons/bella_secondary_button.dart';

class BellaDialog {
  BellaDialog._();

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    String? message,
    String? confirmLabel,
    String? cancelLabel,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: AppTextStyles.h3, textAlign: TextAlign.center),
        content: message != null
            ? Text(
                message,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              )
            : null,
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          Row(
            children: [
              Expanded(
                child: BellaSecondaryButton(
                  label: cancelLabel ?? context.tr('common.cancel'),
                  onPressed: () => Navigator.pop(context, false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BellaPrimaryButton(
                  label: confirmLabel ?? context.tr('common.confirm'),
                  backgroundColor: destructive ? AppColors.error : null,
                  onPressed: () => Navigator.pop(context, true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
