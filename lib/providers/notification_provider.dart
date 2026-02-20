import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import '../services/api/approval_service.dart';
import '../services/api/expense_service.dart';
import '../services/models/approval_dto.dart';
import '../services/models/expense_dto.dart';

/// Provider for managing notifications via polling
///
/// For Approvers: Fetches pending approval tasks from inbox
/// For Employees: Tracks expense status changes (approved/rejected/returned)
class NotificationProvider extends ChangeNotifier {
  final ApprovalService _approvalService = ApprovalService();
  final ExpenseService _expenseService = ExpenseService();

  Timer? _pollingTimer;
  bool _isPolling = false;
  bool _isApprover = false;
  String? _userId;

  // Notification state
  List<AppNotification> _notifications = [];
  int _pendingApprovalCount = 0;
  Set<String> _seenTaskIds = {}; // Track which tasks we've already notified about
  Map<String, int> _expenseStatusCache = {}; // Track expense statuses for change detection

  // Polling configuration
  static const Duration _pollingInterval = Duration(seconds: 30);

  // Getters
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.read).length;
  int get pendingApprovalCount => _pendingApprovalCount;
  bool get isPolling => _isPolling;

  /// Start polling for notifications
  /// Call this after user logs in
  void startPolling({required bool isApprover, required String userId}) {
    _isApprover = isApprover;
    _userId = userId;
    _isPolling = true;

    // Fetch immediately on start
    _fetchNotifications();

    // Then poll at interval
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      _fetchNotifications();
    });

    debugPrint('[NotificationProvider] Started polling (isApprover: $isApprover)');
  }

  /// Stop polling
  /// Call this when user logs out
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
    _notifications = [];
    _seenTaskIds = {};
    _expenseStatusCache = {};
    _pendingApprovalCount = 0;
    notifyListeners();

    debugPrint('[NotificationProvider] Stopped polling');
  }

  /// Force refresh notifications
  Future<void> refresh() async {
    await _fetchNotifications();
  }

  /// Fetch notifications from API
  Future<void> _fetchNotifications() async {
    if (!_isPolling) return;

    try {
      if (_isApprover) {
        await _fetchApproverNotifications();
      } else {
        // For spenders, fetch expense status changes
        await _fetchEmployeeNotifications();
      }
    } catch (e) {
      debugPrint('[NotificationProvider] Error fetching notifications: $e');
    }
  }

  /// Fetch approval inbox and convert to notifications
  Future<void> _fetchApproverNotifications() async {
    // First get summary for count
    final summaryResult = await _approvalService.getInboxSummary();
    if (summaryResult.isSuccess) {
      _pendingApprovalCount = summaryResult.data!.pendingCount;
    }

    // Then get actual inbox items
    final inboxResult = await _approvalService.getInbox(
      ApprovalInboxParams(
        page: 1,
        pageSize: 20,
        sortBy: 'created_at',
        sortOrder: 'desc',
      ),
    );

    if (inboxResult.isSuccess) {
      final tasks = inboxResult.data!.data;

      // Convert new tasks to notifications
      for (final task in tasks) {
        if (!_seenTaskIds.contains(task.id)) {
          _seenTaskIds.add(task.id);

          // Create notification for this approval task
          final notification = _taskToNotification(task);
          _notifications.insert(0, notification);
        }
      }

      // Limit notifications to last 50
      if (_notifications.length > 50) {
        _notifications = _notifications.take(50).toList();
      }

      notifyListeners();
    }
  }

  /// Fetch employee expense status changes
  Future<void> _fetchEmployeeNotifications() async {
    // Fetch expenses with decided statuses (approved=4, rejected=6, returned=7)
    final result = await _expenseService.listExpenses(
      ExpenseListParams(
        page: 1,
        pageSize: 20,
        sortBy: 'updated_at',
        sortOrder: 'desc',
        statuses: [4, 6, 7], // approved, rejected, returned
      ),
    );

    if (result.isSuccess) {
      final expenses = result.data!.data;
      bool hasNewNotifications = false;

      for (final expense in expenses) {
        final cachedStatus = _expenseStatusCache[expense.id];
        final currentStatus = expense.status;

        // If this is a new expense we haven't seen, or status changed
        if (cachedStatus == null) {
          // First time seeing this expense with a decided status
          // Only notify if it was recently updated (within last 24 hours)
          final updateTime = expense.updatedAt ?? expense.createdAt;
          final hoursSinceUpdate = DateTime.now().difference(updateTime).inHours;
          if (hoursSinceUpdate < 24) {
            final notification = _expenseToNotification(expense);
            _notifications.insert(0, notification);
            hasNewNotifications = true;
          }
          _expenseStatusCache[expense.id] = currentStatus;
        } else if (cachedStatus != currentStatus) {
          // Status changed - create notification
          final notification = _expenseToNotification(expense);
          _notifications.insert(0, notification);
          _expenseStatusCache[expense.id] = currentStatus;
          hasNewNotifications = true;
        }
      }

      // Limit notifications to last 50
      if (_notifications.length > 50) {
        _notifications = _notifications.take(50).toList();
      }

      if (hasNewNotifications) {
        notifyListeners();
      }
    }
  }

  /// Convert ExpenseDTO to AppNotification
  AppNotification _expenseToNotification(ExpenseDTO expense) {
    String title;
    String message;
    String type;
    final amount = _formatCurrency(expense.originalAmount, expense.originalCurrency);

    switch (expense.status) {
      case 4: // Approved
        title = 'Expense Approved';
        message = 'Your expense for ${expense.merchant} ($amount) has been approved';
        type = 'approval';
        break;
      case 6: // Rejected
        title = 'Expense Rejected';
        message = 'Your expense for ${expense.merchant} ($amount) has been rejected';
        type = 'rejection';
        break;
      case 7: // Returned
        title = 'Revision Requested';
        message = 'Your expense for ${expense.merchant} ($amount) needs revision';
        type = 'warning';
        break;
      default:
        title = 'Expense Updated';
        message = 'Your expense for ${expense.merchant} has been updated';
        type = 'info';
    }

    final notificationTime = expense.updatedAt ?? expense.createdAt;

    return AppNotification(
      id: '${expense.id}_${expense.status}'.hashCode,
      type: type,
      title: title,
      message: message,
      time: notificationTime.toIso8601String(),
      read: false,
      icon: type,
      action: NotificationAction(
        type: 'navigate',
        screen: 'transactionDetail',
        params: {'expenseId': expense.id},
      ),
      expenseId: expense.id.hashCode,
    );
  }

  /// Convert ApprovalTaskDTO to AppNotification
  AppNotification _taskToNotification(ApprovalTaskDTO task) {
    final amount = _formatCurrency(task.amount, task.currency);

    return AppNotification(
      id: task.id.hashCode, // Convert string ID to int for compatibility
      type: 'approval',
      title: 'New Approval Request',
      message: '${task.requesterName} submitted $amount for ${task.category}',
      time: task.createdAt.toIso8601String(),
      read: false,
      icon: 'approval',
      action: NotificationAction(
        type: 'navigate',
        screen: 'approverExpenseDetail',
        params: {
          'taskId': task.id,
          'expenseId': task.expenseId,
        },
      ),
      expenseId: task.expenseId.hashCode,
    );
  }

  /// Format currency for display
  String _formatCurrency(double amount, String currency) {
    if (currency == 'IDR') {
      final formatted = amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]}.',
      );
      return 'Rp $formatted';
    }
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  /// Mark notification as read
  void markAsRead(int notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(read: true);
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(read: true)).toList();
    notifyListeners();
  }

  /// Clear all notifications
  void clearAll() {
    _notifications = [];
    notifyListeners();
  }

  /// Add notification for expense status change (for requesters)
  /// This can be called when we detect a status change
  void addExpenseStatusNotification({
    required String expenseId,
    required String status,
    required String merchant,
    required double amount,
    required String currency,
    String? approverName,
  }) {
    String title;
    String message;
    String type;

    switch (status) {
      case 'approved':
        title = 'Expense Approved';
        message = approverName != null
            ? '$approverName approved your expense for $merchant'
            : 'Your expense for $merchant has been approved';
        type = 'approval';
        break;
      case 'rejected':
        title = 'Expense Rejected';
        message = approverName != null
            ? '$approverName rejected your expense for $merchant'
            : 'Your expense for $merchant has been rejected';
        type = 'rejection';
        break;
      case 'returned':
        title = 'Revision Requested';
        message = approverName != null
            ? '$approverName requested changes to your expense for $merchant'
            : 'Changes requested for your expense for $merchant';
        type = 'warning';
        break;
      default:
        title = 'Expense Updated';
        message = 'Your expense for $merchant has been updated';
        type = 'info';
    }

    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      type: type,
      title: title,
      message: message,
      time: DateTime.now().toIso8601String(),
      read: false,
      icon: type,
      action: NotificationAction(
        type: 'navigate',
        screen: 'transactionDetail',
        params: {'expenseId': expenseId},
      ),
      expenseId: expenseId.hashCode,
    );

    _notifications.insert(0, notification);
    notifyListeners();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
