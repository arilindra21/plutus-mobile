import 'dart:io';
import 'package:flutter/material.dart';
import '../services/services.dart';
import '../models/expense.dart';
import '../models/financial_instrument.dart';

/// API-backed Expense Provider - uses real backend API
class ApiExpenseProvider extends ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();
  final ApprovalService _approvalService = ApprovalService();
  final CategoryService _categoryService = CategoryService();
  final AuthService _authService = AuthService();
  final BudgetService _budgetService = BudgetService();

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

  // Bulk selection state
  bool _isSelectionMode = false;
  final Set<String> _selectedTaskIds = {};

  // Form state
  List<File> _pendingAttachments = [];

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

  List<File> get pendingAttachments => List.unmodifiable(_pendingAttachments);

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

  // ============ Expense Operations ============

  // Current user ID for filtering
  String? _currentUserId;
  bool _isManager = false;

  /// Set current user context for expense filtering
  void setUserContext({required String userId, required bool isManager}) {
    _currentUserId = userId;
    _isManager = isManager;
  }

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

  /// Get single expense
  Future<ExpenseDTO?> getExpense(String id) async {
    _isLoading = true;
    notifyListeners();

    final result = await _expenseService.getExpense(id);

    _isLoading = false;
    if (result.isSuccess) {
      _selectedExpense = result.data;
      notifyListeners();
      return result.data;
    } else {
      _error = result.error?.toString();
      notifyListeners();
      return null;
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

  /// Upload receipt (supports both web and mobile)
  Future<bool> uploadReceipt(String expenseId, List<int> bytes, String fileName) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final result = await _expenseService.uploadReceipt(expenseId, bytes, fileName);

    _isSubmitting = false;
    if (result.isSuccess) {
      // Refresh expense to get updated receipts
      await getExpense(expenseId);
      return true;
    } else {
      _error = result.error?.toString();
      notifyListeners();
      return false;
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
  }) async {
    final result = await _budgetService.checkBudget(
      budgetId: budgetId,
      expenseAmount: amount,
      expenseCurrency: currency,
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
    notifyListeners();
  }

  void setSelectedApprovalTask(ApprovalTaskDTO? task) {
    _selectedApprovalTask = task;
    notifyListeners();
  }

  // ============ Attachment Methods ============

  void addPendingAttachment(File file) {
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
