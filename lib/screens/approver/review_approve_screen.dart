import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/design_tokens.dart';
import '../../providers/app_provider.dart';
import '../../providers/api_expense_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../utils/formatters.dart';
import '../../widgets/layout/bottom_navigation.dart';

class ReviewApproveScreen extends StatefulWidget {
  const ReviewApproveScreen({super.key});

  @override
  State<ReviewApproveScreen> createState() => _ReviewApproveScreenState();
}

class _ReviewApproveScreenState extends State<ReviewApproveScreen> {
  String _selectedFilter = 'all';
  bool _isInitialized = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    if (_isInitialized) return;

    final apiProvider = context.read<ApiExpenseProvider>();
    final authProvider = context.read<AuthProvider>();

    // Set user context for expense filtering
    if (authProvider.user != null) {
      apiProvider.setUserContext(
        userId: authProvider.user!.id,
        isManager: authProvider.user!.isManager,
      );
    }

    await Future.wait([
      apiProvider.fetchApprovalInbox(refresh: true),
      apiProvider.fetchInboxSummary(),
    ]);
    // Populate requester info for tasks with empty names
    await apiProvider.populateRequesterInfo();
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiExpenseProvider>(
      builder: (context, apiProvider, _) {
        return Scaffold(
          backgroundColor: AppColors.bgPaper,
          body: Column(
            children: [
              _buildHeader(context),
              _buildFilterTabs(),
              Expanded(child: _buildPendingList()),
              if (apiProvider.isSelectionMode && apiProvider.hasSelectedTasks)
                _buildBulkActionBar(context, apiProvider)
              else
                const AppBottomNavigation(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<ApiExpenseProvider>(
      builder: (context, apiProvider, _) {
        final pendingCount = apiProvider.pendingApprovalsCount;
        final isSelectionMode = apiProvider.isSelectionMode;
        final selectedCount = apiProvider.selectedTaskCount;
        final totalTasks = apiProvider.approvalTasks.length;

        return _buildHeaderContent(
          context,
          pendingCount,
          isSelectionMode,
          selectedCount,
          totalTasks,
          apiProvider,
        );
      },
    );
  }

  Widget _buildHeaderContent(
    BuildContext context,
    int pendingCount,
    bool isSelectionMode,
    int selectedCount,
    int totalTasks,
    ApiExpenseProvider apiProvider,
  ) {
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
              if (isSelectionMode) ...[
                GestureDetector(
                  onTap: () => apiProvider.exitSelectionMode(),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  '$selectedCount selected',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: AppTypography.fontWeightSemibold,
                  ),
                ),
              ] else ...[
                GestureDetector(
                  onTap: () => context.read<AppProvider>().toggleSideMenu(),
                  child: const Icon(Icons.menu, color: Colors.white),
                ),
              ],
              const Spacer(),
              if (isSelectionMode) ...[
                // Select All / Deselect All
                GestureDetector(
                  onTap: () {
                    if (selectedCount == totalTasks) {
                      apiProvider.clearTaskSelections();
                    } else {
                      apiProvider.selectAllTasks();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                      borderRadius: AppRadius.borderRadiusSm,
                    ),
                    child: Text(
                      selectedCount == totalTasks ? 'Deselect All' : 'Select All',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Select button
                if (totalTasks > 0)
                  GestureDetector(
                    onTap: () => apiProvider.enableSelectionMode(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withOpacity(0.5)),
                        borderRadius: AppRadius.borderRadiusFull,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.checklist, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Select',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(width: AppSpacing.sm),
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
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Title
          Text(
            isSelectionMode ? 'Bulk Actions' : 'Review & Approve',
            style: AppTypography.headingLarge.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isSelectionMode
                ? 'Select expenses to approve or reject'
                : '$pendingCount expenses awaiting approval',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Consumer<ApiExpenseProvider>(
      builder: (context, apiProvider, _) {
        final readyCount = apiProvider.approvalTasks.length;
        const needsReviewCount = 0;

        return _buildFilterTabsContent(readyCount, needsReviewCount);
      },
    );
  }

  Widget _buildFilterTabsContent(int readyCount, int needsReviewCount) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          _buildFilterChip('All', 'all'),
          const SizedBox(width: AppSpacing.sm),
          _buildFilterChip('Ready ($readyCount)', 'ready'),
          const SizedBox(width: AppSpacing.sm),
          _buildFilterChip('Needs Review ($needsReviewCount)', 'needsReview'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.bgSubtle,
          borderRadius: AppRadius.borderRadiusFull,
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected
                ? AppTypography.fontWeightMedium
                : AppTypography.fontWeightNormal,
          ),
        ),
      ),
    );
  }

  Widget _buildPendingList() {
    return Consumer<ApiExpenseProvider>(
      builder: (context, apiProvider, _) {
        if (apiProvider.isLoading && apiProvider.approvalTasks.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        List<ApprovalTaskDTO> tasks;

        switch (_selectedFilter) {
          case 'ready':
            tasks = apiProvider.approvalTasks;
            break;
          case 'needsReview':
            tasks = [];
            break;
          default:
            tasks = apiProvider.approvalTasks;
        }

        if (tasks.isEmpty) {
          return _buildEmptyState();
        }

        final isSelectionMode = apiProvider.isSelectionMode;

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          children: tasks.map<Widget>((task) => _ApiApprovalCard(
                task: task,
                isSelectionMode: isSelectionMode,
                isSelected: apiProvider.isTaskSelected(task.id),
                onTap: () {
                  if (isSelectionMode) {
                    apiProvider.toggleTaskSelection(task.id);
                  } else {
                    apiProvider.setSelectedApprovalTask(task);
                    context.read<AppProvider>().navigateTo('approverExpenseDetail');
                  }
                },
                onLongPress: () {
                  if (!isSelectionMode) {
                    apiProvider.enableSelectionMode();
                    apiProvider.toggleTaskSelection(task.id);
                  }
                },
              )).toList(),
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
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.success.withOpacity(0.5),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _selectedFilter == 'needsReview'
                ? 'No expenses need review'
                : 'No pending approvals',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'You\'re all caught up!',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkActionBar(BuildContext context, ApiExpenseProvider apiProvider) {
    final selectedCount = apiProvider.selectedTaskCount;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgDefault,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selected count info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Text(
                  '$selectedCount selected',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: AppTypography.fontWeightMedium,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => apiProvider.exitSelectionMode(),
                child: Text(
                  'Cancel',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Action buttons
          Row(
            children: [
              // Reject button
              Expanded(
                child: _BulkActionButton(
                  label: 'Reject All',
                  icon: Icons.close,
                  color: AppColors.danger,
                  isLoading: apiProvider.isSubmitting,
                  onPressed: () => _showBulkRejectDialog(context, apiProvider),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Approve button
              Expanded(
                flex: 2,
                child: _BulkActionButton(
                  label: 'Approve All',
                  icon: Icons.check,
                  color: AppColors.success,
                  isPrimary: true,
                  isLoading: apiProvider.isSubmitting,
                  onPressed: () => _showBulkApproveDialog(context, apiProvider),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBulkApproveDialog(BuildContext context, ApiExpenseProvider apiProvider) {
    _commentController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Approve ${apiProvider.selectedTaskCount} expenses?',
          style: AppTypography.headingSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will approve all selected expenses.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Add comment (optional)',
                hintStyle: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.borderRadiusMd,
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.borderRadiusMd,
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.borderRadiusMd,
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.md),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final result = await apiProvider.bulkApproveTasks(
                comment: _commentController.text.isNotEmpty
                    ? _commentController.text
                    : null,
              );
              if (context.mounted) {
                _showResultSnackBar(context, result);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve All'),
          ),
        ],
      ),
    );
  }

  void _showBulkRejectDialog(BuildContext context, ApiExpenseProvider apiProvider) {
    _commentController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Reject ${apiProvider.selectedTaskCount} expenses?',
          style: AppTypography.headingSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will reject all selected expenses. Please provide a reason.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Rejection reason (required)',
                hintStyle: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.borderRadiusMd,
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.borderRadiusMd,
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.borderRadiusMd,
                  borderSide: BorderSide(color: AppColors.danger),
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.md),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_commentController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please provide a rejection reason'),
                    backgroundColor: AppColors.danger,
                  ),
                );
                return;
              }
              Navigator.pop(ctx);
              final result = await apiProvider.bulkRejectTasks(
                comment: _commentController.text.trim(),
              );
              if (context.mounted) {
                _showResultSnackBar(context, result);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject All'),
          ),
        ],
      ),
    );
  }

  void _showResultSnackBar(BuildContext context, BulkApprovalResult result) {
    final isSuccess = result.isSuccess;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(result.message)),
          ],
        ),
        backgroundColor: isSuccess ? AppColors.success : AppColors.danger,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusMd,
        ),
      ),
    );
  }
}

/// Bulk action button widget
class _BulkActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isPrimary;
  final bool isLoading;
  final VoidCallback onPressed;

  const _BulkActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.isPrimary = false,
    this.isLoading = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? color : Colors.transparent,
      borderRadius: AppRadius.borderRadiusMd,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: AppRadius.borderRadiusMd,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            border: isPrimary ? null : Border.all(color: color),
            borderRadius: AppRadius.borderRadiusMd,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading) ...[
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      isPrimary ? Colors.white : color,
                    ),
                  ),
                ),
              ] else ...[
                Icon(
                  icon,
                  size: 18,
                  color: isPrimary ? Colors.white : color,
                ),
              ],
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: isPrimary ? Colors.white : color,
                  fontWeight: AppTypography.fontWeightSemibold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// API Approval Card - displays approval task from API with requester details
