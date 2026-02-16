import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/design_tokens.dart';
import '../../providers/app_provider.dart';
import '../../providers/api_expense_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/models/budget_dto.dart';
import '../../utils/formatters.dart';
import '../../widgets/layout/bottom_navigation.dart';

class BudgetOverviewScreen extends StatefulWidget {
  const BudgetOverviewScreen({super.key});

  @override
  State<BudgetOverviewScreen> createState() => _BudgetOverviewScreenState();
}

class _BudgetOverviewScreenState extends State<BudgetOverviewScreen> {
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
    await apiProvider.fetchReferenceData();
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return _buildApiContent(context);
  }

  Widget _buildApiContent(BuildContext context) {
    return Consumer<ApiExpenseProvider>(
      builder: (context, apiProvider, _) {
        final budgets = apiProvider.budgets;
        final authProvider = context.read<AuthProvider>();
        final departmentName = authProvider.user?.departmentName ?? 'All Departments';

        // Calculate totals from all budgets using utilization data
        double totalAllocated = 0;
        double totalUsed = 0;
        for (final budget in budgets) {
          final utilization = apiProvider.getBudgetUtilization(budget.id);
          totalAllocated += utilization?.budgetAmount ?? budget.budgetAmount;
          totalUsed += utilization?.spentAmount ?? 0;
        }
        final totalRemaining = totalAllocated - totalUsed;
        final overallUsagePercent = totalAllocated > 0 ? (totalUsed / totalAllocated) * 100 : 0;

        return Scaffold(
          backgroundColor: AppColors.bgPaper,
          body: Column(
            children: [
              _buildHeader(context, departmentName: departmentName),
              Expanded(
                child: apiProvider.isLoading && budgets.isEmpty
                    ? const Center(child: CupertinoActivityIndicator(radius: 14))
                    : budgets.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: () => apiProvider.fetchReferenceData(),
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Budget Remaining Card
                                  _buildApiBudgetRemainingCard(
                                    context,
                                    totalRemaining: totalRemaining,
                                    totalAllocated: totalAllocated,
                                    totalUsed: totalUsed,
                                    usagePercent: overallUsagePercent.toDouble(),
                                  ),

                                  // By Budget Section
                                  Padding(
                                    padding: const EdgeInsets.all(AppSpacing.lg),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Budget Allocation',
                                          style: AppTypography.headingSmall.copyWith(
                                            fontSize: AppTypography.fontSizeLg,
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.md),
                                        ...budgets.map((budget) => _ApiBudgetCard(
                                              budget: budget,
                                              utilization: apiProvider.getBudgetUtilization(budget.id),
                                              onTap: () {
                                                apiProvider.setSelectedBudgetCategory(budget.id);
                                                context.read<AppProvider>().navigateTo('budgetCategoryDetail');
                                              },
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
              ),
              const AppBottomNavigation(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: AppColors.textMuted.withOpacity(0.5),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No budgets available',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Budget allocations will appear here',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {String? departmentName}) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.md,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1a365d),
            Color(0xFF2d4a6f),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar
          Row(
            children: [
              GestureDetector(
                onTap: () => context.read<AppProvider>().toggleSideMenu(),
                child: const Icon(Icons.menu, color: Colors.white),
              ),
              const Spacer(),
              Stack(
                children: [
                  GestureDetector(
                    onTap: () => context.read<AppProvider>().navigateTo('notifications'),
                    child: const Icon(Icons.notifications_outlined, color: Colors.white),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Title
          Text(
            'Budget Overview',
            style: AppTypography.headingLarge.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            departmentName ?? 'Marketing Department',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiBudgetRemainingCard(
    BuildContext context, {
    required double totalRemaining,
    required double totalAllocated,
    required double totalUsed,
    required double usagePercent,
  }) {
    final isOverBudget = totalRemaining < 0;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isOverBudget
              ? [
                  const Color(0xFFEF4444), // Red
                  const Color(0xFFF87171),
                  const Color(0xFFFCA5A5),
                ]
              : [
                  const Color(0xFF10B981), // Green
                  const Color(0xFF34D399),
                  const Color(0xFF6EE7B7),
                ],
        ),
        borderRadius: AppRadius.borderRadiusXl,
        boxShadow: [
          BoxShadow(
            color: (isOverBudget ? const Color(0xFFEF4444) : const Color(0xFF10B981)).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isOverBudget ? 'Over Budget' : 'Budget Remaining',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            formatRupiah(totalRemaining.abs()),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'from ${formatRupiah(totalAllocated)}',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Progress bar
          ClipRRect(
            borderRadius: AppRadius.borderRadiusFull,
            child: LinearProgressIndicator(
              value: (usagePercent / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${usagePercent.toStringAsFixed(0)}% used',
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              Text(
                '${formatRupiah(totalUsed)} spent',
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}

/// API Budget Card - displays budget from API
class _ApiBudgetCard extends StatelessWidget {
  final BudgetItemDTO budget;
  final BudgetUtilizationDTO? utilization;
  final VoidCallback onTap;

  const _ApiBudgetCard({
    required this.budget,
    this.utilization,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use utilization data if available, otherwise fall back to budget data
    final budgetAmount = utilization?.budgetAmount ?? budget.budgetAmount;
    final spentAmount = utilization?.spentAmount ?? 0;
    final availableAmount = utilization?.availableAmount ?? budgetAmount;
    final usedPercent = utilization?.utilizationPct ?? (budgetAmount > 0 ? (spentAmount / budgetAmount) * 100 : 0);
    final isOverBudget = spentAmount > budgetAmount;

    // Determine color based on usage
    Color getProgressColor() {
      if (isOverBudget) return AppColors.danger;
      if (usedPercent > 90) return AppColors.danger;
      if (usedPercent > 70) return AppColors.warning;
      return AppColors.success;
    }

    // Get icon based on category or budget name
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

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgDefault,
        borderRadius: AppRadius.borderRadiusLg,
        boxShadow: AppShadows.card,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderRadiusLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: getProgressColor().withOpacity(0.1),
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                  child: Center(
                    child: Text(getIcon(), style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Name and period
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.name,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: AppTypography.fontWeightMedium,
                        ),
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

                // Percentage
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: getProgressColor().withOpacity(0.1),
                        borderRadius: AppRadius.borderRadiusFull,
                      ),
                      child: Text(
                        isOverBudget ? 'Over!' : '${usedPercent.toStringAsFixed(0)}%',
                        style: AppTypography.caption.copyWith(
                          fontWeight: AppTypography.fontWeightSemibold,
                          color: getProgressColor(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Progress bar
            ClipRRect(
              borderRadius: AppRadius.borderRadiusFull,
              child: LinearProgressIndicator(
                value: (usedPercent / 100).clamp(0.0, 1.0),
                backgroundColor: AppColors.bgSubtle,
                valueColor: AlwaysStoppedAnimation<Color>(getProgressColor()),
                minHeight: 6,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Used',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      formatRupiahCompact(spentAmount),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: AppTypography.fontWeightMedium,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Remaining',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      formatRupiahCompact(availableAmount),
                      style: AppTypography.bodySmall.copyWith(
                        color: isOverBudget ? AppColors.danger : AppColors.success,
                        fontWeight: AppTypography.fontWeightMedium,
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
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      formatRupiahCompact(budgetAmount),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: AppTypography.fontWeightMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // Period info
            Row(
              children: [
                Icon(Icons.calendar_today, size: 12, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  '${budget.period.toUpperCase()} • ${_formatDateRange(utilization?.periodStart ?? budget.startDate, utilization?.periodEnd ?? budget.endDate)}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${start.day} ${months[start.month - 1]} - ${end.day} ${months[end.month - 1]} ${end.year}';
  }
}
