/// Base provider with common functionality
///
/// Provides consistent loading states, error handling, and lifecycle management
/// across all providers to reduce code duplication.
library base_provider;

import 'package:flutter/foundation.dart';
import '../../services/api/api_result.dart';

/// Base provider with common functionality
///
/// Extend this class in your providers to get:
/// - Standardized loading states
/// - Standardized error handling
/// - Common setter methods
abstract class BaseProvider extends ChangeNotifier {
  // Common state
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  // Getters - unmodifiable read access
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get hasError => _error != null;
  String? get error => _error;

  /// Set loading state and notify listeners
  ///
  /// Use this for data fetching operations.
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set submitting state and notify listeners
  ///
  /// Use this for form submission or write operations.
  void setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  /// Set error and notify listeners
  ///
  /// Use this for error reporting from API operations.
  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  /// Clear error and notify listeners
  ///
  /// Use this when error has been resolved or displayed.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Handle API result with standard error handling
  ///
  /// Updates loading state, error state, and optionally calls callbacks.
  void handleApiResult(
    ApiResult result, {
    VoidCallback? onSuccess,
    VoidCallback? onError,
    bool clearPreviousError = true,
  }) {
    if (clearPreviousError) {
      clearError();
    }

    if (result.isSuccess) {
      onSuccess?.call();
    } else {
      setError(result.error?.toString());
      onError?.call();
    }
  }
}
