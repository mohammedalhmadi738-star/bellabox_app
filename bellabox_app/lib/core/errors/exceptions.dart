class AppException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final Map<String, dynamic>? errors;

  const AppException(
    this.message, {
    this.statusCode,
    this.errorCode,
    this.errors,
  });

  @override
  String toString() => 'AppException($statusCode $errorCode): $message';
}

class NetworkException extends AppException {
  const NetworkException([String message = 'لا يوجد اتصال بالإنترنت']) : super(message);
}

class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode, super.errorCode});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([String message = 'يجب تسجيل الدخول أولاً'])
      : super(message, statusCode: 401, errorCode: 'UNAUTHENTICATED');
}

class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    super.errors,
  }) : super(statusCode: 422, errorCode: 'VALIDATION_FAILED');
}

class NotFoundException extends AppException {
  const NotFoundException([String message = 'العنصر غير موجود'])
      : super(message, statusCode: 404, errorCode: 'NOT_FOUND');
}

class RateLimitException extends AppException {
  const RateLimitException([String message = 'عدد كبير من المحاولات، حاول لاحقاً'])
      : super(message, statusCode: 429, errorCode: 'RATE_LIMIT_EXCEEDED');
}

class CacheException extends AppException {
  const CacheException([String message = 'خطأ في التخزين المحلي']) : super(message);
}
