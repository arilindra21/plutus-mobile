import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/services.dart';
import '../services/models/corporate_card_dto.dart';

/// OCR Processing State
enum OCRProcessingState {
  idle,
  creatingDraft,
  uploading,
  processingOCR,
  completed,
  failed,
}

/// Per-item OCR state for multi-scan sessions
enum OCRItemState { pending, uploading, processingOCR, completed, failed }

/// State for a single scanned receipt in a multi-scan session
class ScannedReceiptItem {
  final Uint8List bytes;
  final String fileName;
  OCRItemState ocrState;
  ReceiptDTO? ocrResult;
  String? ocrError;
  String? receiptId; // Set after upload to temp draft

  ScannedReceiptItem({
    required this.bytes,
    required this.fileName,
    this.ocrState = OCRItemState.pending,
    this.ocrResult,
    this.ocrError,
    this.receiptId,
  });
}

/// API-backed Expense Provider - uses real backend API
class ApiExpenseProvider extends ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();
  final ApprovalService _approvalService = ApprovalService();
  final CategoryService _categoryService = CategoryService();
  final AuthService _authService = AuthService();
  final BudgetService _budgetService = BudgetService();
  final ReceiptService _receiptService = ReceiptService();

  // User cache for requester lookups
  final Map<String, UserProfile> _userCache = {};

  // Loading states
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  // Expense list state
  List<ExpenseDTO> _expenses = [];
  PaginationMeta? _pagination;

  // Approval inbox state
  List<ApprovalTaskDTO> _approvalTasks = [];
  ApprovalInboxSummary? _inboxSummary;
  PaginationMeta? _approvalPagination;

  // Reference data
  List<CategoryDTO> _categories = [];
  List<DepartmentDTO> _departments = [];
  List<VendorDTO> _vendors = [];
  List<BudgetItemDTO> _budgets = [];
  List<CostCenterDTO> _costCenters = [];

  // Budget analytics state
  BudgetUtilizationDTO? _selectedBudgetUtilization;
  BudgetTrendDTO? _selectedBudgetTrend;
  BudgetHistoryDTO? _selectedBudgetHistory;
  BudgetPeriodDTO? _selectedBudgetPeriod;

  // Selection state
  ExpenseDTO? _selectedExpense;
  ApprovalTaskDTO? _selectedApprovalTask;
  List<ReceiptDTO> _approvalReceipts = [];
  String? _latestApprovalComment;

  // Bulk selection state
  bool _isSelectionMode = false;
  final Set<String> _selectedTaskIds = {};

  // Form state
  List<dynamic> _pendingAttachments = []; // Can be File, Uint8List, or XFile

  // OCR Processing state
  OCRProcessingState _ocrState = OCRProcessingState.idle;
  dynamic _pendingReceiptImage; // XFile, File, or Uint8List for preview
  Uint8List? _pendingReceiptBytes; // Bytes for image preview
  ReceiptDTO? _ocrResult; // OCR result with extracted data
  String? _tempDraftExpenseId; // Draft expense created for OCR
  String? _ocrError; // Error message if OCR fails

  // Multi-scan session state
  List<ScannedReceiptItem> _scanItems = [];

  // Filter state
  ExpenseListParams _currentFilters = ExpenseListParams();
  ApprovalInboxParams _approvalFilters = ApprovalInboxParams();

  // Financial instrument state (kept for UI compatibility)
  int _activeCardIndex = 0;
  String _instrumentFilter = 'wallet';
  String? _selectedBudgetCategory;
  CorporateCard? _selectedCard;

  // Getters
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  List<ExpenseDTO> get expenses => List.unmodifiable(_expenses);
  PaginationMeta? get pagination => _pagination;

  List<ApprovalTaskDTO> get approvalTasks => List.unmodifiable(_approvalTasks);
  ApprovalInboxSummary? get inboxSummary => _inboxSummary;
  int get pendingApprovalsCount => _inboxSummary?.pendingCount ?? 0;

  List<CategoryDTO> get categories => List.unmodifiable(_categories);
  List<DepartmentDTO> get departments => List.unmodifiable(_departments);
  List<VendorDTO> get vendors => List.unmodifiable(_vendors);
  List<BudgetItemDTO> get budgets => List.unmodifiable(_budgets);
  List<CostCenterDTO> get costCenters => List.unmodifiable(_costCenters);

  // Budget analytics getters
  BudgetUtilizationDTO? get selectedBudgetUtilization => _selectedBudgetUtilization;
  BudgetTrendDTO? get selectedBudgetTrend => _selectedBudgetTrend;
  BudgetHistoryDTO? get selectedBudgetHistory => _selectedBudgetHistory;
  BudgetPeriodDTO? get selectedBudgetPeriod => _selectedBudgetPeriod;

  ExpenseDTO? get selectedExpense => _selectedExpense;
  ApprovalTaskDTO? get selectedApprovalTask => _selectedApprovalTask;
  List<ReceiptDTO> get approvalReceipts => _approvalReceipts;
  String? get latestApprovalComment => _latestApprovalComment;

  List<dynamic> get pendingAttachments => List.unmodifiable(_pendingAttachments);

  // OCR getters
  OCRProcessingState get ocrState => _ocrState;
  dynamic get pendingReceiptImage => _pendingReceiptImage;
  Uint8List? get pendingReceiptBytes => _pendingReceiptBytes;
  ReceiptDTO? get ocrResult => _ocrResult;
  String? get tempDraftExpenseId => _tempDraftExpenseId;
  String? get ocrError => _ocrError;
  bool get isOCRProcessing => _ocrState != OCRProcessingState.idle &&
                               _ocrState != OCRProcessingState.completed &&
                               _ocrState != OCRProcessingState.failed;
  bool get hasOCRResult => _ocrResult != null && _ocrResult!.ocrData != null;

  // Multi-scan getters
  List<ScannedReceiptItem> get scanItems => List.unmodifiable(_scanItems);
  bool get hasScanItems => _scanItems.isNotEmpty;
  int get scanItemCount => _scanItems.length;
  bool get isScanProcessing => _scanItems.any((item) =>
      item.ocrState == OCRItemState.uploading ||
      item.ocrState == OCRItemState.processingOCR);

  int get activeCardIndex => _activeCardIndex;
  String get instrumentFilter => _instrumentFilter;
  String? get selectedBudgetCategory => _selectedBudgetCategory;
  CorporateCard? get selectedCard => _selectedCard;

  // Bulk selection getters
  bool get isSelectionMode => _isSelectionMode;
  Set<String> get selectedTaskIds => Set.unmodifiable(_selectedTaskIds);
  int get selectedTaskCount => _selectedTaskIds.length;
  bool get hasSelectedTasks => _selectedTaskIds.isNotEmpty;

  // Computed getters
  List<ExpenseDTO> get recentExpenses => _expenses.take(5).toList();

  List<ExpenseDTO> get pendingExpenses =>
      _expenses.where((e) => e.status == 1 || e.status == 3).toList();

  /// Total amount of pending reimbursements (for employee dashboard)
  double get totalPendingAmount =>
      pendingExpenses.fold(0.0, (sum, e) => sum + e.originalAmount);

  /// Total amount of draft expenses (status 0)
  double get totalDraftAmount =>
      _expenses.where((e) => e.status == 0).fold(0.0, (sum, e) => sum + e.originalAmount);

  /// Total approved this month
  double get totalApprovedThisMonth {
    final now = DateTime.now();
    return _expenses
        .where((e) =>
            (e.status == 4 || e.status == 5) &&
            e.approvedAt != null &&
            e.approvedAt!.month == now.month &&
            e.approvedAt!.year == now.year)
        .fold(0.0, (sum, e) => sum + e.originalAmount);
  }

  /// Count of expenses by status
  int get draftCount => _expenses.where((e) => e.status == 0).length;
  int get employeePendingCount => pendingExpenses.length;

  /// Get approval task for a specific expense ID (if current user is the approver)
  ApprovalTaskDTO? getApprovalTaskForExpense(String expenseId) {
    try {
      return _approvalTasks.firstWhere(
        (task) => task.expenseId == expenseId && task.status == 1, // status 1 = pending
      );
    } catch (_) {
      return null;
    }
  }

  /// Check if current user can approve this expense
  bool canApproveExpense(String expenseId) {
    return getApprovalTaskForExpense(expenseId) != null;
  }

  // ============ Expense Operations ============

  // Current user ID for filtering
  String? _currentUserId;
  bool _isManager = false;
  UserProfile? _currentUserProfile;

  /// Set current user context for expense filtering
  void setUserContext({required String userId, required bool isManager, UserProfile? userProfile}) {
    _currentUserId = userId;
    _isManager = isManager;
    _currentUserProfile = userProfile;
  }

  /// Current user profile
  UserProfile? get currentUserProfile => _currentUserProfile;

  /// Fetch expenses with pagination and filters
  /// For employees, automatically filters to show only their own expenses
  /// For managers, shows all expenses (can optionally filter by requesterId)
  Future<void> fetchExpenses({
    int page = 1,
    int pageSize = 20,
    int? status,
    List<int>? statuses,
    String? search,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool refresh = false,
    String? requesterId, // Optional: for managers to filter by specific user
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // For employees, always filter by their own requesterId
    String? effectiveRequesterId = requesterId;
    if (!_isManager && _currentUserId != null) {
      effectiveRequesterId = _currentUserId;
    }

    _currentFilters = ExpenseListParams(
      page: page,
      pageSize: pageSize,
      status: status,
      statuses: statuses,
      search: search,
      dateFrom: dateFrom,
      dateTo: dateTo,
      requesterId: effectiveRequesterId,
    );

    final result = await _expenseService.listExpenses(_currentFilters);

    if (result.isSuccess) {
      if (refresh || page == 1) {
        _expenses = result.data!.data;
      } else {
        _expenses.addAll(result.data!.data);
      }
      _pagination = result.data!.pagination;
    } else {
      _error = result.error?.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch multiple expenses by their IDs without touching global state.
  /// Used for budget detail to load related expenses from history sourceIds.
  Future<List<ExpenseDTO>> fetchExpensesByIds(List<String> ids) async {
    final results = <ExpenseDTO>[];
    for (final id in ids) {
      final result = await _expenseService.getExpense(id);
      if (result.isSuccess && result.data != null) {
        results.add(result.data!);
      }
    }
    return results;
  }

  /// Get single expense
  Future<ExpenseDTO?> getExpense(String id) async {
    _isLoading = true;
    notifyListeners();

    final result = await _expenseService.getExpense(id);

    _isLoading = false;
    if (result.isSuccess) {
      _selectedExpense = result.data;
      // Fetch receipts separately to ensure they're loaded
      await refreshReceipts(id);
      notifyListeners();
      return result.data;
    } else {
      // 403 is expected when manager views a subordinate's expense via GET /api/v1/expenses/{id}.
      // Don't surface this as a UI error — the screen already has data from the list response.
      if (result.error?.isForbidden != true) {
        _error = result.error?.toString();
      }
      notifyListeners();
      return null;
    }
  }

  /// Refresh receipts for an expense
  /// This ensures receipts are properly loaded even if not included in getExpense response
  Future<void> refreshReceipts(String expenseId) async {
    try {
      print('DEBUG: refreshReceipts called for expenseId: $expenseId');
      print('DEBUG: _selectedExpenseId: ${_selectedExpense?.id}');

      final result = await _receiptService.listReceipts(expenseId);

      print('DEBUG: Receipts API result success: ${result.isSuccess}');
      print('DEBUG: Receipts API data length: ${result.data?.length ?? 0}');

      if (result.isSuccess) {
        print('DEBUG: Receipts data: $result.data');

        if (_selectedExpense == null) {
          print('DEBUG: _selectedExpense is null, cannot update receipts');
          return;
        }

        print('DEBUG: ID match: ${_selectedExpense!.id == expenseId}');

        // Update the selected expense with the fetched receipts
        _selectedExpense = ExpenseDTO(
          id: _selectedExpense!.id,
          organizationId: _selectedExpense!.organizationId,
          entityId: _selectedExpense!.entityId,
          requesterId: _selectedExpense!.requesterId,
          requesterName: _selectedExpense!.requesterName,
          originalAmount: _selectedExpense!.originalAmount,
          originalCurrency: _selectedExpense!.originalCurrency,
          baseAmount: _selectedExpense!.baseAmount,
          baseCurrency: _selectedExpense!.baseCurrency,
          exchangeRate: _selectedExpense!.exchangeRate,
          categoryId: _selectedExpense!.categoryId,
          categoryName: _selectedExpense!.categoryName,
          categoryCode: _selectedExpense!.categoryCode,
          categoryIcon: _selectedExpense!.categoryIcon,
          categoryFields: _selectedExpense!.categoryFields,
          departmentId: _selectedExpense!.departmentId,
          departmentName: _selectedExpense!.departmentName,
          costCenterId: _selectedExpense!.costCenterId,
          costCenterName: _selectedExpense!.costCenterName,
          expenseType: _selectedExpense!.expenseType,
          expenseDate: _selectedExpense!.expenseDate,
          status: _selectedExpense!.status,
          statusName: _selectedExpense!.statusName,
          statusReason: _selectedExpense!.statusReason,
          receiptStatus: _selectedExpense!.receiptStatus,
          receiptStatusName: _selectedExpense!.receiptStatusName,
          receiptRequired: _selectedExpense!.receiptRequired,
          receiptDueDate: _selectedExpense!.receiptDueDate,
          policyStatus: _selectedExpense!.policyStatus,
          policyStatusName: _selectedExpense!.policyStatusName,
          policyFlags: _selectedExpense!.policyFlags,
          workflowRunId: _selectedExpense!.workflowRunId,
          submittedAt: _selectedExpense!.submittedAt,
          approvedAt: _selectedExpense!.approvedAt,
          completedAt: _selectedExpense!.completedAt,
          requiresEmployeeRepayment: _selectedExpense!.requiresEmployeeRepayment,
          repaymentAmount: _selectedExpense!.repaymentAmount,
          repaymentStatus: _selectedExpense!.repaymentStatus,
          description: _selectedExpense!.description,
          vendorId: _selectedExpense!.vendorId,
          vendorName: _selectedExpense!.vendorName,
          metadata: _selectedExpense!.metadata,
          createdAt: _selectedExpense!.createdAt,
          updatedAt: _selectedExpense!.updatedAt,
          createdBy: _selectedExpense!.createdBy,
          receipts: result.data, // Use the fetched receipts
        );

        print('DEBUG: Updated expense receipts count: ${_selectedExpense!.receipts?.length ?? 0}');
        notifyListeners();

        // Add a small delay to ensure UI has time to rebuild
        await Future.delayed(const Duration(milliseconds: 100));
      } else {
        print('DEBUG: Receipts API failed: ${result.error}');
      }
    } catch (e) {
      print('ERROR: Failed to refresh receipts: $e');
    }
  }

  /// Create new expense
  Future<ExpenseDTO?> createExpense({
    required double amount,
    required String categoryId,
    required DateTime expenseDate,
    String? description,
    String expenseType = 'reimbursement',
    String originalCurrency = 'IDR',
    String? departmentId,
    String? costCenterId,
    String? merchantId,
    String? merchantName,
    bool submitForApproval = false,
    Map<String, dynamic>? metadata,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final request = CreateExpenseRequest(
      originalAmount: amount,
      originalCurrency: originalCurrency,
      categoryId: categoryId,
      expenseDate: expenseDate,
      description: description,
      expenseType: expenseType,
      departmentId: departmentId,
      costCenterId: costCenterId,
      merchantId: merchantId,
      merchantName: merchantName,
      submitForApproval: submitForApproval,
      metadata: metadata,
    );

    final result = await _expenseService.createExpense(request);

    _isSubmitting = false;
    if (result.isSuccess) {
      // Add to local list
      _expenses.insert(0, result.data!);
      notifyListeners();
      return result.data;
    } else {
      _error = result.error?.toString();
      notifyListeners();
      return null;
    }
  }

  /// Update expense
  /// Note: expenseType, originalAmount, originalCurrency cannot be changed after creation
  Future<ExpenseDTO?> updateExpense(
    String id, {
    String? categoryId,
    DateTime? expenseDate,
    String? description,
    String? departmentId,
    String? costCenterId,
    String? merchantId,
    String? merchantName,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final request = UpdateExpenseRequest(
      categoryId: categoryId,
      expenseDate: expenseDate,
      description: description,
      departmentId: departmentId,
      costCenterId: costCenterId,
      merchantId: merchantId,
      merchantName: merchantName,
    );

    final result = await _expenseService.updateExpense(id, request);

    _isSubmitting = false;
    if (result.isSuccess) {
      // Update in local list
      final index = _expenses.indexWhere((e) => e.id == id);
      if (index != -1) {
        _expenses[index] = result.data!;
      }
      notifyListeners();
      return result.data;
    } else {
      _error = result.error?.toString();
      notifyListeners();
      return null;
    }
  }

  /// Submit expense for approval
  Future<bool> submitExpense(String id, {String? comment}) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final result = await _expenseService.submitExpense(id, comment: comment);

    _isSubmitting = false;
    if (result.isSuccess) {
      // Update in local list
      final index = _expenses.indexWhere((e) => e.id == id);
      if (index != -1) {
        _expenses[index] = result.data!;
      }
      // Update selected expense so the detail screen reflects the new status
      _selectedExpense = result.data!;
      notifyListeners();
      return true;
    } else {
      _error = result.error?.toString();
      notifyListeners();
      return false;
    }
  }

  /// Cancel expense
  Future<bool> cancelExpense(String id) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final result = await _expenseService.cancelExpense(id);

    _isSubmitting = false;
    if (result.isSuccess) {
      final index = _expenses.indexWhere((e) => e.id == id);
      if (index != -1) {
        _expenses[index] = result.data!;
      }
      // Update selected expense so the detail screen reflects the new status
      _selectedExpense = result.data!;
      notifyListeners();
      return true;
    } else {
      _error = result.error?.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete expense
  Future<bool> deleteExpense(String id) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final result = await _expenseService.deleteExpense(id);

    _isSubmitting = false;
    if (result.isSuccess) {
      _expenses.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } else {
      _error = result.error?.toString();
      notifyListeners();
      return false;
    }
  }

  // ============ Receipt Operations ============

  /// Upload receipt for an expense (supports both File and Uint8List)
  Future<ReceiptDTO?> uploadReceipt({
    required String expenseId,
    required dynamic file, // File on mobile, Uint8List on web
    String? fileName,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final result = await _receiptService.uploadReceipt(
      expenseId: expenseId,
      file: file,
      fileName: fileName,
    );

    _isSubmitting = false;
    if (result.isSuccess) {
      // Optimistic update: immediately add receipt to UI so flag disappears right away
      if (_selectedExpense != null && _selectedExpense!.id == expenseId && result.data != null) {
        final currentReceipts = List<ReceiptDTO>.from(_selectedExpense!.receipts ?? []);
        currentReceipts.add(result.data!);
        _selectedExpense = ExpenseDTO(
          id: _selectedExpense!.id,
          organizationId: _selectedExpense!.organizationId,
          entityId: _selectedExpense!.entityId,
          requesterId: _selectedExpense!.requesterId,
          requesterName: _selectedExpense!.requesterName,
          originalAmount: _selectedExpense!.originalAmount,
          originalCurrency: _selectedExpense!.originalCurrency,
          baseAmount: _selectedExpense!.baseAmount,
          baseCurrency: _selectedExpense!.baseCurrency,
          exchangeRate: _selectedExpense!.exchangeRate,
          categoryId: _selectedExpense!.categoryId,
          categoryName: _selectedExpense!.categoryName,
          categoryCode: _selectedExpense!.categoryCode,
          categoryIcon: _selectedExpense!.categoryIcon,
          categoryFields: _selectedExpense!.categoryFields,
          departmentId: _selectedExpense!.departmentId,
          departmentName: _selectedExpense!.departmentName,
          costCenterId: _selectedExpense!.costCenterId,
          costCenterName: _selectedExpense!.costCenterName,
          expenseType: _selectedExpense!.expenseType,
          expenseDate: _selectedExpense!.expenseDate,
          status: _selectedExpense!.status,
          statusName: _selectedExpense!.statusName,
          statusReason: _selectedExpense!.statusReason,
          receiptStatus: _selectedExpense!.receiptStatus,
          receiptStatusName: _selectedExpense!.receiptStatusName,
          receiptRequired: _selectedExpense!.receiptRequired,
          receiptDueDate: _selectedExpense!.receiptDueDate,
          policyStatus: _selectedExpense!.policyStatus,
          policyStatusName: _selectedExpense!.policyStatusName,
          policyFlags: _selectedExpense!.policyFlags,
          workflowRunId: _selectedExpense!.workflowRunId,
          submittedAt: _selectedExpense!.submittedAt,
          approvedAt: _selectedExpense!.approvedAt,
          completedAt: _selectedExpense!.completedAt,
          requiresEmployeeRepayment: _selectedExpense!.requiresEmployeeRepayment,
          repaymentAmount: _selectedExpense!.repaymentAmount,
          repaymentStatus: _selectedExpense!.repaymentStatus,
          description: _selectedExpense!.description,
          vendorId: _selectedExpense!.vendorId,
          vendorName: _selectedExpense!.vendorName,
          metadata: _selectedExpense!.metadata,
          createdAt: _selectedExpense!.createdAt,
          updatedAt: _selectedExpense!.updatedAt,
          createdBy: _selectedExpense!.createdBy,
          receipts: currentReceipts,
        );
        notifyListeners();
      }
      // Then refresh from server to confirm
      await getExpense(expenseId);
      notifyListeners();
      return result.data;
    } else {
      _error = result.error?.toString();
      notifyListeners();
      return null;
    }
  }

  /// Download receipt file
  Future<ReceiptDownload?> downloadReceipt(String receiptId) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final result = await _receiptService.downloadReceipt(receiptId);

    _isSubmitting = false;
    if (result.isSuccess) {
      notifyListeners();
      return result.data;
    } else {
      _error = result.error?.toString();
      notifyListeners();
      return null;
    }
  }

  /// List all receipts for an expense
  Future<List<ReceiptDTO>> listReceipts(String expenseId) async {
    final result = await _receiptService.listReceipts(expenseId);

    if (result.isSuccess) {
      return result.data ?? [];
    } else {
      _error = result.error?.toString();
      notifyListeners();
      return [];
    }
  }

  /// Process OCR for a receipt
  ///
  /// Triggers Gemini Vision API to extract data from the receipt image.
  /// Returns the receipt with OCR data populated.
  Future<ReceiptDTO?> processReceiptOCR(String receiptId) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    print('DEBUG: Provider calling processOCR for receipt $receiptId');
    final result = await _receiptService.processOCR(receiptId);

    _isSubmitting = false;
    if (result.isSuccess) {
      print('DEBUG: OCR processed successfully');
      print('DEBUG: OCR Data: ${result.data?.ocrData}');
      notifyListeners();
      return result.data;
    } else {
      _error = result.error?.toString();
      print('ERROR: OCR processing failed: $_error');
      notifyListeners();
      return null;
    }
  }

  /// Get receipt by ID
  ///
  /// Fetches a specific receipt with its OCR data.
  Future<ReceiptDTO?> getReceipt(String receiptId) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final result = await _receiptService.getReceipt(receiptId);

    _isSubmitting = false;
    if (result.isSuccess) {
      notifyListeners();
      return result.data;
    } else {
      _error = result.error?.toString();
      notifyListeners();
      return null;
    }
  }

  /// Delete a receipt
  Future<bool> deleteReceipt(String receiptId, String expenseId) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final result = await _receiptService.deleteReceipt(receiptId);

    _isSubmitting = false;
    if (result.isSuccess) {
      // Refresh expense to get updated receipts list
      await getExpense(expenseId);
      notifyListeners();
      return true;
    } else {
      _error = result.error?.toString();
      notifyListeners();
      return false;
    }
  }

  /// Verify receipt (for approvers/finance)
  Future<ReceiptDTO?> verifyReceipt(String receiptId, String expenseId) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final result = await _receiptService.verifyReceipt(receiptId);

    _isSubmitting = false;
    if (result.isSuccess) {
      // Refresh expense to get updated receipt status
      await getExpense(expenseId);
      notifyListeners();
      return result.data;
    } else {
      _error = result.error?.toString();
      notifyListeners();
      return null;
    }
  }

  // ============ Approval Operations ============

  /// Fetch approval inbox
  Future<void> fetchApprovalInbox({
    int page = 1,
    int pageSize = 20,
    String? status,
    String? decision,
    bool refresh = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _approvalFilters = ApprovalInboxParams(
      page: page,
      pageSize: pageSize,
      status: status,
      decision: decision,
    );

    final result = await _approvalService.getInbox(_approvalFilters);

    if (result.isSuccess) {
      if (refresh || page == 1) {
        _approvalTasks = result.data!.data;
      } else {
        _approvalTasks.addAll(result.data!.data);
      }
      _approvalPagination = result.data!.pagination;
    } else {
      _error = result.error?.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch approval task for a specific expense (by targetId)
  /// Used in budget history to check if a history item has a pending approval
  Future<ApprovalTaskDTO?> fetchApprovalTaskForExpense(String expenseId) async {
    final result = await _approvalService.getInbox(
      ApprovalInboxParams(targetId: expenseId, pageSize: 5),
    );
    if (result.isSuccess && result.data!.data.isNotEmpty) {
      return result.data!.data.first;
    }
    return null;
  }

  /// Fetch inbox summary
  Future<void> fetchInboxSummary() async {
    final result = await _approvalService.getInboxSummary();
    if (result.isSuccess) {
      _inboxSummary = result.data;
      notifyListeners();
    }
  }

  /// Approve task
  Future<bool> approveTask(String taskId, {String? comment}) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final result = await _approvalService.approve(taskId, comment: comment);

    _isSubmitting = false;
    if (result.isSuccess) {
      // Remove from local list or update status
      _approvalTasks.removeWhere((t) => t.id == taskId);
      await fetchInboxSummary();
      notifyListeners();
      return true;
    } else {
      _error = result.error?.toString();
      notifyListeners();
      return false;
    }
  }

  /// Reject task
  Future<bool> rejectTask(String taskId, {required String comment}) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final result = await _approvalService.reject(taskId, comment: comment);

    _isSubmitting = false;
    if (result.isSuccess) {
      _approvalTasks.removeWhere((t) => t.id == taskId);
      await fetchInboxSummary();
      notifyListeners();
      return true;
    } else {
      _error = result.error?.toString();
      notifyListeners();
      return false;
    }
  }

  /// Return task for revision
  Future<bool> returnTask(String taskId, {required String comment}) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final result =
        await _approvalService.returnForRevision(taskId, comment: comment);

    _isSubmitting = false;
    if (result.isSuccess) {
      _approvalTasks.removeWhere((t) => t.id == taskId);
      await fetchInboxSummary();
      notifyListeners();
      return true;
    } else {
      _error = result.error?.toString();
      notifyListeners();
      return false;
    }
  }

  // ============ Bulk Selection Methods ============

  /// Toggle selection mode
  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) {
      _selectedTaskIds.clear();
    }
    notifyListeners();
  }

  /// Enable selection mode
  void enableSelectionMode() {
    _isSelectionMode = true;
    notifyListeners();
  }

  /// Exit selection mode and clear selections
  void exitSelectionMode() {
    _isSelectionMode = false;
    _selectedTaskIds.clear();
    notifyListeners();
  }

  /// Toggle task selection
  void toggleTaskSelection(String taskId) {
    if (_selectedTaskIds.contains(taskId)) {
      _selectedTaskIds.remove(taskId);
    } else {
      _selectedTaskIds.add(taskId);
    }
    notifyListeners();
  }

  /// Select all pending tasks
  void selectAllTasks() {
    for (final task in _approvalTasks) {
      _selectedTaskIds.add(task.id);
    }
    notifyListeners();
  }

  /// Clear all selections
  void clearTaskSelections() {
    _selectedTaskIds.clear();
    notifyListeners();
  }

  /// Check if a task is selected
  bool isTaskSelected(String taskId) {
    return _selectedTaskIds.contains(taskId);
  }

  // ============ Bulk Approval Operations ============

  /// Bulk approve selected tasks
  Future<BulkApprovalResult> bulkApproveTasks({String? comment}) async {
    if (_selectedTaskIds.isEmpty) {
      return BulkApprovalResult(
        processed: 0,
        failed: 0,
        total: 0,
        decision: 'approved',
        message: 'No tasks selected',
      );
    }

    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final taskIds = _selectedTaskIds.toList();
    final result = await _approvalService.bulkApprove(taskIds, comment: comment);

    _isSubmitting = false;
    if (result.isSuccess) {
      // Remove approved tasks from local list
      _approvalTasks.removeWhere((t) => taskIds.contains(t.id));
      _selectedTaskIds.clear();
      _isSelectionMode = false;
      await fetchInboxSummary();
      notifyListeners();
      return BulkApprovalResult(
        processed: taskIds.length,
        failed: 0,
        total: taskIds.length,
        decision: 'approved',
        message: 'Successfully approved ${taskIds.length} tasks',
      );
    } else {
      _error = result.error?.toString();
      notifyListeners();
      return BulkApprovalResult(
        processed: 0,
        failed: taskIds.length,
        total: taskIds.length,
        decision: 'approved',
        message: result.error?.toString() ?? 'Failed to approve tasks',
      );
    }
  }

  /// Bulk reject selected tasks
  Future<BulkApprovalResult> bulkRejectTasks({required String comment}) async {
    if (_selectedTaskIds.isEmpty) {
      return BulkApprovalResult(
        processed: 0,
        failed: 0,
        total: 0,
        decision: 'rejected',
        message: 'No tasks selected',
      );
    }

    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final taskIds = _selectedTaskIds.toList();
    final result = await _approvalService.bulkReject(taskIds, comment: comment);

    _isSubmitting = false;
    if (result.isSuccess) {
      // Remove rejected tasks from local list
      _approvalTasks.removeWhere((t) => taskIds.contains(t.id));
      _selectedTaskIds.clear();
      _isSelectionMode = false;
      await fetchInboxSummary();
      notifyListeners();
      return BulkApprovalResult(
        processed: taskIds.length,
        failed: 0,
        total: taskIds.length,
        decision: 'rejected',
        message: 'Successfully rejected ${taskIds.length} tasks',
      );
    } else {
      _error = result.error?.toString();
      notifyListeners();
      return BulkApprovalResult(
        processed: 0,
        failed: taskIds.length,
        total: taskIds.length,
        decision: 'rejected',
        message: result.error?.toString() ?? 'Failed to reject tasks',
      );
    }
  }

  /// Bulk return selected tasks for revision
  Future<BulkApprovalResult> bulkReturnTasks({required String comment}) async {
    if (_selectedTaskIds.isEmpty) {
      return BulkApprovalResult(
        processed: 0,
        failed: 0,
        total: 0,
        decision: 'returned',
        message: 'No tasks selected',
      );
    }

    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final taskIds = _selectedTaskIds.toList();
    final result = await _approvalService.bulkReturn(taskIds, comment: comment);

    _isSubmitting = false;
    if (result.isSuccess) {
      // Remove returned tasks from local list
      _approvalTasks.removeWhere((t) => taskIds.contains(t.id));
      _selectedTaskIds.clear();
      _isSelectionMode = false;
      await fetchInboxSummary();
      notifyListeners();
      return BulkApprovalResult(
        processed: taskIds.length,
        failed: 0,
        total: taskIds.length,
        decision: 'returned',
        message: 'Successfully returned ${taskIds.length} tasks',
      );
    } else {
      _error = result.error?.toString();
      notifyListeners();
      return BulkApprovalResult(
        processed: 0,
        failed: taskIds.length,
        total: taskIds.length,
        decision: 'returned',
        message: result.error?.toString() ?? 'Failed to return tasks',
      );
    }
  }

  // ============ Audit Log / Activity History ============

  List<AuditLogDTO> _auditLogs = [];
  PaginationMeta? _auditLogPagination;
  bool _isLoadingAuditLog = false;

  List<AuditLogDTO> get auditLogs => List.unmodifiable(_auditLogs);
  PaginationMeta? get auditLogPagination => _auditLogPagination;
  bool get isLoadingAuditLog => _isLoadingAuditLog;

  // Keep old getters for compatibility
  List<AuditLogDTO> get approvalHistory => _auditLogs;
  PaginationMeta? get historyPagination => _auditLogPagination;
  bool get isLoadingHistory => _isLoadingAuditLog;

  /// Fetch audit log / activity history (for Team Activity screen)
  Future<void> fetchAuditLog({
    int page = 1,
    String? action,
    String? targetType,
    bool append = false,
  }) async {
    if (_isLoadingAuditLog) return;

    _isLoadingAuditLog = true;
    if (!append) {
      _auditLogs = [];
    }
    notifyListeners();

    // Determine actorId filter: only filter for non-admin users
    String? actorIdFilter;
    if (_currentUserProfile != null && !_currentUserProfile!.isAdmin) {
      actorIdFilter = _currentUserId;
    }

    final result = await _approvalService.getAuditLog(
      page: page,
      action: action,
      targetType: targetType ?? 'expense', // Default to expense activities
      actorId: actorIdFilter, // Filter by current user for non-admins
    );

    _isLoadingAuditLog = false;
    if (result.isSuccess) {
      final logs = result.data!.data;

      // Enrich audit logs with expense details
      await _enrichAuditLogsWithExpenseDetails(logs);

      if (append) {
        _auditLogs.addAll(logs);
      } else {
        _auditLogs = logs;
      }
      _auditLogPagination = result.data!.pagination;
    } else {
      _error = result.error?.toString();
    }
    notifyListeners();
  }

  /// Enrich audit logs with expense details (amount, merchant, etc.)
  Future<void> _enrichAuditLogsWithExpenseDetails(List<AuditLogDTO> logs) async {
    // Get unique expense IDs
    final expenseIds = logs
        .where((log) => log.targetType == 'expense' && log.targetId.isNotEmpty)
        .map((log) => log.targetId)
        .toSet()
        .toList();

    if (expenseIds.isEmpty) return;

    // Fetch expense details in parallel (max 5 at a time to avoid overwhelming the server)
    final Map<String, ExpenseDTO> expenseCache = {};
    final Set<String> failedIds = {}; // Track IDs that failed (403, etc.)

    for (var i = 0; i < expenseIds.length; i += 5) {
      final batch = expenseIds.skip(i).take(5).toList();
      final futures = batch.map((id) async {
        try {
          final result = await _expenseService.getExpense(id);
          if (result.isSuccess && result.data != null) {
            return MapEntry(id, result.data!);
          } else {
            // API returned error (403, 404, etc.)
            failedIds.add(id);
          }
        } catch (e) {
          // Exception during fetch (403, 404, etc.)
          failedIds.add(id);
          print('Could not fetch expense $id: $e');
        }
        return null;
      });

      final results = await Future.wait(futures);
      for (final entry in results) {
        if (entry != null) {
          expenseCache[entry.key] = entry.value;
        }
      }
    }

    // Update audit logs with expense details or mark as no permission
    for (final log in logs) {
      if (log.targetType == 'expense') {
        if (expenseCache.containsKey(log.targetId)) {
          final expense = expenseCache[log.targetId]!;
          log.enrichWithExpense(expense);
        } else if (failedIds.contains(log.targetId)) {
          // Mark as no permission if fetch failed
          log.markNoPermission();
        }
      }
    }
  }

  /// Alias for backward compatibility
  Future<void> fetchApprovalHistory({int page = 1, String? action, bool append = false}) async {
    await fetchAuditLog(page: page, action: action, append: append);
  }

  // ============ Reference Data ============

  /// Fetch all reference data
  Future<void> fetchReferenceData() async {
    await Future.wait([
      _fetchCategories(),
      _fetchDepartments(),
      _fetchVendors(),
      _fetchBudgets(),
      _fetchCostCenters(),
    ]);
    notifyListeners();
  }

  Future<void> _fetchCategories() async {
    final result = await _categoryService.listCategories();
    if (result.isSuccess) {
      _categories = result.data!;
      print('Categories loaded: ${_categories.length}');
    } else {
      print('Failed to load categories: ${result.error}');
    }
  }

  Future<void> _fetchDepartments() async {
    final result = await _categoryService.listDepartments();
    if (result.isSuccess) {
      _departments = result.data!;
    }
  }

  Future<void> _fetchVendors() async {
    final result = await _categoryService.listVendors();
    if (result.isSuccess) {
      _vendors = result.data!;
    }
  }

  // Budget utilization cache
  final Map<String, BudgetUtilizationDTO> _budgetUtilizationCache = {};

  /// Get cached utilization for a budget
  BudgetUtilizationDTO? getBudgetUtilization(String budgetId) => _budgetUtilizationCache[budgetId];

  Future<void> _fetchBudgets() async {
    final result = await _budgetService.listBudgets();
    if (result.isSuccess) {
      _budgets = result.data!.budgets;

      // Fetch utilization for each budget
      await _fetchBudgetUtilizations();
    }
  }

  /// Fetch utilization for all budgets
  Future<void> _fetchBudgetUtilizations() async {
    for (final budget in _budgets) {
      final result = await _budgetService.getUtilization(budget.id);
      if (result.isSuccess && result.data != null) {
        _budgetUtilizationCache[budget.id] = result.data!;
      }
    }
  }

  // ============ Budget Analytics Operations ============

  /// Fetch budget utilization details
  Future<BudgetUtilizationDTO?> fetchBudgetUtilization(String budgetId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _budgetService.getUtilization(budgetId);

    _isLoading = false;
    if (result.isSuccess) {
      _selectedBudgetUtilization = result.data;
      notifyListeners();
      return result.data;
    } else {
      _error = result.error?.toString();
      notifyListeners();
      return null;
    }
  }

  /// Fetch budget trend data
  Future<BudgetTrendDTO?> fetchBudgetTrend(String budgetId, {int? periods}) async {
    _isLoading = true;
    notifyListeners();

    final result = await _budgetService.getTrend(budgetId, periods: periods);

    _isLoading = false;
    if (result.isSuccess) {
      _selectedBudgetTrend = result.data;
      notifyListeners();
      return result.data;
    } else {
      _error = result.error?.toString();
      notifyListeners();
      return null;
    }
  }

  /// Fetch budget history
  Future<BudgetHistoryDTO?> fetchBudgetHistory(
    String budgetId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _budgetService.getHistory(
      budgetId,
      page: page,
      pageSize: pageSize,
    );

    _isLoading = false;
    if (result.isSuccess) {
      _selectedBudgetHistory = result.data;
      notifyListeners();
      return result.data;
    } else {
      _error = result.error?.toString();
      notifyListeners();
      return null;
    }
  }

  /// Fetch active budget period
  Future<BudgetPeriodDTO?> fetchBudgetPeriod(String budgetId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _budgetService.getActivePeriod(budgetId);

    _isLoading = false;
    if (result.isSuccess) {
      _selectedBudgetPeriod = result.data;
      notifyListeners();
      return result.data;
    } else {
      _error = result.error?.toString();
      notifyListeners();
      return null;
    }
  }

  /// Check budget availability for an expense
  Future<BudgetCheckResponse?> checkBudgetAvailability({
    required String budgetId,
    required double amount,
    String currency = 'IDR',
    String expenseType = 'reimbursement',
  }) async {
    final result = await _budgetService.checkBudget(
      budgetId: budgetId,
      expenseAmount: amount,
      expenseCurrency: currency,
      expenseType: expenseType,
    );

    if (result.isSuccess) {
      return result.data;
    } else {
      _error = result.error?.toString();
      notifyListeners();
      return null;
    }
  }

  /// Match budget for expense criteria
  Future<BudgetMatchResponse?> matchBudgetForExpense({
    String? departmentId,
    String? categoryId,
    String? costCenterId,
  }) async {
    final result = await _budgetService.matchBudget(
      departmentId: departmentId,
      categoryId: categoryId,
      costCenterId: costCenterId,
    );

    if (result.isSuccess) {
      return result.data;
    }
    return null;
  }


  /// Fetch all budget analytics data for a budget
  Future<void> fetchBudgetAnalytics(String budgetId) async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      _budgetService.getUtilization(budgetId).then((result) {
        if (result.isSuccess) _selectedBudgetUtilization = result.data;
      }),
      _budgetService.getTrend(budgetId).then((result) {
        if (result.isSuccess) _selectedBudgetTrend = result.data;
      }),
      _budgetService.getHistory(budgetId).then((result) {
        if (result.isSuccess) _selectedBudgetHistory = result.data;
      }),
      _budgetService.getActivePeriod(budgetId).then((result) {
        if (result.isSuccess) _selectedBudgetPeriod = result.data;
      }),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  /// Clear budget analytics state
  void clearBudgetAnalytics() {
    _selectedBudgetUtilization = null;
    _selectedBudgetTrend = null;
    _selectedBudgetHistory = null;
    _selectedBudgetPeriod = null;
    notifyListeners();
  }

  Future<void> _fetchCostCenters() async {
    final result = await _categoryService.listCostCenters();
    if (result.isSuccess) {
      _costCenters = result.data!;
    }
  }

  // ============ Selection Methods ============

  void setSelectedExpense(ExpenseDTO? expense) {
    _selectedExpense = expense;
    _latestApprovalComment = null;
    notifyListeners();
  }

  void setSelectedApprovalTask(ApprovalTaskDTO? task) {
    _selectedApprovalTask = task;
    _approvalReceipts = [];
    // Clear stale selectedExpense so the detail screen doesn't show cached data
    // from a previous navigation. The detail screen will re-populate it.
    _selectedExpense = task?.expense;
    notifyListeners();
  }

  /// Fetch receipts for an expense being reviewed by an approver.
  /// Uses GET /api/v1/expenses/{expenseId}/receipts directly.
  Future<void> fetchReceiptsForApprovalTask(String expenseId) async {
    final receipts = await listReceipts(expenseId);
    _approvalReceipts = receipts;
    notifyListeners();
  }

  /// Fetch the latest reject/return comment for an expense from approval history.
  /// Populates [latestApprovalComment] so the UI can display the approver's reason.
  Future<void> fetchLatestApprovalComment(String expenseId) async {
    final result = await _approvalService.getHistory(
      targetType: 'expense',
      targetId: expenseId,
    );
    if (!result.isSuccess) return;

    final history = result.data!.data;
    // Find the most recent rejected or returned entry that has a comment
    final relevant = history.where((h) {
      final action = h.action.toLowerCase();
      return (action == 'rejected' || action == 'returned' ||
              action == 'reject' || action == 'return') &&
          h.comment != null &&
          h.comment!.isNotEmpty;
    }).toList();

    if (relevant.isNotEmpty) {
      _latestApprovalComment = relevant.first.comment;
      notifyListeners();
    }
  }

  /// Fetch a single approval task by its ID using the approver-safe endpoint.
  /// Uses GET /api/v1/approvals/{id} instead of GET /api/v1/expenses/{id}
  /// to avoid 403 for manager/approver roles.
  Future<void> fetchApprovalTaskDetail(String taskId) async {
    final result = await _approvalService.getTask(taskId);
    if (result.isSuccess) {
      final task = result.data!;
      _selectedApprovalTask = task;
      // If the API embedded the full expense in the task response, use it
      if (task.expense != null) {
        _selectedExpense = task.expense;
      }
      notifyListeners();
    }
  }

  // ============ Attachment Methods ============

  void addPendingAttachment(dynamic file) {
    // Can accept File, Uint8List, XFile, etc.
    _pendingAttachments.add(file);
    notifyListeners();
  }

  void removePendingAttachment(int index) {
    if (index >= 0 && index < _pendingAttachments.length) {
      _pendingAttachments.removeAt(index);
      notifyListeners();
    }
  }

  void clearPendingAttachments() {
    _pendingAttachments.clear();
    notifyListeners();
  }

  // ============ OCR Processing Methods ============

  /// Set pending receipt image for preview and OCR processing
  Future<void> setPendingReceiptImage(dynamic image) async {
    _pendingReceiptImage = image;
    _ocrState = OCRProcessingState.idle;
    _ocrResult = null;
    _ocrError = null;

    // Read bytes for preview
    try {
      if (image is File) {
        _pendingReceiptBytes = await image.readAsBytes();
      } else if (image is Uint8List) {
        _pendingReceiptBytes = image;
      } else if (image.runtimeType.toString().contains('XFile')) {
        // XFile from image_picker
        final xFile = image as dynamic;
        _pendingReceiptBytes = await xFile.readAsBytes() as Uint8List;
      }
    } catch (e) {
      print('ERROR: Failed to read receipt bytes: $e');
    }

    notifyListeners();
  }

  /// Clear all OCR state (including multi-scan items)
  void clearOCRState() {
    _ocrState = OCRProcessingState.idle;
    _pendingReceiptImage = null;
    _pendingReceiptBytes = null;
    _ocrResult = null;
    _tempDraftExpenseId = null;
    _ocrError = null;
    _scanItems = [];
    notifyListeners();
  }

  /// Process receipt with OCR: Create draft → Upload → OCR → Return result
  ///
  /// This method handles the complete flow:
  /// 1. Create a minimal draft expense
  /// 2. Upload the receipt to that expense
  /// 3. Trigger OCR processing
  /// 4. Return the OCR result for auto-fill
  Future<ReceiptDTO?> processReceiptWithOCR({
    required String categoryId,
    String? departmentId,
  }) async {
    if (_pendingReceiptImage == null && _pendingReceiptBytes == null) {
      _ocrError = 'No receipt image to process';
      notifyListeners();
      return null;
    }

    try {
      // Step 1: Create draft expense
      _ocrState = OCRProcessingState.creatingDraft;
      _ocrError = null;
      notifyListeners();

      print('DEBUG OCR: Creating draft expense...');
      final draftExpense = await createExpense(
        amount: 0, // Will be filled by OCR
        categoryId: categoryId,
        expenseDate: DateTime.now(),
        description: 'Receipt scan - pending OCR',
        expenseType: 'reimbursement',
        departmentId: departmentId,
        submitForApproval: false,
      );

      if (draftExpense == null) {
        throw Exception(_error ?? 'Failed to create draft expense');
      }

      _tempDraftExpenseId = draftExpense.id;
      print('DEBUG OCR: Draft expense created: ${draftExpense.id}');

      // Step 2: Upload receipt
      _ocrState = OCRProcessingState.uploading;
      notifyListeners();

      print('DEBUG OCR: Uploading receipt...');

      // Prepare file data
      dynamic fileData;
      String fileName;

      if (_pendingReceiptImage is File) {
        fileData = _pendingReceiptImage;
        fileName = (_pendingReceiptImage as File).path.split('/').last.split('\\').last;
      } else if (_pendingReceiptBytes != null) {
        fileData = _pendingReceiptBytes;
        fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
      } else if (_pendingReceiptImage.runtimeType.toString().contains('XFile')) {
        final xFile = _pendingReceiptImage as dynamic;
        fileData = await xFile.readAsBytes();
        fileName = xFile.name as String;
      } else {
        throw Exception('Unsupported file type');
      }

      final uploadResult = await uploadReceipt(
        expenseId: draftExpense.id,
        file: fileData,
        fileName: fileName,
      );

      if (uploadResult == null) {
        throw Exception(_error ?? 'Failed to upload receipt');
      }

      print('DEBUG OCR: Receipt uploaded: ${uploadResult.id}');

      // Step 3: Trigger OCR
      _ocrState = OCRProcessingState.processingOCR;
      notifyListeners();

      print('DEBUG OCR: Processing OCR...');
      final ocrResult = await processReceiptOCR(uploadResult.id);

      if (ocrResult == null) {
        throw Exception(_error ?? 'OCR processing failed');
      }

      print('DEBUG OCR: OCR completed!');
      print('DEBUG OCR: Merchant: ${ocrResult.ocrData?['merchantName']}');
      print('DEBUG OCR: Amount: ${ocrResult.ocrData?['totalAmount']}');
      print('DEBUG OCR: Date: ${ocrResult.ocrData?['transactionDate']}');

      // Step 4: Success!
      _ocrState = OCRProcessingState.completed;
      _ocrResult = ocrResult;
      notifyListeners();

      return ocrResult;
    } catch (e) {
      print('ERROR OCR: $e');
      _ocrState = OCRProcessingState.failed;
      _ocrError = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Retry OCR processing after failure
  Future<ReceiptDTO?> retryOCR({
    required String categoryId,
    String? departmentId,
  }) async {
    // If we have a temp draft, delete it first
    if (_tempDraftExpenseId != null) {
      try {
        await deleteExpense(_tempDraftExpenseId!);
      } catch (e) {
        print('WARNING: Failed to delete temp draft: $e');
      }
      _tempDraftExpenseId = null;
    }

    // Reset state and retry
    _ocrState = OCRProcessingState.idle;
    _ocrResult = null;
    _ocrError = null;
    notifyListeners();

    return processReceiptWithOCR(
      categoryId: categoryId,
      departmentId: departmentId,
    );
  }

  /// Multi-file scan: create ONE shared draft, upload+OCR each file sequentially.
  /// Sets _ocrResult and _pendingReceiptBytes to first successful result for backward compat.
  Future<void> processScanItems({
    required List<dynamic> files, // List of XFile
    required String categoryId,
    String? departmentId,
  }) async {
    if (files.isEmpty) return;

    // Initialize scan items: read bytes from each XFile
    _scanItems = [];
    for (final file in files) {
      final bytes = await file.readAsBytes() as Uint8List;
      final name = file.name as String;
      _scanItems.add(ScannedReceiptItem(bytes: bytes, fileName: name));
    }

    // Backward compat: set first item bytes for preview
    _pendingReceiptBytes = _scanItems.first.bytes;
    _ocrState = OCRProcessingState.creatingDraft;
    _ocrError = null;
    _ocrResult = null;
    notifyListeners();

    try {
      // Step 1: Create ONE shared draft expense
      final draftExpense = await createExpense(
        amount: 0,
        categoryId: categoryId,
        expenseDate: DateTime.now(),
        description: 'Receipt scan - pending OCR',
        expenseType: 'reimbursement',
        departmentId: departmentId,
        submitForApproval: false,
      );
      if (draftExpense == null) throw Exception(_error ?? 'Failed to create draft expense');
      _tempDraftExpenseId = draftExpense.id;

      // Step 2: Upload + OCR each item sequentially
      ReceiptDTO? firstSuccess;
      for (int i = 0; i < _scanItems.length; i++) {
        final item = _scanItems[i];
        item.ocrState = OCRItemState.uploading;
        notifyListeners();

        final uploadResult = await uploadReceipt(
          expenseId: draftExpense.id,
          file: item.bytes,
          fileName: item.fileName,
        );
        if (uploadResult == null) {
          item.ocrState = OCRItemState.failed;
          item.ocrError = _error ?? 'Upload failed';
          notifyListeners();
          continue;
        }
        item.receiptId = uploadResult.id;
        item.ocrState = OCRItemState.processingOCR;
        notifyListeners();

        final ocrResult = await processReceiptOCR(uploadResult.id);
        if (ocrResult != null && ocrResult.ocrData != null) {
          item.ocrState = OCRItemState.completed;
          item.ocrResult = ocrResult;
          firstSuccess ??= ocrResult;
        } else {
          item.ocrState = OCRItemState.failed;
          item.ocrError = 'OCR extraction failed';
        }
        notifyListeners();
      }

      // Step 3: Set global state from first success (backward compat for auto-fill)
      if (firstSuccess != null) {
        _ocrResult = firstSuccess;
        _ocrState = OCRProcessingState.completed;
      } else {
        _ocrState = OCRProcessingState.failed;
        _ocrError = 'OCR failed for all receipts';
      }
      notifyListeners();
    } catch (e) {
      print('ERROR processScanItems: $e');
      _ocrState = OCRProcessingState.failed;
      _ocrError = e.toString();
      notifyListeners();
    }
  }

  /// Get OCR data field with null safety
  dynamic getOCRField(String fieldName) {
    return _ocrResult?.ocrData?[fieldName];
  }

  /// Get parsed amount from OCR
  double? getOCRAmount() {
    final amount = getOCRField('totalAmount');
    if (amount == null) return null;
    if (amount is num) return amount.toDouble();
    if (amount is String) return double.tryParse(amount);
    return null;
  }

  /// Get parsed date from OCR
  DateTime? getOCRDate() {
    final dateStr = getOCRField('transactionDate');
    if (dateStr == null) return null;
    if (dateStr is String) {
      return DateTime.tryParse(dateStr);
    }
    return null;
  }

  /// Get merchant name from OCR
  String? getOCRMerchantName() {
    return getOCRField('merchantName')?.toString();
  }

  /// Get currency from OCR
  String? getOCRCurrency() {
    return getOCRField('currency')?.toString();
  }

  // ============ UI State Methods ============

  void setActiveCardIndex(int index) {
    _activeCardIndex = index;
    notifyListeners();
  }

  void setInstrumentFilter(String filter) {
    _instrumentFilter = filter;
    notifyListeners();
  }

  void setSelectedBudgetCategory(String? category) {
    _selectedBudgetCategory = category;
    notifyListeners();
  }

  void setSelectedCard(CorporateCard? card) {
    _selectedCard = card;
    notifyListeners();
  }

  // ============ Lookup Methods ============

  /// Lookup category by ID
  CategoryDTO? getCategoryById(String? categoryId) {
    if (categoryId == null || categoryId.isEmpty) return null;
    try {
      return _categories.firstWhere((c) => c.id == categoryId);
    } catch (_) {
      return null;
    }
  }

  /// Get category name by ID (with fallback)
  String getCategoryName(String? categoryId) {
    final category = getCategoryById(categoryId);
    return category?.name ?? 'Uncategorized';
  }

  /// Get category icon by ID (with fallback to name-based lookup)
  String getCategoryIcon(String? categoryId) {
    final category = getCategoryById(categoryId);
    if (category != null) {
      // If API has icon, use it
      if (category.icon != null && category.icon!.isNotEmpty) {
        return category.icon!;
      }
      // Otherwise, try to map from category name
      return _mapCategoryNameToIcon(category.name);
    }
    return '📋';
  }

  /// Map category name to emoji icon
  String _mapCategoryNameToIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('transport') || lower.contains('taxi') || lower.contains('fuel') || lower.contains('gas')) {
      return '🚗';
    } else if (lower.contains('meal') || lower.contains('food') || lower.contains('restaurant') || lower.contains('dining')) {
      return '🍽️';
    } else if (lower.contains('travel') || lower.contains('flight') || lower.contains('hotel') || lower.contains('accommodation')) {
      return '✈️';
    } else if (lower.contains('office') || lower.contains('supplies') || lower.contains('stationery')) {
      return '📦';
    } else if (lower.contains('entertainment') || lower.contains('event')) {
      return '🎬';
    } else if (lower.contains('software') || lower.contains('subscription') || lower.contains('license')) {
      return '💻';
    } else if (lower.contains('training') || lower.contains('education') || lower.contains('course')) {
      return '📚';
    } else if (lower.contains('utility') || lower.contains('phone') || lower.contains('internet') || lower.contains('telecom')) {
      return '📱';
    } else if (lower.contains('coffee') || lower.contains('beverage')) {
      return '☕';
    }
    return '📋';
  }

  /// Lookup department by ID
  DepartmentDTO? getDepartmentById(String? departmentId) {
    if (departmentId == null || departmentId.isEmpty) return null;
    try {
      return _departments.firstWhere((d) => d.id == departmentId);
    } catch (_) {
      return null;
    }
  }

  /// Get department name by ID
  String getDepartmentName(String? departmentId) {
    final dept = getDepartmentById(departmentId);
    return dept?.name ?? '';
  }

  /// Lookup cost center by ID
  CostCenterDTO? getCostCenterById(String? costCenterId) {
    if (costCenterId == null || costCenterId.isEmpty) return null;
    try {
      return _costCenters.firstWhere((c) => c.id == costCenterId);
    } catch (_) {
      return null;
    }
  }

  /// Get cost center name by ID
  String getCostCenterName(String? costCenterId) {
    final cc = getCostCenterById(costCenterId);
    return cc?.name ?? '';
  }

  /// Clear all state
  void clearState() {
    _expenses = [];
    _approvalTasks = [];
    _selectedExpense = null;
    _selectedApprovalTask = null;
    _pendingAttachments = [];
    _error = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ============ User Lookup Methods ============

  /// Get user by ID with caching
  Future<UserProfile?> getUserById(String userId) async {
    // Check cache first
    if (_userCache.containsKey(userId)) {
      return _userCache[userId];
    }

    // Fetch from API
    final result = await _authService.getUser(userId);
    if (result.isSuccess && result.data != null) {
      _userCache[userId] = result.data!;
      return result.data;
    }
    return null;
  }

  /// Get user from cache (synchronous, may return null)
  UserProfile? getCachedUser(String userId) {
    return _userCache[userId];
  }

  /// Populate requester info for approval tasks with empty requester names
  Future<void> populateRequesterInfo() async {
    bool hasChanges = false;

    for (final task in _approvalTasks) {
      if (task.requesterName.isEmpty && task.expense?.requesterId != null) {
        final requesterId = task.expense!.requesterId;
        if (requesterId.isNotEmpty && requesterId != '00000000-0000-0000-0000-000000000000') {
          final user = await getUserById(requesterId);
          if (user != null) {
            // Note: We can't modify the task directly since it's immutable
            // The UI will use getCachedUser to get the info
            hasChanges = true;
          }
        }
      }
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  /// Get requester name for an expense (with user lookup fallback)
  String getRequesterName(ExpenseDTO expense) {
    if (expense.submitterName.isNotEmpty && expense.submitterName != 'Unknown') {
      return expense.submitterName;
    }
    // Check cache for requester
    final cachedUser = _userCache[expense.requesterId];
    if (cachedUser != null) {
      return cachedUser.name;
    }
    return expense.merchant.isNotEmpty ? expense.merchant : 'Unknown';
  }

  /// Get requester initials for an expense
  String getRequesterInitials(ExpenseDTO expense) {
    final name = getRequesterName(expense);
    if (name.isEmpty || name == 'Unknown') return '?';

    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  /// Get requester details for an expense
  RequesterDetails getExpenseRequesterDetails(ExpenseDTO expense) {
    final requesterId = expense.requesterId;

    // Try to get from cached user
    if (requesterId.isNotEmpty && requesterId != '00000000-0000-0000-0000-000000000000') {
      final cachedUser = _userCache[requesterId];
      if (cachedUser != null) {
        return RequesterDetails(
          name: cachedUser.name,
          email: cachedUser.email,
          department: cachedUser.departmentName ?? '',
          jobTitle: cachedUser.jobTitle ?? '',
          jobLevel: cachedUser.jobLevelName ?? '',
        );
      }
    }

    // Fallback
    return RequesterDetails(
      name: getRequesterName(expense),
      email: expense.submitterEmail,
      department: expense.departmentName ?? '',
      jobTitle: '',
      jobLevel: '',
    );
  }

  /// Populate requester info for expenses with empty requester names
  Future<void> populateExpenseRequesterInfo() async {
    bool hasChanges = false;

    for (final expense in _expenses) {
      if ((expense.requesterName == null || expense.requesterName!.isEmpty) &&
          expense.requesterId.isNotEmpty &&
          expense.requesterId != '00000000-0000-0000-0000-000000000000') {
        final user = await getUserById(expense.requesterId);
        if (user != null) {
          hasChanges = true;
        }
      }
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  /// Get requester name for an approval task (with user lookup fallback)
  String getTaskRequesterName(ApprovalTaskDTO task) {
    // Try from task directly
    if (task.requesterName.isNotEmpty) {
      return task.requesterName;
    }
    // Try from expense submitterName
    if (task.expense != null && task.expense!.submitterName.isNotEmpty && task.expense!.submitterName != 'Unknown') {
      return task.expense!.submitterName;
    }
    // Try from cached user by requesterId
    final requesterId = task.requesterId;
    if (requesterId.isNotEmpty && requesterId != '00000000-0000-0000-0000-000000000000') {
      final cachedUser = _userCache[requesterId];
      if (cachedUser != null) {
        return cachedUser.name;
      }
    }
    // Fallback to merchant
    if (task.merchant.isNotEmpty && task.merchant != 'Unknown Vendor') {
      return task.merchant;
    }
    return 'Unknown';
  }

  /// Get requester initials for an approval task
  String getTaskRequesterInitials(ApprovalTaskDTO task) {
    final name = getTaskRequesterName(task);
    if (name.isEmpty || name == 'Unknown') return '?';

    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  /// Get requester details for an approval task
  RequesterDetails getTaskRequesterDetails(ApprovalTaskDTO task) {
    final requesterId = task.requesterId;

    // Try to get from cached user
    if (requesterId.isNotEmpty && requesterId != '00000000-0000-0000-0000-000000000000') {
      final cachedUser = _userCache[requesterId];
      if (cachedUser != null) {
        return RequesterDetails(
          name: cachedUser.name,
          email: cachedUser.email,
          department: cachedUser.departmentName ?? '',
          jobTitle: cachedUser.jobTitle ?? '',
          jobLevel: cachedUser.jobLevelName ?? '',
        );
      }
    }

    // Fallback
    return RequesterDetails(
      name: getTaskRequesterName(task),
      email: task.requesterEmail,
      department: '',
      jobTitle: '',
      jobLevel: '',
    );
  }
}

/// Requester details model
class RequesterDetails {
  final String name;
  final String email;
  final String department;
  final String jobTitle;
  final String jobLevel;

  RequesterDetails({
    required this.name,
    required this.email,
    required this.department,
    required this.jobTitle,
    required this.jobLevel,
  });

  String get initials {
    if (name.isEmpty || name == 'Unknown') return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  /// Get subtitle text (department - job title)
  String get subtitle {
    final parts = <String>[];
    if (department.isNotEmpty) parts.add(department);
    if (jobTitle.isNotEmpty) parts.add(jobTitle);
    return parts.isNotEmpty ? parts.join(' • ') : '';
  }
}

/// Bulk approval result model
class BulkApprovalResult {
  final int processed;
  final int failed;
  final int total;
  final String decision;
  final String message;

  BulkApprovalResult({
    required this.processed,
    required this.failed,
    required this.total,
    required this.decision,
    required this.message,
  });

  bool get isSuccess => failed == 0 && processed > 0;
  bool get isPartialSuccess => processed > 0 && failed > 0;
  bool get isFailure => processed == 0;
}
