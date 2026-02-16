import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/design_tokens.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common/app_button.dart';

class ApprovalSuccessScreen extends StatelessWidget {
  const ApprovalSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the action from navigation params
    final appProvider = context.read<AppProvider>();
    final params = appProvider.screenParams;
    final action = params?['action'] ?? 'approved';
    final isApproved = action == 'approved';

    return Scaffold(
      backgroundColor: AppColors.bgPaper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(),

              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: (isApproved ? AppColors.success : AppColors.danger)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: (isApproved ? AppColors.success : AppColors.danger)
                        .withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isApproved ? Icons.check_rounded : Icons.close_rounded,
                    size: 48,
                    color: isApproved ? AppColors.success : AppColors.danger,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Title
              Text(
                isApproved ? 'Expense Approved!' : 'Expense Rejected',
                style: AppTypography.headingMedium,
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                isApproved
                    ? 'The expense has been approved and the submitter will be notified.'
                    : 'The expense has been rejected and returned to the submitter.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Buttons
              AppButton(
                label: 'Review More Expenses',
                fullWidth: true,
                onPressed: () {
                  appProvider.clearNavigationParams();
                  appProvider.navigateTo('reviewApprove');
                },
              ),

              const SizedBox(height: AppSpacing.md),

              AppButton(
                label: 'Back to Home',
                variant: AppButtonVariant.secondary,
                fullWidth: true,
                onPressed: () {
                  appProvider.clearNavigationParams();
                  appProvider.navigateToTab('home');
                },
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
