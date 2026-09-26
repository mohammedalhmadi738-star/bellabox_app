import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bellabox/core/localization/app_localizations.dart';
import 'package:bellabox/core/routing/route_names.dart';
import 'package:bellabox/core/theme/app_colors.dart';
import 'package:bellabox/core/theme/app_dimensions.dart';
import 'package:bellabox/core/theme/app_text_styles.dart';
import 'package:bellabox/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:bellabox/shared/widgets/buttons/bella_primary_button.dart';
import 'package:bellabox/shared/widgets/dialogs/bella_dialog.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('profile.title')),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          // ── User header / guest prompt ──
          if (user != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radius24),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      gradient: AppColors.goldGradient,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0] : '؟',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: AppTextStyles.h3),
                        const SizedBox(height: 4),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            user.phone,
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radius24),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    size: 48,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.tr('profile.guestTitle'),
                    style: AppTextStyles.h4,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  BellaPrimaryButton(
                    label: context.tr('auth.loginTitle'),
                    onPressed: () => context.push(RouteNames.login),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // ── Account section ──
          if (user != null) ...[
            _MenuGroup(
              children: [
                _MenuItem(
                  icon: Icons.receipt_long_outlined,
                  label: context.tr('orders.title'),
                  onTap: () => context.push(RouteNames.orders),
                ),
                _MenuItem(
                  icon: Icons.favorite_border_rounded,
                  label: context.tr('profile.wishlist'),
                  onTap: () {
                    // TODO(phase5): dedicated wishlist page
                  },
                  trailing: _SoonBadge(label: context.tr('common.soon')),
                ),
                _MenuItem(
                  icon: Icons.location_on_outlined,
                  label: context.tr('profile.addresses'),
                  onTap: () {
                    // TODO(phase5): addresses management page
                    // (adding addresses works from checkout)
                  },
                  trailing: _SoonBadge(label: context.tr('common.soon')),
                ),
                _MenuItem(
                  icon: Icons.edit_outlined,
                  label: context.tr('profile.editProfile'),
                  onTap: () {
                    // TODO(phase5): edit profile page (PATCH /profile)
                  },
                  trailing: _SoonBadge(label: context.tr('common.soon')),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // ── App section ──
          _MenuGroup(
            children: [
              _MenuItem(
                icon: Icons.language_rounded,
                label: context.tr('profile.language'),
                onTap: () {
                  // TODO(phase5): language switcher (AR live, EN placeholder)
                },
                trailing: Text('العربية', style: AppTextStyles.bodySmall),
              ),
              _MenuItem(
                icon: Icons.notifications_none_rounded,
                label: context.tr('profile.notifications'),
                onTap: () => context.push(RouteNames.notifications),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Legal / info ──
          _MenuGroup(
            children: [
              _MenuItem(
                icon: Icons.info_outline_rounded,
                label: context.tr('profile.about'),
                onTap: () => context.push('${RouteNames.staticPage}/about'),
              ),
              _MenuItem(
                icon: Icons.privacy_tip_outlined,
                label: context.tr('profile.privacy'),
                onTap: () =>
                    context.push('${RouteNames.staticPage}/privacy-policy'),
              ),
              _MenuItem(
                icon: Icons.description_outlined,
                label: context.tr('profile.terms'),
                onTap: () => context.push('${RouteNames.staticPage}/terms'),
              ),
            ],
          ),

          // ── Logout ──
          if (user != null) ...[
            const SizedBox(height: 24),
            _MenuGroup(
              children: [
                _MenuItem(
                  icon: Icons.logout_rounded,
                  label: context.tr('profile.logout'),
                  destructive: true,
                  onTap: () async {
                    final confirmed = await BellaDialog.confirm(
                      context,
                      title: context.tr('profile.logout'),
                      message: context.tr('profile.logoutConfirm'),
                      confirmLabel: context.tr('common.yes'),
                      cancelLabel: context.tr('common.no'),
                      destructive: true,
                    );
                    if (confirmed == true) {
                      await ref.read(authSessionProvider.notifier).logout();
                      if (context.mounted) context.go(RouteNames.home);
                    }
                  },
                ),
              ],
            ),
          ],

          const SizedBox(height: 24),
          Center(
            child: Text(
              'Bella Box v1.0.0',
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final List<Widget> children;
  const _MenuGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius20),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) const Divider(height: 1, indent: 56),
          ],
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool destructive;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.error : AppColors.textPrimary;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon,
          color: destructive ? AppColors.error : AppColors.textSecondary,
          size: 22),
      title: Text(
        label,
        style: AppTextStyles.labelLarge.copyWith(color: color),
      ),
      trailing: trailing ??
          Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.chevron_left_rounded
                : Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
          ),
      minLeadingWidth: 24,
    );
  }
}

class _SoonBadge extends StatelessWidget {
  final String label;
  const _SoonBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.secondaryDark,
        ),
      ),
    );
  }
}
