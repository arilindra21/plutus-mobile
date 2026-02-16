import 'package:dio/dio.dart';

/// Wrapper for API responses with error handling
class ApiResult<T> {
  final T? data;
  final ApiError? error;
  final bool isSuccess;

  ApiResult._({
    this.data,
    this.error,
    required this.isSuccess,
  });

  factory ApiResult.success(T data) {
    return ApiResult._(data: data, isSuccess: true);
  }

  factory ApiResult.failure(ApiError error) {
    return ApiResult._(error: error, isSuccess: false);
  }

  factory ApiResult.fromDioError(DioException e) {
    return ApiResult._(
      error: ApiError.fromDioException(e),
      isSuccess: false,
    );
  }
}

/// API error representation
class ApiError {
  final int? statusCode;
  final String message;
  final String? detail;

  ApiError({
    this.statusCode,
    required this.message,
    this.detail,
  });

  factory ApiError.fromDioException(DioException e) {
    final response = e.response;

    if (response != null) {
      final data = response.data;
      String message = 'An error occurred';
      String? detail;

      if (data is Map<String, dynamic>) {
        message = data['title'] ?? data['message'] ?? message;
        detail = data['detail'];
      }

      return ApiError(
        statusCode: response.statusCode,
        message: message,
        detail: detail,
      );
    }

    // Network errors
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return ApiError(message: 'Connection timeout');
      case DioExceptionType.sendTimeout:
        return ApiError(message: 'Send timeout');
      case DioExceptionType.receiveTimeout:
        return ApiError(message: 'Receive timeout');
      case DioExceptionType.connectionError:
        return ApiError(message: 'No internet connection');
      default:
        return ApiError(message: e.message ?? 'Unknown error');
    }
  }

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isValidationError => statusCode == 400;

  @override
  String toString() => detail ?? message;
}

/// Pagination metadata from API responses
class PaginationMeta {
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  PaginationMeta({
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      hasNext: json['hasNext'] ?? false,
      hasPrev: json['hasPrev'] ?? false,
    );
  }
}

/// Paginated response wrapper
class PaginatedResult<T> {
  final List<T> data;
  final PaginationMeta pagination;

  PaginatedResult({
    required this.data,
    required this.pagination,
  });
}
