import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Minimal, dependency-free localization.
/// Loads assets/translations/{locale}.json.
class AppLocalizations {
  final Locale locale;
  Map<String, dynamic> _strings = {};

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    final loc = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(loc != null, 'AppLocalizations missing — did you add the delegate?');
    return loc!;
  }

  Future<void> _load() async {
    final jsonStr =
        await rootBundle.loadString('assets/translations/${locale.languageCode}.json');
    _strings = json.decode(jsonStr) as Map<String, dynamic>;
  }

  /// Nested key access: "auth.loginTitle" or "orders.status.pending"
  String tr(String key, {Map<String, String>? args}) {
    dynamic node = _strings;
    for (final part in key.split('.')) {
      if (node is Map<String, dynamic> && node.containsKey(part)) {
        node = node[part];
      } else {
        if (kDebugMode) debugPrint('Missing translation: $key');
        return key;
      }
    }
    var result = node is String ? node : key;
    if (args != null) {
      args.forEach((k, v) => result = result.replaceAll('{$k}', v));
    }
    return result;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _Delegate();
}

class _Delegate extends LocalizationsDelegate<AppLocalizations> {
  const _Delegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final loc = AppLocalizations(locale);
    await loc._load();
    return loc;
  }

  @override
  bool shouldReload(_Delegate old) => false;
}

extension AppLocalizationsX on BuildContext {
  String tr(String key, {Map<String, String>? args}) =>
      AppLocalizations.of(this).tr(key, args: args);
}
