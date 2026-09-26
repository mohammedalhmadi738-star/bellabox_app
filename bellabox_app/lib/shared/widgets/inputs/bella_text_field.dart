import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bellabox/core/theme/app_colors.dart';
import 'package:bellabox/core/theme/app_text_styles.dart';

class BellaTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final Widget? prefix;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final VoidCallback? onEditingComplete;
  final bool obscureText;
  final bool autofocus;
  final int? maxLength;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final bool enabled;

  const BellaTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.prefixIcon,
    this.suffix,
    this.prefix,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.onChanged,
    this.onEditingComplete,
    this.obscureText = false,
    this.autofocus = false,
    this.maxLength,
    this.maxLines = 1,
    this.textInputAction,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
          obscureText: obscureText,
          autofocus: autofocus,
          maxLength: maxLength,
          maxLines: maxLines,
          textInputAction: textInputAction,
          enabled: enabled,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textTertiary, size: 20)
                : null,
            prefix: prefix,
            suffixIcon: suffix,
            errorText: errorText,
            counterText: '',
          ),
        ),
      ],
    );
  }
}
