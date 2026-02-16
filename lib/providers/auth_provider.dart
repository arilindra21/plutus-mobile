import 'package:flutter/material.dart';
import '../services/services.dart';

/// Authentication state enum
enum AuthStatus {
  initial,
  authenticating,
  authenticated,
  unauthenticated,
  error,
}

/// Auth Provider - manages authentication state with real API
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final TokenStorage _tokenStorage = TokenStorage();

  AuthStatus _status = AuthStatus.initial;
  UserProfile? _user;
  UserCapabilities _capabilities = UserCapabilities();
  String? _errorMessage;
  bool _isLoading = false;

  // Tenant context
  String? _organizationId;
  String? _entityId;
  List<OrganizationOption> _organizations = [];
  List<EntityOption> _entities = [];

  // Getters
  AuthStatus get status => _status;
  UserProfile? get user => _user;
  UserCapabilities get capabilities => _capabilities;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get organizationId => _organizationId;
  String? get entityId => _entityId;
  List<OrganizationOption> get organizations => _organizations;
  List<EntityOption> get entities => _entities;

  // Legacy getters for compatibility
  String get userRole => _capabilities.navType;
  bool get canApprove => _capabilities.canApprove;
  bool get canViewBudgets => _capabilities.canViewBudgets;
  String get userName => _user?.name ?? '';
  String get userInitials => _user?.initials ?? 'U';
  String get userEmail => _user?.email ?? '';
  int get jobLevel => _user?.jobLevel ?? 0;

  /// Initialize - check for existing session
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final hasTokens = await _tokenStorage.hasValidTokens();
      if (hasTokens) {
        // Try to fetch current user
        final result = await _authService.getMe();
        if (result.isSuccess) {
          _user = result.data;
          _capabilities = UserCapabilities.fromPermissions(
            _user!.permissions,
            _user!.jobLevel,
          );
          _organizationId = await _tokenStorage.getOrganizationId();
          _entityId = await _tokenStorage.getEntityId();
          _status = AuthStatus.authenticated;
        } else {
          // Token invalid, clear it
          await _tokenStorage.clearTokens();
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    _isLoading = true;
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.login(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );

    if (result.isSuccess) {
      _user = result.data!.user;
      _capabilities = UserCapabilities.fromPermissions(
        _user!.permissions,
        _user!.jobLevel,
      );
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _status = AuthStatus.error;
      _errorMessage = result.error?.toString() ?? 'Login failed';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// SSO Login
  Future<bool> loginSSO({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.loginSSO(
      email: email,
      password: password,
    );

    if (result.isSuccess) {
      _user = result.data!.user;
      _capabilities = UserCapabilities.fromPermissions(
        _user!.permissions,
        _user!.jobLevel,
      );
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _status = AuthStatus.error;
      _errorMessage = result.error?.toString() ?? 'SSO login failed';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();

    _user = null;
    _capabilities = UserCapabilities();
    _organizationId = null;
    _entityId = null;
    _status = AuthStatus.unauthenticated;
    _isLoading = false;
    DioClient.reset();

    notifyListeners();
  }

  /// Refresh user profile
  Future<void> refreshProfile() async {
    final result = await _authService.getMe();
    if (result.isSuccess) {
      _user = result.data;
      _capabilities = UserCapabilities.fromPermissions(
        _user!.permissions,
        _user!.jobLevel,
      );
      notifyListeners();
    }
  }

  /// Set tenant context
  void setTenantContext({
    required String organizationId,
    required String entityId,
  }) {
    _organizationId = organizationId;
    _entityId = entityId;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

/// Organization selection option
class OrganizationOption {
  final String id;
  final String name;
  final String? code;

  OrganizationOption({
    required this.id,
    required this.name,
    this.code,
  });
}

/// Entity selection option
class EntityOption {
  final String id;
  final String name;
  final String? code;
  final String organizationId;

  EntityOption({
    required this.id,
    required this.name,
    this.code,
    required this.organizationId,
  });
}
