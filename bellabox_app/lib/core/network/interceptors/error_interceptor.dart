import 'dart:io';
import 'package:dio/dio.dart';
import 'package:bellabox/core/errors/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapDioException(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
        message: exception.message,
      ),
    );
  }

  AppException _mapDioException(DioException err) {
    if (err.error is SocketException || err.type == DioExceptionType.connectionError) {
      return const NetworkException();
    }
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return const NetworkException('انتهت مهلة الاتصال، حاول مرة أخرى');
    }

    final response = err.response;
    if (response == null) {
      return AppException(err.message ?? 'حدث خطأ غير متوقع');
    }

    final data = response.data;
    Map<String, dynamic>? body;
    if (data is Map<String, dynamic>) {
      body = data;
    }

    final message = body?['message'] as String? ?? 'حدث خطأ';
    final errorCode = body?['error_code'] as String?;
    final errors = body?['errors'] as Map<String, dynamic>?;
    final statusCode = response.statusCode;

    switch (statusCode) {
      case 401:
        return UnauthorizedException(message);
      case 404:
        return NotFoundException(message);
      case 422:
        return ValidationException(message, errors: errors);
      case 429:
        return RateLimitException(message);
      default:
        return ServerException(
          message,
          statusCode: statusCode,
          errorCode: errorCode,
        );
    }
  }
}
