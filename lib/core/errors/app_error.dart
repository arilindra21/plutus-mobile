/// Centralized error types and handling
///
/// Provides type-safe error definitions and common error
/// messages throughout the application.
import 'package:flutter/material.dart';
import '../design_tokens.dart';

/// App exception type
enum AppErrorType {
  /// Network connectivity issues
  network,

  /// Authentication and authorization failures
  authentication,

  /// Form validation errors
  validation,

  /// Resource not found errors
  notFound,

  /// Server-side errors
  server,

  /// Unknown or unexpected errors
  unknown,

  /// Permission denied errors
  permissionDenied,

  /// Timeout errors
  timeout,

  /// Parsing errors
  parsing,
}

/// Common error messages
class AppErrorMessages {
  static const String networkError = 'Network connection failed. Please check your internet connection.';
  static const String authenticationError = 'Authentication failed. Please log in again.';
  static const String permissionError = 'You do not have permission to perform this action.';
  static const String notFoundError = 'The requested resource was not found.';
  static const String serverError = 'Server error occurred. Please try again later.';
  static const String timeoutError = 'Request timed out. Please try again.';
  static const String validationError = 'Please check your input and try again.';
  static const String unknownError = 'An unexpected error occurred.';
  static const String expenseNotFound = 'Expense not found.';
  static const String receiptUploadFailed = 'Failed to upload receipt. Please try again.';
  static const String ocrFailed = 'Failed to process receipt with OCR.';
  static const String approvalFailed = 'Failed to approve expense. Please try again.';
  static const String submitFailed = 'Failed to submit expense.';
}

/// App exception for type-safe error handling
///
/// Wrap application errors with this class for consistent
/// error handling and user feedback.
class AppException implements Exception {
  final String message;
  final AppErrorType type;
  final dynamic details;
  final int? statusCode;
  final String? userFriendlyMessage;

  const AppException({
    required this.message,
    required this.type,
    this.details,
    this.statusCode,
    this.userFriendlyMessage,
  });

  /// Create a network error
  factory AppException.network({
    String message = AppErrorMessages.networkError,
    int? statusCode,
    dynamic details,
  }) {
    return AppException(
      message: message,
      type: AppErrorType.network,
      statusCode: statusCode,
      details: details,
    );
  }

  /// Create an authentication error
  factory AppException.authentication({
    String message = AppErrorMessages.authenticationError,
    int? statusCode,
    dynamic details,
  }) {
    return AppException(
      message: message,
      type: AppErrorType.authentication,
      statusCode: statusCode,
      details: details,
    );
  }

  /// Create a validation error
  factory AppException.validation({
    required String message,
    dynamic details,
  }) {
    return AppException(
      message: message,
      type: AppErrorType.validation,
      details: details,
    );
  }

  /// Create a not found error
  factory AppException.notFound({
    String message = AppErrorMessages.notFoundError,
    dynamic details,
  }) {
    return AppException(
      message: message,
      type: AppErrorType.notFound,
      details: details,
    );
  }

  /// Create a server error
  factory AppException.server({
    String message = AppErrorMessages.serverError,
    int? statusCode,
    dynamic details,
  }) {
    return AppException(
      message: message,
      type: AppErrorType.server,
      statusCode: statusCode,
      details: details,
    );
  }

  /// Create a permission denied error
  factory AppException.permissionDenied({
    String message = AppErrorMessages.permissionError,
  int? statusCode,
    dynamic details,
  }) {
    return AppException(
      message: message,
      type: AppErrorType.permissionDenied,
      statusCode: statusCode,
      details: details,
    );
  }

  /// Create a timeout error
  factory AppException.timeout({
    String message = AppErrorMessages.timeoutError,
    dynamic details,
  }) {
    return AppException(
      message: message,
      type: AppErrorType.timeout,
      details: details,
    );
  }

  /// Create an unknown error
  factory AppException.unknown({
    String message = AppErrorMessages.unknownError,
    dynamic details,
  }) {
    return AppException(
      message: message,
      type: AppErrorType.unknown,
      details: details,
    );
  }

  /// Get user-friendly message
  String get displayMessage => userFriendlyMessage ?? message;

  @override
  String toString() => 'AppException: $message (type: $type)';
}

/// Error handling utilities
///
/// Helper methods for consistent error handling.
class ErrorHelper {
  /// Check if error is a network error
  static bool isNetworkError(dynamic error) {
    return error is AppException && (error as AppException).type == AppErrorType.network;
  }

  /// Check if error is an authentication error
  static bool isAuthenticationError(dynamic error) {
    return error is AppException && (error as AppException).type == AppErrorType.authentication;
  }

  /// Check if error is a validation error
  static bool isValidationError(dynamic error) {
    return error is AppException && (error as AppException).type == AppErrorType.validation;
  }

  /// Get error message from any error type
  static String getMessage(dynamic error) {
    if (error is AppException) {
      return (error as AppException).displayMessage;
    } else if (error is String) {
      return error;
    }
    return AppErrorMessages.unknownError;
  }

  /// Show error snackbar
  static void showErrorSnackbar(BuildContext context, dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(getMessage(error)),
        backgroundColor: AppColors.statusRejected,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.statusApproved,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show info snackbar
  static void showInfoSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: FintechColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
