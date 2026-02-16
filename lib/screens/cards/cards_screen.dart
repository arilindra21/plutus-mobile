import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/design_tokens.dart';
import '../../providers/app_provider.dart';
import '../../providers/api_transaction_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/layout/bottom_navigation.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<ApiTransactionProvider>();
    await provider.loadTransactions(refresh: true);
    await provider.loadPendingReceiptTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPaper,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildContent(context)),
          const AppBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.md,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.xl,
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
              const SizedBox(width: AppSpacing.md),
              GestureDetector(
                onTap: () {},
                child: const Icon(Icons.settings_outlined, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Title
          Text(
            'Corporate Cards',
            style: AppTypography.headingLarge.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'View your card transactions',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Consumer<ApiTransactionProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.transactions.isEmpty) {
          return const Center(child: CupertinoActivityIndicator(radius: 14));
        }

        // Show transactions that need receipts as "card transactions"
        final pendingReceipts = provider.pendingReceiptTransactions;

        if (pendingReceipts.isEmpty && provider.transactions.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              // Pending receipts section
              if (pendingReceipts.isNotEmpty) ...[
                Text(
                  'Pending Receipts',
                  style: AppTypography.headingSmall.copyWith(
                    fontSize: AppTypography.fontSizeLg,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ...pendingReceipts.map((tx) => _TransactionCard(
                  transaction: tx,
                  onTap: () {
                    // Navigate to transaction detail or card transaction screen
                    context.read<AppProvider>().navigateTo('cardTransactions');
                  },
                )),
              ],

              // Info card
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.lg),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: AppRadius.borderRadiusLg,
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 24),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Card Management',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: AppTypography.fontWeightSemibold,
                              color: AppColors.info,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Corporate card transactions will appear here once connected to your account.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
            Icons.credit_card_outlined,
            size: 64,
            color: AppColors.textMuted.withOpacity(0.5),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No corporate cards',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Card transactions will appear here once linked',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final dynamic transaction;
  final VoidCallback onTap;

  const _TransactionCard({
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.bgDefault,
          borderRadius: AppRadius.borderRadiusLg,
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: const Center(
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.warning,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.merchantName ?? 'Transaction',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: AppTypography.fontWeightMedium,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Receipt needed',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              formatRupiah(transaction.amount ?? 0),
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: AppTypography.fontWeightSemibold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
