import 'dart:io';
import 'package:dio/dio.dart';
import 'dio_client.dart';
import 'api_result.dart';
import '../models/transaction_dto.dart';
import '../models/expense_dto.dart';

/// Service for card transaction operations
class TransactionService {
  final Dio _dio = DioClient().dio;

  /// List current user's transactions (Employee view)
  Future<ApiResult<PaginatedResult<TransactionDTO>>> listMyTransactions(
    TransactionListParams params,
  ) async {
    try {
      final response = await _dio.get(
        '/api/v1/me/transactions',
        queryParameters: params.toQueryParams(),
      );

      final data = response.data;
      final listData = data['transactions'] ?? data['data'] ?? [];

      final items = (listData as List<dynamic>)
          .map((e) => TransactionDTO.fromJson(e))
          .toList();

      final pagination = PaginationMeta.fromJson(data['pagination'] ?? {
        'page': params.page,
        'pageSize': params.pageSize,
        'totalCount': items.length,
        'totalPages': 1,
        'hasNext': false,
        'hasPrev': false,
      });

      return ApiResult.success(PaginatedResult(
        data: items,
        pagination: pagination,
      ));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// List all transactions (Admin/Manager view)
  Future<ApiResult<PaginatedResult<TransactionDTO>>> listTransactions(
    TransactionListParams params,
  ) async {
    try {
      final response = await _dio.get(
        '/api/v1/transactions',
        queryParameters: params.toQueryParams(),
      );

      final data = response.data;
      final listData = data['transactions'] ?? data['data'] ?? [];

      final items = (listData as List<dynamic>)
          .map((e) => TransactionDTO.fromJson(e))
          .toList();

      final pagination = PaginationMeta.fromJson(data['pagination'] ?? {});

      return ApiResult.success(PaginatedResult(
        data: items,
        pagination: pagination,
      ));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Get single transaction by ID
  Future<ApiResult<TransactionDTO>> getTransaction(String id) async {
    try {
      final response = await _dio.get('/api/v1/transactions/$id');
      return ApiResult.success(TransactionDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Get transactions that need receipt upload (unmatched)
  Future<ApiResult<PaginatedResult<TransactionDTO>>> getUnmatchedTransactions({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/transactions/unmatched',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
        },
      );

      final data = response.data;
      final listData = data['transactions'] ?? data['data'] ?? [];

      final items = (listData as List<dynamic>)
          .map((e) => TransactionDTO.fromJson(e))
          .toList();

      final pagination = PaginationMeta.fromJson(data['pagination'] ?? {
        'page': page,
        'pageSize': pageSize,
        'totalCount': items.length,
        'totalPages': 1,
        'hasNext': false,
        'hasPrev': false,
      });

      return ApiResult.success(PaginatedResult(
        data: items,
        pagination: pagination,
      ));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Link transaction to an existing expense
  Future<ApiResult<TransactionDTO>> linkExpense(
    String transactionId,
    String expenseId,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v1/transactions/$transactionId/link-expense',
        data: {'expenseId': expenseId},
      );
      return ApiResult.success(TransactionDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Unlink expense from transaction
  Future<ApiResult<TransactionDTO>> unlinkExpense(String transactionId) async {
    try {
      final response = await _dio.delete(
        '/api/v1/transactions/$transactionId/link-expense',
      );
      return ApiResult.success(TransactionDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Create expense from transaction (auto-link)
  Future<ApiResult<ExpenseDTO>> createExpenseFromTransaction(
    String transactionId,
    CreateExpenseFromTransactionRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v1/transactions/$transactionId/expense',
        data: request.toJson(),
      );
      return ApiResult.success(ExpenseDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Upload receipt directly to transaction
  Future<ApiResult<ReceiptDTO>> uploadReceiptToTransaction(
    String transactionId,
    File file,
  ) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/api/v1/transactions/$transactionId/receipts',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      return ApiResult.success(ReceiptDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Get transaction summary for dashboard
  Future<ApiResult<TransactionSummary>> getTransactionSummary() async {
    try {
      // Get pending receipt count
      final pendingResult = await listMyTransactions(
        TransactionListParams(
          page: 1,
          pageSize: 1,
          receiptStatus: 1, // Pending
        ),
      );

      // Get overdue receipt count
      final overdueResult = await listMyTransactions(
        TransactionListParams(
          page: 1,
          pageSize: 1,
          receiptStatus: 4, // Missing/Overdue
        ),
      );

      // Get total transactions this month
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final totalResult = await listMyTransactions(
        TransactionListParams(
          page: 1,
          pageSize: 1,
          dateFrom: startOfMonth,
        ),
      );

      if (pendingResult.isSuccess && overdueResult.isSuccess && totalResult.isSuccess) {
        return ApiResult.success(TransactionSummary(
          totalCount: totalResult.data!.pagination.totalCount,
          pendingReceiptCount: pendingResult.data!.pagination.totalCount,
          overdueReceiptCount: overdueResult.data!.pagination.totalCount,
          totalAmount: 0, // Would need aggregation endpoint
          currency: 'IDR',
        ));
      }

      return ApiResult.failure(ApiError(message: 'Failed to fetch summary'));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Get transactions needing receipt (convenience method)
  Future<ApiResult<List<TransactionDTO>>> getTransactionsNeedingReceipt({
    int limit = 5,
  }) async {
    final result = await listMyTransactions(
      TransactionListParams(
        page: 1,
        pageSize: limit,
        receiptStatus: 1, // Pending receipt
        sortBy: 'transaction_date',
        sortOrder: 'desc',
      ),
    );

    if (result.isSuccess) {
      return ApiResult.success(result.data!.data);
    }
    return ApiResult.failure(result.error!);
  }

  /// Update transaction (add notes, etc.)
  Future<ApiResult<TransactionDTO>> updateTransaction(
    String id,
    UpdateTransactionRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '/api/v1/transactions/$id',
        data: request.toJson(),
      );
      return ApiResult.success(TransactionDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }
}

/// Request to create expense from transaction
class CreateExpenseFromTransactionRequest {
  final String categoryId;
  final String? description;
  final String? costCenterId;
  final String? departmentId;
  final bool submitForApproval;

  CreateExpenseFromTransactionRequest({
    required this.categoryId,
    this.description,
    this.costCenterId,
    this.departmentId,
    this.submitForApproval = false,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'categoryId': categoryId,
    };
    if (description != null) map['description'] = description;
    if (costCenterId != null) map['costCenterId'] = costCenterId;
    if (departmentId != null) map['departmentId'] = departmentId;
    if (submitForApproval) map['submitForApproval'] = submitForApproval;
    return map;
  }
}

/// Request to update transaction
class UpdateTransactionRequest {
  final String? notes;
  final String? categoryId;
  final Map<String, dynamic>? metadata;

  UpdateTransactionRequest({
    this.notes,
    this.categoryId,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (notes != null) map['notes'] = notes;
    if (categoryId != null) map['categoryId'] = categoryId;
    if (metadata != null) map['metadata'] = metadata;
    return map;
  }
}
