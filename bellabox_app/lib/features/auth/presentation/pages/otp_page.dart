import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import 'package:bellabox/core/constants/app_constants.dart';
import 'package:bellabox/core/localization/app_localizations.dart';
import 'package:bellabox/core/routing/route_names.dart';
import 'package:bellabox/core/theme/app_colors.dart';
import 'package:bellabox/core/theme/app_dimensions.dart';
import 'package:bellabox/core/theme/app_text_styles.dart';
import 'package:bellabox/core/utils/formatters.dart';
import 'package:bellabox/features/auth/presentation/providers/login_flow_provider.dart';
import 'package:bellabox/shared/widgets/buttons/bella_primary_button.dart';

class OtpPage extends ConsumerStatefulWidget {
  const OtpPage({super.key});

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _verify(String code) async {
    if (code.length != AppConstants.otpLength) return;
    FocusScope.of(context).unfocus();
    final ok = await ref.read(loginFlowProvider.notifier).verifyOtp(code);
    if (ok && mounted) {
      context.go(RouteNames.authSuccess);
    } else {
      _pinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final flowState = ref.watch(loginFlowProvider);

    final defaultPinTheme = PinTheme(
      width: 64,
      height: 64,
      textStyle: AppTextStyles.h2,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        border: Border.all(color: AppColors.divider),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppDimensions.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(context.tr('auth.otpTitle'), style: AppTextStyles.h1),
              const SizedBox(height: 8),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '${context.tr('auth.otpSubtitle')} ',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      Formatters.phone(flowState.phone),
                      style: AppTextStyles.labelLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Center(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Pinput(
                    controller: _pinController,
                    length: AppConstants.otpLength,
                    autofocus: true,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        border: Border.all(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                    errorPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        border: Border.all(color: AppColors.error),
                      ),
                    ),
                    forceErrorState: flowState.error != null,
                    onCompleted: _verify,
                  ),
                ),
              ),
              if (flowState.error != null) ...[
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    flowState.error!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              BellaPrimaryButton(
                label: flowState.verifying
                    ? context.tr('auth.verifying')
                    : context.tr('auth.verify'),
                loading: flowState.verifying,
                onPressed: () => _verify(_pinController.text),
              ),
              const SizedBox(height: 24),
              Center(
                child: flowState.canResend
                    ? TextButton(
                        onPressed: () =>
                            ref.read(loginFlowProvider.notifier).resendOtp(),
                        child: Text(
                          context.tr('auth.otpResend'),
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )
                    : Text(
                        '${context.tr('auth.otpResendIn')} '
                        '${flowState.resendSecondsLeft} '
                        '${context.tr('auth.otpSeconds')}',
                        style: AppTextStyles.bodySmall,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
