import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../config/environment.dart';
import 'token_storage.dart';

/// Singleton Dio HTTP client with authentication interceptor
class DioClient {
  static DioClient? _instance;
  late final Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Environment.apiBaseUrl,
        connectTimeout: Duration(milliseconds: Environment.connectTimeout),
        receiveTimeout: Duration(milliseconds: Environment.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(_tokenStorage, _dio),
      if (Environment.enableLogging) _LoggingInterceptor(),
    ]);
  }

  factory DioClient() {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  Dio get dio => _dio;

  /// Clear the singleton instance (useful for logout)
  static void reset() {
    _instance = null;
  }
}

/// Interceptor that adds auth token and handles token refresh
class _AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final Dio _dio;
  bool _isRefreshing = false;

  _AuthInterceptor(this._tokenStorage, this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for public endpoints
    final publicPaths = [
      '/auth/login',
      '/auth/login/sso',
      '/auth/refresh',
      '/auth/request-password-reset',
      '/auth/reset-password',
      '/auth/validate-invite',
      '/auth/accept-invite',
      '/health',
      '/ready',
    ];

    final isPublic = publicPaths.any((path) => options.path.contains(path));

    if (!isPublic) {
      try {
        final token = await _tokenStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      } catch (e) {
        // Ignore token storage errors, continue without auth
        debugPrint('AuthInterceptor: Error getting token: $e');
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;

      try {
        final refreshToken = await _tokenStorage.getRefreshToken();
        if (refreshToken != null) {
          final response = await _dio.post(
            '/auth/refresh',
            data: {'refreshToken': refreshToken},
          );

          if (response.statusCode == 200) {
            final newAccessToken = response.data['accessToken'];
            final newRefreshToken = response.data['refreshToken'];

            await _tokenStorage.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );

            // Retry the original request
            final retryOptions = err.requestOptions;
            retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await _dio.fetch(retryOptions);
            _isRefreshing = false;
            return handler.resolve(retryResponse);
          }
        }
      } catch (e) {
        // Refresh failed, try to clear tokens
        debugPrint('AuthInterceptor: Token refresh failed: $e');
        try {
          await _tokenStorage.clearTokens();
        } catch (_) {
          // Ignore clear errors
        }
      }

      _isRefreshing = false;
    }

    handler.next(err);
  }
}

/// Logging interceptor for debugging
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('==> ${options.method} ${options.uri}');
      if (options.data != null) {
        debugPrint('Body: ${options.data}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('<== ${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('<== ERROR ${err.response?.statusCode} ${err.requestOptions.uri}');
      debugPrint('Message: ${err.message}');
    }
    handler.next(err);
  }
}
