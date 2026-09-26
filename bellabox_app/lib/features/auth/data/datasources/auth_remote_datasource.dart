import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bellabox/core/constants/api_endpoints.dart';
import 'package:bellabox/core/network/dio_client.dart';
import 'package:bellabox/core/network/response_handler.dart';
import 'package:bellabox/features/auth/domain/entities/user.dart';

class AuthRemoteDataSource {
  final Dio _dio;
  AuthRemoteDataSource(this._dio);

  /// POST /auth/send-otp — { phone, purpose }
  Future<void> sendOtp({required String phone, String purpose = 'login'}) async {
    final res = await _dio.post(
      ApiEndpoints.sendOtp,
      data: {'phone': phone, 'purpose': purpose},
    );
    ensureSuccess(res);
  }

  /// POST /auth/verify-otp — { phone, code, purpose } → { token, user }
  Future<({String token, User user})> verifyOtp({
    required String phone,
    required String code,
    String purpose = 'login',
  }) async {
    final res = await _dio.post(
      ApiEndpoints.verifyOtp,
      data: {'phone': phone, 'code': code, 'purpose': purpose},
    );
    final body = ensureSuccess(res);
    final data = body['data'] as Map<String, dynamic>;
    return (
      token: data['token'] as String,
      user: User.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  /// GET /auth/me
  Future<User> me() async {
    final res = await _dio.get(ApiEndpoints.me);
    final body = ensureSuccess(res);
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// POST /auth/logout
  Future<void> logout() async {
    final res = await _dio.post(ApiEndpoints.logout);
    ensureSuccess(res);
  }

}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(dioClientProvider));
});
