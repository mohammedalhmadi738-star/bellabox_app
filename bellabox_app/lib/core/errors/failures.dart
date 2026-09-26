import 'package:equatable/equatable.dart';
import 'exceptions.dart';

sealed class Failure extends Equatable {
  final String message;
  final String? errorCode;

  const Failure(this.message, {this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'لا يوجد اتصال بالإنترنت']);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.errorCode});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'يجب تسجيل الدخول أولاً'])
      : super(errorCode: 'UNAUTHENTICATED');
}

class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;
  const ValidationFailure(super.message, {this.fieldErrors})
      : super(errorCode: 'VALIDATION_FAILED');

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'العنصر غير موجود'])
      : super(errorCode: 'NOT_FOUND');
}

class RateLimitFailure extends Failure {
  const RateLimitFailure([super.message = 'عدد كبير من المحاولات، حاول لاحقاً'])
      : super(errorCode: 'RATE_LIMIT_EXCEEDED');
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'خطأ في التخزين المحلي']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'حدث خطأ غير متوقع']);
}

/// Convert exception to failure
Failure mapExceptionToFailure(Object e) {
  if (e is NetworkException) return NetworkFailure(e.message);
  if (e is UnauthorizedException) return UnauthorizedFailure(e.message);
  if (e is ValidationException) {
    final fe = e.errors?.map((k, v) => MapEntry(k, List<String>.from(v as List)));
    return ValidationFailure(e.message, fieldErrors: fe);
  }
  if (e is NotFoundException) return NotFoundFailure(e.message);
  if (e is RateLimitException) return RateLimitFailure(e.message);
  if (e is CacheException) return CacheFailure(e.message);
  if (e is ServerException) return ServerFailure(e.message, errorCode: e.errorCode);
  return UnknownFailure(e.toString());
}
