import 'package:flutter/material.dart';
import 'package:bellabox/core/theme/app_colors.dart';
import 'package:bellabox/core/theme/app_dimensions.dart';

class BellaIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? background;
  final Color? iconColor;
  final double size;
  final int? badge;
  final String? semanticLabel;

  const BellaIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.background,
    this.iconColor,
    this.size = 44,
    this.badge,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: background ?? AppColors.surface,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: AppDimensions.shadowSm,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
                if (badge != null && badge! > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.surface, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        badge! > 99 ? '99+' : '$badge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
