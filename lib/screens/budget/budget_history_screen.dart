import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/design_tokens.dart';
import '../../providers/app_provider.dart';
import '../../providers/api_expense_provider.dart';
import '../../services/models/budget_dto.dart';
import '../../services/models/approval_dto.dart';
import '../../utils/formatters.dart';

class BudgetHistoryScreen extends StatefulWidget {
  const BudgetHistoryScreen({super.key});

  @override
  State<BudgetHistoryScreen> createState() => _BudgetHistoryScreenState();
}

class _BudgetHistoryScreenState extends State<BudgetHistoryScreen> {
  bool _isInitialized = false;
  bool _isNavigating = false;
  Map<String, ApprovalTaskDTO> _inboxTaskMap = {};
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeData());
  }

  Future<void> _initializeData() async {
    if (_isInitialized) return;
    _isInitialized = true;
    final inboxMap = await context.read<ApiExpenseProvider>().fetchInboxAsMap();
    if (mounted) setState(() => _inboxTaskMap = inboxMap);
  }

  Future<void> _navigateToExpense(BudgetTransactionItem tx) async {
    if (_isNavigating || tx.sourceId.isEmpty) return;
    final apiProvider = context.read<ApiExpenseProvider>();
    final appProvider = context.read<AppProvider>();
    setState(() => _isNavigating = true);
    try {
      final approvalTask = _inboxTaskMap[tx.sourceId];
      if (!mounted) return;
      if (approvalTask != null) {
        apiProvider.setSelectedApprovalTask(approvalTask);
        appProvider.navigateTo('approverExpenseDetail');
      } else {
        final fetched = await apiProvider.fetchExpensesByIds([tx.sourceId]);
        if (!mounted) return;
        if (fetched.isEmpty) {
          appProvider.showNotification('Expense not found', type: 'error');
          return;
        }
        apiProvider.setSelectedExpense(fetched.first);
        appProvider.navigateTo('transactionDetail');
      }
    } finally {
      if (mounted) setState(() => _isNavigating = false);
    }
  }

  List<BudgetTransactionItem> _applyFilter(List<BudgetTransactionItem> txs) {
    if (_selectedFilter == 'all') return txs;
    return txs.where((tx) => tx.sourceType == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiExpenseProvider>(
      builder: (context, apiProvider, _) {
        final history = apiProvider.selectedBudgetHistory;
        final allTxs = history != null ? history.transactions : const <BudgetTransactionItem>[];
        final filtered = _applyFilter(allTxs);

        int expenseCount = 0;
        int adjustmentCount = 0;
        for (final tx in allTxs) {
          if (tx.sourceType == 'expense') expenseCount++;
          else if (tx.sourceType == 'adjustment') adjustmentCount++;
        }

        return Scaffold(
          backgroundColor: AppColors.bgPaper,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, history),
                const SizedBox(height: AppSpacing.sm),
                _buildFilterChips(allTxs.length, expenseCount, adjustmentCount),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: apiProvider.isLoading
                      ? const Center(child: CupertinoActivityIndicator(radius: 14))
                      : _buildList(context, apiProvider, filtered),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, BudgetHistoryDTO? history) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.read<AppProvider>().goBack(),
            child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Transaction History', style: AppTypography.headingSmall),
                if (history != null && history.budgetName.isNotEmpty)
                  Text(
                    history.budgetName,
                    style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
          if (history != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.bgSubtle,
                borderRadius: AppRadius.borderRadiusFull,
              ),
              child: Text(
                '${history.totalCount} total',
                style: AppTypography.caption.copyWith(color: AppColors.textMuted),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(int allCount, int expenseCount, int adjustmentCount) {
    final keys = <String>['all', 'expense', 'adjustment'];
    final labels = <String>['All', 'Expenses', 'Adjustments'];
    final counts = <int>[allCount, expenseCount, adjustmentCount];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: List.generate(keys.length, (i) {
          final key = keys[i];
          final label = labels[i];
          final count = counts[i];
          final isSelected = _selectedFilter == key;

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.bgDefault,
                  borderRadius: AppRadius.borderRadiusFull,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.borderDefault,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AppTypography.bodySmall.copyWith(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? AppTypography.fontWeightSemibold
                            : AppTypography.fontWeightNormal,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.25)
                            : AppColors.bgSubtle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$count',
                        style: AppTypography.caption.copyWith(
                          color: isSelected ? Colors.white : AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: AppTypography.fontWeightMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    ApiExpenseProvider apiProvider,
    List<BudgetTransactionItem> txs,
  ) {
    if (txs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No transactions',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _selectedFilter == 'all'
                  ? 'This budget has no recorded activity yet'
                  : 'No ${_selectedFilter}s found',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final selectedBudgetId = apiProvider.selectedBudgetCategory;
        final Future<Map<String, ApprovalTaskDTO>> inboxFuture =
            apiProvider.fetchInboxAsMap();
        if (selectedBudgetId != null && selectedBudgetId.isNotEmpty) {
          await apiProvider.fetchBudgetAnalytics(selectedBudgetId);
        }
        final inboxMap = await inboxFuture;
        if (mounted) setState(() => _inboxTaskMap = inboxMap);
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: txs.length,
        itemBuilder: (context, i) => _buildItem(txs[i]),
      ),
    );
  }

  Widget _buildItem(BudgetTransactionItem tx) {
    final isExpenseTap = tx.sourceType == 'expense' && tx.sourceId.isNotEmpty;
    final isPending = _inboxTaskMap.containsKey(tx.sourceId);

    Color operationColor() {
      switch (tx.operation) {
        case 'commit':
          return AppColors.danger;
        case 'add_pending':
        case 'reserve':
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

    IconData operationIcon() {
      switch (tx.operation) {
        case 'commit':
          return Icons.check_circle_outline;
        case 'add_pending':
        case 'reserve':
          return Icons.hourglass_top_outlined;
        case 'release':
        case 'release_reserve':
          return Icons.undo_outlined;
        case 'adjust':
          return Icons.tune_outlined;
        default:
          return Icons.swap_horiz;
      }
    }

    String sourceTypeLabel() {
      switch (tx.sourceType) {
        case 'expense':
          return 'Expense';
        case 'adjustment':
          return 'Adjustment';
        case 'transaction':
          return 'Transaction';
        default:
          return tx.sourceType;
      }
    }

    final color = operationColor();
    final title = tx.description?.isNotEmpty == true
        ? tx.description!
        : tx.categoryName?.isNotEmpty == true
            ? tx.categoryName!
            : tx.operationLabel;
    final subtitle = tx.requesterName?.isNotEmpty == true
        ? tx.requesterName!
        : sourceTypeLabel();

    return GestureDetector(
      onTap: isExpenseTap ? () => _navigateToExpense(tx) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.bgDefault,
          borderRadius: AppRadius.borderRadiusMd,
          border: isExpenseTap
              ? Border.all(color: AppColors.primary.withOpacity(0.12))
              : null,
        ),
        child: Row(
          children: [
            // Operation icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: _isNavigating && isExpenseTap
                  ? const CupertinoActivityIndicator(radius: 10)
                  : Icon(operationIcon(), color: color, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: AppTypography.fontWeightMedium,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Source type tag
                      Container(
                        margin: const EdgeInsets.only(left: AppSpacing.xs),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.bgSubtle,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          sourceTypeLabel(),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDateTime(tx.createdAt),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            // Amount + badges
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${tx.isDebit ? '-' : '+'}${formatRupiahCompact(tx.amount)}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: tx.isDebit ? AppColors.danger : AppColors.success,
                    fontWeight: AppTypography.fontWeightSemibold,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Operation badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: AppRadius.borderRadiusFull,
                      ),
                      child: Text(
                        tx.operationLabel,
                        style: AppTypography.caption.copyWith(
                          color: color,
                          fontSize: 10,
                          fontWeight: AppTypography.fontWeightMedium,
                        ),
                      ),
                    ),
                    if (isPending) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.15),
                          borderRadius: AppRadius.borderRadiusFull,
                        ),
                        child: Text(
                          'Pending',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.warning,
                            fontSize: 10,
                            fontWeight: AppTypography.fontWeightMedium,
                          ),
                        ),
                      ),
                    ],
                    if (isExpenseTap) ...[
                      const SizedBox(width: 4),
                      Icon(CupertinoIcons.chevron_right,
                          size: 12, color: AppColors.textMuted),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
