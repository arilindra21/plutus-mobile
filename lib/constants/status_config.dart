import 'package:flutter/material.dart';
import '../core/design_tokens.dart';

/// Expense Status Codes
class ExpenseStatus {
  ExpenseStatus._();

  static const int draft = 0;
  static const int pending = 1;
  static const int processing = 2;
  static const int pendingApproval = 3;
  static const int approved = 4;
  static const int completed = 5;
  static const int rejected = 6;
  static const int returned = 7;
  static const int onHold = 8;
  static const int cancelled = 9;
  static const int approvedPendingBudget = 10;
}

/// Status code to key mapping
const Map<int, String> statusCodeMap = {
  0: 'draft',
  1: 'pending',
  2: 'processing',
  3: 'pending_approval',
  4: 'approved',
  5: 'completed',
  6: 'rejected',
  7: 'returned',
  8: 'on_hold',
  9: 'cancelled',
  10: 'approved_pending_budget',
};

/// Status key to code mapping
const Map<String, int> statusKeyMap = {
  'draft': 0,
  'pending': 1,
  'processing': 2,
  'pending_approval': 3,
  'approved': 4,
  'completed': 5,
  'rejected': 6,
  'returned': 7,
  'on_hold': 8,
  'cancelled': 9,
  'approved_pending_budget': 10,
};

/// Status Configuration
class StatusConfig {
  final int code;
  final String key;
  final String label;
  final String description;
  final String icon;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final String category;
  final List<int> allowedTransitions;

  const StatusConfig({
    required this.code,
    required this.key,
    required this.label,
    required this.description,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.category,
    required this.allowedTransitions,
  });
}

/// All status configurations
final Map<int, StatusConfig> statusConfigs = {
  ExpenseStatus.draft: StatusConfig(
    code: 0,
    key: 'draft',
    label: 'Draft',
    description: 'Expense saved but not yet submitted',
    icon: '📝',
    backgroundColor: AppColors.bgSubtle,
    textColor: AppColors.textSecondary,
    borderColor: AppColors.borderDefault,
    category: 'active',
    allowedTransitions: [ExpenseStatus.pending, ExpenseStatus.cancelled],
  ),
  ExpenseStatus.pending: StatusConfig(
    code: 1,
    key: 'pending',
    label: 'Pending',
    description: 'Expense submitted, awaiting processing',
    icon: '⏳',
    backgroundColor: const Color(0xFFFEF3C7),
    textColor: AppColors.warningDark,
    borderColor: AppColors.warning,
    category: 'active',
    allowedTransitions: [
      ExpenseStatus.processing,
      ExpenseStatus.pendingApproval,
      ExpenseStatus.returned,
      ExpenseStatus.cancelled,
    ],
  ),
  ExpenseStatus.processing: StatusConfig(
    code: 2,
    key: 'processing',
    label: 'Processing',
    description: 'Expense being reviewed by finance',
    icon: '⚙️',
    backgroundColor: const Color(0xFFDBEAFE),
    textColor: AppColors.infoDark,
    borderColor: AppColors.info,
    category: 'active',
    allowedTransitions: [
      ExpenseStatus.pendingApproval,
      ExpenseStatus.approved,
      ExpenseStatus.rejected,
      ExpenseStatus.returned,
      ExpenseStatus.onHold,
    ],
  ),
  ExpenseStatus.pendingApproval: StatusConfig(
    code: 3,
    key: 'pending_approval',
    label: 'Pending Approval',
    description: 'Waiting for manager approval',
    icon: '👤',
    backgroundColor: const Color(0xFFE0F2FE),
    textColor: AppColors.primaryDark,
    borderColor: AppColors.primary,
    category: 'active',
    allowedTransitions: [
      ExpenseStatus.approved,
      ExpenseStatus.rejected,
      ExpenseStatus.returned,
      ExpenseStatus.onHold,
      ExpenseStatus.approvedPendingBudget,
    ],
  ),
  ExpenseStatus.approved: StatusConfig(
    code: 4,
    key: 'approved',
    label: 'Approved',
    description: 'Expense approved, ready for payment',
    icon: '✅',
    backgroundColor: const Color(0xFFDCFCE7),
    textColor: AppColors.successDark,
    borderColor: AppColors.success,
    category: 'final',
    allowedTransitions: [ExpenseStatus.completed, ExpenseStatus.onHold],
  ),
  ExpenseStatus.completed: StatusConfig(
    code: 5,
    key: 'completed',
    label: 'Completed',
    description: 'Expense fully processed and paid',
    icon: '💰',
    backgroundColor: const Color(0xFFBBF7D0),
    textColor: const Color(0xFF166534),
    borderColor: AppColors.successDark,
    category: 'final',
    allowedTransitions: [],
  ),
  ExpenseStatus.rejected: StatusConfig(
    code: 6,
    key: 'rejected',
    label: 'Rejected',
    description: 'Expense was not approved',
    icon: '❌',
    backgroundColor: const Color(0xFFFEE2E2),
    textColor: AppColors.dangerDark,
    borderColor: AppColors.danger,
    category: 'final',
    allowedTransitions: [],
  ),
  ExpenseStatus.returned: StatusConfig(
    code: 7,
    key: 'returned',
    label: 'Returned',
    description: 'Expense returned for corrections',
    icon: '↩️',
    backgroundColor: const Color(0xFFFFEDD5),
    textColor: const Color(0xFFC2410C),
    borderColor: const Color(0xFFF97316),
    category: 'active',
    allowedTransitions: [ExpenseStatus.pending, ExpenseStatus.cancelled],
  ),
  ExpenseStatus.onHold: StatusConfig(
    code: 8,
    key: 'on_hold',
    label: 'On Hold',
    description: 'Expense temporarily paused',
    icon: '⏸️',
    backgroundColor: const Color(0xFFE2E8F0),
    textColor: const Color(0xFF475569),
    borderColor: const Color(0xFF94A3B8),
    category: 'hold',
    allowedTransitions: [
      ExpenseStatus.processing,
      ExpenseStatus.pendingApproval,
      ExpenseStatus.cancelled,
    ],
  ),
  ExpenseStatus.cancelled: StatusConfig(
    code: 9,
    key: 'cancelled',
    label: 'Cancelled',
    description: 'Expense was cancelled',
    icon: '🚫',
    backgroundColor: AppColors.bgSubtle,
    textColor: AppColors.textMuted,
    borderColor: AppColors.borderDefault,
    category: 'final',
    allowedTransitions: [],
  ),
  ExpenseStatus.approvedPendingBudget: StatusConfig(
    code: 10,
    key: 'approved_pending_budget',
    label: 'Approved - Pending Budget',
    description: 'Approved but waiting for budget allocation',
    icon: '📊',
    backgroundColor: const Color(0xFFF3E8FF),
    textColor: const Color(0xFF7E22CE),
    borderColor: AppColors.chartPurple,
    category: 'hold',
    allowedTransitions: [
      ExpenseStatus.approved,
      ExpenseStatus.completed,
      ExpenseStatus.cancelled,
    ],
  ),
};

