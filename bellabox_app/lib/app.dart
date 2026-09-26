import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bellabox/core/localization/app_localizations.dart';
import 'package:bellabox/core/routing/app_router.dart';
import 'package:bellabox/core/theme/app_theme.dart';
import 'package:bellabox/shared/providers/locale_provider.dart';

class BellaBoxApp extends ConsumerWidget {
  const BellaBoxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Bella Box',
      debugShowCheckedModeBanner: false,
      routerConfig: router,

      // ── Theme ──
      theme: AppTheme.light,
      darkTheme: AppTheme.dark, // Placeholder (mirrors light for MVP)
      themeMode: ThemeMode.light,

      // ── Localization (AR default, RTL-first) ──
      locale: locale,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
