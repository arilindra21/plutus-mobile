import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/design_tokens.dart';
import '../../providers/app_provider.dart';
import '../../providers/api_expense_provider.dart';
import '../../services/services.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/app_button.dart';

class ExpenseCreatedScreen extends StatelessWidget {
  const ExpenseCreatedScreen({super.key});

  String _getStatusLabel(int status) {
    // Status codes: 0=DRAFT, 1=PENDING, 2=SUBMITTED, 3=PENDING_APPROVAL, 4=APPROVED, 5=COMPLETED, 6=REJECTED, 7=RETURNED
    switch (status) {
      case 0:
        return 'Draft';
      case 1:
        return 'Pending';
      case 2:
        return 'Submitted';
      case 3:
        return 'Pending Approval';
      case 4:
        return 'Approved';
      case 5:
        return 'Completed';
      case 6:
        return 'Rejected';
      case 7:
        return 'Returned';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiExpenseProvider>(
      builder: (context, apiProvider, _) {
        // Use selectedExpense first (set during creation), fallback to first expense
        final latestExpense = apiProvider.selectedExpense ??
            (apiProvider.expenses.isNotEmpty ? apiProvider.expenses.first : null);

        return Scaffold(
          backgroundColor: AppColors.bgPaper,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  const Spacer(),

                  // Success Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 48,
                        color: AppColors.success,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  Text(
                    'Expense Created!',
                    style: AppTypography.headingMedium,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    'Your expense has been saved successfully',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  if (latestExpense != null) ...[
                    _buildDetailCard(latestExpense),
                    const SizedBox(height: AppSpacing.lg),
                    if (latestExpense.missingReceipt)
                      _buildMissingReceiptWarning(),
                  ],

                  const Spacer(),

                  AppButton(
                    label: 'View Expense',
                    fullWidth: true,
                    onPressed: () {
                      if (latestExpense != null) {
                        apiProvider.setSelectedExpense(latestExpense);
                        context.read<AppProvider>().navigateTo('transactionDetail');
                      }
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),

                  AppButton(
                    label: 'Back to Home',
                    variant: AppButtonVariant.secondary,
                    fullWidth: true,
                    onPressed: () {
                      context.read<AppProvider>().navigateToTab('home');
                    },
                  ),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailCard(ExpenseDTO expense) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgDefault,
        borderRadius: AppRadius.borderRadiusXl,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.bgSubtle,
                  borderRadius: AppRadius.borderRadiusMd,
                ),
                child: Center(
                  child: Text(expense.categoryIcon ?? '📋', style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.merchant,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: AppTypography.fontWeightSemibold,
                      ),
                    ),
                    Text(expense.category, style: AppTypography.bodySmall),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.lg),

          _DetailRow(label: 'Amount', value: formatRupiah(expense.originalAmount)),
          _DetailRow(label: 'Date', value: expense.formattedDate),
          _DetailRow(label: 'Status', value: expense.statusName ?? _getStatusLabel(expense.status)),
        ],
      ),
    );
  }

  Widget _buildMissingReceiptWarning() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'This expense is flagged as "Missing Receipt". Please attach a receipt when available.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.warningDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: AppTypography.fontWeightMedium)),
        ],
      ),
    );
  }
}
