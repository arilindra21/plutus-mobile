import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import '../../core/design_tokens.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/api_expense_provider.dart';
import '../../services/services.dart';
import '../../constants/categories.dart';
import '../../widgets/fintech/fintech_widgets.dart';

class NewExpenseScreen extends StatefulWidget {
  const NewExpenseScreen({super.key});

  @override
  State<NewExpenseScreen> createState() => _NewExpenseScreenState();
}

class _NewExpenseScreenState extends State<NewExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  // Saved reference for safe use in dispose()
  ApiExpenseProvider? _apiProviderRef;

  String? _selectedCategoryId;
  String? _selectedDepartmentId;
  String? _selectedCostCenterId;
  String? _selectedVendorId;
  String? _otherVendorName; // Used when "Other" vendor is selected
  String _selectedCurrency = 'IDR';
  String _selectedExpenseType = 'reimbursement';
  bool _submitForApproval = false;
  DateTime _selectedDate = DateTime.now();
  bool _isEditing = false;
  String? _editingApiId;
  bool _isInitialized = false;
  bool _isFromScan = false; // Flag to indicate OCR mode
  bool _ocrAutoFillApplied = false; // Prevent duplicate auto-fill

  final List<String> _currencies = ['IDR', 'USD', 'SGD', 'MYR', 'EUR', 'JPY', 'AUD'];

  final List<Map<String, dynamic>> _expenseTypes = [
    {'value': 'reimbursement', 'label': 'Reimbursement', 'icon': CupertinoIcons.doc_text_fill},
    {'value': 'card', 'label': 'Card', 'icon': CupertinoIcons.creditcard_fill},
    // Hide petty_cash and cash_advance for MVP (not implemented yet)
    // {'value': 'petty_cash', 'label': 'Petty Cash', 'icon': CupertinoIcons.money_dollar_circle_fill},
    // {'value': 'cash_advance', 'label': 'Advance', 'icon': CupertinoIcons.arrow_right_circle_fill},
  ];

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clearStaleReceiptState();
      _initializeData();
    });
  }

  /// Always clear stale receipt/OCR state when entering the form,
  /// unless coming from scan flow which carries receipt data intentionally.
  void _clearStaleReceiptState() {
    final apiProvider = context.read<ApiExpenseProvider>();
    _apiProviderRef = apiProvider; // Save for dispose()
    final appProvider = context.read<AppProvider>();
    final params = appProvider.screenParams;
    final isFromScan = params?['fromScan'] == true;

    // Set _isFromScan early and consume params so they don't leak to next navigation
    _isFromScan = isFromScan;
    appProvider.clearNavigationParams();

    if (!isFromScan) {
      apiProvider.clearOCRState();
      apiProvider.clearPendingAttachments();
    }
  }

  Future<void> _initializeData() async {
    if (_isInitialized) return;

    final apiProvider = context.read<ApiExpenseProvider>();

    await apiProvider.fetchReferenceData();
    _loadEditingData();

    // Auto-fill form from OCR result (reference data must be loaded first
    // so vendor matching has the full vendors list available)
    if (_isFromScan && apiProvider.hasOCRResult) {
      _applyOCRAutoFill(apiProvider);
    }

    _isInitialized = true;
  }

  void _applyOCRAutoFill(ApiExpenseProvider apiProvider) {
    if (_ocrAutoFillApplied) return;


    // Get OCR data
    final amount = apiProvider.getOCRAmount();
    final date = apiProvider.getOCRDate();
    final currency = apiProvider.getOCRCurrency();
    final merchantName = apiProvider.getOCRMerchantName();

    setState(() {
      // Auto-fill amount
      if (amount != null && amount > 0) {
        _amountController.text = _ThousandsSeparatorFormatter._format(amount.toStringAsFixed(0));
      }

      // Auto-fill date
      if (date != null) {
        _selectedDate = date;
      }

      // Auto-fill currency
      if (currency != null && _currencies.contains(currency)) {
        _selectedCurrency = currency;
      }

      // Try to match merchant/vendor by name
      if (merchantName != null && merchantName.isNotEmpty) {
        final matchedVendor = apiProvider.vendors.where(
          (v) => v.name.toLowerCase().contains(merchantName.toLowerCase()) ||
                 merchantName.toLowerCase().contains(v.name.toLowerCase())
        ).firstOrNull;

        if (matchedVendor != null) {
          _selectedVendorId = matchedVendor.id;
        } else {
        }
      }

      _ocrAutoFillApplied = true;
    });
  }

  /// Build metadata map to be stored on the expense.
  /// Supports both multi-scan (receipts array) and legacy single-receipt flows.
  Map<String, dynamic>? _buildExpenseMetadata(ApiExpenseProvider apiProvider) {
    final scanItems = apiProvider.scanItems;
    final hasPending = apiProvider.pendingReceiptBytes != null;
    final hasOCR = apiProvider.hasOCRResult;

    if (scanItems.isEmpty && !hasPending && !hasOCR) return null;

    final meta = <String, dynamic>{};
    meta['receiptSource'] = _isFromScan ? 'camera_scan' : 'manual_attach';

    if (scanItems.isNotEmpty) {
      // Multi-scan: include array of all receipts with their OCR results
      meta['receipts'] = scanItems.asMap().entries.map((e) {
        final i = e.key;
        final item = e.value;
        final ocrData = item.ocrResult?.ocrData ?? <String, dynamic>{};
        return <String, dynamic>{
          'index': i,
          'fileName': item.fileName,
          'ocrStatus': item.ocrState.name,
          if (item.receiptId != null) 'receiptId': item.receiptId,
          if (ocrData['merchantName'] != null) 'merchantName': ocrData['merchantName'],
          if (ocrData['totalAmount'] != null) 'totalAmount': ocrData['totalAmount'],
          if (ocrData['transactionDate'] != null) 'transactionDate': ocrData['transactionDate'],
          if (ocrData['currency'] != null) 'currency': ocrData['currency'],
          if (ocrData['taxAmount'] != null) 'taxAmount': ocrData['taxAmount'],
          if (ocrData['lineItems'] != null) 'lineItems': ocrData['lineItems'],
        };
      }).toList();

      // Primary OCR: first successful item
      ScannedReceiptItem? primaryItem;
      try {
        primaryItem = scanItems.firstWhere(
          (item) => item.ocrState == OCRItemState.completed && item.ocrResult != null,
        );
      } catch (_) {}
      if (primaryItem?.ocrResult?.ocrData != null) {
        meta['primaryOcr'] = primaryItem!.ocrResult!.ocrData;
      }
    } else if (hasOCR) {
      // Legacy single-item flow (from camera_screen.dart scan)
      final ocrData = apiProvider.ocrResult?.ocrData ?? <String, dynamic>{};
      final receiptId = apiProvider.ocrResult?.id;
      meta['ocr'] = {
        'status': 'completed',
        if (receiptId != null) 'receiptId': receiptId,
        if (ocrData['merchantName'] != null) 'merchantName': ocrData['merchantName'],
        if (ocrData['merchantAddress'] != null) 'merchantAddress': ocrData['merchantAddress'],
        if (ocrData['transactionDate'] != null) 'transactionDate': ocrData['transactionDate'],
        if (ocrData['totalAmount'] != null) 'totalAmount': ocrData['totalAmount'],
        if (ocrData['currency'] != null) 'currency': ocrData['currency'],
        if (ocrData['subtotal'] != null) 'subtotal': ocrData['subtotal'],
        if (ocrData['taxAmount'] != null) 'taxAmount': ocrData['taxAmount'],
        if (ocrData['discountAmount'] != null) 'discountAmount': ocrData['discountAmount'],
        if (ocrData['paymentMethod'] != null) 'paymentMethod': ocrData['paymentMethod'],
        if (ocrData['lineItems'] != null) 'lineItems': ocrData['lineItems'],
      };
    }

    return meta;
  }

  void _loadEditingData() {
    final apiProvider = context.read<ApiExpenseProvider>();
    final authProvider = context.read<AuthProvider>();
    final expense = apiProvider.selectedExpense;

    if (expense != null && (expense.status == 0 || expense.status == 7)) {
      setState(() {
        _isEditing = true;
        _editingApiId = expense.id;
        _amountController.text = _ThousandsSeparatorFormatter._format(expense.originalAmount.toStringAsFixed(0));
        _selectedCategoryId = expense.categoryId;
        _selectedDepartmentId = expense.departmentId;
        _selectedCostCenterId = expense.costCenterId;
        _selectedVendorId = expense.vendorId;
        _selectedCurrency = expense.originalCurrency;
        _selectedExpenseType = expense.expenseType.isNotEmpty ? expense.expenseType : 'reimbursement';
        _notesController.text = expense.description ?? '';
        _selectedDate = expense.expenseDate;
      });
    } else {
      // For new expense, auto-fill department from user profile
      setState(() {
        if (apiProvider.categories.isNotEmpty) {
          _selectedCategoryId = apiProvider.categories.first.id;
        }
        // Auto-fill department from user's profile
        _selectedDepartmentId = authProvider.user?.departmentId;
      });
    }
  }

  @override
  void dispose() {
    // Clear OCR state when leaving (use saved ref, context is unsafe in dispose)
    _apiProviderRef?.clearOCRState();

    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Build receipt preview section with OCR status (supports multi-scan)
  Widget _buildReceiptPreviewSection() {
    return Consumer<ApiExpenseProvider>(
      builder: (context, apiProvider, _) {
        final hasScan = apiProvider.hasScanItems;
        final hasLegacy = apiProvider.pendingReceiptBytes != null;
        final ocrState = apiProvider.ocrState;
        final hasOCRResult = apiProvider.hasOCRResult;
        final items = apiProvider.scanItems;

        // Don't show if nothing to display
        if (!hasScan && !hasLegacy && !_isFromScan) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.borderRadiusMd,
            border: Border.all(
              color: _getOCRBorderColor(ocrState),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Icon(
                    CupertinoIcons.doc_text_viewfinder,
                    size: 20,
                    color: _getOCRIconColor(ocrState),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    items.length > 1 ? 'Receipts (${items.length})' : 'Receipt',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  _buildOCRStatusBadge(ocrState),
                ],
              ),
              const SizedBox(height: 12),

              // Content: multi-thumbnail strip or single thumbnail + OCR result
              if (items.length > 1)
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => _buildScanItemThumbnail(items[i]),
                  ),
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Single thumbnail
                    if (items.isNotEmpty || hasLegacy)
                      _buildSingleThumbnail(
                        items.isNotEmpty ? items.first.bytes : apiProvider.pendingReceiptBytes!,
                      ),
                    const SizedBox(width: 12),
                    // OCR status content
                    Expanded(
                      child: _buildOCRStatusContent(apiProvider, ocrState, hasOCRResult),
                    ),
                  ],
                ),

              // Actions row (shown when not actively processing)
              if (!apiProvider.isScanProcessing &&
                  ocrState != OCRProcessingState.creatingDraft &&
                  ocrState != OCRProcessingState.uploading &&
                  ocrState != OCRProcessingState.processingOCR)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      // Remove All button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _removeAllReceipts,
                          icon: const Icon(CupertinoIcons.trash, size: 16),
                          label: const Text('Remove All'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.statusRejected,
                            side: BorderSide(color: AppColors.statusRejected.withOpacity(0.5)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Add More button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showScanSourceSheet(apiProvider),
                          icon: const Icon(CupertinoIcons.add, size: 16),
                          label: const Text('Add More'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      // Retry button (single-file OCR failure)
                      if (ocrState == OCRProcessingState.failed && items.isEmpty) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _retryOCR,
                            icon: const Icon(CupertinoIcons.arrow_clockwise, size: 16),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Thumbnail for a single scan item with per-item OCR status badge
  Widget _buildScanItemThumbnail(ScannedReceiptItem item) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () => _showReceiptFullscreen(item.bytes),
          child: Container(
            width: 72,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _getItemBorderColor(item.ocrState)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Image.memory(item.bytes, fit: BoxFit.cover),
            ),
          ),
        ),
        // Status badge overlay at bottom
        Positioned(
          bottom: 4,
          left: 0,
          right: 0,
          child: Center(child: _buildOCRItemBadge(item.ocrState)),
        ),
      ],
    );
  }

  Color _getItemBorderColor(OCRItemState state) {
    switch (state) {
      case OCRItemState.completed:
        return AppColors.statusApproved;
      case OCRItemState.failed:
        return AppColors.statusRejected;
      case OCRItemState.uploading:
      case OCRItemState.processingOCR:
        return AppColors.primary;
      default:
        return AppColors.border;
    }
  }

  Widget _buildOCRItemBadge(OCRItemState state) {
    Color bgColor;
    Widget child;

    switch (state) {
      case OCRItemState.uploading:
      case OCRItemState.processingOCR:
        bgColor = AppColors.primary;
        child = const SizedBox(
          width: 10,
          height: 10,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        );
        break;
      case OCRItemState.completed:
        bgColor = AppColors.statusApproved;
        child = const Icon(CupertinoIcons.checkmark, size: 10, color: Colors.white);
        break;
      case OCRItemState.failed:
        bgColor = AppColors.statusRejected;
        child = const Icon(CupertinoIcons.xmark, size: 10, color: Colors.white);
        break;
      default:
        bgColor = AppColors.textMuted;
        child = const Icon(CupertinoIcons.clock, size: 10, color: Colors.white);
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }

  Widget _buildSingleThumbnail(Uint8List bytes) {
    return GestureDetector(
      onTap: () => _showReceiptFullscreen(bytes),
      child: Container(
        width: 80,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Image.memory(bytes, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Color _getOCRBorderColor(OCRProcessingState state) {
    switch (state) {
      case OCRProcessingState.completed:
        return AppColors.statusApproved;
      case OCRProcessingState.failed:
        return AppColors.statusRejected;
      case OCRProcessingState.creatingDraft:
      case OCRProcessingState.uploading:
      case OCRProcessingState.processingOCR:
        return AppColors.primary;
      default:
        return AppColors.border;
    }
  }

  Color _getOCRIconColor(OCRProcessingState state) {
    switch (state) {
      case OCRProcessingState.completed:
        return AppColors.statusApproved;
      case OCRProcessingState.failed:
        return AppColors.statusRejected;
      case OCRProcessingState.creatingDraft:
      case OCRProcessingState.uploading:
      case OCRProcessingState.processingOCR:
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildOCRStatusBadge(OCRProcessingState state) {
    String text;
    Color bgColor;
    Color textColor;

    switch (state) {
      case OCRProcessingState.idle:
        text = 'Ready';
        bgColor = AppColors.border;
        textColor = AppColors.textSecondary;
        break;
      case OCRProcessingState.creatingDraft:
        text = 'Preparing...';
        bgColor = AppColors.primary.withOpacity(0.1);
        textColor = AppColors.primary;
        break;
      case OCRProcessingState.uploading:
        text = 'Uploading...';
        bgColor = AppColors.primary.withOpacity(0.1);
        textColor = AppColors.primary;
        break;
      case OCRProcessingState.processingOCR:
        text = 'Extracting...';
        bgColor = AppColors.primary.withOpacity(0.1);
        textColor = AppColors.primary;
        break;
      case OCRProcessingState.completed:
        text = 'Extracted';
        bgColor = AppColors.statusApproved.withOpacity(0.1);
        textColor = AppColors.statusApproved;
        break;
      case OCRProcessingState.failed:
        text = 'Failed';
        bgColor = AppColors.statusRejected.withOpacity(0.1);
        textColor = AppColors.statusRejected;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state == OCRProcessingState.creatingDraft ||
              state == OCRProcessingState.uploading ||
              state == OCRProcessingState.processingOCR)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor,
                ),
              ),
            ),
          Text(
            text,
            style: AppTypography.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOCRStatusContent(ApiExpenseProvider apiProvider, OCRProcessingState state, bool hasOCRResult) {
    switch (state) {
      case OCRProcessingState.idle:
        return Text(
          'Receipt attached. Tap to process.',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        );

      case OCRProcessingState.creatingDraft:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Creating expense...',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              backgroundColor: AppColors.border,
              color: AppColors.primary,
            ),
          ],
        );

      case OCRProcessingState.uploading:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uploading receipt...',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              backgroundColor: AppColors.border,
              color: AppColors.primary,
            ),
          ],
        );

      case OCRProcessingState.processingOCR:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Extracting data with AI...',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Analyzing receipt details',
              style: AppTypography.caption.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              backgroundColor: AppColors.border,
              color: AppColors.primary,
            ),
          ],
        );

      case OCRProcessingState.completed:
        // Show extracted data summary
        final merchantName = apiProvider.getOCRMerchantName();
        final amount = apiProvider.getOCRAmount();
        final date = apiProvider.getOCRDate();
        final currency = apiProvider.getOCRCurrency() ?? 'IDR';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (merchantName != null) ...[
              Row(
                children: [
                  Icon(CupertinoIcons.building_2_fill, size: 14, color: AppColors.statusApproved),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      merchantName,
                      style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            if (amount != null) ...[
              Row(
                children: [
                  Icon(CupertinoIcons.money_dollar_circle, size: 14, color: AppColors.statusApproved),
                  const SizedBox(width: 4),
                  Text(
                    '$currency ${_formatAmount(amount)}',
                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            if (date != null) ...[
              Row(
                children: [
                  Icon(CupertinoIcons.calendar, size: 14, color: AppColors.statusApproved),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(date),
                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Text(
              '✓ Form auto-filled with extracted data',
              style: AppTypography.caption.copyWith(
                color: AppColors.statusApproved,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        );

      case OCRProcessingState.failed:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(CupertinoIcons.exclamationmark_triangle, size: 14, color: AppColors.statusRejected),
                const SizedBox(width: 4),
                Text(
                  'OCR extraction failed',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.statusRejected,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              apiProvider.ocrError ?? 'Unknown error',
              style: AppTypography.caption.copyWith(
                color: AppColors.textMuted,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'You can retry or fill the form manually.',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        );
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showReceiptFullscreen(Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.memory(imageBytes),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeAllReceipts() {
    final apiProvider = context.read<ApiExpenseProvider>();

    // Delete temp draft expense if created
    if (apiProvider.tempDraftExpenseId != null) {
      apiProvider.deleteExpense(apiProvider.tempDraftExpenseId!);
    }

    apiProvider.clearOCRState(); // also clears _scanItems
    setState(() {
      _isFromScan = false;
      _ocrAutoFillApplied = false;
    });
  }

  void _retryOCR() async {
    final apiProvider = context.read<ApiExpenseProvider>();
    final authProvider = context.read<AuthProvider>();

    final categoryId = _selectedCategoryId ?? apiProvider.categories.firstOrNull?.id;
    if (categoryId == null) return;

    await apiProvider.retryOCR(
      categoryId: categoryId,
      departmentId: authProvider.user?.departmentId,
    );

    // Auto-fill if successful
    if (apiProvider.hasOCRResult && mounted) {
      setState(() {
        _ocrAutoFillApplied = false;
      });
      _applyOCRAutoFill(apiProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info banner for new expense
                      if (!_isEditing) _buildInfoBanner(),

                      // Receipt Preview Section (when from scan)
                      _buildReceiptPreviewSection(),

                      // Amount Section (Hero)
                      _buildAmountSection(),

                      // Form Fields
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Vendor
                            _buildSectionTitle('Merchant / Vendor', CupertinoIcons.building_2_fill),
                            const SizedBox(height: 12),
                            _buildVendorSelector(),

                            const SizedBox(height: 24),

                            // Expense Type
                            _buildSectionTitle('Expense Type', CupertinoIcons.tag_fill),
                            const SizedBox(height: 12),
                            _buildExpenseTypeSelector(),

                            const SizedBox(height: 24),

                            // Category
                            _buildSectionTitle('Category', CupertinoIcons.folder_fill),
                            const SizedBox(height: 12),
                            _buildCategorySelector(),

                            const SizedBox(height: 24),

                            // Date
                            _buildSectionTitle('Date', CupertinoIcons.calendar),
                            const SizedBox(height: 12),
                            _buildDateSelector(),

                            const SizedBox(height: 24),

                            // Department (read-only from user profile) & Cost Center Row
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildSectionTitle('Department', CupertinoIcons.person_2_fill, small: true),
                                      const SizedBox(height: 8),
                                      _buildDepartmentDisplay(),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildSectionTitle('Cost Center', CupertinoIcons.chart_pie_fill, small: true),
                                      const SizedBox(height: 8),
                                      _buildCostCenterDropdown(),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Notes
                            _buildSectionTitle(
                              'Notes ${!_isEditing ? "(Required)" : "(Optional)"}',
                              CupertinoIcons.text_quote,
                            ),
                            const SizedBox(height: 12),
                            _buildModernTextField(
                              controller: _notesController,
                              hint: 'Business justification or details...',
                              icon: CupertinoIcons.pencil,
                              maxLines: 3,
                              validator: !_isEditing
                                  ? (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Notes are required for expenses without receipt';
                                      }
                                      return null;
                                    }
                                  : null,
                            ),

                            const SizedBox(height: 24),

                            // Attachments (only for new expense, not editing)
                            if (!_isEditing) ...[
                              _buildSectionTitle('Attachments', CupertinoIcons.paperclip),
                              const SizedBox(height: 12),
                              _buildAttachmentSection(),
                              const SizedBox(height: 8),
                            ],

                            // Action Buttons
                            _buildActionButtons(),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
              context.read<ApiExpenseProvider>().setSelectedExpense(null);
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Edit Expense' : 'New Expense',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isEditing ? 'Update your expense details' : 'Create a new expense claim',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Consumer<ApiExpenseProvider>(
      builder: (context, apiProvider, _) {
        final hasReceipt = apiProvider.hasScanItems ||
            apiProvider.pendingReceiptBytes != null ||
            apiProvider.pendingAttachments.isNotEmpty;

        // Don't show "needs receipt" banner when receipt is already attached
        if (hasReceipt) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: AlertBanner(
            icon: CupertinoIcons.info_circle_fill,
            iconColor: FintechColors.categoryBlue,
            backgroundColor: FintechColors.categoryBlueBg,
            title: 'Manual Entry',
            subtitle: 'This expense will need a receipt attachment before submission.',
          ),
        );
      },
    );
  }

  Widget _buildAmountSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: FintechColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Enter Amount',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Currency Selector
              GestureDetector(
                onTap: _showCurrencyPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _selectedCurrency,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        CupertinoIcons.chevron_down,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Amount Input - Using Container with white background for visibility
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_ThousandsSeparatorFormatter()],
                    textAlign: TextAlign.center,
                    cursorColor: FintechColors.primary,
                    cursorWidth: 2,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: FintechColors.primary,
                      letterSpacing: -1,
                    ),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      errorStyle: TextStyle(
                        color: FintechColors.categoryRed,
                        fontSize: 12,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Amount is required';
                      }
                      final parsed = double.tryParse(_ThousandsSeparatorFormatter.toRaw(value));
                      if (parsed == null || parsed <= 0) {
                        return 'Invalid amount';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCurrencyPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 280,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Currency',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: FintechColors.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Icon(CupertinoIcons.xmark_circle_fill, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 44,
                scrollController: FixedExtentScrollController(
                  initialItem: _currencies.indexOf(_selectedCurrency),
                ),
                onSelectedItemChanged: (index) {
                  setState(() => _selectedCurrency = _currencies[index]);
                },
                children: _currencies.map((c) => Center(
                  child: Text(c, style: const TextStyle(fontSize: 18)),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, {bool small = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: small ? 14 : 16,
          color: FintechColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: small ? 13 : 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 15,
            color: AppColors.textMuted,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(icon, size: 20, color: AppColors.textMuted),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide(color: FintechColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide(color: AppColors.statusRejected, width: 1),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildExpenseTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: _expenseTypes.map((type) {
          final isSelected = _selectedExpenseType == type['value'];
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedExpenseType = type['value']),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? FintechColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  children: [
                    Icon(
                      type['icon'] as IconData,
                      size: 22,
                      color: isSelected ? Colors.white : AppColors.textMuted,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      (type['label'] as String).split(' ').first,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Consumer<ApiExpenseProvider>(
      builder: (context, apiProvider, _) {
        final categories = apiProvider.categories;

        if (categories.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.card,
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CupertinoActivityIndicator(),
                ),
                const SizedBox(width: 12),
                Text('Loading categories...', style: TextStyle(color: AppColors.textMuted)),
              ],
            ),
          );
        }

        return GestureDetector(
          onTap: () => _showCategoryPicker(categories),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.card,
            ),
            child: Row(
              children: [
                // Category icon
                Builder(
                  builder: (context) {
                    final selectedCat = categories.firstWhere(
                      (c) => c.id == _selectedCategoryId,
                      orElse: () => categories.first,
                    );
                    return CategoryIconCircle(
                      icon: selectedCat.icon ?? getCategoryIcon(selectedCat.name),
                      categoryCode: selectedCat.name.toLowerCase(),
                      size: 40,
                    );
                  },
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        categories.firstWhere(
                          (c) => c.id == _selectedCategoryId,
                          orElse: () => categories.first,
                        ).name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
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
        );
      },
    );
  }

  void _showCategoryPicker(List<CategoryDTO> categories) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Category',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.bgSubtle,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(CupertinoIcons.xmark, size: 16, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = cat.id == _selectedCategoryId;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategoryId = cat.id);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected ? FintechColors.primary.withValues(alpha: 0.1) : AppColors.bgSubtle,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: isSelected ? Border.all(color: FintechColors.primary, width: 2) : null,
                      ),
                      child: Row(
                        children: [
                          CategoryIconCircle(
                            icon: cat.icon ?? getCategoryIcon(cat.name),
                            categoryCode: cat.name.toLowerCase(),
                            size: 44,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              cat.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              CupertinoIcons.checkmark_circle_fill,
                              color: FintechColors.primary,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorSelector() {
    return Consumer<ApiExpenseProvider>(
      builder: (context, apiProvider, _) {
        final vendors = apiProvider.vendors;

        if (vendors.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.card,
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CupertinoActivityIndicator(),
                ),
                const SizedBox(width: 12),
                Text('Loading vendors...', style: TextStyle(color: AppColors.textMuted)),
              ],
            ),
          );
        }

        final selectedVendor = _selectedVendorId != null
            ? vendors.where((v) => v.id == _selectedVendorId).firstOrNull
            : null;

        return GestureDetector(
          onTap: () => _showVendorPicker(vendors),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.card,
              border: (_selectedVendorId == null && _otherVendorName == null)
                  ? Border.all(color: AppColors.statusRejected.withValues(alpha: 0.5), width: 1)
                  : null,
            ),
            child: Row(
              children: [
                // Vendor icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: FintechColors.categoryBlueBg,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    CupertinoIcons.building_2_fill,
                    color: FintechColors.categoryBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Vendor',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selectedVendor?.name ?? _otherVendorName ?? 'Tap to select vendor',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: (selectedVendor != null || _otherVendorName != null) ? FontWeight.w600 : FontWeight.w400,
                          color: (selectedVendor != null || _otherVendorName != null) ? AppColors.textPrimary : AppColors.textMuted,
                        ),
                      ),
                      if (selectedVendor?.externalId != null && selectedVendor!.externalId!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          selectedVendor.externalId!,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
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
        );
      },
    );
  }

  void _showVendorPicker(List<VendorDTO> vendors) {
    // Filter out blocked vendors
    final activeVendors = vendors.where((v) => !v.isBlocked).toList();
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final query = searchController.text.toLowerCase();
          final filteredVendors = query.isEmpty
              ? activeVendors
              : activeVendors.where((v) =>
                  v.name.toLowerCase().contains(query) ||
                  (v.externalId?.toLowerCase().contains(query) ?? false)).toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Vendor',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.bgSubtle,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(CupertinoIcons.xmark, size: 16, color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
                // Search field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: searchController,
                    onChanged: (_) => setModalState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search vendor...',
                      prefixIcon: const Icon(CupertinoIcons.search, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: filteredVendors.length + 1, // +1 for "Other" option
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      // "Other" option at the end
                      if (index == filteredVendors.length) {
                        final isOtherSelected = _selectedVendorId == null && _otherVendorName != null;
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(ctx);
                            _showOtherVendorInput();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isOtherSelected
                                  ? FintechColors.primary.withValues(alpha: 0.1)
                                  : AppColors.bgSubtle,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: isOtherSelected
                                  ? Border.all(color: FintechColors.primary, width: 2)
                                  : Border.all(color: AppColors.border, width: 1),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.bgSubtle,
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Icon(
                                    CupertinoIcons.pencil,
                                    color: AppColors.textMuted,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Other',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        isOtherSelected
                                            ? _otherVendorName!
                                            : 'Enter vendor name manually',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isOtherSelected)
                                  Icon(
                                    CupertinoIcons.checkmark_circle_fill,
                                    color: FintechColors.primary,
                                    size: 22,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }

                      final vendor = filteredVendors[index];
                      final isSelected = vendor.id == _selectedVendorId;
                      final isGlobal = vendor.isGlobal;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedVendorId = vendor.id;
                            _otherVendorName = null;
                          });
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected ? FintechColors.primary.withValues(alpha: 0.1) : AppColors.bgSubtle,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: isSelected ? Border.all(color: FintechColors.primary, width: 2) : null,
                          ),
                          child: Row(
                            children: [
                              // Vendor icon with global indicator
                              Stack(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isGlobal ? FintechColors.categoryGreenBg : FintechColors.categoryBlueBg,
                                      borderRadius: BorderRadius.circular(AppRadius.md),
                                    ),
                                    child: Icon(
                                      CupertinoIcons.building_2_fill,
                                      color: isGlobal ? FintechColors.categoryGreen : FintechColors.categoryBlue,
                                      size: 22,
                                    ),
                                  ),
                                  if (isGlobal)
                                    Positioned(
                                      right: -2,
                                      bottom: -2,
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: FintechColors.categoryGreen,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                        child: const Icon(
                                          CupertinoIcons.globe,
                                          color: Colors.white,
                                          size: 8,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            vendor.name,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        if (isGlobal)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: FintechColors.categoryGreenBg,
                                              borderRadius: BorderRadius.circular(AppRadius.sm),
                                            ),
                                            child: Text(
                                              'Global',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: FintechColors.categoryGreen,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (vendor.externalId != null && vendor.externalId!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'ID: ${vendor.externalId}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                    if (vendor.normalizedName != null && vendor.normalizedName != vendor.name) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        vendor.normalizedName!,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textMuted,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  CupertinoIcons.checkmark_circle_fill,
                                  color: FintechColors.primary,
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showOtherVendorInput() {
    final controller = TextEditingController(text: _otherVendorName ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Vendor Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Warung Makan Padang'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _selectedVendorId = null;
                  _otherVendorName = name;
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: FintechColors.primary,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: AppColors.textPrimary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          setState(() => _selectedDate = date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: FintechColors.categoryPurpleBg,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                CupertinoIcons.calendar,
                color: FintechColors.categoryPurple,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expense Date',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(_selectedDate),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
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
    );
  }

  /// Read-only department display from user profile
  Widget _buildDepartmentDisplay() {
    return Consumer2<AuthProvider, ApiExpenseProvider>(
      builder: (context, authProvider, apiProvider, _) {
        final user = authProvider.user;
        final departmentId = user?.departmentId;

        // Debug logging
        if (apiProvider.departments.isNotEmpty) {
        }

        // Try to get department name from user profile first, then look up from departments list
        String departmentName = user?.departmentName ?? '';
        if (departmentName.isEmpty && departmentId != null) {
          final dept = apiProvider.departments.where((d) => d.id == departmentId).firstOrNull;
          departmentName = dept?.name ?? 'Loading...';
        }
        if (departmentName.isEmpty) {
          departmentName = 'Not Assigned';
        }

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgSubtle,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.building_2_fill,
                size: 16,
                color: FintechColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  departmentName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Lock icon to indicate read-only
              Icon(
                CupertinoIcons.lock_fill,
                size: 12,
                color: AppColors.textMuted,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCostCenterDropdown() {
    return Consumer<ApiExpenseProvider>(
      builder: (context, apiProvider, _) {
        final costCenters = apiProvider.costCenters;
        final selectedCC = costCenters.where((c) => c.id == _selectedCostCenterId).firstOrNull;

        return GestureDetector(
          onTap: () => _showSelectionSheet(
            title: 'Select Cost Center',
            items: costCenters.map((c) => {'id': c.id, 'name': c.name}).toList(),
            selectedId: _selectedCostCenterId,
            onSelect: (id) => setState(() => _selectedCostCenterId = id),
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.card,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedCC?.name ?? 'Select',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: selectedCC != null ? AppColors.textPrimary : AppColors.textMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(CupertinoIcons.chevron_down, size: 14, color: AppColors.textMuted),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSelectionSheet({
    required String title,
    required List<Map<String, String>> items,
    String? selectedId,
    required Function(String?) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  // None option
                  _buildSelectionItem(
                    name: 'None',
                    isSelected: selectedId == null,
                    onTap: () {
                      onSelect(null);
                      Navigator.pop(ctx);
                    },
                  ),
                  ...items.map((item) => _buildSelectionItem(
                    name: item['name']!,
                    isSelected: item['id'] == selectedId,
                    onTap: () {
                      onSelect(item['id']);
                      Navigator.pop(ctx);
                    },
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionItem({
    required String name,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? FintechColors.primary.withValues(alpha: 0.1) : AppColors.bgSubtle,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: isSelected ? Border.all(color: FintechColors.primary) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(CupertinoIcons.checkmark_circle_fill, color: FintechColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Consumer<ApiExpenseProvider>(
      builder: (context, apiProvider, _) {
        // Check both isLoading and isSubmitting (upload receipts uses isSubmitting)
        final isLoading = apiProvider.isLoading || apiProvider.isSubmitting;

        if (_isEditing) {
          return Column(
            children: [
              _buildPrimaryButton(
                label: isLoading ? 'Saving...' : 'Save Changes',
                icon: CupertinoIcons.checkmark_alt,
                isLoading: isLoading,
                onTap: isLoading ? null : _submitForm,
              ),
              const SizedBox(height: 12),
              _buildSecondaryButton(
                label: 'Cancel',
                icon: CupertinoIcons.xmark,
                onTap: isLoading ? null : () {
                  context.read<ApiExpenseProvider>().setSelectedExpense(null);
                  context.read<AppProvider>().goBack();
                },
              ),
            ],
          );
        }

        return Column(
          children: [
            // Primary: Submit for Approval
            _buildPrimaryButton(
              label: isLoading && _submitForApproval ? 'Submitting...' : 'Submit for Approval',
              icon: CupertinoIcons.paperplane_fill,
              isLoading: isLoading && _submitForApproval,
              onTap: isLoading ? null : () => _submitFormWithAction(true),
            ),
            const SizedBox(height: 12),
            // Secondary: Save as Draft
            _buildSecondaryButton(
              label: isLoading && !_submitForApproval ? 'Saving...' : 'Save as Draft',
              icon: CupertinoIcons.doc_fill,
              onTap: isLoading ? null : () => _submitFormWithAction(false),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAttachmentSection() {
    return Consumer<ApiExpenseProvider>(
      builder: (context, apiProvider, _) {
        final attachments = apiProvider.pendingAttachments;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Attachment list
            if (attachments.isNotEmpty) ...[
              ...attachments.asMap().entries.map((entry) {
                final index = entry.key;
                final file = entry.value;
                final fileName = file.path.split('/').last.split('\\').last;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgSubtle,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: file is File
                              ? Image.file(
                                  file,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: FintechColors.primary.withValues(alpha: 0.1),
                                    child: Icon(CupertinoIcons.doc_fill, color: FintechColors.primary, size: 20),
                                  ),
                                )
                              : Container(
                                  color: FintechColors.primary.withValues(alpha: 0.1),
                                  child: Icon(CupertinoIcons.doc_fill, color: FintechColors.primary, size: 20),
                                ),
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
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Ready to upload',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => apiProvider.removePendingAttachment(index),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            CupertinoIcons.xmark_circle_fill,
                            color: AppColors.textMuted,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],

            // Single Scan Receipt button
            _buildAttachButton(
              icon: CupertinoIcons.viewfinder,
              label: 'Scan Receipt',
              onTap: () => _showScanSourceSheet(apiProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAttachButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.bgSubtle,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: FintechColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: FintechColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show bottom sheet to choose receipt source (camera or gallery)
  void _showScanSourceSheet(ApiExpenseProvider apiProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add Receipt',
              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(CupertinoIcons.camera_fill, color: AppColors.primary),
              title: const Text('Take Photo'),
              subtitle: const Text('Capture receipt with camera'),
              onTap: () {
                Navigator.pop(ctx);
                _pickSingleCamera(apiProvider);
              },
            ),
            ListTile(
              leading: Icon(CupertinoIcons.photo, color: AppColors.primary),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Select one or multiple receipts'),
              onTap: () {
                Navigator.pop(ctx);
                _pickMultiGallery(apiProvider);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickSingleCamera(ApiExpenseProvider apiProvider) async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (file == null) return;
      await _runScanItems([file], apiProvider);
    } catch (e) {
      if (mounted) {
        context.read<AppProvider>().showNotification('Failed to capture photo: $e', type: 'error');
      }
    }
  }

  Future<void> _pickMultiGallery(ApiExpenseProvider apiProvider) async {
    try {
      final List<XFile> files = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (files.isEmpty) return;
      await _runScanItems(files, apiProvider);
    } catch (e) {
      if (mounted) {
        context.read<AppProvider>().showNotification('Failed to pick images: $e', type: 'error');
      }
    }
  }

  Future<void> _runScanItems(List<XFile> files, ApiExpenseProvider apiProvider) async {
    setState(() => _ocrAutoFillApplied = false);
    final authProvider = context.read<AuthProvider>();
    final categoryId = _selectedCategoryId ?? apiProvider.categories.firstOrNull?.id ?? '';
    await apiProvider.processScanItems(
      files: files,
      categoryId: categoryId,
      departmentId: _selectedDepartmentId ?? authProvider.user?.departmentId,
    );
    if (mounted && apiProvider.hasOCRResult) {
      _applyOCRAutoFill(apiProvider);
    }
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    bool isLoading = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: onTap != null
              ? LinearGradient(
                  colors: [FintechColors.primary, FintechColors.primaryLight],
                )
              : null,
          color: onTap == null ? AppColors.textMuted : null,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: FintechColors.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _submitExpense();
    }
  }

  void _submitFormWithAction(bool submitForApproval) {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _submitForApproval = submitForApproval;
      });
      _submitExpense();
    }
  }

  Future<void> _submitExpense() async {
    final apiProvider = context.read<ApiExpenseProvider>();
    final appProvider = context.read<AppProvider>();

    try {
      // Validate vendor selection
      if (_selectedVendorId == null && (_otherVendorName == null || _otherVendorName!.trim().isEmpty)) {
        appProvider.showNotification('Please select a vendor', type: 'error');
        return;
      }

      final amount = double.parse(_ThousandsSeparatorFormatter.toRaw(_amountController.text));
      final categoryId = _selectedCategoryId ?? apiProvider.categories.first.id;
      final description = _notesController.text.isNotEmpty ? _notesController.text : null;

      // Get vendor name from selected vendor or "Other" input
      final selectedVendor = apiProvider.vendors.where((v) => v.id == _selectedVendorId).firstOrNull;
      final merchantName = selectedVendor?.name ?? _otherVendorName;

      ExpenseDTO? result;

    if (_isEditing && _editingApiId != null) {
      result = await apiProvider.updateExpense(
        _editingApiId!,
        categoryId: categoryId,
        expenseDate: _selectedDate,
        description: description,
        departmentId: _selectedDepartmentId,
        costCenterId: _selectedCostCenterId,
        merchantId: _selectedVendorId,
        merchantName: merchantName,
      );

      if (result != null) {
        // Upload any new receipts if attached during edit
        final pendingAttachments = apiProvider.pendingAttachments;
        if (pendingAttachments.isNotEmpty) {
          int uploadedCount = 0;

          for (final file in pendingAttachments) {
            try {
              // Handle different file types (File, XFile)
              String fileName;
              dynamic fileData;

              if (file is File) {
                // Mobile: dart:io File
                fileName = file.path.split('/').last.split('\\').last;
                fileData = file;
              } else if (file.runtimeType.toString().contains('XFile')) {
                // Web: XFile from image_picker
                final xFile = file as dynamic;
                fileName = xFile.name as String;
                fileData = await xFile.readAsBytes();
              } else {
                fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
                fileData = file;
              }

              final uploadResult = await apiProvider.uploadReceipt(
                expenseId: result.id,
                file: fileData,
                fileName: fileName,
              );

              if (uploadResult != null) {
                uploadedCount++;

                // Process OCR for the uploaded receipt
                await apiProvider.processReceiptOCR(uploadResult.id);
              }
            } catch (e) {
            }
          }

          apiProvider.clearPendingAttachments();

          // IMPORTANT: Refresh expense to get updated receipts list
          if (uploadedCount > 0) {
            final refreshedExpense = await apiProvider.getExpense(result.id);
            if (refreshedExpense != null) {
              result = refreshedExpense;
            }
          }
        }

        apiProvider.setSelectedExpense(result);
        appProvider.goBack();
        appProvider.showNotification('Expense updated', type: 'success');
      } else {
        appProvider.showNotification(
          apiProvider.error ?? 'Failed to update expense',
          type: 'error',
        );
      }
    } else {
      // Build metadata: receipt source info + full OCR data if available
      final metadata = _buildExpenseMetadata(apiProvider);

      // Create new expense with correct amount
      result = await apiProvider.createExpense(
        amount: amount,
        categoryId: categoryId,
        expenseDate: _selectedDate,
        description: description,
        expenseType: _selectedExpenseType,
        originalCurrency: _selectedCurrency,
        departmentId: _selectedDepartmentId,
        costCenterId: _selectedCostCenterId,
        merchantId: _selectedVendorId,
        merchantName: merchantName,
        submitForApproval: false, // Always create as draft first
        metadata: metadata,
      );

      if (result != null) {
        // Upload receipts to the real expense.
        // Multi-scan: upload all scan items (they have pre-read bytes).
        // Legacy single: upload pendingReceiptBytes (from camera_screen flow).
        // The temp draft (if any) is deleted after upload.
        int receiptUploadedCount = 0;
        int receiptFailedCount = 0;
        final scanItems = apiProvider.scanItems;
        if (scanItems.isNotEmpty) {
          for (final item in scanItems) {
            final uploadResult = await apiProvider.uploadReceipt(
              expenseId: result.id,
              file: item.bytes,
              fileName: item.fileName,
            );
            if (uploadResult != null) {
              receiptUploadedCount++;
            } else {
              receiptFailedCount++;
            }
          }
        } else if (apiProvider.pendingReceiptBytes != null) {
          final receiptBytes = apiProvider.pendingReceiptBytes!;
          final uploadResult = await apiProvider.uploadReceipt(
            expenseId: result.id,
            file: receiptBytes,
            fileName: 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
          if (uploadResult != null) {
            receiptUploadedCount++;
          } else {
            receiptFailedCount++;
          }
        }

        // Show receipt upload failure warning (non-blocking)
        if (receiptFailedCount > 0 && receiptUploadedCount == 0) {
          appProvider.showNotification(
            'Receipt upload failed. You can attach it later from expense detail.',
            type: 'warning',
          );
        } else if (receiptFailedCount > 0) {
          appProvider.showNotification(
            '$receiptUploadedCount receipt(s) uploaded, $receiptFailedCount failed',
            type: 'warning',
          );
        }

        // Refresh expense after receipt uploads to get updated receipt list.
        // getExpense() internally calls refreshReceipts() which updates
        // _selectedExpense with the receipts array. Use selectedExpense
        // (not the return value) since refreshReceipts updates it after return.
        if (receiptUploadedCount > 0) {
          await apiProvider.getExpense(result.id);
          result = apiProvider.selectedExpense ?? result;
        }

        // Delete the temp draft expense that was created for OCR (if any)
        if (apiProvider.tempDraftExpenseId != null) {
          apiProvider.deleteExpense(apiProvider.tempDraftExpenseId!);
        }

        // Upload receipts from manual attachment (gallery)
        final pendingAttachments = apiProvider.pendingAttachments;
        if (pendingAttachments.isNotEmpty) {
          int uploadedCount = 0;
          int failedCount = 0;

          for (final file in pendingAttachments) {
            try {
              // Handle different file types (File, XFile)
              String fileName;
              dynamic fileData;

              if (file is File) {
                // Mobile: dart:io File
                fileName = file.path.split('/').last.split('\\').last;
                fileData = file;
              } else if (file.runtimeType.toString().contains('XFile')) {
                // Web: XFile from image_picker
                final xFile = file as dynamic;
                fileName = xFile.name as String;
                fileData = await xFile.readAsBytes(); // Read as Uint8List for web
              } else {
                // Fallback: assume it has a name property
                fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
                fileData = file;
              }


              final uploadResult = await apiProvider.uploadReceipt(
                expenseId: result.id,
                file: fileData,
                fileName: fileName,
              );

              if (uploadResult != null) {
                uploadedCount++;

                // Process OCR for the uploaded receipt
                final ocrResult = await apiProvider.processReceiptOCR(uploadResult.id);

                if (ocrResult != null && ocrResult.ocrData != null) {
                  // OCR data is now available in ocrResult.ocrData
                  // You can use this to auto-fill form fields if needed
                } else {
                }
              } else {
                failedCount++;
              }
            } catch (e) {
              failedCount++;
            }
          }

          apiProvider.clearPendingAttachments();

          // IMPORTANT: Refresh expense to get updated receipts list.
          // Use selectedExpense after getExpense since refreshReceipts updates it.
          await apiProvider.getExpense(result.id);
          result = apiProvider.selectedExpense ?? result;

          // Show upload status
          if (failedCount > 0) {
            appProvider.showNotification(
              'Uploaded $uploadedCount receipts, $failedCount failed',
              type: 'warning',
            );
          }
        }

        // If user wants to submit for approval, call submit API separately
        if (_submitForApproval) {
          // Budget availability check before submission
          final matchResponse = await apiProvider.matchBudgetForExpense(
            departmentId: _selectedDepartmentId,
            categoryId: categoryId,
            costCenterId: _selectedCostCenterId,
          );

          if (matchResponse?.budget != null) {
            final budgetId = matchResponse!.budget!.id;

            final checkResponse = await apiProvider.checkBudgetAvailability(
              budgetId: budgetId,
              amount: amount,
              currency: _selectedCurrency,
              expenseType: _selectedExpenseType ?? 'reimbursement',
            );

            if (checkResponse != null) {
              // Hard cap enforced — block submission
              if (!checkResponse.canProceed) {
                appProvider.showNotification(
                  checkResponse.reason ?? 'Expense exceeds budget limit',
                  type: 'error',
                );
                return;
              }

              // Would exceed budget but still allowed (e.g. card, out-of-policy)
              if (checkResponse.wouldExceed) {
                final shouldProceed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Budget Warning'),
                    content: Text(
                      'This expense will exceed the available budget '
                      '(${checkResponse.budgetCurrency} ${_formatAmount(checkResponse.availableAmount)} remaining). '
                      'It will be flagged as out-of-policy. Do you want to proceed?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Proceed'),
                      ),
                    ],
                  ),
                );
                if (shouldProceed != true) return;
              }
            }
            // checkResponse null = budget check API failed → proceed without blocking
          }
          // matchResponse.budget null = no matching budget found → proceed normally


          final submitSuccess = await apiProvider.submitExpense(result.id);

          if (submitSuccess) {
            // submitExpense updates selectedExpense with new status.
            // Re-fetch receipts so the success screen shows them correctly.
            await apiProvider.refreshReceipts(result.id);
            result = apiProvider.selectedExpense;
          } else {
            // Submit failed, but expense was created as draft
            final errorMsg = apiProvider.error ?? "Unknown error";
            appProvider.showNotification(
              'Cannot submit: $errorMsg',
              type: 'error',
            );
            apiProvider.setSelectedExpense(result);
            appProvider.navigateTo('expenseCreated');
            return;
          }
        } else {
          apiProvider.setSelectedExpense(result);
        }

        // Clear all receipt/OCR state so next "New Expense" starts fresh
        apiProvider.clearOCRState();
        apiProvider.clearPendingAttachments();

        appProvider.showNotification(
          _submitForApproval
              ? 'Expense created and submitted for approval!'
              : 'Expense saved as draft!',
          type: 'success',
        );

        appProvider.navigateTo('expenseCreated');
      } else {
        appProvider.showNotification(
          apiProvider.error ?? 'Failed to create expense',
          type: 'error',
        );
      }
    }
    } catch (e, stackTrace) {
      appProvider.showNotification(
        'Error: ${e.toString()}',
        type: 'error',
      );
    }
  }
}

class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');
    final formatted = _format(digits);
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String _format(String digits) {
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i != 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  static String toRaw(String formatted) => formatted.replaceAll('.', '');
}
