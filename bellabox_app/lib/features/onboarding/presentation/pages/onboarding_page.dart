import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:bellabox/core/constants/storage_keys.dart';
import 'package:bellabox/core/localization/app_localizations.dart';
import 'package:bellabox/core/routing/route_names.dart';
import 'package:bellabox/core/storage/local_storage.dart';
import 'package:bellabox/core/theme/app_colors.dart';
import 'package:bellabox/core/theme/app_dimensions.dart';
import 'package:bellabox/core/theme/app_text_styles.dart';
import 'package:bellabox/shared/widgets/buttons/bella_primary_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnbData(
      icon: Icons.spa_rounded,
      titleKey: 'onboarding.page1Title',
      bodyKey: 'onboarding.page1Body',
    ),
    _OnbData(
      icon: Icons.face_retouching_natural_rounded,
      titleKey: 'onboarding.page2Title',
      bodyKey: 'onboarding.page2Body',
    ),
    _OnbData(
      icon: Icons.card_giftcard_rounded,
      titleKey: 'onboarding.page3Title',
      bodyKey: 'onboarding.page3Body',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await LocalStorage.prefs.setBool(StorageKeys.onboardingSeen, true);
    if (mounted) context.go(RouteNames.login);
  }

  void _next() {
    if (_currentPage == _pages.length - 1) {
      _finish();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    context.tr('common.skip'),
                    style: AppTextStyles.labelLarge
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) => _OnboardingSlide(data: _pages[i]),
              ),
            ),
            const SizedBox(height: 24),
            SmoothPageIndicator(
              controller: _pageController,
              count: _pages.length,
              effect: const ExpandingDotsEffect(
                dotColor: AppColors.divider,
                activeDotColor: AppColors.secondary,
                dotHeight: 8,
                dotWidth: 8,
                expansionFactor: 3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: BellaPrimaryButton(
                label: isLast
                    ? context.tr('onboarding.getStarted')
                    : context.tr('common.next'),
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnbData {
  final IconData icon;
  final String titleKey;
  final String bodyKey;
  const _OnbData({
    required this.icon,
    required this.titleKey,
    required this.bodyKey,
  });
}

class _OnboardingSlide extends StatelessWidget {
  final _OnbData data;
  const _OnboardingSlide({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimensions.pagePadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: const BoxDecoration(
              gradient: AppColors.goldGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 88, color: AppColors.primary),
          ),
          const SizedBox(height: 48),
          Text(
            context.tr(data.titleKey),
            style: AppTextStyles.h1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            context.tr(data.bodyKey),
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
