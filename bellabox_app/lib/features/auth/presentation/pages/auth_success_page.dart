import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bellabox/core/localization/app_localizations.dart';
import 'package:bellabox/core/routing/route_names.dart';
import 'package:bellabox/core/theme/app_colors.dart';
import 'package:bellabox/core/theme/app_text_styles.dart';
import 'package:bellabox/features/auth/presentation/providers/login_flow_provider.dart';

class AuthSuccessPage extends ConsumerStatefulWidget {
  const AuthSuccessPage({super.key});

  @override
  ConsumerState<AuthSuccessPage> createState() => _AuthSuccessPageState();
}

class _AuthSuccessPageState extends ConsumerState<AuthSuccessPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();

    _navTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        ref.read(loginFlowProvider.notifier).reset();
        context.go(RouteNames.home);
      }
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 64,
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeTransition(
              opacity: _controller,
              child: Column(
                children: [
                  Text(
                    context.tr('auth.successTitle'),
                    style: AppTextStyles.h1,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('auth.successBody'),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
