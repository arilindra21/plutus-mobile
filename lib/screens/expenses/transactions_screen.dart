import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/api_expense_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/expense.dart';
import '../../services/services.dart';
import '../../utils/formatters.dart';
import '../../widgets/layout/bottom_navigation.dart';
import '../../constants/status_config.dart';
import '../../core/design_tokens.dart';
import '../../widgets/fintech/fintech_widgets.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  bool _showFilters = false;
  bool _isInitialized = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = 200.0; // Load more when 200px from bottom

    if (currentScroll >= maxScroll - threshold) {
      _loadMoreExpenses();
    }
  }

  Future<void> _loadMoreExpenses() async {
    final apiProvider = context.read<ApiExpenseProvider>();
    final pagination = apiProvider.pagination;

    // Check if there are more pages
    if (pagination == null || !pagination.hasNext) return;

    setState(() => _isLoadingMore = true);

    await apiProvider.fetchExpenses(page: pagination.page + 1);
    await apiProvider.populateExpenseRequesterInfo();

    if (mounted) {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _initializeData() async {
    if (_isInitialized) return;

    final apiProvider = context.read<ApiExpenseProvider>();
    final authProvider = context.read<AuthProvider>();

    // Set user context for expense filtering
    // Employee (jobLevel < 3) can only see their own expenses
    // Manager (jobLevel >= 3) can see all expenses
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
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Search & Filter
            _buildSearchBar(),

            // Filter Panel
            if (_showFilters) _buildFilterPanel(),

            // Transaction Count
            _buildTransactionCount(),

            // Transaction List
            Expanded(child: _buildTransactionList()),

            // Bottom Navigation
            const AppBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => context.read<AppProvider>().goBack(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                CupertinoIcons.back,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Title
          const Text(
            'Expenses',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          // Add Button
          GestureDetector(
            onTap: () {
              context.read<ApiExpenseProvider>().setSelectedExpense(null);
              context.read<AppProvider>().navigateTo('newExpense');
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: FintechColors.accent,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                CupertinoIcons.add,
                size: 22,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          // Search Field
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.card,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  // TODO: Implement search functionality
                },
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search expenses...',
                  hintStyle: TextStyle(
                    fontSize: 15,
                    color: AppColors.textMuted,
                  ),
                  prefixIcon: Icon(
                    CupertinoIcons.search,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Filter Button
          GestureDetector(
            onTap: () => setState(() => _showFilters = !_showFilters),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _showFilters ? FintechColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.card,
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.slider_horizontal_3,
                    size: 18,
                    color: _showFilters ? Colors.white : FintechColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Filter',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _showFilters ? Colors.white : FintechColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    // Simplified filter panel - filters can be implemented as needed
    return FintechCard(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        'Filters coming soon',
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildTransactionCount() {
    return Consumer<ApiExpenseProvider>(
      builder: (context, apiProvider, _) {
        final expenses = apiProvider.expenses;
        final pagination = apiProvider.pagination;
        final displayedCount = expenses.length;
        final totalCount = pagination?.totalCount ?? displayedCount;
        final totalAmount = expenses.fold(0.0, (sum, exp) => sum + exp.originalAmount);

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '$displayedCount',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (totalCount > displayedCount) ...[
                    Text(
                      ' of $totalCount',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                  Text(
                    ' expenses',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Total: ',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    formatRupiahCompact(totalAmount),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionList() {
    return Consumer<ApiExpenseProvider>(
      builder: (context, apiProvider, _) {
        if (apiProvider.isLoading && apiProvider.expenses.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(FintechColors.primary),
            ),
          );
        }

        final expenses = apiProvider.expenses;
        final pagination = apiProvider.pagination;
        final hasMore = pagination?.hasNext ?? false;

        if (expenses.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: expenses.length + (hasMore || _isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            // Loading indicator at the bottom
            if (index >= expenses.length) {
              return _buildLoadMoreIndicator(hasMore);
            }
            return _ExpenseCard(expense: expenses[index]);
          },
        );
      },
    );
  }

  Widget _buildLoadMoreIndicator(bool hasMore) {
    if (_isLoadingMore) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(FintechColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Loading more...',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (hasMore) {
      return GestureDetector(
        onTap: _loadMoreExpenses,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: FintechColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.arrow_down_circle,
                    size: 18,
                    color: FintechColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Load More',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: FintechColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
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
              color: FintechColors.categoryBlueBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.doc_text,
              size: 36,
              color: FintechColors.categoryBlue,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No expenses yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your expenses will appear here',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => context.read<AppProvider>().navigateTo('newExpense'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: FintechColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: FintechColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'Add Expense',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Expense Card with Fintech styling
class _ExpenseCard extends StatelessWidget {
  final ExpenseDTO expense;

  const _ExpenseCard({required this.expense});

  @override
  Widget build(BuildContext context) {
    final apiProvider = context.read<ApiExpenseProvider>();

    final categoryIcon = expense.categoryIcon?.isNotEmpty == true
        ? expense.categoryIcon!
        : apiProvider.getCategoryIcon(expense.categoryId);
    final categoryName = expense.categoryName?.isNotEmpty == true
        ? expense.categoryName!
        : apiProvider.getCategoryName(expense.categoryId);

    // Get requester details
    final requester = apiProvider.getExpenseRequesterDetails(expense);

    return FintechCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      onTap: () {
        context.read<ApiExpenseProvider>().setSelectedExpense(expense);
        context.read<AppProvider>().navigateTo('transactionDetail');
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Avatar, Requester info, Amount
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with initials
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        FintechColors.primary,
                        FintechColors.primaryLight,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      requester.initials,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (requester.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          requester.subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (requester.email.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          requester.email,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
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
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    StatusPill(status: expense.status),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Divider
            Container(
              height: 1,
              color: AppColors.border,
            ),
            const SizedBox(height: 12),
            // Bottom row: Category, merchant, date
            Row(
              children: [
                // Category icon with colored background
                CategoryIconCircle(
                  icon: categoryIcon,
                  categoryCode: categoryName.toLowerCase(),
                  size: 32,
                ),
                const SizedBox(width: 10),
                // Category & Merchant
                Expanded(
                  child: Text(
                    '$categoryName • ${expense.merchant}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Date
                Text(
                  expense.formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
