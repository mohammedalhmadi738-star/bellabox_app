import 'package:dio/dio.dart';
import 'package:bellabox/core/storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for public endpoints (login/register/otp)
    final path = options.path;
    final isAuthPath = path.startsWith('/auth/') &&
        !path.contains('/me') &&
        !path.contains('/logout');
    if (!isAuthPath) {
      final token = await SecureStorage.instance.read(SecureStorage.tokenKey);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }
}
