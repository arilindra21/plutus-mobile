import 'package:flutter/material.dart';

/// Type-safe navigation routes
///
/// Centralizes all route strings and provides navigation methods
/// to avoid hardcoded string literals throughout the codebase.
class AppRoutes {
  // Auth routes
  static const String login = '/login';
  static const String apiLogin = '/api-login';

  // Home routes
  static const String home = '/home';
  static const String dashboard = '/dashboard';

  // Expense routes
  static const String expenses = '/expenses';
  static const String expenseList = '/expenses/list';
  static const String expenseDetail = '/expenses/detail';
  static const String newExpense = '/expenses/new';

  // Approval routes
  static const String approval = '/approval';
  static const String approvalInbox = '/approval/inbox';
  static const String approvalDetail = '/approval/detail';
  static const String reviewApprove = '/approval/review';

  // Budget routes
  static const String budget = '/budget';
  static const String budgetOverview = '/budget/overview';
  static const String budgetDetails = '/budget/details';

  // Card routes
  static const String cards = '/cards';
  static const String cardList = '/cards/list';
  static const String cardDetail = '/cards/detail';
  static const String cardTransactions = '/cards/transactions';

  // Transaction routes
  static const String transactions = '/transactions';
  static const String transactionList = '/transactions/list';
  static const String transactionDetail = '/transactions/detail';

  // Notification routes
  static const String notifications = '/notifications';

  // Camera routes
  static const String camera = '/camera';
  static const String cameraAttach = '/camera/attach';
  static const String cameraScan = '/camera/scan';

  // Receipt routes
  static const String receiptViewer = '/receipt/viewer';
}

/// Helper methods for navigation
///
/// Provides type-safe navigation methods with argument passing.
class NavigationHelper {
  /// Navigate to a route with optional arguments
  ///
  /// ```dart
  /// NavigationHelper.navigateTo(context, AppRoutes.expenseDetail, arguments: expenseId);
  /// ```
  static void navigateTo(
    BuildContext context,
    String route, {
    dynamic arguments,
  }) {
    Navigator.of(context).pushNamed(route, arguments: arguments);
  }

  /// Navigate to a route and replace the current route
  ///
  /// Use this when navigating to a new screen that replaces the current one.
  static void navigateReplacement(
    BuildContext context,
    String route, {
    dynamic arguments,
  }) {
    Navigator.of(context).pushReplacementNamed(route, arguments: arguments);
  }

  /// Navigate to a route and clear all previous routes
  ///
  /// Use this for login screens to prevent going back.
  static void navigateAndClear(
    BuildContext context,
    String route, {
    dynamic arguments,
  }) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(route, (route) => false, arguments: arguments);
  }

  /// Pop the current route
  ///
  /// Returns to the previous screen with optional result.
  static void pop(BuildContext context, {dynamic result}) {
    Navigator.of(context).pop(result);
  }

  /// Pop multiple routes at once
  ///
  /// Returns to a specific route in the navigation stack.
  static void popUntil(BuildContext context, String routeName) {
    Navigator.of(context).popUntil((route) => route.settings.name == routeName);
  }

  /// Pop all routes to root
  ///
  /// Returns to the bottom of the navigation stack.
  static void popToRoot(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Get arguments passed to the current route
  ///
  /// ```dart
  /// final expenseId = NavigationHelper.getArgument<String>(context);
  /// ```
  static T? getArgument<T>(BuildContext context) {
    return ModalRoute.of(context)?.settings.arguments as T?;
  }

  /// Check if a specific argument was passed
  ///
  /// ```dart
  /// if (NavigationHelper.hasArgument<String>(context)) {
  ///   // Process argument
  /// }
  /// ```
  static bool hasArgument<T>(BuildContext context) {
    return ModalRoute.of(context)?.settings.arguments is T;
  }
}

/// Extension to add navigation methods directly to BuildContext
///
/// Allows for more concise navigation code:
/// ```dart
/// context.navigateTo(AppRoutes.expenses);
/// context.pop(result: 'saved');
/// ```
extension NavigationExtension on BuildContext {
  void navigateTo(String route, {dynamic arguments}) {
    NavigationHelper.navigateTo(this, route, arguments: arguments);
  }

  void navigateReplacement(String route, {dynamic arguments}) {
    NavigationHelper.navigateReplacement(this, route, arguments: arguments);
  }

  void navigateAndClear(String route, {dynamic arguments}) {
    NavigationHelper.navigateAndClear(this, route, arguments: arguments);
  }

  void pop({dynamic result}) {
    NavigationHelper.pop(this, result: result);
  }

  T? getArgument<T>() {
    return NavigationHelper.getArgument<T>(this);
  }

  bool hasArgument<T>() {
    return NavigationHelper.hasArgument<T>(this);
  }
}
