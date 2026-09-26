/// Mirrors the backend response envelope:
/// { status, message, data, errors?, meta?, error_code? }
class ApiResponse<T> {
  final bool status;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;
  final Map<String, dynamic>? meta;
  final String? errorCode;

  const ApiResponse({
    required this.status,
    required this.message,
    this.data,
    this.errors,
    this.meta,
    this.errorCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? data)? fromDataT,
  ) {
    return ApiResponse<T>(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: fromDataT != null ? fromDataT(json['data']) : json['data'] as T?,
      errors: json['errors'] as Map<String, dynamic>?,
      meta: json['meta'] as Map<String, dynamic>?,
      errorCode: json['error_code'] as String?,
    );
  }
}

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  bool get hasNext => currentPage < lastPage;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => PaginationMeta(
        currentPage: json['current_page'] as int? ?? 1,
        lastPage: json['last_page'] as int? ?? 1,
        perPage: json['per_page'] as int? ?? 20,
        total: json['total'] as int? ?? 0,
      );

  factory PaginationMeta.empty() =>
      const PaginationMeta(currentPage: 1, lastPage: 1, perPage: 20, total: 0);
}
