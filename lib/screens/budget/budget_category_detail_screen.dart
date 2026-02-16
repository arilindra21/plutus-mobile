import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/design_tokens.dart';
import '../../providers/app_provider.dart';
import '../../providers/api_expense_provider.dart';
import '../../services/models/expense_dto.dart';
import '../../services/models/budget_dto.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/status_badge.dart';

class BudgetCategoryDetailScreen extends StatefulWidget {
  const BudgetCategoryDetailScreen({super.key});

  @override
  State<BudgetCategoryDetailScreen> createState() => _BudgetCategoryDetailScreenState();
}

class _BudgetCategoryDetailScreenState extends State<BudgetCategoryDetailScreen> {
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

    final apiProvider = context.read<ApiExpenseProvider>();
    final selectedBudgetId = apiProvider.selectedBudgetCategory;

    // Fetch expenses and budget analytics
    final futures = <Future>[];
    if (apiProvider.expenses.isEmpty) {
      futures.add(apiProvider.fetchExpenses());
    }
    if (selectedBudgetId != null && selectedBudgetId.isNotEmpty) {
      futures.add(apiProvider.fetchBudgetAnalytics(selectedBudgetId));
    }
    await Future.wait(futures);
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return _buildApiContent(context);
  }

  Widget _buildApiContent(BuildContext context) {
    return Consumer<ApiExpenseProvider>(
      builder: (context, apiProvider, _) {
        final selectedBudgetId = apiProvider.selectedBudgetCategory;

        // Find the selected budget
        final budget = apiProvider.budgets.firstWhere(
          (b) => b.id == selectedBudgetId,
          orElse: () => apiProvider.budgets.isNotEmpty
              ? apiProvider.budgets.first
              : BudgetItemDTO(
                  id: '',
                  code: '',
                  name: 'Unknown',
                  budgetAmount: 0,
                  renewalPeriod: 'monthly',
                  createdAt: DateTime.now(),
                ),
        );

        return Scaffold(
          backgroundColor: AppColors.bgPaper,
          body: SafeArea(
            child: Column(
              children: [
                _buildApiHeader(context, budget),
                Expanded(
                  child: apiProvider.isLoading
                      ? const Center(child: CupertinoActivityIndicator(radius: 14))
                      : _buildContent(context, apiProvider, budget),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, ApiExpenseProvider apiProvider, BudgetItemDTO budget) {
    final utilization = apiProvider.getBudgetUtilization(budget.id);
    final trend = apiProvider.selectedBudgetTrend;
    final history = apiProvider.selectedBudgetHistory;

    // Get expense IDs from budget history transactions (the reliable source)
    // Budget history contains transactions with sourceType='expense' and sourceId=expenseId
    final Set<String> budgetExpenseIds = {};
    if (history != null) {
      for (final tx in history.transactions) {
        if (tx.sourceType == 'expense' && tx.sourceId.isNotEmpty) {
          budgetExpenseIds.add(tx.sourceId);
        }
      }
    }

    // Filter expenses to only show those that belong to this budget
    final budgetExpenses = apiProvider.expenses.where((expense) {
      return budgetExpenseIds.contains(expense.id);
    }).toList();

    // Sort expenses by date (newest first)
    budgetExpenses.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));

    return RefreshIndicator(
      onRefresh: () async {
        await apiProvider.fetchExpenses();
        if (budget.id.isNotEmpty) {
          await apiProvider.fetchBudgetAnalytics(budget.id);
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Budget Summary Card
            _buildApiSummaryCard(budget, utilization),

            // Utilization Breakdown by Category (if available)
            if (utilization != null && utilization.byCategory.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  'Spending by Category',
                  style: AppTypography.headingSmall.copyWith(
                    fontSize: AppTypography.fontSizeLg,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...utilization.byCategory.map((item) => _buildBreakdownItem(item)),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Spending Trend Section (if available)
            if (trend != null && trend.dataPoints.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Spending Trend',
                      style: AppTypography.headingSmall.copyWith(
                        fontSize: AppTypography.fontSizeLg,
                      ),
                    ),
                    Text(
                      '${trend.totalPeriods} periods',
                      style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...trend.dataPoints.take(3).map((point) => _buildTrendItem(point)),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Transaction History Section (if available)
            if (history != null && history.transactions.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Budget Transactions',
                      style: AppTypography.headingSmall.copyWith(
                        fontSize: AppTypography.fontSizeLg,
                      ),
                    ),
                    Text(
                      '${history.totalCount} items',
                      style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: history.transactions.take(5).map((tx) => _buildHistoryItem(tx)).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Recent Expenses Section
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Expenses',
                        style: AppTypography.headingSmall.copyWith(
                          fontSize: AppTypography.fontSizeLg,
                        ),
                      ),
                      Text(
                        '${budgetExpenses.length} items',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (budgetExpenses.isEmpty)
                    _buildEmptyState()
                  else
                    ...budgetExpenses.take(10).map((expense) => _ApiExpenseItem(
                          expense: expense,
                          onTap: () {
                            apiProvider.setSelectedExpense(expense);
                            context.read<AppProvider>().navigateTo('transactionDetail');
                          },
                        )),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownItem(BudgetUtilizationBreakdown item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgDefault,
        borderRadius: AppRadius.borderRadiusMd,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: AppTypography.fontWeightMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: AppRadius.borderRadiusFull,
                  child: LinearProgressIndicator(
                    value: (item.percentage / 100).clamp(0.0, 1.0),
                    backgroundColor: AppColors.bgSubtle,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      item.percentage > 90
                          ? AppColors.danger
                          : item.percentage > 70
                              ? AppColors.warning
                              : AppColors.primary,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatRupiahCompact(item.spentAmount),
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: AppTypography.fontWeightSemibold,
                ),
              ),
              Text(
                '${item.percentage.toStringAsFixed(0)}%',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendItem(BudgetTrendDataPoint point) {
    final isOverBudget = point.spentAmount > point.budgetAmount;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgDefault,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(
          color: isOverBudget ? AppColors.danger.withOpacity(0.3) : AppColors.borderDefault,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                point.period,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: AppTypography.fontWeightMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isOverBudget
                      ? AppColors.danger.withOpacity(0.1)
                      : point.utilizationPct > 80
                          ? AppColors.warning.withOpacity(0.1)
                          : AppColors.success.withOpacity(0.1),
                  borderRadius: AppRadius.borderRadiusFull,
                ),
                child: Text(
                  '${point.utilizationPct.toStringAsFixed(0)}%',
                  style: AppTypography.caption.copyWith(
                    color: isOverBudget
                        ? AppColors.danger
                        : point.utilizationPct > 80
                            ? AppColors.warning
                            : AppColors.success,
                    fontWeight: AppTypography.fontWeightSemibold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppRadius.borderRadiusFull,
            child: LinearProgressIndicator(
              value: (point.utilizationPct / 100).clamp(0.0, 1.0),
              backgroundColor: AppColors.bgSubtle,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget
                    ? AppColors.danger
                    : point.utilizationPct > 80
                        ? AppColors.warning
                        : AppColors.success,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: ${formatRupiahCompact(point.spentAmount)}',
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                'Budget: ${formatRupiahCompact(point.budgetAmount)}',
                style: AppTypography.caption.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BudgetTransactionItem transaction) {
    final isDebit = transaction.isDebit;

    IconData getIcon() {
      switch (transaction.operation) {
        case 'commit':
          return Icons.check_circle;
        case 'reserve':
        case 'add_pending':
          return Icons.hourglass_top;
        case 'release':
        case 'release_reserve':
          return Icons.undo;
        case 'adjust':
          return Icons.tune;
        default:
          return Icons.swap_horiz;
      }
    }

    Color getColor() {
      switch (transaction.operation) {
        case 'commit':
          return AppColors.danger;
        case 'reserve':
        case 'add_pending':
          return AppColors.warning;
        case 'release':
        case 'release_reserve':
          return AppColors.success;
        case 'adjust':
          return AppColors.info;
        default:
          return AppColors.textMuted;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgDefault,
        borderRadius: AppRadius.borderRadiusMd,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: getColor().withOpacity(0.1),
              borderRadius: AppRadius.borderRadiusMd,
            ),
            child: Icon(getIcon(), color: getColor(), size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.operationLabel,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: AppTypography.fontWeightMedium,
                  ),
                ),
                Text(
                  transaction.description ?? transaction.sourceType,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatDateTime(transaction.createdAt),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isDebit ? '-' : '+'}${formatRupiahCompact(transaction.amount)}',
            style: AppTypography.bodyMedium.copyWith(
              color: isDebit ? AppColors.danger : AppColors.success,
              fontWeight: AppTypography.fontWeightSemibold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildApiHeader(BuildContext context, BudgetItemDTO budget) {
    // Determine icon based on category/budget name
    String getIcon() {
      final name = budget.categoryName?.toLowerCase() ?? budget.name.toLowerCase();
      if (name.contains('transport') || name.contains('travel')) return '🚗';
      if (name.contains('food') || name.contains('meal') || name.contains('makan')) return '🍽️';
      if (name.contains('office') || name.contains('supplies')) return '📦';
      if (name.contains('entertainment') || name.contains('client')) return '🎭';
      if (name.contains('tech') || name.contains('it') || name.contains('software')) return '💻';
      if (name.contains('marketing') || name.contains('ads')) return '📢';
      if (name.contains('training') || name.contains('education')) return '📚';
      return '💰';
    }

    // Determine color based on usage
    Color getColor() {
      if (budget.isOverBudget) return AppColors.danger;
      if (budget.usagePercent > 90) return AppColors.danger;
      if (budget.usagePercent > 70) return AppColors.warning;
      return AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.read<AppProvider>().goBack(),
            child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          const SizedBox(width: AppSpacing.lg),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: getColor().withOpacity(0.1),
              borderRadius: AppRadius.borderRadiusMd,
            ),
            child: Center(
              child: Text(getIcon(), style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  budget.name,
                  style: AppTypography.headingSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                if (budget.categoryName != null && budget.categoryName!.isNotEmpty)
                  Text(
                    budget.categoryName!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiSummaryCard(BudgetItemDTO budget, BudgetUtilizationDTO? utilization) {
    // Use utilization data if available
    final budgetAmount = utilization?.budgetAmount ?? budget.budgetAmount;
    final spentAmount = utilization?.spentAmount ?? 0;
    final availableAmount = utilization?.availableAmount ?? budgetAmount;
    final usagePercent = utilization?.utilizationPct ?? (budgetAmount > 0 ? (spentAmount / budgetAmount) * 100 : 0);
    final isOverBudget = spentAmount > budgetAmount;
    final isNearLimit = usagePercent > 80;
    final periodStart = utilization?.periodStart ?? budget.startDate;
    final periodEnd = utilization?.periodEnd ?? budget.endDate;

    // Determine color based on usage
    Color getColor() {
      if (isOverBudget) return AppColors.danger;
      if (usagePercent > 90) return AppColors.danger;
      if (usagePercent > 70) return AppColors.warning;
      return AppColors.success;
    }

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            getColor(),
            getColor().withOpacity(0.8),
          ],
        ),
        borderRadius: AppRadius.borderRadiusXl,
        boxShadow: [
          BoxShadow(
            color: getColor().withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Spent
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spent',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    formatRupiah(spentAmount),
                    style: AppTypography.headingMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: AppRadius.borderRadiusFull,
                ),
                child: Text(
                  isOverBudget ? 'Over!' : '${usagePercent.toStringAsFixed(0)}%',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: AppTypography.fontWeightSemibold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Progress bar
          ClipRRect(
            borderRadius: AppRadius.borderRadiusFull,
            child: LinearProgressIndicator(
              value: (usagePercent / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget
                    ? Colors.red.shade100
                    : isNearLimit
                        ? AppColors.warning
                        : Colors.white,
              ),
              minHeight: 8,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Remaining & Allocated
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remaining',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    formatRupiah(availableAmount.abs()),
                    style: AppTypography.bodyLarge.copyWith(
                      color: isOverBudget ? Colors.red.shade100 : Colors.white,
                      fontWeight: AppTypography.fontWeightSemibold,
                    ),
                  ),
                  if (isOverBudget)
                    Text(
                      'Over budget!',
                      style: AppTypography.caption.copyWith(
                        color: Colors.red.shade100,
                      ),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Allocated',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    formatRupiah(budgetAmount),
                    style: AppTypography.bodyLarge.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Period info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: AppRadius.borderRadiusMd,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.white.withOpacity(0.8)),
                const SizedBox(width: 6),
                Text(
                  '${budget.period.toUpperCase()} • ${_formatDateRange(periodStart, periodEnd)}',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${start.day} ${months[start.month - 1]} - ${end.day} ${months[end.month - 1]} ${end.year}';
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No transactions yet',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Expenses in this category will appear here',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// API Expense Item - displays expense from API
class _ApiExpenseItem extends StatelessWidget {
  final ExpenseDTO expense;
  final VoidCallback onTap;

  const _ApiExpenseItem({
    required this.expense,
    required this.onTap,
  });

  String _getCategoryIcon() {
    final categoryName = expense.categoryName?.toLowerCase() ?? '';
    if (categoryName.contains('transport') || categoryName.contains('travel')) return '🚗';
    if (categoryName.contains('food') || categoryName.contains('meal') || categoryName.contains('makan')) return '🍽️';
    if (categoryName.contains('office') || categoryName.contains('supplies')) return '📦';
    if (categoryName.contains('entertainment') || categoryName.contains('client')) return '🎭';
    if (categoryName.contains('tech') || categoryName.contains('it') || categoryName.contains('software')) return '💻';
    if (categoryName.contains('marketing') || categoryName.contains('ads')) return '📢';
    if (categoryName.contains('training') || categoryName.contains('education')) return '📚';
    return '💰';
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgDefault,
        borderRadius: AppRadius.borderRadiusMd,
        boxShadow: AppShadows.card,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderRadiusMd,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.bgSubtle,
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: Center(
                child: Text(_getCategoryIcon(), style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.vendorName ?? expense.description ?? 'Expense',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: AppTypography.fontWeightMedium,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(expense.expenseDate),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatRupiah(expense.originalAmount),
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: AppTypography.fontWeightSemibold,
                  ),
                ),
                StatusBadge(status: expense.status, small: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
