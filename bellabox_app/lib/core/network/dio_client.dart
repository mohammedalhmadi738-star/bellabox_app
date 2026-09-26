import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'package:bellabox/core/env/env_config.dart';
import 'package:bellabox/core/network/interceptors/auth_interceptor.dart';
import 'package:bellabox/core/network/interceptors/language_interceptor.dart';
import 'package:bellabox/core/network/interceptors/error_interceptor.dart';

final dioClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: EnvConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      // Do NOT throw on 4xx — let interceptor handle
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  dio.interceptors.addAll([
    LanguageInterceptor(),
    AuthInterceptor(),
    ErrorInterceptor(),
    if (EnvConfig.enableLogging)
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
  ]);

  return dio;
});
