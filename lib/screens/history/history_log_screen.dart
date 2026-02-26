import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/api_expense_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../utils/formatters.dart';
import '../../widgets/layout/bottom_navigation.dart';

/// Activity History Item Model
class ActivityItem {
  final int id;
  final String action;
  final String actorName;
  final String refId;
  final String merchant;
  final double amount;
  final String expenseIcon;
  final String? comments;
  final DateTime createdAt;

  ActivityItem({
    required this.id,
    required this.action,
    required this.actorName,
    required this.refId,
    required this.merchant,
    required this.amount,
    required this.expenseIcon,
    this.comments,
    required this.createdAt,
  });
}

/// Mock Activity History Data
final List<ActivityItem> mockActivityHistory = [
  ActivityItem(
    id: 1,
    action: 'approved',
    actorName: 'Rizki Pratama',
    refId: 'EXP-2025-001',
    merchant: 'Grab',
    amount: 89000,
    expenseIcon: '🚗',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  ActivityItem(
    id: 2,
    action: 'submitted',
    actorName: 'Andi Rahman',
    refId: 'EXP-2025-002',
    merchant: 'Starbucks',
    amount: 125000,
    expenseIcon: '🍽️',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  ActivityItem(
    id: 3,
    action: 'created',
    actorName: 'Andi Rahman',
    refId: 'EXP-2025-003',
    merchant: 'Tokopedia',
    amount: 325000,
    expenseIcon: '📦',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  ActivityItem(
    id: 4,
    action: 'rejected',
    actorName: 'Rizki Pratama',
    refId: 'EXP-2025-004',
    merchant: 'McDonald\'s',
    amount: 85000,
    expenseIcon: '🍽️',
    comments: 'Missing business justification',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
  ),
  ActivityItem(
    id: 5,
    action: 'attachment_added',
    actorName: 'Andi Rahman',
    refId: 'EXP-2025-005',
    merchant: 'Gojek',
    amount: 45000,
    expenseIcon: '🚗',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  ActivityItem(
    id: 6,
    action: 'edited',
    actorName: 'Andi Rahman',
    refId: 'EXP-2025-006',
    merchant: 'Garuda Indonesia',
    amount: 1850000,
    expenseIcon: '✈️',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  ActivityItem(
    id: 7,
    action: 'approved',
    actorName: 'Rizki Pratama',
    refId: 'EXP-2025-007',
    merchant: 'Marriott Hotel',
    amount: 950000,
    expenseIcon: '🏨',
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
  ),
];

/// Get action style for history items
Map<String, dynamic> getActionStyle(String action) {
  switch (action) {
    case 'approved':
      return {
        'icon': CupertinoIcons.checkmark_circle_fill,
        'label': 'Approved',
        'color': const Color(0xFF30D158),
      };
    case 'rejected':
      return {
        'icon': CupertinoIcons.xmark_circle_fill,
        'label': 'Rejected',
        'color': const Color(0xFFFF3B30),
      };
    case 'submitted':
      return {
        'icon': CupertinoIcons.arrow_up_circle_fill,
        'label': 'Submitted',
        'color': const Color(0xFF007AFF),
      };
    case 'created':
      return {
        'icon': CupertinoIcons.plus_circle_fill,
        'label': 'Created',
        'color': const Color(0xFF5856D6),
      };
    case 'edited':
      return {
        'icon': CupertinoIcons.pencil_circle_fill,
        'label': 'Edited',
        'color': const Color(0xFFFF9500),
      };
    case 'attachment_added':
      return {
        'icon': CupertinoIcons.paperclip,
        'label': 'Receipt Added',
        'color': const Color(0xFF007AFF),
      };
    default:
      return {
        'icon': CupertinoIcons.doc_fill,
        'label': action,
        'color': const Color(0xFF8E8E93),
      };
  }
}

/// Format date time for display
Map<String, String> formatActivityDateTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  String date;
  if (difference.inDays == 0) {
    date = 'Today';
  } else if (difference.inDays == 1) {
    date = 'Yesterday';
  } else if (difference.inDays < 7) {
    date = '${difference.inDays} days ago';
  } else {
    date = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final time = '$hour:$minute';

  return {'date': date, 'time': time};
}

/// History Log Screen - iOS Style
class HistoryLogScreen extends StatefulWidget {
  const HistoryLogScreen({super.key});

  @override
  State<HistoryLogScreen> createState() => _HistoryLogScreenState();
}

class _HistoryLogScreenState extends State<HistoryLogScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    if (_isInitialized) return;

    final appProvider = context.read<AppProvider>();
    if (appProvider.isApiMode) {
      final apiProvider = context.read<ApiExpenseProvider>();
      final authProvider = context.read<AuthProvider>();

      if (authProvider.user != null) {
        apiProvider.setUserContext(
          userId: authProvider.user!.id,
          isManager: authProvider.user!.isManager,
          userProfile: authProvider.user,
        );
      }

      // Managers see their team's approval tasks; regular users see their own expenses
      final isApprover = appProvider.userCapabilities.canApprove;
      if (isApprover) {
        await apiProvider.fetchApprovalInbox();
      } else {
        await apiProvider.fetchExpenses();
      }
    }
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.read<AppProvider>();

    if (appProvider.isApiMode) {
      return _buildApiContent(context);
    }

    return _buildDemoContent(context);
  }

  Widget _buildApiContent(BuildContext context) {
    return Consumer2<AppProvider, ApiExpenseProvider>(
      builder: (context, appProvider, apiProvider, _) {
        final isApprover = appProvider.userCapabilities.canApprove;
        final isLoading = apiProvider.isLoading;
        final itemCount = isApprover
            ? apiProvider.approvalTasks.length
            : apiProvider.expenses.length;

        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F7),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, isApprover, itemCount),
                Expanded(
                  child: isLoading && itemCount == 0
                      ? const Center(child: CupertinoActivityIndicator(radius: 14))
                      : itemCount == 0
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: () => isApprover
                                  ? apiProvider.fetchApprovalInbox()
                                  : apiProvider.fetchExpenses(),
                              child: ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: itemCount,
                                itemBuilder: (context, index) {
                                  if (isApprover) {
                                    final task = apiProvider.approvalTasks[index];
                                    return _ApprovalTaskHistoryItem(
                                      task: task,
                                      onTap: () {
                                        apiProvider.setSelectedApprovalTask(task);
                                        context.read<AppProvider>().navigateTo('approverExpenseDetail');
                                      },
                                    );
                                  } else {
                                    final expense = apiProvider.expenses[index];
                                    return _ApiHistoryItem(
                                      expense: expense,
                                      onTap: () {
                                        apiProvider.setSelectedExpense(expense);
                                        context.read<AppProvider>().navigateTo('transactionDetail');
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                ),
                const AppBottomNavigation(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDemoContent(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        final isApprover = appProvider.userCapabilities.canApprove;
        final historyItems = mockActivityHistory;

        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F7),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, isApprover, historyItems.length),
                Expanded(
                  child: historyItems.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: historyItems.length,
                          itemBuilder: (context, index) {
                            return _HistoryItem(item: historyItems[index]);
                          },
                        ),
                ),
                const AppBottomNavigation(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isApprover, int itemCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Hamburger menu button
              GestureDetector(
                onTap: () => context.read<AppProvider>().toggleSideMenu(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    CupertinoIcons.line_horizontal_3,
                    size: 18,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Activity icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isApprover
                      ? const Color(0xFF5856D6).withOpacity(0.12)
                      : const Color(0xFF007AFF).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isApprover ? CupertinoIcons.person_3_fill : CupertinoIcons.doc_text_fill,
                  size: 18,
                  color: isApprover ? const Color(0xFF5856D6) : const Color(0xFF007AFF),
                ),
              ),
              const SizedBox(width: 12),
              // Title - different for Manager vs Employee
              Expanded(
                child: Text(
                  isApprover ? 'My Team Activity' : 'My Activity',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
              ),
              // Notification bell
              GestureDetector(
                onTap: () => context.read<AppProvider>().navigateTo('notifications'),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    CupertinoIcons.bell_fill,
                    size: 18,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$itemCount recent activities',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.clock,
              size: 36,
              color: Color(0xFF007AFF),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No activity yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your activity will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final ActivityItem item;

  const _HistoryItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final actionStyle = getActionStyle(item.action);
    final dateTime = formatActivityDateTime(item.createdAt);
    final Color color = actionStyle['color'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(item.expenseIcon, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.actorName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          actionStyle['label'],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.merchant} • ${formatRupiahCompact(item.amount)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  if (item.comments != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '"${item.comments}"',
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    '${dateTime['date']} at ${dateTime['time']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// API History Item
class _ApiHistoryItem extends StatelessWidget {
  final ExpenseDTO expense;
  final VoidCallback onTap;

  const _ApiHistoryItem({
    required this.expense,
    required this.onTap,
  });

  Map<String, dynamic> _getStatusStyle(int status) {
    // Status codes: 0=DRAFT, 1=PENDING, 2=SUBMITTED, 3=PENDING_APPROVAL, 4=APPROVED, 5=COMPLETED, 6=REJECTED, 7=RETURNED
    switch (status) {
      case 0:
        return {
          'label': 'Draft',
          'color': const Color(0xFF8E8E93),
        };
      case 1:
        return {
          'label': 'Pending',
          'color': const Color(0xFFFF9500),
        };
      case 2:
        return {
          'label': 'Submitted',
          'color': const Color(0xFF007AFF),
        };
      case 3:
        return {
          'label': 'Pending Approval',
          'color': const Color(0xFFFF9500),
        };
      case 4:
        return {
          'label': 'Approved',
          'color': const Color(0xFF30D158),
        };
      case 5:
        return {
          'label': 'Completed',
          'color': const Color(0xFF30D158),
        };
      case 6:
        return {
          'label': 'Rejected',
          'color': const Color(0xFFFF3B30),
        };
      case 7:
        return {
          'label': 'Returned',
          'color': const Color(0xFF007AFF),
        };
      default:
        return {
          'label': expense.statusName ?? 'Unknown',
          'color': const Color(0xFF8E8E93),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiProvider = context.read<ApiExpenseProvider>();
    final statusStyle = _getStatusStyle(expense.status);
    final dateTime = formatActivityDateTime(expense.createdAt);
    final Color color = statusStyle['color'];

    final categoryIcon = expense.categoryIcon?.isNotEmpty == true
        ? expense.categoryIcon!
        : apiProvider.getCategoryIcon(expense.categoryId);
    final categoryName = expense.categoryName?.isNotEmpty == true
        ? expense.categoryName!
        : apiProvider.getCategoryName(expense.categoryId);

    // Get requester details
    final requester = apiProvider.getExpenseRequesterDetails(expense);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Avatar, Requester info, Amount
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF007AFF).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          requester.initials,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF007AFF),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Requester details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            requester.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C1C1E),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (requester.subtitle.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              requester.subtitle,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8E8E93),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (requester.email.isNotEmpty) ...[
                            const SizedBox(height: 1),
                            Text(
                              requester.email,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFAEAEB2),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Amount & Status
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatRupiahCompact(expense.originalAmount),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            statusStyle['label'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFE5E5EA)),
                const SizedBox(height: 10),
                // Bottom row: Category, merchant, date
                Row(
                  children: [
                    // Category icon
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(categoryIcon, style: const TextStyle(fontSize: 14)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Category & Merchant
                    Expanded(
                      child: Text(
                        '$categoryName • ${expense.merchant}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8E8E93),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Date
                    Text(
                      dateTime['date'] ?? expense.formattedDate,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFAEAEB2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 16, color: Color(0xFFAEAEB2)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// History item using real ApprovalHistoryDTO from API
class _ApprovalHistoryItem extends StatelessWidget {
  final ApprovalHistoryDTO item;
  final VoidCallback onTap;

  const _ApprovalHistoryItem({
    required this.item,
    required this.onTap,
  });

  Map<String, dynamic> _getActionStyle() {
    switch (item.action.toLowerCase()) {
      case 'approved':
      case 'approve':
        return {
          'icon': CupertinoIcons.checkmark_circle_fill,
          'label': 'Approved',
          'color': const Color(0xFF30D158),
        };
      case 'rejected':
      case 'reject':
        return {
          'icon': CupertinoIcons.xmark_circle_fill,
          'label': 'Rejected',
          'color': const Color(0xFFFF3B30),
        };
      case 'returned':
      case 'return':
        return {
          'icon': CupertinoIcons.arrow_uturn_left_circle_fill,
          'label': 'Returned',
          'color': const Color(0xFF007AFF),
        };
      case 'submitted':
      case 'submit':
        return {
          'icon': CupertinoIcons.arrow_up_circle_fill,
          'label': 'Submitted',
          'color': const Color(0xFF007AFF),
        };
      case 'created':
      case 'create':
        return {
          'icon': CupertinoIcons.plus_circle_fill,
          'label': 'Created',
          'color': const Color(0xFF5856D6),
        };
      case 'edited':
      case 'edit':
        return {
          'icon': CupertinoIcons.pencil_circle_fill,
          'label': 'Edited',
          'color': const Color(0xFFFF9500),
        };
      default:
        return {
          'icon': CupertinoIcons.doc_fill,
          'label': item.actionDisplay,
          'color': const Color(0xFF8E8E93),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionStyle = _getActionStyle();
    final dateTime = formatActivityDateTime(item.createdAt);
    final Color color = actionStyle['color'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Actor name, action badge, amount
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Action icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        actionStyle['icon'],
                        size: 20,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Actor and action info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.actorName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${actionStyle['label']} • ${item.formattedRefId}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8E8E93),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Amount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatRupiah(item.amount),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            actionStyle['label'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Comment if available
                if (item.comment != null && item.comment!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '"${item.comment}"',
                      style: const TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF636366),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFE5E5EA)),
                const SizedBox(height: 10),
                // Bottom row: Category, merchant, date
                Row(
                  children: [
                    // Category icon
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          item.categoryIcon ?? '📋',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Category & Merchant
                    Expanded(
                      child: Text(
                        '${item.category ?? 'Other'} • ${item.merchant ?? 'Unknown'}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8E8E93),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Date
                    Text(
                      dateTime['date'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFAEAEB2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 16, color: Color(0xFFAEAEB2)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Audit log item using AuditLogDTO from /reports/audit-log API
class _AuditLogItem extends StatelessWidget {
  final AuditLogDTO item;
  final VoidCallback onTap;

  const _AuditLogItem({
    required this.item,
    required this.onTap,
  });

  Map<String, dynamic> _getActionStyle() {
    switch (item.action.toLowerCase()) {
      case 'approve':
      case 'approved':
        return {
          'icon': CupertinoIcons.checkmark_circle_fill,
          'label': 'Approved',
          'color': const Color(0xFF30D158),
        };
      case 'reject':
      case 'rejected':
        return {
          'icon': CupertinoIcons.xmark_circle_fill,
          'label': 'Rejected',
          'color': const Color(0xFFFF3B30),
        };
      case 'return':
      case 'returned':
        return {
          'icon': CupertinoIcons.arrow_uturn_left_circle_fill,
          'label': 'Returned',
          'color': const Color(0xFF007AFF),
        };
      case 'submit':
      case 'submitted':
        return {
          'icon': CupertinoIcons.arrow_up_circle_fill,
          'label': 'Submitted',
          'color': const Color(0xFF007AFF),
        };
      case 'create':
      case 'created':
        return {
          'icon': CupertinoIcons.plus_circle_fill,
          'label': 'Created',
          'color': const Color(0xFF5856D6),
        };
      case 'update':
      case 'updated':
      case 'edit':
      case 'edited':
        return {
          'icon': CupertinoIcons.pencil_circle_fill,
          'label': 'Edited',
          'color': const Color(0xFFFF9500),
        };
      case 'delete':
      case 'deleted':
        return {
          'icon': CupertinoIcons.trash_circle_fill,
          'label': 'Deleted',
          'color': const Color(0xFFFF3B30),
        };
      default:
        return {
          'icon': CupertinoIcons.doc_fill,
          'label': item.actionDisplay,
          'color': const Color(0xFF8E8E93),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionStyle = _getActionStyle();
    final dateTime = formatActivityDateTime(item.createdAt);
    final Color color = actionStyle['color'];
    final bool hasDetails = item.expense != null;
    final bool noPermission = !item.hasPermission;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: noPermission ? const Color(0xFFF8F8F8) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasDetails ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Actor name, action badge, amount
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Action icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        actionStyle['icon'],
                        size: 20,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Actor and action info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.actorName ?? 'Unknown User',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.expenseRef,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                  ),
                                ),
                              ),
                              if (hasDetails) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '•',
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  formatRupiah(item.amount),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1C1C1E),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Action badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        actionStyle['label'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                // Show merchant and description only if we have details
                if (hasDetails) ...[
                  const SizedBox(height: 10),
                  // Merchant name
                  Text(
                    item.merchant,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF636366),
                    ),
                  ),
                  // Description if available
                  if (item.description != null && item.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '"${item.description}"',
                        style: const TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF636366),
                        ),
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 10),
                // Bottom: Date/time
                Row(
                  children: [
                    Icon(CupertinoIcons.clock, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      '${dateTime['date']} at ${dateTime['time']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFAEAEB2),
                      ),
                    ),
                    const Spacer(),
                    if (hasDetails)
                      const Icon(Icons.chevron_right, size: 16, color: Color(0xFFAEAEB2))
                    else
                      Icon(CupertinoIcons.lock_fill, size: 14, color: Colors.grey[400]),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// History item for manager view — renders an ApprovalTaskDTO from GET /api/v1/approvals/inbox
class _ApprovalTaskHistoryItem extends StatelessWidget {
  final ApprovalTaskDTO task;
  final VoidCallback onTap;

  const _ApprovalTaskHistoryItem({required this.task, required this.onTap});

  Map<String, dynamic> _getDecisionStyle() {
    if (task.isApproved) {
      return {'label': 'Approved', 'color': const Color(0xFF30D158)};
    }
    if (task.isRejected) {
      return {'label': 'Rejected', 'color': const Color(0xFFFF3B30)};
    }
    if (task.isReturned) {
      return {'label': 'Returned', 'color': const Color(0xFF007AFF)};
    }
    return {'label': 'Pending', 'color': const Color(0xFFFF9500)};
  }

  @override
  Widget build(BuildContext context) {
    final decisionStyle = _getDecisionStyle();
    final dateTime = formatActivityDateTime(task.createdAt);
    final Color color = decisionStyle['color'];

    final name = task.requesterName.isNotEmpty ? task.requesterName : 'Unknown';
    final nameParts = name.split(' ');
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : name[0].toUpperCase();

    final categoryIcon = task.categoryIcon ?? '📋';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar with initials
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5856D6).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5856D6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Requester name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C1C1E),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (task.requesterEmail.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              task.requesterEmail,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFAEAEB2),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Amount + Decision badge
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatRupiahCompact(task.amount),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            decisionStyle['label'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFE5E5EA)),
                const SizedBox(height: 10),
                // Bottom row: category icon, category • merchant, date
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(categoryIcon, style: const TextStyle(fontSize: 14)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${task.category} • ${task.merchant}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8E8E93),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      dateTime['date'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFAEAEB2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 16, color: Color(0xFFAEAEB2)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
