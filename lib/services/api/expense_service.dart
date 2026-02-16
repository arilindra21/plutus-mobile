import 'dart:io';
import 'package:dio/dio.dart';
import 'dio_client.dart';
import 'api_result.dart';
import '../models/expense_dto.dart';

/// Service for expense CRUD operations
class ExpenseService {
  final Dio _dio = DioClient().dio;

  /// List expenses with pagination and filters
  Future<ApiResult<PaginatedResult<ExpenseDTO>>> listExpenses(
    ExpenseListParams params,
  ) async {
    try {
      final response = await _dio.get(
        '/api/v1/expenses',
        queryParameters: params.toQueryParams(),
      );

      final data = response.data;
      print('Expenses API response keys: ${data.keys.toList()}');

      // API returns 'expenses' key, not 'data'
      final listData = data['expenses'] ?? data['data'];
      print('Expenses listData type: ${listData?.runtimeType}, length: ${listData?.length}');

      final items = (listData as List<dynamic>?)
              ?.map((e) => ExpenseDTO.fromJson(e))
              .toList() ??
          [];

      final pagination = PaginationMeta.fromJson(data['pagination'] ?? {});

      return ApiResult.success(PaginatedResult(
        data: items,
        pagination: pagination,
      ));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Get single expense by ID
  Future<ApiResult<ExpenseDTO>> getExpense(String id) async {
    try {
      final response = await _dio.get('/api/v1/expenses/$id');
      return ApiResult.success(ExpenseDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Create new expense
  Future<ApiResult<ExpenseDTO>> createExpense(CreateExpenseRequest request) async {
    try {
      final response = await _dio.post(
        '/api/v1/expenses',
        data: request.toJson(),
      );
      return ApiResult.success(ExpenseDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Update existing expense
  Future<ApiResult<ExpenseDTO>> updateExpense(
    String id,
    UpdateExpenseRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '/api/v1/expenses/$id',
        data: request.toJson(),
      );
      return ApiResult.success(ExpenseDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Submit expense for approval
  Future<ApiResult<ExpenseDTO>> submitExpense(String id, {String? comment}) async {
    try {
      final response = await _dio.post(
        '/api/v1/expenses/$id/submit',
        data: {
          'comment': comment ?? '',
        },
      );
      return ApiResult.success(ExpenseDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Cancel expense
  Future<ApiResult<ExpenseDTO>> cancelExpense(String id) async {
    try {
      final response = await _dio.post('/api/v1/expenses/$id/cancel');
      return ApiResult.success(ExpenseDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Delete expense (soft delete)
  Future<ApiResult<void>> deleteExpense(String id) async {
    try {
      await _dio.delete('/api/v1/expenses/$id');
      return ApiResult.success(null);
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Upload receipt to expense (supports both web and mobile)
  Future<ApiResult<ReceiptDTO>> uploadReceipt(
    String expenseId,
    List<int> bytes,
    String fileName,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/api/v1/expenses/$expenseId/receipts',
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

  /// List receipts for expense
  Future<ApiResult<List<ReceiptDTO>>> listReceipts(String expenseId) async {
    try {
      final response = await _dio.get('/api/v1/expenses/$expenseId/receipts');
      final items = (response.data['data'] as List<dynamic>?)
              ?.map((e) => ReceiptDTO.fromJson(e))
              .toList() ??
          [];
      return ApiResult.success(items);
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Delete receipt
  Future<ApiResult<void>> deleteReceipt(String receiptId) async {
    try {
      await _dio.delete('/api/v1/receipts/$receiptId');
      return ApiResult.success(null);
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Get recent expenses (last 5)
  Future<ApiResult<List<ExpenseDTO>>> getRecentExpenses() async {
    final result = await listExpenses(ExpenseListParams(
      page: 1,
      pageSize: 5,
      sortBy: 'created_at',
      sortOrder: 'desc',
    ));

    if (result.isSuccess) {
      return ApiResult.success(result.data!.data);
    }
    return ApiResult.failure(result.error!);
  }

  /// Get pending expenses count
  Future<ApiResult<int>> getPendingExpensesCount() async {
    final result = await listExpenses(ExpenseListParams(
      page: 1,
      pageSize: 1,
      statuses: [1, 2, 3], // Pending, Processing, Pending Approval
    ));

    if (result.isSuccess) {
      return ApiResult.success(result.data!.pagination.totalCount);
    }
    return ApiResult.failure(result.error!);
  }
}
