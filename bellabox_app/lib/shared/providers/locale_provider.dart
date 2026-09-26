import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bellabox/core/constants/storage_keys.dart';
import 'package:bellabox/core/storage/local_storage.dart';

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final code = LocalStorage.prefs.getString(StorageKeys.language) ?? 'ar';
    return Locale(code);
  }

  Future<void> setLocale(String code) async {
    await LocalStorage.prefs.setString(StorageKeys.language, code);
    state = Locale(code);
  }

  void toggle() {
    setLocale(state.languageCode == 'ar' ? 'en' : 'ar');
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
