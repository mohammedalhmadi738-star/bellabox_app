import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bellabox/core/constants/storage_keys.dart';
import 'package:bellabox/core/localization/app_localizations.dart';
import 'package:bellabox/core/routing/route_names.dart';
import 'package:bellabox/core/storage/local_storage.dart';
import 'package:bellabox/core/theme/app_colors.dart';
import 'package:bellabox/core/theme/app_text_styles.dart';
import 'package:bellabox/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:bellabox/shared/providers/settings_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoScale = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeOutBack),
      ),
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1, curve: Curves.easeIn),
    );
    _controller.forward();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Run all boot tasks in parallel + minimum splash duration
    await Future.wait([
      ref.read(authSessionProvider.notifier).restore(),
      ref.read(settingsProvider.notifier).preload(),
      Future<void>.delayed(const Duration(milliseconds: 1600)),
    ]);

    if (!mounted) return;

    final onboardingSeen =
        LocalStorage.prefs.getBool(StorageKeys.onboardingSeen) ?? false;

    if (!onboardingSeen) {
      context.go(RouteNames.onboarding);
      return;
    }
    // Guest browsing is allowed — always land on home.
    context.go(RouteNames.home);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _logoScale,
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  gradient: AppColors.goldGradient,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  'BB',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            FadeTransition(
              opacity: _fade,
              child: Column(
                children: [
                  Text(
                    'Bella Box',
                    style: AppTextStyles.displaySmall.copyWith(
                      color: AppColors.textOnDark,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('app.tagline'),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 64),
            FadeTransition(
              opacity: _fade,
              child: const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppColors.secondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
