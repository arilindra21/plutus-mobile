/// Base service with common API functionality
///
/// Provides standardized HTTP methods (GET, POST, PUT, DELETE)
/// to reduce code duplication across all service classes.
library base_service;

import 'package:dio/dio.dart';
import '../api_result.dart';
import '../dio_client.dart';

/// Base service for common API operations
///
/// All services should extend this to use standardized request handling.
class BaseService {
  final Dio _dio;

  BaseService() : _dio = DioClient().dio;

  /// Standardized GET request
  ///
  /// Makes a GET request to the specified endpoint.
  /// Returns parsed data or error if request fails.
  Future<ApiResult<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
      );
      final data = parser?.call(response.data) ?? response.data;
      return ApiResult.success(data);
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    } catch (e) {
      return ApiResult.failure(ApiError(message: e.toString()));
    }
  }

  /// Standardized POST request
  ///
  /// Makes a POST request with the specified body.
  /// Returns parsed data or error if request fails.
  Future<ApiResult<T>> post<T>(
    String endpoint, {
    dynamic body,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: body,
      );
      final data = parser?.call(response.data) ?? response.data;
      return ApiResult.success(data);
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    } catch (e) {
      return ApiResult.failure(ApiError(message: e.toString()));
    }
  }

  /// Standardized PUT request
  ///
  /// Makes a PUT request with the specified body.
  /// Returns parsed data or error if request fails.
  Future<ApiResult<T>> put<T>(
    String endpoint, {
    dynamic body,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: body,
      );
      final data = parser?.call(response.data) ?? response.data;
      return ApiResult.success(data);
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    } catch (e) {
      return ApiResult.failure(ApiError(message: e.toString()));
    }
  }

  /// Standardized DELETE request
  ///
  /// Makes a DELETE request to the specified endpoint.
  /// Returns success or error if request fails.
  Future<ApiResult<bool>> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return ApiResult.success(response.statusCode == 200 || response.statusCode == 204);
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    } catch (e) {
      return ApiResult.failure(ApiError(message: e.toString()));
    }
  }

  /// Standardized PATCH request
  ///
  /// Makes a PATCH request with the specified body.
  /// Returns parsed data or error if request fails.
  Future<ApiResult<T>> patch<T>(
    String endpoint, {
    dynamic body,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: body,
      );
      final data = parser?.call(response.data) ?? response.data;
      return ApiResult.success(data);
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    } catch (e) {
      return ApiResult.failure(ApiError(message: e.toString()));
    }
  }

  /// Standardized file upload request
  ///
  /// Makes a multipart file upload request.
  /// Returns parsed data or error if request fails.
  Future<ApiResult<T>> upload<T>(
    String endpoint,
    dynamic formData, {
    T Function(dynamic)? parser,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: formData,
        onSendProgress: onSendProgress != null
            ? (sent, total) => onSendProgress(sent, total)
            : null,
      );
      final data = parser?.call(response.data) ?? response.data;
      return ApiResult.success(data);
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    } catch (e) {
      return ApiResult.failure(ApiError(message: e.toString()));
    }
  }
}
