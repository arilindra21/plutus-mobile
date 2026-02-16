import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/design_tokens.dart';
import '../../providers/app_provider.dart';

class AddExpenseSheet extends StatelessWidget {
  const AddExpenseSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const AddExpenseSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgDefault,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.md),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderDefault,
              borderRadius: AppRadius.borderRadiusFull,
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add New Expense',
                  style: AppTypography.headingSmall,
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.bgSubtle,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Options
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                _OptionCard(
                  icon: Icons.camera_alt_outlined,
                  title: 'Scan Receipt',
                  description: 'Take a photo or upload a receipt image',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    context.read<AppProvider>().navigateToWithParams('camera', {
                      'mode': 'scan',
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _OptionCard(
                  icon: Icons.edit_outlined,
                  title: 'Manual Entry',
                  description: 'Enter expense details manually',
                  color: AppColors.info,
                  onTap: () {
                    Navigator.pop(context);
                    context.read<AppProvider>().navigateTo('newExpense');
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _OptionCard(
                  icon: Icons.receipt_long_outlined,
                  title: 'From Card Transaction',
                  description: 'Attach receipt to an existing transaction',
                  color: AppColors.success,
                  onTap: () {
                    Navigator.pop(context);
                    context.read<AppProvider>().navigateTo('cards');
                  },
                ),
              ],
            ),
          ),

          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.bgPaper,
          borderRadius: AppRadius.borderRadiusLg,
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: AppTypography.fontWeightMedium,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
