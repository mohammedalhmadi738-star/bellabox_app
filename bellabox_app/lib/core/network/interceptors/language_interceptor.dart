import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bellabox/core/constants/storage_keys.dart';

class LanguageInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(StorageKeys.language) ?? 'ar';
    options.headers['Accept-Language'] = lang;
    handler.next(options);
  }
}
