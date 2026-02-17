import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/design_tokens.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/api_expense_provider.dart';
import '../../providers/api_transaction_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/layout/bottom_navigation.dart';
import '../../widgets/fintech/fintech_widgets.dart';

void _showAddExpenseSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const _AddExpenseBottomSheet(),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    final apiExpenseProvider = context.read<ApiExpenseProvider>();
    final transactionProvider = context.read<ApiTransactionProvider>();
    final authProvider = context.read<AuthProvider>();

    if (authProvider.user != null) {
      apiExpenseProvider.setUserContext(
        userId: authProvider.user!.id,
        isManager: authProvider.user!.isManager,
        userProfile: authProvider.user,
      );
    }

    await Future.wait([
      apiExpenseProvider.fetchExpenses(pageSize: 5),
      apiExpenseProvider.fetchReferenceData(),
      transactionProvider.loadPendingReceiptTransactions(),
      if (appProvider.userCapabilities.canApprove)
        apiExpenseProvider.fetchInboxSummary(),
    ]);
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPaper,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Header with gradient
                  SliverToBoxAdapter(child: _buildHeader()),

                  // Balance Card
                  SliverToBoxAdapter(child: _buildBalanceCard()),

                  // Quick Actions
                  SliverToBoxAdapter(child: _buildQuickActions()),

                  // Alert Banners
                  SliverToBoxAdapter(child: _buildAlertBanners()),

                  // Recent Expenses
                  SliverToBoxAdapter(child: _buildRecentExpenses()),

                  // Bottom spacing
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
            const AppBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer2<AppProvider, AuthProvider>(
      builder: (context, appProvider, authProvider, _) {
        final userName = authProvider.user?.name ?? 'User';
        final initials = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: const BoxDecoration(
            gradient: AppColors.headerGradient,
          ),
          child: Row(
            children: [
              // Menu button
              GestureDetector(
                onTap: () => appProvider.toggleSideMenu(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    CupertinoIcons.line_horizontal_3,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Greeting
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good ${_getGreeting()}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Notifications
              GestureDetector(
                onTap: () => appProvider.navigateTo('notifications'),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(
                          CupertinoIcons.bell_fill,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: FintechColors.accent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: FintechColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _buildBalanceCard() {
    final appProvider = context.read<AppProvider>();
    final isManager = appProvider.userCapabilities.canApprove;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Transform.translate(
        offset: const Offset(0, -20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            boxShadow: [
              BoxShadow(
                color: FintechColors.primary.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Consumer<ApiExpenseProvider>(
            builder: (context, apiProvider, _) {
              if (isManager) {
                return _buildManagerBalanceContent(apiProvider);
              } else {
                return _buildEmployeeBalanceContent(apiProvider);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeBalanceContent(ApiExpenseProvider apiProvider) {
    final pendingAmount = apiProvider.totalPendingAmount;
    final pendingCount = apiProvider.employeePendingCount;
    final draftCount = apiProvider.draftCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pending Reimbursement',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: pendingCount > 0
                    ? FintechColors.categoryYellow.withValues(alpha: 0.2)
                    : FintechColors.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    pendingCount > 0 ? CupertinoIcons.clock_fill : CupertinoIcons.checkmark_circle_fill,
                    size: 12,
                    color: pendingCount > 0 ? FintechColors.categoryYellow : FintechColors.accent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    pendingCount > 0 ? '$pendingCount Pending' : 'All Clear',
                    style: TextStyle(
                      color: pendingCount > 0 ? FintechColors.categoryYellow : FintechColors.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          formatRupiah(pendingAmount),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Awaiting approval',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 20),
        // Stats row
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                icon: CupertinoIcons.doc_text,
                label: 'Draft',
                value: draftCount.toString(),
                color: FintechColors.categoryBlue,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            Expanded(
              child: _buildStatItem(
                icon: CupertinoIcons.clock,
                label: 'Pending',
                value: pendingCount.toString(),
                color: FintechColors.categoryYellow,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            Expanded(
              child: _buildStatItem(
                icon: CupertinoIcons.checkmark_circle,
                label: 'This Month',
                value: formatRupiahCompact(apiProvider.totalApprovedThisMonth),
                color: FintechColors.accent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildManagerBalanceContent(ApiExpenseProvider apiProvider) {
    final pendingApprovals = apiProvider.pendingApprovalsCount;
    final inboxSummary = apiProvider.inboxSummary;
    final approvedCount = inboxSummary?.approvedCount ?? 0;
    final rejectedCount = inboxSummary?.rejectedCount ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pending Approvals',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: () => context.read<AppProvider>().navigateTo('approvals'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: pendingApprovals > 0
                      ? FintechColors.categoryOrange.withValues(alpha: 0.2)
                      : FintechColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      pendingApprovals > 0 ? CupertinoIcons.bell_fill : CupertinoIcons.checkmark_circle_fill,
                      size: 12,
                      color: pendingApprovals > 0 ? FintechColors.categoryOrange : FintechColors.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      pendingApprovals > 0 ? 'Action Required' : 'All Clear',
                      style: TextStyle(
                        color: pendingApprovals > 0 ? FintechColors.categoryOrange : FintechColors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              pendingApprovals.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w700,
                letterSpacing: -2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 8),
              child: Text(
                'expenses',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Need your review',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 20),
        // Stats row
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                icon: CupertinoIcons.clock,
                label: 'Pending',
                value: pendingApprovals.toString(),
                color: FintechColors.categoryYellow,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            Expanded(
              child: _buildStatItem(
                icon: CupertinoIcons.checkmark_circle,
                label: 'Approved',
                value: approvedCount.toString(),
                color: FintechColors.accent,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            Expanded(
              child: _buildStatItem(
                icon: CupertinoIcons.xmark_circle,
                label: 'Rejected',
                value: rejectedCount.toString(),
                color: FintechColors.categoryRed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Quick Actions'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: QuickActionCard(
                  icon: CupertinoIcons.doc_text_fill,
                  iconColor: FintechColors.categoryBlue,
                  title: 'Reimbursement',
                  subtitle: 'Out-of-pocket',
                  onTap: () => _showAddExpenseSheet(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickActionCard(
                  icon: CupertinoIcons.creditcard_fill,
                  iconColor: FintechColors.categoryGreen,
                  title: 'Cash Advance',
                  subtitle: 'Pre-paid',
                  onTap: () => context.read<AppProvider>().navigateTo('cashAdvance'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBanners() {
    final appProvider = context.read<AppProvider>();
    final isManager = appProvider.userCapabilities.canApprove;

    return Consumer2<ApiExpenseProvider, ApiTransactionProvider>(
      builder: (context, apiExpenseProvider, transactionProvider, _) {
        final pendingApprovals = apiExpenseProvider.pendingApprovalsCount;
        final pendingReceipts = transactionProvider.pendingReceiptCount;

        final List<Widget> banners = [];

        if (isManager && pendingApprovals > 0) {
          banners.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: AlertBanner(
                icon: CupertinoIcons.checkmark_seal_fill,
                iconColor: FintechColors.categoryGreen,
                backgroundColor: FintechColors.categoryGreenBg,
                title: '$pendingApprovals expense${pendingApprovals > 1 ? 's' : ''} need${pendingApprovals > 1 ? '' : 's'} your approval',
                subtitle: 'Ready to review',
                onTap: () => context.read<AppProvider>().navigateTo('reviewApprove'),
              ),
            ),
          );
        }

        if (pendingReceipts > 0) {
          banners.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: AlertBanner(
                icon: CupertinoIcons.doc_text_fill,
                iconColor: FintechColors.categoryYellow,
                backgroundColor: FintechColors.categoryYellowBg,
                title: '$pendingReceipts expense${pendingReceipts > 1 ? 's' : ''} need${pendingReceipts > 1 ? '' : 's'} receipts',
                subtitle: 'Attach receipts to complete',
                onTap: () => context.read<AppProvider>().navigateTo('cardTransactions'),
              ),
            ),
          );
        }

        if (banners.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(children: banners);
      },
    );
  }

  Widget _buildRecentExpenses() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        children: [
          SectionHeader(
            title: 'Recent Expenses',
            actionText: 'See All',
            onActionTap: () => context.read<AppProvider>().navigateTo('transactions'),
          ),
          const SizedBox(height: 16),
          Consumer<ApiExpenseProvider>(
            builder: (context, apiProvider, _) {
              if (apiProvider.isLoading && apiProvider.expenses.isEmpty) {
                return FintechCard(
                  padding: EdgeInsets.zero,
                  child: const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CupertinoActivityIndicator()),
                  ),
                );
              }

              final expenses = apiProvider.recentExpenses;
              if (expenses.isEmpty) {
                return FintechCard(
                  padding: EdgeInsets.zero,
                  child: const EmptyState(
                    icon: CupertinoIcons.doc_text,
                    title: 'No transactions yet',
                    subtitle: 'Your expenses will appear here',
                  ),
                );
              }

              return Column(
                children: [
                  for (int i = 0; i < expenses.take(5).length; i++)
                    _RecentExpenseCard(expense: expenses[i]),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// Recent Expense Card - matches Transactions List style
class _RecentExpenseCard extends StatelessWidget {
  final dynamic expense;

  const _RecentExpenseCard({required this.expense});

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
                // Avatar with gradient
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

// Add Expense Bottom Sheet
class _AddExpenseBottomSheet extends StatelessWidget {
  const _AddExpenseBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderDefault,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add New Expense',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.bgSubtle,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        CupertinoIcons.xmark,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: AppColors.borderDefault),

            // Options
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _SheetOption(
                    icon: CupertinoIcons.camera_fill,
                    iconColor: FintechColors.categoryBlue,
                    title: 'Scan Receipt',
                    subtitle: 'Take a photo or upload receipt',
                    onTap: () {
                      Navigator.pop(context);
                      context.read<AppProvider>().navigateToWithParams('camera', {
                        'mode': 'scan',
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _SheetOption(
                    icon: CupertinoIcons.pencil,
                    iconColor: FintechColors.categoryPurple,
                    title: 'Manual Entry',
                    subtitle: 'Enter expense details manually',
                    onTap: () {
                      Navigator.pop(context);
                      context.read<AppProvider>().navigateTo('newExpense');
                    },
                  ),
                  const SizedBox(height: 12),
                  _SheetOption(
                    icon: CupertinoIcons.creditcard_fill,
                    iconColor: FintechColors.categoryGreen,
                    title: 'From Card Transaction',
                    subtitle: 'Attach receipt to existing transaction',
                    onTap: () {
                      Navigator.pop(context);
                      context.read<AppProvider>().navigateTo('cardTransactions');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgSubtle,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 18,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
