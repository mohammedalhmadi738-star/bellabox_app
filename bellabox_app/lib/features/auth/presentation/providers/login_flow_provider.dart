import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bellabox/core/constants/app_constants.dart';
import 'package:bellabox/core/errors/failures.dart';
import 'package:bellabox/core/utils/formatters.dart';
import 'package:bellabox/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bellabox/features/auth/presentation/providers/auth_session_provider.dart';

/// State for the login → OTP flow
class LoginFlowState {
  final String phone; // normalized E.164
  final bool sendingOtp;
  final bool verifying;
  final String? error;
  final bool otpSent;
  final bool verified;
  final int resendSecondsLeft;

  const LoginFlowState({
    this.phone = '',
    this.sendingOtp = false,
    this.verifying = false,
    this.error,
    this.otpSent = false,
    this.verified = false,
    this.resendSecondsLeft = 0,
  });

  bool get canResend => resendSecondsLeft <= 0 && !sendingOtp;

  LoginFlowState copyWith({
    String? phone,
    bool? sendingOtp,
    bool? verifying,
    String? error,
    bool clearError = false,
    bool? otpSent,
    bool? verified,
    int? resendSecondsLeft,
  }) {
    return LoginFlowState(
      phone: phone ?? this.phone,
      sendingOtp: sendingOtp ?? this.sendingOtp,
      verifying: verifying ?? this.verifying,
      error: clearError ? null : (error ?? this.error),
      otpSent: otpSent ?? this.otpSent,
      verified: verified ?? this.verified,
      resendSecondsLeft: resendSecondsLeft ?? this.resendSecondsLeft,
    );
  }
}

class LoginFlowNotifier extends Notifier<LoginFlowState> {
  Timer? _resendTimer;

  @override
  LoginFlowState build() {
    ref.onDispose(() => _resendTimer?.cancel());
    return const LoginFlowState();
  }

  Future<bool> sendOtp(String rawPhone) async {
    final phone = Formatters.normalizeSaudiPhone(rawPhone);
    state = state.copyWith(phone: phone, sendingOtp: true, clearError: true);

    final result = await ref.read(authRepositoryProvider).sendOtp(phone);
    return result.fold(
      (failure) {
        state = state.copyWith(sendingOtp: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(
          sendingOtp: false,
          otpSent: true,
          resendSecondsLeft: AppConstants.otpResendSeconds,
        );
        _startResendTimer();
        return true;
      },
    );
  }

  Future<bool> resendOtp() async {
    if (!state.canResend) return false;
    state = state.copyWith(sendingOtp: true, clearError: true);
    final result = await ref.read(authRepositoryProvider).sendOtp(state.phone);
    return result.fold(
      (failure) {
        state = state.copyWith(sendingOtp: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(
          sendingOtp: false,
          resendSecondsLeft: AppConstants.otpResendSeconds,
        );
        _startResendTimer();
        return true;
      },
    );
  }

  Future<bool> verifyOtp(String code) async {
    state = state.copyWith(verifying: true, clearError: true);
    final result =
        await ref.read(authRepositoryProvider).verifyOtp(state.phone, code);
    return result.fold(
      (failure) {
        final msg = failure is ValidationFailure
            ? failure.message
            : failure.message;
        state = state.copyWith(verifying: false, error: msg);
        return false;
      },
      (user) {
        state = state.copyWith(verifying: false, verified: true);
        ref.read(authSessionProvider.notifier).setAuthenticated(user);
        return true;
      },
    );
  }

  void reset() {
    _resendTimer?.cancel();
    state = const LoginFlowState();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final left = state.resendSecondsLeft - 1;
      if (left <= 0) {
        timer.cancel();
        state = state.copyWith(resendSecondsLeft: 0);
      } else {
        state = state.copyWith(resendSecondsLeft: left);
      }
    });
  }
}

final loginFlowProvider =
    NotifierProvider<LoginFlowNotifier, LoginFlowState>(LoginFlowNotifier.new);
