import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/api_expense_provider.dart';
import '../../services/services.dart';
import '../../utils/formatters.dart';
import '../../core/design_tokens.dart';
import '../../widgets/fintech/fintech_widgets.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildApiContent(context);
  }

  Widget _buildApiContent(BuildContext context) {
    return Consumer<ApiExpenseProvider>(
      builder: (context, apiProvider, _) {
        final expense = apiProvider.selectedExpense;

        if (expense == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: FintechColors.categoryBlueBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.doc_text,
                      size: 32,
                      color: FintechColors.categoryBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No expense selected',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final isDraft = expense.status == 0;
        final isReturned = expense.status == 7;
        final isRejected = expense.status == 6;
        final isPendingApproval = expense.status == 3;
        final canEdit = isDraft || isReturned;
        final canDelete = isDraft;
        final canSubmit = isDraft || isReturned;

        // Check if current user can approve this expense (has pending approval task)
        final canApprove = isPendingApproval && apiProvider.canApproveExpense(expense.id);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                _buildHeader(context, canEdit, isApi: true),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isRejected) _buildRejectedBanner(context, expense.statusReason),
                        if (isReturned) _buildReturnedBanner(context, expense.statusReason),
                        // Only show Missing Receipt banner if user can actually attach
                        if (expense.missingReceipt && canEdit) _buildMissingReceiptBanner(context, expense.id, canAttach: true),
                        _buildRequesterSection(context, apiProvider, expense),
                        const SizedBox(height: 16),
                        _buildMainCard(
                          context,
                          icon: apiProvider.getCategoryIcon(expense.categoryId),
                          merchant: expense.merchant,
                          status: expense.status,
                          statusName: expense.statusName,
                          amount: expense.originalAmount,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailsSection(
                          context,
                          category: apiProvider.getCategoryName(expense.categoryId),
                          date: expense.formattedDate,
                          type: expense.expenseType,
                          department: expense.departmentName ?? apiProvider.getDepartmentName(expense.departmentId),
                          costCenter: apiProvider.getCostCenterName(expense.costCenterId),
                          vendor: expense.vendorName,
                        ),
                        const SizedBox(height: 16),
                        _buildReceiptsSection(context, expense.receipts, isApi: true, expenseId: expense.id, canEdit: canEdit),
                        if (expense.description != null && expense.description!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildNotesSection(expense.description!),
                        ],
                        const SizedBox(height: 16),
                        _buildApprovalTimeline(context, expense),
                        const SizedBox(height: 24),
                        _buildActionButtons(context, canEdit: canEdit, canDelete: canDelete, canSubmit: canSubmit, canApprove: canApprove, isApi: true),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildHeader(BuildContext context, bool canEdit, {bool isApi = false}) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (isApi) {
                context.read<ApiExpenseProvider>().setSelectedExpense(null);
              }
              context.read<AppProvider>().goBack();
            },
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
          const Text(
            'Expense Details',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          if (canEdit)
            GestureDetector(
              onTap: () {
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
                  CupertinoIcons.pencil,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRejectedBanner(BuildContext context, String? statusReason) {
    return AlertBanner(
      icon: CupertinoIcons.xmark_circle_fill,
      iconColor: AppColors.statusRejected,
      backgroundColor: AppColors.statusRejected.withOpacity(0.1),
      title: 'Expense Rejected',
      subtitle: statusReason ?? 'This expense has been rejected and cannot be edited or resubmitted.',
    );
  }

  Widget _buildReturnedBanner(BuildContext context, String? statusReason) {
    return AlertBanner(
      icon: CupertinoIcons.arrow_uturn_left_circle_fill,
      iconColor: FintechColors.categoryBlue,
      backgroundColor: FintechColors.categoryBlueBg,
      title: 'Returned for Revision',
      subtitle: statusReason ?? 'Please review and edit this expense, then resubmit.',
    );
  }

  Widget _buildMissingReceiptBanner(BuildContext context, String expenseId, {bool canAttach = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FintechColors.categoryOrangeBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: FintechColors.categoryOrange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: FintechColors.categoryOrange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              color: FintechColors.categoryOrange,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Receipt Required',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  canAttach
                      ? 'Please attach a receipt for this expense'
                      : 'Receipt is missing. Edit this expense to attach.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (canAttach)
            GestureDetector(
              onTap: () {
                context.read<AppProvider>().navigateToWithParams('camera', {
                  'mode': 'attach',
                  'expenseId': expenseId,
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: FintechColors.categoryOrange,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Text(
                  'Attach',
                  style: TextStyle(
                    fontSize: 13,
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

  Widget _buildRequesterSection(BuildContext context, ApiExpenseProvider apiProvider, ExpenseDTO expense) {
    final requester = apiProvider.getExpenseRequesterDetails(expense);

    // Generate Ref ID
    final expenseIdShort = expense.id.length >= 8
        ? expense.id.substring(0, 8).toUpperCase()
        : expense.id.toUpperCase();
    final refId = 'EXP-$expenseIdShort';

    return FintechCard(
      child: Row(
        children: [
          // Avatar with gradient
          Container(
            width: 52,
            height: 52,
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
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ref ID badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: FintechColors.primaryLight.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    refId,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: FintechColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Submitted by',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  requester.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (requester.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    requester.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (requester.email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    requester.email,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(
    BuildContext context, {
    required String icon,
    required String merchant,
    required dynamic status,
    String? statusName,
    required double amount,
  }) {
    return FintechCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              // Category icon with colored background
              CategoryIconCircle(
                icon: icon,
                size: 56,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      merchant,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    StatusPill(status: status is int ? status : 0),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Amount card with gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              children: [
                const Text(
                  'Amount',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatRupiah(amount),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(
    BuildContext context, {
    required String category,
    required String date,
    String? type,
    String? department,
    String? costCenter,
    String? vendor,
  }) {
    return FintechCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with icon
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: FintechColors.categoryTealBg,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  CupertinoIcons.list_bullet,
                  size: 18,
                  color: FintechColors.categoryTeal,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Details list with clean dividers
          _DetailRow(icon: CupertinoIcons.folder, label: 'Category', value: category, isLast: false),
          _DetailRow(icon: CupertinoIcons.calendar, label: 'Date', value: date, isLast: type == null && (department == null || department.isEmpty) && (costCenter == null || costCenter.isEmpty) && (vendor == null || vendor.isEmpty)),
          if (type != null) _DetailRow(icon: CupertinoIcons.tag, label: 'Type', value: type, isLast: (department == null || department.isEmpty) && (costCenter == null || costCenter.isEmpty) && (vendor == null || vendor.isEmpty)),
          if (department != null && department.isNotEmpty)
            _DetailRow(icon: CupertinoIcons.building_2_fill, label: 'Department', value: department, isLast: (costCenter == null || costCenter.isEmpty) && (vendor == null || vendor.isEmpty)),
          if (costCenter != null && costCenter.isNotEmpty)
            _DetailRow(icon: CupertinoIcons.money_dollar_circle, label: 'Cost Center', value: costCenter, isLast: vendor == null || vendor.isEmpty),
          if (vendor != null && vendor.isNotEmpty)
            _DetailRow(icon: CupertinoIcons.person, label: 'Vendor', value: vendor, isLast: true),
        ],
      ),
    );
  }

  Widget _buildReceiptsSection(BuildContext context, dynamic attachments, {bool isApi = false, String? expenseId, bool canEdit = false}) {
    final hasAttachments = attachments != null && attachments.isNotEmpty;

    return FintechCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with icon
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: FintechColors.categoryBlueBg,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  CupertinoIcons.doc_on_doc,
                  size: 18,
                  color: FintechColors.categoryBlue,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Receipts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (hasAttachments)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: FintechColors.categoryBlueBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${attachments.length} file${attachments.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: FintechColors.categoryBlue,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (!hasAttachments)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: FintechColors.categoryBlueBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.doc_text,
                      size: 28,
                      color: FintechColors.categoryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No receipts attached',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textMuted,
                    ),
                  ),
                  if (canEdit) ...[
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        context.read<AppProvider>().navigateToWithParams('camera', {
                          'mode': 'attach',
                          'expenseId': expenseId,
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: FintechColors.primary,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          boxShadow: [
                            BoxShadow(
                              color: FintechColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(CupertinoIcons.camera, size: 18, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Add Receipt',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            )
          else
            ...attachments.map<Widget>((attachment) => _ReceiptItem(receipt: attachment, isApi: isApi)).toList(),
        ],
      ),
    );
  }

  Widget _buildNotesSection(String notes) {
    return FintechCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with icon - matching other sections
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: FintechColors.categoryIndigoBg,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  CupertinoIcons.text_quote,
                  size: 18,
                  color: FintechColors.categoryIndigo,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Notes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Notes content with subtle background
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              notes,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalTimeline(BuildContext context, ExpenseDTO expense) {
    // Build timeline items based on expense status
    final List<_TimelineItem> items = [];

    // Created
    items.add(_TimelineItem(
      icon: CupertinoIcons.doc_text_fill,
      iconColor: FintechColors.categoryBlue,
      bgColor: FintechColors.categoryBlueBg,
      title: 'Created',
      subtitle: _formatDateTime(expense.createdAt),
      isCompleted: true,
    ));

    // Submitted
    if (expense.submittedAt != null) {
      items.add(_TimelineItem(
        icon: CupertinoIcons.paperplane_fill,
        iconColor: FintechColors.categoryPurple,
        bgColor: FintechColors.categoryPurpleBg,
        title: 'Submitted',
        subtitle: _formatDateTime(expense.submittedAt!),
        isCompleted: true,
      ));
    } else if (expense.status == 0) {
      // Still in draft
      items.add(_TimelineItem(
        icon: CupertinoIcons.paperplane,
        iconColor: AppColors.textMuted,
        bgColor: AppColors.surfaceVariant,
        title: 'Submit for Approval',
        subtitle: 'Pending submission',
        isCompleted: false,
      ));
    }

    // Add status-specific items
    if (expense.status == 3) {
      // Pending Approval
      items.add(_TimelineItem(
        icon: CupertinoIcons.clock_fill,
        iconColor: FintechColors.categoryYellow,
        bgColor: FintechColors.categoryYellowBg,
        title: 'Pending Approval',
        subtitle: 'Awaiting manager review',
        isCompleted: false,
        isActive: true,
      ));
    } else if (expense.status == 4) {
      // Approved
      items.add(_TimelineItem(
        icon: CupertinoIcons.checkmark_circle_fill,
        iconColor: FintechColors.categoryGreen,
        bgColor: FintechColors.categoryGreenBg,
        title: 'Approved',
        subtitle: expense.approvedAt != null ? _formatDateTime(expense.approvedAt!) : 'Approved',
        isCompleted: true,
      ));
    } else if (expense.status == 5) {
      // Completed
      items.add(_TimelineItem(
        icon: CupertinoIcons.checkmark_circle_fill,
        iconColor: FintechColors.categoryGreen,
        bgColor: FintechColors.categoryGreenBg,
        title: 'Approved',
        subtitle: expense.approvedAt != null ? _formatDateTime(expense.approvedAt!) : 'Approved',
        isCompleted: true,
      ));
      items.add(_TimelineItem(
        icon: CupertinoIcons.checkmark_seal_fill,
        iconColor: FintechColors.categoryGreen,
        bgColor: FintechColors.categoryGreenBg,
        title: 'Completed',
        subtitle: expense.completedAt != null ? _formatDateTime(expense.completedAt!) : 'Completed',
        isCompleted: true,
      ));
    } else if (expense.status == 6) {
      // Rejected
      items.add(_TimelineItem(
        icon: CupertinoIcons.xmark_circle_fill,
        iconColor: AppColors.statusRejected,
        bgColor: FintechColors.categoryRedBg,
        title: 'Rejected',
        subtitle: expense.statusReason ?? 'Rejected by approver',
        isCompleted: true,
        isError: true,
      ));
    } else if (expense.status == 7) {
      // Returned
      items.add(_TimelineItem(
        icon: CupertinoIcons.arrow_uturn_left_circle_fill,
        iconColor: FintechColors.categoryOrange,
        bgColor: FintechColors.categoryOrangeBg,
        title: 'Returned',
        subtitle: expense.statusReason ?? 'Returned for revision',
        isCompleted: true,
        isWarning: true,
      ));
    }

    return FintechCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: FintechColors.categoryPurpleBg,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  CupertinoIcons.arrow_right_arrow_left_circle_fill,
                  size: 18,
                  color: FintechColors.categoryPurple,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Approval Timeline',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Timeline items
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;
            return _buildTimelineRow(item, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineRow(_TimelineItem item, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline connector
        SizedBox(
          width: 36,
          child: Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: item.bgColor,
                  shape: BoxShape.circle,
                  border: item.isActive
                      ? Border.all(color: item.iconColor, width: 2)
                      : null,
                ),
                child: Icon(
                  item.icon,
                  size: 14,
                  color: item.iconColor,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: item.isCompleted
                      ? item.iconColor.withOpacity(0.3)
                      : AppColors.border,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: item.isError
                        ? AppColors.statusRejected
                        : item.isWarning
                            ? FintechColors.categoryOrange
                            : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  Widget _buildActionButtons(
    BuildContext context, {
    required bool canEdit,
    required bool canDelete,
    required bool canSubmit,
    bool canApprove = false,
    bool isApi = false,
  }) {
    // Show approve/reject buttons if user can approve
    if (canApprove) {
      return Consumer<ApiExpenseProvider>(
        builder: (context, apiProvider, _) {
          final isLoading = apiProvider.isSubmitting;
          return Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: isLoading ? 'Processing...' : 'Reject',
                  icon: CupertinoIcons.xmark_circle_fill,
                  color: AppColors.statusRejected,
                  onTap: isLoading ? null : () => _showRejectDialog(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _ActionButton(
                  label: isLoading ? 'Processing...' : 'Approve',
                  icon: CupertinoIcons.checkmark_circle_fill,
                  color: AppColors.statusApproved,
                  isPrimary: true,
                  onTap: isLoading ? null : () => _showApproveDialog(context),
                ),
              ),
            ],
          );
        },
      );
    }

    if (!canEdit && !canDelete && !canSubmit) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (canDelete)
          Expanded(
            child: _ActionButton(
              label: 'Delete',
              icon: CupertinoIcons.trash,
              color: AppColors.statusRejected,
              onTap: () => _showDeleteConfirmation(context, isApi),
            ),
          ),
        if (canDelete && canSubmit) const SizedBox(width: 12),
        if (canSubmit)
          Expanded(
            child: Consumer<ApiExpenseProvider>(
              builder: (context, apiProvider, _) {
                return _ActionButton(
                  label: isApi && apiProvider.isSubmitting ? 'Submitting...' : 'Submit',
                  icon: CupertinoIcons.paperplane_fill,
                  color: FintechColors.primary,
                  isPrimary: true,
                  onTap: isApi && apiProvider.isSubmitting ? null : () => _submitExpense(context, isApi),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, bool isApi) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense? This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () async {
              Navigator.pop(ctx);
              final apiProvider = context.read<ApiExpenseProvider>();
              final expense = apiProvider.selectedExpense;
              if (expense != null) {
                final success = await apiProvider.deleteExpense(expense.id);
                if (success) {
                  context.read<AppProvider>().goBack();
                  context.read<AppProvider>().showNotification('Expense deleted', type: 'success');
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _submitExpense(BuildContext context, bool isApi) async {
    final apiProvider = context.read<ApiExpenseProvider>();
    final expense = apiProvider.selectedExpense;
    if (expense != null) {
      final success = await apiProvider.submitExpense(expense.id);
      if (success) {
        context.read<AppProvider>().showNotification('Expense submitted for approval', type: 'success');
        context.read<AppProvider>().goBack();
      }
    }
  }

  void _showApproveDialog(BuildContext context) {
    final commentController = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Approve Expense'),
        content: Column(
          children: [
            const SizedBox(height: 8),
            const Text('Are you sure you want to approve this expense?'),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: commentController,
              placeholder: 'Add comment (optional)',
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Approve'),
            onPressed: () async {
              Navigator.pop(ctx);
              await _approveExpense(context, commentController.text);
            },
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final commentController = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Reject Expense'),
        content: Column(
          children: [
            const SizedBox(height: 8),
            const Text('Please provide a reason for rejection.'),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: commentController,
              placeholder: 'Rejection reason (required)',
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Reject'),
            onPressed: () async {
              if (commentController.text.trim().isEmpty) {
                return; // Don't allow empty comment for rejection
              }
              Navigator.pop(ctx);
              await _rejectExpense(context, commentController.text);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _approveExpense(BuildContext context, String comment) async {
    final apiProvider = context.read<ApiExpenseProvider>();
    final appProvider = context.read<AppProvider>();
    final expense = apiProvider.selectedExpense;
    if (expense == null) return;

    final approvalTask = apiProvider.getApprovalTaskForExpense(expense.id);
    if (approvalTask == null) return;

    final success = await apiProvider.approveTask(approvalTask.id, comment: comment);
    if (success) {
      appProvider.showNotification('Expense approved', type: 'success');
      appProvider.goBack();
    }
  }

  Future<void> _rejectExpense(BuildContext context, String comment) async {
    final apiProvider = context.read<ApiExpenseProvider>();
    final appProvider = context.read<AppProvider>();
    final expense = apiProvider.selectedExpense;
    if (expense == null) return;

    final approvalTask = apiProvider.getApprovalTaskForExpense(expense.id);
    if (approvalTask == null) return;

    final success = await apiProvider.rejectTask(approvalTask.id, comment: comment);
    if (success) {
      appProvider.showNotification('Expense rejected', type: 'success');
      appProvider.goBack();
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, size: 18, color: AppColors.textMuted),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: AppColors.border,
          ),
      ],
    );
  }
}

class _ReceiptItem extends StatelessWidget {
  final dynamic receipt;
  final bool isApi;

  const _ReceiptItem({required this.receipt, this.isApi = false});

  @override
  Widget build(BuildContext context) {
    String fileName;
    String fileType;

    if (isApi) {
      fileName = receipt.fileName ?? 'Receipt';
      fileType = receipt.fileType ?? 'image/jpeg';
    } else {
      fileName = receipt.fileName ?? 'Receipt';
      fileType = receipt.fileType ?? 'image/jpeg';
    }

    final isImage = fileType.startsWith('image/');
    final iconColor = isImage ? FintechColors.categoryBlue : FintechColors.categoryRed;
    final bgColor = isImage ? FintechColors.categoryBlueBg : FintechColors.categoryRedBg;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              isImage ? CupertinoIcons.photo : CupertinoIcons.doc_fill,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  isImage ? 'Image' : 'PDF Document',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            CupertinoIcons.eye,
            color: AppColors.textMuted,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isPrimary;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.isPrimary = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: isPrimary ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isPrimary ? Colors.white : color,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isActive;
  final bool isError;
  final bool isWarning;

  _TimelineItem({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    this.isActive = false,
    this.isError = false,
    this.isWarning = false,
  });
}
