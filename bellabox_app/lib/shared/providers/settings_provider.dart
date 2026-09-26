import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bellabox/core/constants/api_endpoints.dart';
import 'package:bellabox/core/constants/storage_keys.dart';
import 'package:bellabox/core/network/dio_client.dart';
import 'package:bellabox/core/storage/local_storage.dart';

/// App-wide settings from GET /settings (currency, VAT, contact, versions).
/// Falls back to cached copy when offline.
class AppSettings {
  final Map<String, dynamic> raw;
  const AppSettings(this.raw);

  int get vatPercentage => raw['vat_percentage'] as int? ?? 15;
  String get currency => raw['currency'] as String? ?? 'SAR';
  num get freeShippingThreshold =>
      raw['free_shipping_threshold'] as num? ?? 200;
  String? get supportPhone => raw['support_phone'] as String?;
  String? get supportEmail => raw['support_email'] as String?;

  factory AppSettings.empty() => const AppSettings({});
}

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => AppSettings.empty();

  Future<void> preload() async {
    // 1. Load cached copy for instant availability
    final cached = LocalStorage.prefs.getString(StorageKeys.settingsCache);
    if (cached != null) {
      try {
        state = AppSettings(jsonDecode(cached) as Map<String, dynamic>);
      } catch (_) {}
    }

    // 2. Fetch fresh (graceful failure — keep cached on error)
    try {
      final dio = ref.read(dioClientProvider);
      final res = await dio.get(ApiEndpoints.settings);
      final body = res.data as Map<String, dynamic>;
      if (body['status'] == true && body['data'] is Map<String, dynamic>) {
        final data = body['data'] as Map<String, dynamic>;
        state = AppSettings(data);
        await LocalStorage.prefs
            .setString(StorageKeys.settingsCache, jsonEncode(data));
        await LocalStorage.prefs.setString(
          StorageKeys.settingsCachedAt,
          DateTime.now().toIso8601String(),
        );
      }
    } on DioException {
      // Offline / server error → keep cached (already set above)
    } catch (_) {}
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
