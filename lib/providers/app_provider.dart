import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/models/user_dto.dart' as api;

/// User capabilities
class UserCapabilities {
  final bool canApprove;
  final bool canViewBudgets;
  final String navType;

  const UserCapabilities({
    this.canApprove = false,
    this.canViewBudgets = false,
    this.navType = 'spender',
  });

  UserCapabilities copyWith({
    bool? canApprove,
    bool? canViewBudgets,
    String? navType,
  }) {
    return UserCapabilities(
      canApprove: canApprove ?? this.canApprove,
      canViewBudgets: canViewBudgets ?? this.canViewBudgets,
      navType: navType ?? this.navType,
    );
  }
}

/// Tab root screens
const Map<String, String> tabRootScreens = {
  'home': 'home',
  'approverHome': 'approverHome',
  'review': 'reviewApprove',
  'budget': 'budgetOverview',
  'cards': 'cards',
  'history': 'historyLog',
  'expenses': 'transactions',
  'alerts': 'notifications',
  'profile': 'profile',
};

/// App Provider - manages authentication, navigation, and UI state
class AppProvider extends ChangeNotifier {
  // Authentication state
  UserCapabilities _userCapabilities = const UserCapabilities();
  bool _isLoggedIn = false;

  // Navigation state
  List<String> _navigationStack = ['login'];
  Map<String, dynamic>? _navigationParams;

  // UI state
  bool _sideMenuOpen = false;
  bool _showAddExpenseSheet = false;
  bool _isUploadingReceipt = false;

  // Toast notification
  String? _toastMessage;
  String _toastType = 'success';

  // Notifications
  List<AppNotification> _notifications = [];

  // Getters
  UserCapabilities get userCapabilities => _userCapabilities;
  String get userRole => _userCapabilities.navType;
  bool get isLoggedIn => _isLoggedIn;

  // Always API mode - no demo mode
  bool get isApiMode => true;

  String get currentScreen => _navigationStack.last;
  List<String> get navigationStack => List.unmodifiable(_navigationStack);
  Map<String, dynamic>? get navigationParams => _navigationParams;

  bool get sideMenuOpen => _sideMenuOpen;
  bool get showAddExpenseSheet => _showAddExpenseSheet;
  bool get isUploadingReceipt => _isUploadingReceipt;

  String? get toastMessage => _toastMessage;
  String get toastType => _toastType;

  Map<String, dynamic>? get notification => _toastMessage != null
      ? {'message': _toastMessage, 'type': _toastType}
      : null;

  Map<String, dynamic>? get screenParams => _navigationParams;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadNotificationCount =>
      _notifications.where((n) => !n.read).length;

  /// Login with API user profile
  void loginWithApi(api.UserProfile user) {
    _isLoggedIn = true;
    _userCapabilities = UserCapabilities(
      canApprove: user.canApprove,
      canViewBudgets: user.canViewBudgets,
      navType: user.canApprove ? 'approver' : 'spender',
    );

    // Clear notifications on login
    _notifications = [];

    // Navigate to appropriate home screen
    final homeScreen = user.canApprove ? 'approverHome' : 'home';
    _navigationStack = [homeScreen];

    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userCapabilities = const UserCapabilities();
    _navigationStack = ['login'];
    _sideMenuOpen = false;
    _notifications = [];
    notifyListeners();
  }

  // Navigation methods
  void navigateTo(String screen, {bool trackHistory = true}) {
    if (trackHistory) {
      if (_navigationStack.last != screen) {
        _navigationStack.add(screen);
      }
    } else {
      _navigationStack[_navigationStack.length - 1] = screen;
    }
    _sideMenuOpen = false;
    notifyListeners();
  }

  void navigateToWithParams(String screen, Map<String, dynamic> params) {
    _navigationParams = params;
    navigateTo(screen);
  }

  void goBack({String fallback = 'home'}) {
    if (_navigationStack.length > 1) {
      _navigationStack.removeLast();
    } else {
      _navigationStack = [fallback];
    }
    notifyListeners();
  }

  void navigateToTab(String screen) {
    _navigationStack = [screen];
    _sideMenuOpen = false;
    notifyListeners();
  }

  void setCurrentScreen(String screen) {
    // Check if this is a tab root screen
    final isTabRoot = tabRootScreens.values.contains(screen);
    if (isTabRoot) {
      _navigationStack = [screen];
    } else {
      _navigationStack[_navigationStack.length - 1] = screen;
    }
    _sideMenuOpen = false;
    notifyListeners();
  }

  void clearNavigationParams() {
    _navigationParams = null;
    notifyListeners();
  }

  // UI state methods
  void setSideMenuOpen(bool open) {
    _sideMenuOpen = open;
    notifyListeners();
  }

  void toggleSideMenu() {
    _sideMenuOpen = !_sideMenuOpen;
    notifyListeners();
  }

  void setShowAddExpenseSheet(bool show) {
    _showAddExpenseSheet = show;
    notifyListeners();
  }

  void setIsUploadingReceipt(bool uploading) {
    _isUploadingReceipt = uploading;
    notifyListeners();
  }

  // Toast notifications
  void showNotification(String message, {String type = 'success'}) {
    _toastMessage = message;
    _toastType = type;
    notifyListeners();

    // Auto-clear after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      clearToast();
    });
  }

  void clearToast() {
    _toastMessage = null;
    notifyListeners();
  }

  void hideNotification() {
    clearToast();
  }

  // Notification queue methods
  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void markAllRead() {
    _notifications = _notifications.map((n) => n.copyWith(read: true)).toList();
    notifyListeners();
  }

  void markAllNotificationsRead() {
    markAllRead();
  }

  void markNotificationRead(int notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(read: true);
      notifyListeners();
    }
  }
}
