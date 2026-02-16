import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/services.dart';

/// Provider for managing transaction state with API integration
class ApiTransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  // State
  List<TransactionDTO> _transactions = [];
  List<TransactionDTO> _pendingReceiptTransactions = [];
  TransactionSummary? _summary;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  TransactionListParams _currentParams = TransactionListParams();

  // Getters
  List<TransactionDTO> get transactions => _transactions;
  List<TransactionDTO> get pendingReceiptTransactions => _pendingReceiptTransactions;
  TransactionSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMore => _hasMore;
  int get pendingReceiptCount => _pendingReceiptTransactions.length;

  /// Load transactions for the current user
  Future<void> loadTransactions({
    TransactionListParams? params,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _transactions = [];
    }

    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentParams = params ?? TransactionListParams(page: _currentPage);
      final result = await _transactionService.listMyTransactions(_currentParams);

      if (result.isSuccess) {
        if (refresh || _currentPage == 1) {
          _transactions = result.data!.data;
        } else {
          _transactions.addAll(result.data!.data);
        }
        _hasMore = result.data!.pagination.hasNext;
        _currentPage = result.data!.pagination.page;
      } else {
        _error = result.error?.message ?? 'Failed to load transactions';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more transactions (pagination)
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final params = TransactionListParams(
        page: _currentPage + 1,
        pageSize: _currentParams.pageSize,
        status: _currentParams.status,
        receiptStatus: _currentParams.receiptStatus,
        sortBy: _currentParams.sortBy,
        sortOrder: _currentParams.sortOrder,
      );

      final result = await _transactionService.listMyTransactions(params);

      if (result.isSuccess) {
        _transactions.addAll(result.data!.data);
        _hasMore = result.data!.pagination.hasNext;
        _currentPage = result.data!.pagination.page;
      }
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Load transactions that need receipt upload
  Future<void> loadPendingReceiptTransactions({int limit = 10}) async {
    try {
      final result = await _transactionService.getTransactionsNeedingReceipt(
        limit: limit,
      );

      if (result.isSuccess) {
        // Filter to only include transactions that actually need receipts
        // (receiptRequired=true AND receiptStatus=1 pending)
        _pendingReceiptTransactions = result.data!
            .where((t) => t.needsReceipt)
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading pending receipt transactions: $e');
    }
  }

  /// Load transaction summary for dashboard
  Future<void> loadSummary() async {
    try {
      final result = await _transactionService.getTransactionSummary();

      if (result.isSuccess) {
        _summary = result.data;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading transaction summary: $e');
    }
  }

  /// Upload receipt to a transaction
  Future<bool> uploadReceipt(String transactionId, File file) async {
    try {
      final result = await _transactionService.uploadReceiptToTransaction(
        transactionId,
        file,
      );

      if (result.isSuccess) {
        // Update the local transaction status
        final index = _transactions.indexWhere((t) => t.id == transactionId);
        if (index >= 0) {
          // Refresh the transaction list to get updated status
          await loadTransactions(refresh: true);
          await loadPendingReceiptTransactions();
        }
        return true;
      } else {
        _error = result.error?.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Create expense from transaction
  Future<ExpenseDTO?> createExpenseFromTransaction(
    String transactionId,
    CreateExpenseFromTransactionRequest request,
  ) async {
    try {
      final result = await _transactionService.createExpenseFromTransaction(
        transactionId,
        request,
      );

      if (result.isSuccess) {
        // Refresh transactions
        await loadTransactions(refresh: true);
        await loadPendingReceiptTransactions();
        return result.data;
      } else {
        _error = result.error?.message;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Link transaction to existing expense
  Future<bool> linkToExpense(String transactionId, String expenseId) async {
    try {
      final result = await _transactionService.linkExpense(
        transactionId,
        expenseId,
      );

      if (result.isSuccess) {
        await loadTransactions(refresh: true);
        await loadPendingReceiptTransactions();
        return true;
      } else {
        _error = result.error?.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Get transaction by ID from local cache
  TransactionDTO? getTransactionById(String id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Filter transactions by status
  List<TransactionDTO> getTransactionsByReceiptStatus(int status) {
    return _transactions.where((t) => t.receiptStatus == status).toList();
  }

  /// Get transactions needing attention (pending or overdue receipt)
  List<TransactionDTO> get transactionsNeedingAttention {
    return _transactions.where((t) => t.needsReceipt || t.isReceiptOverdue).toList();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _transactions = [];
    _pendingReceiptTransactions = [];
    _summary = null;
    _isLoading = false;
    _error = null;
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }
}
