import 'package:dio/dio.dart';

import 'package:bellabox/core/errors/exceptions.dart';

/// Validates the API envelope {status, message, data, ...}.
///
/// Because DioClient uses `validateStatus < 500`, 4xx responses arrive here
/// as normal responses (ErrorInterceptor never sees them). This helper maps
/// them to typed [AppException]s and throws them **wrapped in a
/// [DioException]** so that every existing `on DioException catch (e)` in
/// repositories/providers handles them uniformly, and checks like
/// `e.error is UnauthorizedException` (session expiry) work correctly.
Map<String, dynamic> ensureSuccess(Response res) {
  final body = res.data;
  if (body is Map<String, dynamic> && body['status'] == true) {
    return body;
  }

  final map = body is Map<String, dynamic> ? body : const <String, dynamic>{};
  final message = map['message'] as String? ?? 'حدث خطأ';
  final errorCode = map['error_code'] as String?;
  final errors = map['errors'] as Map<String, dynamic>?;

  final AppException exception = switch (res.statusCode) {
    401 => UnauthorizedException(message),
    404 => NotFoundException(message),
    422 => ValidationException(message, errors: errors),
    429 => RateLimitException(message),
    _ => ServerException(
        message,
        statusCode: res.statusCode,
        errorCode: errorCode,
      ),
  };

  throw DioException(
    requestOptions: res.requestOptions,
    response: res,
    type: DioExceptionType.badResponse,
    error: exception,
    message: exception.message,
  );
}
