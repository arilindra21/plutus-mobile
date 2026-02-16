import 'package:dio/dio.dart';
import 'dio_client.dart';
import 'token_storage.dart';
import 'api_result.dart';
import '../models/user_dto.dart';

/// Authentication service for login, logout, and user profile operations
class AuthService {
  final Dio _dio = DioClient().dio;
  final TokenStorage _tokenStorage = TokenStorage();

  /// Login with email and password
  Future<ApiResult<LoginResponse>> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final loginResponse = LoginResponse.fromJson(response.data);

      // Save tokens
      await _tokenStorage.saveTokens(
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
      );

      return ApiResult.success(loginResponse);
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// SSO Login via Milky Way
  Future<ApiResult<LoginResponse>> loginSSO({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login/sso',
        data: {
          'email': email,
          'password': password,
        },
      );

      final loginResponse = LoginResponse.fromJson(response.data);

      await _tokenStorage.saveTokens(
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
      );

      return ApiResult.success(loginResponse);
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Logout current user
  Future<ApiResult<void>> logout() async {
    try {
      await _dio.post('/auth/logout');
      await _tokenStorage.clearAll();
      DioClient.reset();
      return ApiResult.success(null);
    } on DioException catch (e) {
      // Still clear tokens even if server logout fails
      await _tokenStorage.clearAll();
      DioClient.reset();
      return ApiResult.fromDioError(e);
    }
  }

  /// Get current user profile
  Future<ApiResult<UserProfile>> getMe() async {
    try {
      final response = await _dio.get('/auth/me');
      return ApiResult.success(UserProfile.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Refresh access token
  Future<ApiResult<void>> refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        return ApiResult.failure(ApiError(message: 'No refresh token'));
      }

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      await _tokenStorage.saveTokens(
        accessToken: response.data['accessToken'],
        refreshToken: response.data['refreshToken'],
      );

      return ApiResult.success(null);
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Request password reset
  Future<ApiResult<void>> requestPasswordReset({
    required String email,
    required String organizationId,
  }) async {
    try {
      await _dio.post(
        '/auth/request-password-reset',
        data: {
          'email': email,
          'orgId': organizationId,
        },
      );
      return ApiResult.success(null);
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Change password (authenticated user)
  Future<ApiResult<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _dio.post(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
      return ApiResult.success(null);
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Check if user has valid session
  Future<bool> isAuthenticated() async {
    return _tokenStorage.hasValidTokens();
  }

  /// Get user by ID
  Future<ApiResult<UserProfile>> getUser(String userId) async {
    try {
      final response = await _dio.get('/api/v1/users/$userId');
      return ApiResult.success(UserProfile.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }
}

/// Login response from the API
class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final UserProfile user;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      user: UserProfile.fromJson(json['user'] ?? {}),
    );
  }
}
