import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/design_tokens.dart';
import '../../providers/app_provider.dart';
import '../../providers/api_expense_provider.dart';
import '../../services/services.dart';
import '../../utils/formatters.dart';
import '../../widgets/fintech/fintech_widgets.dart';

class ApproverExpenseDetailScreen extends StatefulWidget {
  const ApproverExpenseDetailScreen({super.key});

  @override
  State<ApproverExpenseDetailScreen> createState() => _ApproverExpenseDetailScreenState();
}

class _ApproverExpenseDetailScreenState extends State<ApproverExpenseDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch expense details if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchExpenseIfNeeded();
    });
  }

  Future<void> _fetchExpenseIfNeeded() async {
    final apiProvider = context.read<ApiExpenseProvider>();
    final task = apiProvider.selectedApprovalTask;

    if (task == null || task.expenseId.isEmpty) return;

    // Step 1: Look up the expense from the pre-loaded expense list.
    // This gives us vendor, dept, cost center, expenseType (not available via
    // GET /api/v1/expenses/{id} for manager role — would return 403).
    // Fall back to the embedded task.expense snapshot if the list is empty
    // (e.g. when navigating from History which only called fetchApprovalInbox).
    final expenseFromList = apiProvider.expenses
        .where((e) => e.id == task.expenseId)
        .firstOrNull;
    final expenseSource = expenseFromList ?? task.expense;
    if (expenseSource != null) {
      apiProvider.setSelectedExpense(expenseSource);
    }

    // Step 2: Fetch approval task detail for authorization/stage/policy info
    // Step 3: Fetch receipts using the expense ID
    await Future.wait([
      apiProvider.fetchApprovalTaskDetail(task.id),
      apiProvider.fetchReceiptsForApprovalTask(task.expenseId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiExpenseProvider>(
      builder: (context, apiProvider, _) {
        final task = apiProvider.selectedApprovalTask;

        if (task == null) {
          return Scaffold(
            backgroundColor: AppColors.bgPaper,
            body: Center(
              child: Text('No expense selected', style: AppTypography.bodyLarge),
            ),
          );
        }

        // Use fetched expense if available
        final expense = apiProvider.selectedExpense;
        final isPending = task.status == 'pending';

        return Scaffold(
          backgroundColor: AppColors.bgPaper,
          body: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSubmitterInfo(task, expense),
                      // Show policy flags/warnings to approver for awareness
                      if (expense != null) _buildPolicyFlags(expense),
                      _buildAmountCard(task, expense),
                      _buildExpenseDetails(task, expense, context.read<ApiExpenseProvider>()),
                      // Receipts Section
                      _buildReceiptsSection(apiProvider),
                      _buildApprovalTrail(task, expense),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
              if (isPending) _buildApiActionButtons(context, task),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.md,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.md,
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
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.read<AppProvider>().goBack(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Expense Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // Show options menu
            },
            child: const Icon(Icons.menu, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ReceiptThumbnailWidget extends StatefulWidget {
  final ReceiptDTO receipt;
  final VoidCallback onTap;

  const _ReceiptThumbnailWidget({
    required this.receipt,
    required this.onTap,
  });

  @override
  State<_ReceiptThumbnailWidget> createState() => _ReceiptThumbnailWidgetState();
}

class _ReceiptThumbnailWidgetState extends State<_ReceiptThumbnailWidget> {
  Uint8List? _imageData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    final receipt = widget.receipt;
    final fileName = receipt.fileName ?? '';
    final isImage = receipt.fileType?.contains('image') == true ||
        fileName.toLowerCase().endsWith('.jpg') ||
        fileName.toLowerCase().endsWith('.jpeg') ||
        fileName.toLowerCase().endsWith('.png');

    final id = receipt.id;
    if (isImage && id != null && id.isNotEmpty) {
      final result = await ReceiptService().downloadReceipt(id);
      if (mounted && result.isSuccess) {
        setState(() => _imageData = result.data!.data);
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.receipt.fileName ?? '';
    final isPdf = fileName.toLowerCase().endsWith('.pdf');

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 80,
        height: 80,
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.bgSubtle,
          borderRadius: AppRadius.borderRadiusMd,
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: ClipRRect(
          borderRadius: AppRadius.borderRadiusMd,
          child: _loading
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : _imageData != null
                  ? Image.memory(_imageData!, fit: BoxFit.cover)
                  : Icon(
                      isPdf ? CupertinoIcons.doc_text_fill : CupertinoIcons.doc,
                      size: 32,
                      color: isPdf ? FintechColors.categoryRed : FintechColors.categoryBlue,
                    ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final String? icon;

  const _DetailRow({
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Row(
            children: [
              if (icon != null) ...[
                Text(icon!, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
              ],
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: AppTypography.fontWeightMedium,
                  color: label == 'Category' ? AppColors.info : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============ Widget Builders ============

extension _WidgetBuilders on _ApproverExpenseDetailScreenState {
  Widget _buildSubmitterInfo(ApprovalTaskDTO task, ExpenseDTO? expense) {
    final apiProvider = context.read<ApiExpenseProvider>();

    // Get requester name - prefer task, then expense, then lookup
    String requesterName = task.requesterName;
    if (requesterName.isEmpty && expense != null) {
      requesterName = expense.requesterName ?? expense.submitterName;
    }
    if (requesterName.isEmpty) {
      requesterName = apiProvider.getTaskRequesterName(task);
    }
    if (requesterName.isEmpty) {
      requesterName = 'Unknown';
    }

    // Get email
    String email = task.requesterEmail;
    if (email.isEmpty && expense != null) {
      email = expense.submitterEmail;
    }

    // Get initials
    String initials = '?';
    if (requesterName.isNotEmpty && requesterName != 'Unknown') {
      final parts = requesterName.split(' ');
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        initials = requesterName[0].toUpperCase();
      }
    }

    final expenseIdShort = task.expenseId.length >= 8
        ? task.expenseId.substring(0, 8).toUpperCase()
        : task.expenseId.toUpperCase();
    final refId = 'EXP-$expenseIdShort';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                initials,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  requesterName,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: AppTypography.fontWeightSemibold,
                    color: Colors.white,
                  ),
                ),
                if (expense?.departmentName != null && expense!.departmentName!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    expense.departmentName!,
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: AppRadius.borderRadiusSm,
                      ),
                      child: Text(
                        refId,
                        style: AppTypography.caption.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.borderRadiusFull,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, size: 12, color: AppColors.success),
                          const SizedBox(width: 4),
                          Text(
                            'Ready',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyFlags(ExpenseDTO expense) {
    // Show policy flags if any exist
    final hasFlags = expense.policyFlags != null && expense.policyFlags!.isNotEmpty;
    // Use the actually-fetched approvalReceipts as the authoritative source.
    // expense.missingReceipt checks expense.receipts which is empty in list-API responses.
    final approvalReceipts = context.read<ApiExpenseProvider>().approvalReceipts;
    final hasMissingReceipt = expense.missingReceipt && approvalReceipts.isEmpty;

    if (!hasFlags && !hasMissingReceipt) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      child: Column(
        children: [
          // Missing Receipt Warning
          if (hasMissingReceipt)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              margin: EdgeInsets.only(bottom: hasFlags ? AppSpacing.sm : 0),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_triangle_fill,
                    size: 20,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Missing Receipt',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'This expense requires a receipt to be attached',
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

          // Policy Flags
          if (hasFlags)
            ...expense.policyFlags!.map((flag) {
              Color flagColor;
              IconData flagIcon;

              switch (flag.severity.toLowerCase()) {
                case 'error':
                  flagColor = AppColors.statusRejected;
                  flagIcon = CupertinoIcons.xmark_circle_fill;
                  break;
                case 'warning':
                  flagColor = AppColors.warning;
                  flagIcon = CupertinoIcons.exclamationmark_triangle_fill;
                  break;
                default:
                  flagColor = FintechColors.categoryBlue;
                  flagIcon = CupertinoIcons.info_circle_fill;
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: flagColor.withOpacity(0.1),
                  border: Border.all(color: flagColor.withOpacity(0.3)),
                  borderRadius: AppRadius.borderRadiusMd,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      flagIcon,
                      size: 20,
                      color: flagColor,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            flag.name,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: flagColor,
                            ),
                          ),
                          if (flag.message != null && flag.message!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              flag.message!,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                          if (flag.resolution != null && flag.resolution!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Resolution: ${flag.resolution}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildAmountCard(ApprovalTaskDTO task, ExpenseDTO? expense) {
    // Get amount - prefer task, then expense
    double amount = task.amount;
    if (amount <= 0 && expense != null) {
      amount = expense.originalAmount;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: AppRadius.borderRadiusLg,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          const Text(
            'Total Amount',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
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
    );
  }

  Widget _buildExpenseDetails(ApprovalTaskDTO task, ExpenseDTO? expense, ApiExpenseProvider apiProvider) {
    // Get vendor/merchant - prefer expense, then task
    String vendor = expense?.merchant ?? task.merchant;
    if (vendor == 'Unknown Merchant') vendor = 'Unknown Vendor';

    // Get category - prefer task (from API), then expense
    String category = task.category;
    if (category == 'Other' && expense != null) {
      category = expense.category;
    }

    // Get category icon
    String? categoryIcon = task.categoryIcon ?? expense?.categoryIcon;

    // Get description
    String? description = task.description;
    if ((description == null || description.isEmpty) && expense != null) {
      description = expense.description;
    }

    // Get expense type
    String expenseType = expense?.expenseType ?? 'reimbursement';
    expenseType = expenseType[0].toUpperCase() + expenseType.substring(1);

    // Get formatted date
    String dateStr = task.formattedDate;
    if (expense != null) {
      dateStr = expense.formattedDate;
    }

    // Get department name
    String? departmentName = expense?.departmentName;
    if ((departmentName == null || departmentName.isEmpty) && expense != null) {
      departmentName = apiProvider.getDepartmentName(expense.departmentId);
    }

    // Get cost center name
    String? costCenterName;
    if (expense != null) {
      costCenterName = apiProvider.getCostCenterName(expense.costCenterId);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgDefault,
        borderRadius: AppRadius.borderRadiusLg,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Expense Details',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: AppTypography.fontWeightSemibold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _DetailRow(label: 'Vendor', value: vendor),
          _DetailRow(
            label: 'Category',
            value: category,
            icon: categoryIcon,
          ),
          _DetailRow(label: 'Date', value: dateStr),
          _DetailRow(label: 'Expense Type', value: expenseType),
          if (departmentName != null && departmentName.isNotEmpty)
            _DetailRow(label: 'Department', value: departmentName),
          if (costCenterName != null && costCenterName.isNotEmpty)
            _DetailRow(label: 'Cost Center', value: costCenterName),
          if (description != null && description.isNotEmpty)
            _DetailRow(label: 'Description', value: description),
        ],
      ),
    );
  }

  // Note: _buildMissingReceiptBanner removed - approvers cannot attach receipts
  // Only expense owners can see and act on missing receipt warnings

  Widget _buildReceiptsSection(ApiExpenseProvider apiProvider) {
    final receipts = apiProvider.approvalReceipts;
    final hasReceipts = receipts.isNotEmpty;
    final receiptCount = receipts.length;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgDefault,
        borderRadius: AppRadius.borderRadiusLg,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  CupertinoIcons.doc_text_fill,
                  size: 18,
                  color: FintechColors.categoryPurple,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Receipts',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: AppTypography.fontWeightSemibold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hasReceipts
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.warning.withOpacity(0.1),
                  borderRadius: AppRadius.borderRadiusFull,
                ),
                child: Text(
                  hasReceipts ? '$receiptCount attached' : 'None',
                  style: AppTypography.caption.copyWith(
                    color: hasReceipts ? AppColors.success : AppColors.warning,
                    fontWeight: AppTypography.fontWeightMedium,
                  ),
                ),
              ),
            ],
          ),
          if (hasReceipts) ...[
            const SizedBox(height: AppSpacing.lg),
            ...receipts.map((receipt) => _buildReceiptItem(receipt)),
          ] else ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.bgSubtle,
                borderRadius: AppRadius.borderRadiusMd,
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.doc_text,
                    size: 32,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'No receipts attached',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReceiptItem(ReceiptDTO receipt) {
    final fileName = receipt.fileName ?? 'Receipt';
    final isImage = receipt.fileType?.contains('image') == true ||
        fileName.toLowerCase().endsWith('.jpg') ||
        fileName.toLowerCase().endsWith('.jpeg') ||
        fileName.toLowerCase().endsWith('.png');
    final isPdf = fileName.toLowerCase().endsWith('.pdf');

    IconData icon = CupertinoIcons.doc;
    Color iconColor = FintechColors.categoryBlue;
    if (isImage) {
      icon = CupertinoIcons.photo;
      iconColor = FintechColors.categoryGreen;
    } else if (isPdf) {
      icon = CupertinoIcons.doc_text_fill;
      iconColor = FintechColors.categoryRed;
    }

    void openReceipt() {
      final receiptId = receipt.id;
      if (receiptId != null && receiptId.isNotEmpty) {
        Provider.of<AppProvider>(context, listen: false)
            .navigateToWithParams('receiptViewer', {'receiptId': receiptId});
      }
    }

    return GestureDetector(
      onTap: openReceipt,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.bgSubtle,
          borderRadius: AppRadius.borderRadiusMd,
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: AppRadius.borderRadiusSm,
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: AppTypography.fontWeightMedium,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    isImage ? 'Image' : (isPdf ? 'PDF Document' : 'Document'),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalTrail(ApprovalTaskDTO task, ExpenseDTO? expense) {
    // Get submitter name
    String submitterName = task.requesterName;
    if (submitterName.isEmpty && expense != null) {
      submitterName = expense.requesterName ?? expense.submitterName;
    }
    if (submitterName.isEmpty) {
      final apiProvider = context.read<ApiExpenseProvider>();
      submitterName = apiProvider.getTaskRequesterName(task);
    }
    if (submitterName.isEmpty) {
      submitterName = 'Unknown';
    }

    // Get approver name and decision info
    String approverDisplayName = task.approverName ?? 'Pending Approval';
    String decisionText = '';
    Color decisionColor = AppColors.warning;

    if (task.isApproved) {
      decisionText = 'Approved';
      decisionColor = AppColors.success;
    } else if (task.isRejected) {
      decisionText = 'Rejected';
      decisionColor = AppColors.danger;
    } else if (task.isReturned) {
      decisionText = 'Returned';
      decisionColor = AppColors.statusReturned;
    }

    // Format decision date if available
    String decisionDateText = '';
    if (task.decidedAt != null) {
      decisionDateText = ' on ${DateFormat('dd MMM yyyy, HH:mm').format(task.decidedAt!)}';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgDefault,
        borderRadius: AppRadius.borderRadiusLg,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  CupertinoIcons.time,
                  size: 18,
                  color: FintechColors.categoryBlue,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Approval Trail',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: AppTypography.fontWeightSemibold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 16, color: AppColors.success),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Submitted by $submitterName',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: AppTypography.fontWeightMedium,
                      ),
                    ),
                    Text(
                      task.formattedDate,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(left: 15),
            height: 24,
            width: 2,
            color: AppColors.borderDefault,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: decisionColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  task.isApproved
                      ? Icons.check_circle
                      : task.isRejected
                          ? Icons.close
                          : task.isReturned
                              ? Icons.undo
                              : Icons.hourglass_empty,
                  size: 16,
                  color: decisionColor,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.isPending
                          ? 'Pending approval by $approverDisplayName'
                          : '$decisionText by $approverDisplayName$decisionDateText',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: AppTypography.fontWeightMedium,
                      ),
                    ),
                    if (task.comment != null && task.comment!.isNotEmpty)
                      Text(
                        task.comment!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptPreviewStrip(List<ReceiptDTO> receipts) {
    if (receipts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Receipts',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: AppTypography.fontWeightSemibold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: AppRadius.borderRadiusFull,
              ),
              child: Text(
                '${receipts.length}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.success,
                  fontWeight: AppTypography.fontWeightMedium,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: receipts.map((receipt) {
              return _ReceiptThumbnailWidget(
                receipt: receipt,
                onTap: () {
                  final id = receipt.id;
                  if (id != null && id.isNotEmpty) {
                    Provider.of<AppProvider>(context, listen: false)
                        .navigateToWithParams('receiptViewer', {'receiptId': id});
                  }
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _buildApiActionButtons(BuildContext context, ApprovalTaskDTO task) {
    return Consumer<ApiExpenseProvider>(
      builder: (context, apiProvider, _) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.bgDefault,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: apiProvider.isSubmitting
                      ? null
                      : () => _showApiReturnDialog(context, task),
                  icon: const Icon(Icons.undo, size: 18),
                  label: const Text('Return for Revision'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.borderDefault),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusLg,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: apiProvider.isSubmitting
                          ? null
                          : () => _showApiRejectDialog(context, task),
                      icon: apiProvider.isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderRadiusLg,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: apiProvider.isSubmitting
                          ? null
                          : () => _approveApiExpense(context, task),
                      icon: apiProvider.isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Icon(Icons.check, size: 18),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderRadiusLg,
                        ),
                      ),
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

  Future<void> _approveApiExpense(BuildContext context, ApprovalTaskDTO task) async {
    final apiProvider = context.read<ApiExpenseProvider>();
    final appProvider = context.read<AppProvider>();

    final success = await apiProvider.approveTask(task.id);

    if (success) {
      appProvider.navigateTo('approvalSuccess');
    } else {
      appProvider.showNotification(
        apiProvider.error ?? 'Failed to approve expense',
        type: 'error',
      );
    }
  }

  void _showApiRejectDialog(BuildContext context, ApprovalTaskDTO task) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter reason...',
                border: OutlineInputBorder(
                  borderRadius: AppRadius.borderRadiusMd,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a reason')),
                );
                return;
              }

              Navigator.pop(ctx);

              final apiProvider = context.read<ApiExpenseProvider>();
              final appProvider = context.read<AppProvider>();

              final success = await apiProvider.rejectTask(
                task.id,
                comment: reasonController.text,
              );

              if (success) {
                appProvider.navigateTo('approvalSuccess');
              } else {
                appProvider.showNotification(
                  apiProvider.error ?? 'Failed to reject expense',
                  type: 'error',
                );
              }
            },
            child: Text('Reject', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _showApiReturnDialog(BuildContext context, ApprovalTaskDTO task) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Return for Revision'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide instructions for the submitter:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter your feedback...',
                border: OutlineInputBorder(
                  borderRadius: AppRadius.borderRadiusMd,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide feedback')),
                );
                return;
              }

              Navigator.pop(ctx);

              final apiProvider = context.read<ApiExpenseProvider>();
              final appProvider = context.read<AppProvider>();

              final success = await apiProvider.returnTask(
                task.id,
                comment: reasonController.text,
              );

              if (success) {
                appProvider.showNotification(
                  'Expense returned for revision',
                  type: 'success',
                );
                appProvider.goBack();
              } else {
                appProvider.showNotification(
                  apiProvider.error ?? 'Failed to return expense',
                  type: 'error',
                );
              }
            },
            child: const Text('Return'),
          ),
        ],
      ),
    );
  }
}
