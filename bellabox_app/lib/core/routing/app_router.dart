import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bellabox/core/routing/route_names.dart';
import 'package:bellabox/features/auth/presentation/pages/auth_success_page.dart';
import 'package:bellabox/features/auth/presentation/pages/login_page.dart';
import 'package:bellabox/features/auth/presentation/pages/otp_page.dart';
import 'package:bellabox/features/cart/presentation/pages/cart_page.dart';
import 'package:bellabox/features/categories/presentation/pages/categories_page.dart';
import 'package:bellabox/features/categories/presentation/pages/category_details_page.dart';
import 'package:bellabox/features/checkout/presentation/pages/checkout_page.dart';
import 'package:bellabox/features/home/presentation/pages/home_page.dart';
import 'package:bellabox/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:bellabox/features/orders/presentation/pages/order_details_page.dart';
import 'package:bellabox/features/orders/presentation/pages/orders_page.dart';
import 'package:bellabox/features/payment/presentation/pages/payment_failed_page.dart';
import 'package:bellabox/features/payment/presentation/pages/payment_pending_page.dart';
import 'package:bellabox/features/payment/presentation/pages/payment_success_page.dart';
import 'package:bellabox/features/products/domain/entities/product.dart' as domain;
import 'package:bellabox/features/products/presentation/pages/product_details_page.dart';
import 'package:bellabox/features/profile/presentation/pages/profile_page.dart';
import 'package:bellabox/features/profile/presentation/pages/static_page.dart';
import 'package:bellabox/features/search/presentation/pages/search_page.dart';
import 'package:bellabox/features/splash/presentation/pages/splash_page.dart';
import 'package:bellabox/shared/widgets/bottom_nav/floating_bottom_nav.dart';
import 'package:bellabox/shared/widgets/states/offline_banner.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: false,
    routes: [
      // ── Boot flow ──
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),

      // ── Auth flow ──
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.otp,
        builder: (context, state) => const OtpPage(),
      ),
      GoRoute(
        path: RouteNames.authSuccess,
        builder: (context, state) => const AuthSuccessPage(),
      ),

      // ── Main shell: 5 tabs with independent navigation stacks ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _ShellScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.home,
              builder: (context, state) => const HomePage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.categories,
              builder: (context, state) => const CategoriesPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.cart,
              builder: (context, state) => const CartPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.orders,
              builder: (context, state) => const OrdersPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.profile,
              builder: (context, state) => const ProfilePage(),
            ),
          ]),
        ],
      ),

      // ── Full-screen sub-pages (outside shell → no bottom nav) ──
      GoRoute(
        path: RouteNames.search,
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: '${RouteNames.productDetails}/:slug',
        builder: (context, state) => ProductDetailsPage(
          slug: state.pathParameters['slug']!,
        ),
      ),
      GoRoute(
        path: '${RouteNames.categoryDetails}/:slug',
        builder: (context, state) => CategoryDetailsPage(
          slug: state.pathParameters['slug']!,
          category: state.extra is domain.Category
              ? state.extra as domain.Category
              : null,
        ),
      ),
      GoRoute(
        path: RouteNames.checkout,
        builder: (context, state) => const CheckoutPage(),
      ),

      // ── Payment ──
      GoRoute(
        path: RouteNames.paymentPending,
        builder: (context, state) {
          final q = state.uri.queryParameters;
          return PaymentPendingPage(
            orderId: int.tryParse(q['orderId'] ?? '') ?? 0,
            orderNumber: q['order'] ?? '',
            gateway: q['gateway'] ?? 'moyasar',
          );
        },
      ),
      GoRoute(
        path: RouteNames.paymentSuccess,
        builder: (context, state) => PaymentSuccessPage(
          orderNumber: state.uri.queryParameters['order'] ?? '',
        ),
      ),
      GoRoute(
        path: RouteNames.paymentFailed,
        builder: (context, state) {
          final q = state.uri.queryParameters;
          return PaymentFailedPage(
            orderId: int.tryParse(q['orderId'] ?? '') ?? 0,
            orderNumber: q['order'] ?? '',
            gateway: q['gateway'] ?? 'moyasar',
            reason: q['reason'],
          );
        },
      ),

      // ── Orders details ──
      GoRoute(
        path: '${RouteNames.orderDetails}/:orderNumber',
        builder: (context, state) => OrderDetailsPage(
          orderNumber: state.pathParameters['orderNumber']!,
        ),
      ),

      // ── Profile sub-pages ──
      GoRoute(
        path: RouteNames.notifications,
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '${RouteNames.staticPage}/:slug',
        builder: (context, state) => StaticPage(
          slug: state.pathParameters['slug']!,
        ),
      ),
      // Legacy aliases from login page links
      GoRoute(
        path: RouteNames.terms,
        builder: (context, state) => const StaticPage(slug: 'terms'),
      ),
      GoRoute(
        path: RouteNames.privacy,
        builder: (context, state) =>
            const StaticPage(slug: 'privacy-policy'),
      ),
    ],
  );
});

/// Shell scaffold: floating bottom nav + global offline banner
class _ShellScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const _ShellScaffold({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Content scrolls under the floating nav
      body: Stack(
        children: [
          navigationShell,
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(child: OfflineBanner()),
          ),
        ],
      ),
      bottomNavigationBar: FloatingBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          // Tapping active tab again pops that branch to its root
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
