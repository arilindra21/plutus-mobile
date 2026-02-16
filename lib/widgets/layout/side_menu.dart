import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/api_expense_provider.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        final isApprover = appProvider.userCapabilities.canApprove;
        final pendingCount = context.read<ApiExpenseProvider>().pendingApprovalsCount;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: appProvider.sideMenuOpen ? 300 : 0,
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(),
          child: SizedBox(
            width: 300,
            child: appProvider.sideMenuOpen
              ? Material(
                  color: Colors.white,
                  elevation: 16,
                  shadowColor: Colors.black.withOpacity(0.15),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Header
                        _buildHeader(context, appProvider),

                        // Menu Items
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            children: [
                              const _SectionHeader(title: 'MAIN'),
                              _MenuItem(
                                icon: CupertinoIcons.house_fill,
                                label: 'Home',
                                isSelected: appProvider.currentScreen == 'home' ||
                                    appProvider.currentScreen == 'approverHome',
                                onTap: () {
                                  appProvider.toggleSideMenu();
                                  appProvider.navigateToTab('home');
                                },
                              ),
                              _MenuItem(
                                icon: CupertinoIcons.doc_text_fill,
                                label: 'My Expenses',
                                isSelected: appProvider.currentScreen == 'transactions',
                                onTap: () {
                                  appProvider.toggleSideMenu();
                                  appProvider.navigateToTab('expenses');
                                },
                              ),
                              _MenuItem(
                                icon: CupertinoIcons.creditcard_fill,
                                label: 'My Cards',
                                isSelected: appProvider.currentScreen == 'cards',
                                onTap: () {
                                  appProvider.toggleSideMenu();
                                  appProvider.navigateTo('cards');
                                },
                              ),

                              if (isApprover) ...[
                                const _SectionHeader(title: 'MANAGER'),
                                _MenuItem(
                                  icon: CupertinoIcons.checkmark_seal_fill,
                                  label: 'Approvals',
                                  badge: pendingCount > 0 ? pendingCount : null,
                                  badgeColor: const Color(0xFFFF3B30),
                                  isSelected: appProvider.currentScreen == 'reviewApprove',
                                  onTap: () {
                                    appProvider.toggleSideMenu();
                                    appProvider.navigateTo('reviewApprove');
                                  },
                                ),
                                _MenuItem(
                                  icon: CupertinoIcons.chart_pie_fill,
                                  label: 'Budget Overview',
                                  isSelected: appProvider.currentScreen == 'budgetOverview',
                                  onTap: () {
                                    appProvider.toggleSideMenu();
                                    appProvider.navigateTo('budgetOverview');
                                  },
                                ),
                                _MenuItem(
                                  icon: CupertinoIcons.person_3_fill,
                                  label: 'Team Expenses',
                                  isSelected: appProvider.currentScreen == 'teamExpenses',
                                  onTap: () {
                                    appProvider.toggleSideMenu();
                                    appProvider.navigateTo('teamExpenses');
                                  },
                                ),
                              ],

                              const _SectionHeader(title: 'OTHER'),
                              _MenuItem(
                                icon: CupertinoIcons.bell_fill,
                                label: 'Notifications',
                                badge: appProvider.unreadNotificationCount > 0
                                    ? appProvider.unreadNotificationCount
                                    : null,
                                badgeColor: const Color(0xFF007AFF),
                                isSelected: appProvider.currentScreen == 'notifications',
                                onTap: () {
                                  appProvider.toggleSideMenu();
                                  appProvider.navigateToTab('notifications');
                                },
                              ),
                              _MenuItem(
                                icon: CupertinoIcons.clock_fill,
                                label: 'Activity History',
                                isSelected: appProvider.currentScreen == 'historyLog',
                                onTap: () {
                                  appProvider.toggleSideMenu();
                                  appProvider.navigateToTab('historyLog');
                                },
                              ),
                              _MenuItem(
                                icon: CupertinoIcons.gear_alt_fill,
                                label: 'Settings',
                                isSelected: appProvider.currentScreen == 'settings',
                                onTap: () {
                                  appProvider.toggleSideMenu();
                                  appProvider.navigateTo('settings');
                                },
                              ),
                              _MenuItem(
                                icon: CupertinoIcons.question_circle_fill,
                                label: 'Help & Support',
                                onTap: () {
                                  appProvider.toggleSideMenu();
                                },
                              ),
                            ],
                          ),
                        ),

                        // Footer
                        _buildFooter(context, appProvider),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppProvider appProvider) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final apiUser = authProvider.user;
        final userName = apiUser?.name ?? 'User';
        final userRole = apiUser?.jobTitle ?? (apiUser?.isManager == true ? 'Manager' : 'Employee');
        final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
        final jobLevel = apiUser?.jobLevel;
        final isManager = appProvider.userCapabilities.canApprove;

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isManager
                  ? [const Color(0xFF5856D6), const Color(0xFF007AFF)]
                  : [const Color(0xFF007AFF), const Color(0xFF34C759)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isManager ? 'Manager Portal' : 'Employee Portal',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => appProvider.toggleSideMenu(),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        CupertinoIcons.xmark,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Avatar and Info
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        userInitial,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: isManager
                              ? const Color(0xFF5856D6)
                              : const Color(0xFF007AFF),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                userRole,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (jobLevel != null) ...[
                              const SizedBox(width: 6),
                              Text(
                                'Level $jobLevel',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
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

  Widget _buildFooter(BuildContext context, AppProvider appProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: GestureDetector(
        onTap: () async {
          appProvider.toggleSideMenu();
          await context.read<AuthProvider>().logout();
          context.read<ApiExpenseProvider>().clearState();
          appProvider.logout();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFF3B30).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                CupertinoIcons.square_arrow_left,
                color: Color(0xFFFF3B30),
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF3B30),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8E8E93),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final int? badge;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.badge,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF007AFF).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF007AFF)
                    : const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF8E8E93),
                size: 17,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF007AFF)
                      : const Color(0xFF1C1C1E),
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor ?? const Color(0xFF007AFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge! > 99 ? '99+' : '$badge',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
