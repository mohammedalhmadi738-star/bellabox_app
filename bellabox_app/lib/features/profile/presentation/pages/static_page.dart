import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bellabox/core/constants/api_endpoints.dart';
import 'package:bellabox/core/localization/app_localizations.dart';
import 'package:bellabox/core/network/dio_client.dart';
import 'package:bellabox/core/theme/app_colors.dart';
import 'package:bellabox/core/theme/app_text_styles.dart';
import 'package:bellabox/shared/widgets/loaders/shimmer_box.dart';
import 'package:bellabox/shared/widgets/states/empty_state.dart';
import 'package:bellabox/shared/widgets/states/error_state.dart';

/// Static content pages via GET /pages/{slug}
/// (about, privacy-policy, terms, return-policy...)
final staticPageProvider = FutureProvider.autoDispose
    .family<({String title, String content}), String>((ref, slug) async {
  final dio = ref.watch(dioClientProvider);
  final res = await dio.get('${ApiEndpoints.page}/$slug');
  final body = res.data as Map<String, dynamic>;
  if (body['status'] != true) {
    throw DioException(
      requestOptions: RequestOptions(path: '${ApiEndpoints.page}/$slug'),
      message: body['message'] as String?,
    );
  }
  final data = body['data'] as Map<String, dynamic>? ?? {};
  return (
    title: data['title'] as String? ?? '',
    content: data['content'] as String? ?? '',
  );
});

class StaticPage extends ConsumerWidget {
  final String slug;
  const StaticPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(staticPageProvider(slug));

    return Scaffold(
      appBar: AppBar(
        title: pageAsync.valueOrNull != null
            ? Text(pageAsync.value!.title)
            : const SizedBox.shrink(),
      ),
      body: pageAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            ShimmerLine(width: 200, height: 20),
            SizedBox(height: 20),
            ShimmerLine(width: double.infinity, height: 12),
            SizedBox(height: 10),
            ShimmerLine(width: double.infinity, height: 12),
            SizedBox(height: 10),
            ShimmerLine(width: 240, height: 12),
          ],
        ),
        error: (e, _) => ErrorStateView(
          onRetry: () => ref.invalidate(staticPageProvider(slug)),
        ),
        data: (page) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          // TODO(phase5): render HTML content with flutter_html if the
          // backend returns rich HTML. Plain text stripping for MVP.
          child: Text(
            _stripHtml(page.content),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.9,
            ),
          ),
        ),
      ),
    );
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .trim();
  }
}

/// Notifications — MVP placeholder (backend list exists; push wiring is phase 5)
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('profile.notifications'))),
      body: EmptyState(
        icon: Icons.notifications_none_rounded,
        title: context.tr('notifications.empty'),
        body: context.tr('notifications.emptyHint'),
      ),
      // TODO(phase5): GET /notifications + POST /notifications/mark-read
      // + FCM device registration via /devices/register
    );
  }
}