/// Get status configuration by code
StatusConfig getStatusConfig(int status) {
  return statusConfigs[status] ?? statusConfigs[ExpenseStatus.draft]!;
}

/// Get status label
String getStatusLabel(int status) {
  return getStatusConfig(status).label;
}

/// Check if status transition is valid
bool isValidTransition(int fromStatus, int toStatus) {
  final config = statusConfigs[fromStatus];
  return config?.allowedTransitions.contains(toStatus) ?? false;
}

/// Check if status is final
bool isFinalStatus(int status) {
  return getStatusConfig(status).category == 'final';
}

/// Check if expense can be edited
bool canEditExpense(int status) {
  const editableStatuses = [
    ExpenseStatus.draft,
    ExpenseStatus.pending,
    ExpenseStatus.rejected,
    ExpenseStatus.returned,
  ];
  return editableStatuses.contains(status);
}

/// Check if expense can be deleted
bool canDeleteExpense(int status) {
  const deletableStatuses = [
    ExpenseStatus.draft,
    ExpenseStatus.pending,
    ExpenseStatus.returned,
  ];
  return deletableStatuses.contains(status);
}

/// Check if expense can be submitted
bool canSubmitExpense(int status) {
  const submittableStatuses = [
    ExpenseStatus.draft,
    ExpenseStatus.pending,
    ExpenseStatus.rejected,
    ExpenseStatus.returned,
  ];
  return submittableStatuses.contains(status);
}

/// Check if expense can be cancelled
bool canCancelExpense(int status) {
  const cancellableStatuses = [
    ExpenseStatus.draft,
    ExpenseStatus.pending,
    ExpenseStatus.onHold,
  ];
  return cancellableStatuses.contains(status);
}

/// Get all permissions for an expense
Map<String, dynamic> getExpensePermissions(int status) {
  final config = getStatusConfig(status);
  return {
    'canView': true,
    'canEdit': canEditExpense(status),
    'canDelete': canDeleteExpense(status),
    'canSubmit': canSubmitExpense(status),
    'canCancel': canCancelExpense(status),
    'isViewOnly': !canEditExpense(status),
    'statusCode': status,
    'statusKey': config.key,
    'statusLabel': config.label,
  };
}
