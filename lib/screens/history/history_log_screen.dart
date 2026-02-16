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

      // Set user context for expense filtering
      if (authProvider.user != null) {
        apiProvider.setUserContext(
          userId: authProvider.user!.id,
          isManager: authProvider.user!.isManager,
        );
      }

      await apiProvider.fetchReferenceData();
      await apiProvider.fetchExpenses(refresh: true);
      // Populate requester info for expenses
      await apiProvider.populateExpenseRequesterInfo();
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
        final expenses = apiProvider.expenses;

        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F7),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, isApprover, expenses.length),
                Expanded(
                  child: apiProvider.isLoading && expenses.isEmpty
                      ? const Center(child: CupertinoActivityIndicator(radius: 14))
                      : expenses.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: () => apiProvider.fetchExpenses(refresh: true),
                              child: ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: expenses.length,
                                itemBuilder: (context, index) {
                                  return _ApiHistoryItem(
                                    expense: expenses[index],
                                    onTap: () {
                                      apiProvider.setSelectedExpense(expenses[index]);
                                      context.read<AppProvider>().navigateTo('transactionDetail');
                                    },
                                  );
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