class _ApiApprovalCard extends StatelessWidget {
  final ApprovalTaskDTO task;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _ApiApprovalCard({
    required this.task,
    this.isSelectionMode = false,
    this.isSelected = false,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final apiProvider = context.read<ApiExpenseProvider>();

    // Get full requester details
    final requester = apiProvider.getTaskRequesterDetails(task);
    final categoryLower = task.category.isNotEmpty ? task.category.toLowerCase() : 'expense';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.05) : AppColors.bgDefault,
        borderRadius: AppRadius.borderRadiusLg,
        boxShadow: AppShadows.card,
        border: isSelected
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: AppRadius.borderRadiusLg,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Checkbox (if selection mode), Avatar, Name, Amount
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox for selection mode
                  if (isSelectionMode) ...[
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(right: AppSpacing.sm, top: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  ],

                  // Submitter Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        requester.initials,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: AppTypography.fontWeightSemibold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Name and Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          requester.name,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: AppTypography.fontWeightSemibold,
                          ),
                        ),
                        if (requester.subtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            requester.subtitle,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        if (requester.email.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            requester.email,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatRupiah(task.amount),
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: AppTypography.fontWeightSemibold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        task.formattedDate,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.sm),

              // Bottom row: Category and merchant
              Row(
                children: [
                  // Add left padding if in selection mode to align with content above
                  if (isSelectionMode)
                    const SizedBox(width: 32), // 24 checkbox + 8 margin

                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: AppRadius.borderRadiusSm,
                    ),
                    child: Text(
                      categoryLower,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.info,
                        fontWeight: AppTypography.fontWeightMedium,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Merchant
                  if (task.merchant.isNotEmpty && task.merchant != 'Unknown Vendor')
                    Expanded(
                      child: Text(
                        task.merchant,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const Spacer(),
                  // Arrow (hide in selection mode)
                  if (!isSelectionMode)
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
