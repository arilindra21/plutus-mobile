import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/notification_provider.dart';
import '../../core/design_tokens.dart';

void _showAddExpenseSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const _AddExpenseBottomSheet(),
  );
}

/// Fintech-style Bottom Navigation
class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        final currentScreen = appProvider.currentScreen;
        final isManager = appProvider.userCapabilities.canApprove;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: FintechColors.primary.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Home
                  _NavItem(
                    icon: CupertinoIcons.house,
                    activeIcon: CupertinoIcons.house_fill,
                    label: 'Home',
                    isActive: currentScreen == 'home' || currentScreen == 'approverHome',
                    onTap: () => appProvider.navigateToTab('home'),
                  ),

                  // Review (Manager) or Expenses (Employee)
                  if (isManager)
                    Consumer<NotificationProvider>(
                      builder: (context, notificationProvider, _) => _NavItem(
                        icon: CupertinoIcons.checkmark_seal,
                        activeIcon: CupertinoIcons.checkmark_seal_fill,
                        label: 'Review',
                        isActive: currentScreen == 'reviewApprove',
                        badge: notificationProvider.pendingApprovalCount,
                        onTap: () => appProvider.navigateToTab('reviewApprove'),
                      ),
                    )
                  else
                    _NavItem(
                      icon: CupertinoIcons.doc_text,
                      activeIcon: CupertinoIcons.doc_text_fill,
                      label: 'Expenses',
                      isActive: currentScreen == 'transactions' || currentScreen == 'expenses',
                      onTap: () => appProvider.navigateToTab('transactions'),
                    ),

                  // Center FAB (Add)
                  _CenterFAB(
                    onTap: () => _showAddExpenseSheet(context),
                  ),

                  // Budget (Manager only) or Alert (Employee)
                  if (isManager)
                    _NavItem(
                      icon: CupertinoIcons.chart_pie,
                      activeIcon: CupertinoIcons.chart_pie_fill,
                      label: 'Budget',
                      isActive: currentScreen == 'budgetOverview' || currentScreen == 'budgetCategoryDetail',
                      onTap: () => appProvider.navigateToTab('budgetOverview'),
                    )
                  else
                    Consumer<NotificationProvider>(
                      builder: (context, notificationProvider, _) => _NavItem(
                        icon: CupertinoIcons.bell,
                        activeIcon: CupertinoIcons.bell_fill,
                        label: 'Alert',
                        isActive: currentScreen == 'notifications' || currentScreen == 'alerts',
                        badge: notificationProvider.unreadCount,
                        onTap: () => appProvider.navigateToTab('notifications'),
                      ),
                    ),

                  // History
                  _NavItem(
                    icon: CupertinoIcons.clock,
                    activeIcon: CupertinoIcons.clock_fill,
                    label: 'History',
                    isActive: currentScreen == 'historyLog',
                    onTap: () => appProvider.navigateToTab('historyLog'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final int badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    this.badge = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: AppDurations.fast,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isActive ? FintechColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    isActive ? activeIcon : icon,
                    size: 24,
                    color: isActive ? FintechColors.primary : AppColors.textMuted,
                  ),
                ),
                if (badge > 0)
                  Positioned(
                    right: -4,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.statusRejected,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        badge > 9 ? '9+' : badge.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? FintechColors.primary : AppColors.textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterFAB extends StatelessWidget {
  final VoidCallback onTap;

  const _CenterFAB({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.only(bottom: 8),
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
          boxShadow: [
            BoxShadow(
              color: FintechColors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          CupertinoIcons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

// Fintech-style Add Expense Bottom Sheet
class _AddExpenseBottomSheet extends StatelessWidget {
  const _AddExpenseBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: FintechColors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
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
                color: AppColors.border,
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
                        color: AppColors.surfaceVariant,
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

            Divider(height: 1, color: AppColors.border),

            // Options
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _SheetOptionCard(
                    icon: CupertinoIcons.camera_fill,
                    iconColor: FintechColors.categoryBlue,
                    iconBgColor: FintechColors.categoryBlueBg,
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
                  _SheetOptionCard(
                    icon: CupertinoIcons.pencil,
                    iconColor: FintechColors.categoryPurple,
                    iconBgColor: FintechColors.categoryPurpleBg,
                    title: 'Manual Entry',
                    subtitle: 'Enter expense details manually',
                    onTap: () {
                      Navigator.pop(context);
                      context.read<AppProvider>().navigateTo('newExpense');
                    },
                  ),
                  const SizedBox(height: 12),
                  _SheetOptionCard(
                    icon: CupertinoIcons.creditcard_fill,
                    iconColor: FintechColors.categoryGreen,
                    iconBgColor: FintechColors.categoryGreenBg,
                    title: 'From Card Transaction',
                    subtitle: 'Attach receipt to existing transaction',
                    onTap: () {
                      Navigator.pop(context);
                      context.read<AppProvider>().navigateTo('cards');
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

class _SheetOptionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SheetOptionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceVariant,
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
                  color: iconBgColor,
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
                        color: AppColors.textSecondary,
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
