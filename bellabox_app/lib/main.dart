import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bellabox/app.dart';
import 'package:bellabox/core/storage/local_storage.dart';
import 'package:bellabox/core/storage/secure_storage.dart';
import 'package:bellabox/core/theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait only (e-commerce UX)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Storage init (SharedPreferences + Hive boxes + secure storage)
  await LocalStorage.init();
  await SecureStorage.init();

  runApp(
    const ProviderScope(
      child: BellaBoxApp(),
    ),
  );
}
