import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bellabox/core/localization/app_localizations.dart';
import 'package:bellabox/core/routing/route_names.dart';
import 'package:bellabox/core/theme/app_colors.dart';
import 'package:bellabox/core/theme/app_dimensions.dart';
import 'package:bellabox/core/theme/app_text_styles.dart';
import 'package:bellabox/core/utils/validators.dart';
import 'package:bellabox/features/auth/presentation/providers/login_flow_provider.dart';
import 'package:bellabox/shared/widgets/buttons/bella_primary_button.dart';
import 'package:bellabox/shared/widgets/inputs/bella_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phoneController = TextEditingController();
  String? _phoneError;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final phone = _phoneController.text.trim();
    if (!Validators.isValidSaudiPhone(phone)) {
      setState(() => _phoneError = context.tr('auth.invalidPhone'));
      return;
    }
    setState(() => _phoneError = null);
    FocusScope.of(context).unfocus();

    final success = await ref.read(loginFlowProvider.notifier).sendOtp(phone);
    if (success && mounted) {
      context.push(RouteNames.otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final flowState = ref.watch(loginFlowProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppDimensions.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              // Brand mark
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    gradient: AppColors.goldGradient,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'BB',
                    style: AppTextStyles.displaySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(context.tr('auth.loginTitle'), style: AppTextStyles.h1),
              const SizedBox(height: 8),
              Text(
                context.tr('auth.loginSubtitle'),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              // Phone input with +966 prefix
              Directionality(
                textDirection: TextDirection.ltr,
                child: BellaTextField(
                  controller: _phoneController,
                  label: context.tr('auth.phone'),
                  hint: context.tr('auth.phoneHint'),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  errorText: _phoneError ?? flowState.error,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  prefix: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text('+966', style: AppTextStyles.bodyLarge),
                  ),
                  onEditingComplete: _submit,
                ),
              ),
              const SizedBox(height: 32),
              BellaPrimaryButton(
                label: context.tr('auth.sendCode'),
                loading: flowState.sendingOtp,
                onPressed: _submit,
              ),
              const SizedBox(height: 24),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${context.tr('auth.termsAgree')} ',
                      style: AppTextStyles.caption,
                    ),
                    GestureDetector(
                      onTap: () => context.push(RouteNames.terms),
                      child: Text(
                        context.tr('auth.termsLink'),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Text(
                      ' ${context.tr('auth.and')} ',
                      style: AppTextStyles.caption,
                    ),
                    GestureDetector(
                      onTap: () => context.push(RouteNames.privacy),
                      child: Text(
                        context.tr('auth.privacyLink'),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
