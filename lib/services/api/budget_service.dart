import 'package:dio/dio.dart';
import 'dio_client.dart';
import 'api_result.dart';
import '../models/budget_dto.dart';

/// Service for all Budget API operations
class BudgetService {
  final Dio _dio = DioClient().dio;

  // ============ CRUD Operations ============

  /// List all budgets
  /// GET /api/v1/budgets
  Future<ApiResult<BudgetListResponse>> listBudgets({
    bool? isActive,
    String? departmentId,
    String? categoryId,
    String? costCenterId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/budgets',
        queryParameters: {
          if (isActive != null) 'is_active': isActive,
          if (departmentId != null) 'department_id': departmentId,
          if (categoryId != null) 'category_id': categoryId,
          if (costCenterId != null) 'cost_center_id': costCenterId,
          'page': page,
          'per_page': pageSize,
        },
      );

      return ApiResult.success(BudgetListResponse.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    } catch (e) {
      return ApiResult.failure(ApiError(message: 'Failed to list budgets: $e'));
    }
  }

  /// Get single budget by ID
  /// GET /api/v1/budgets/{id}
  Future<ApiResult<BudgetDetailDTO>> getBudget(String id) async {
    try {
      final response = await _dio.get('/api/v1/budgets/$id');
      return ApiResult.success(BudgetDetailDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    } catch (e) {
      return ApiResult.failure(ApiError(message: 'Failed to get budget: $e'));
    }
  }

  /// Create a new budget
  /// POST /api/v1/budgets
  Future<ApiResult<BudgetDetailDTO>> createBudget(CreateBudgetRequest request) async {
    try {
      final response = await _dio.post(
        '/api/v1/budgets',
        data: request.toJson(),
      );
      return ApiResult.success(BudgetDetailDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    } catch (e) {
      return ApiResult.failure(ApiError(message: 'Failed to create budget: $e'));
    }
  }

  /// Update a budget
  /// PUT /api/v1/budgets/{id}
  Future<ApiResult<BudgetDetailDTO>> updateBudget(String id, UpdateBudgetRequest request) async {
    try {
      final response = await _dio.put(
        '/api/v1/budgets/$id',
        data: request.toJson(),
      );
      return ApiResult.success(BudgetDetailDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    } catch (e) {
      return ApiResult.failure(ApiError(message: 'Failed to update budget: $e'));
    }
  }

  /// Delete a budget (soft delete)
  /// DELETE /api/v1/budgets/{id}
  Future<ApiResult<void>> deleteBudget(String id) async {
    try {
      await _dio.delete('/api/v1/budgets/$id');
      return ApiResult.success(null);
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    } catch (e) {
      return ApiResult.failure(ApiError(message: 'Failed to delete budget: $e'));
    }
  }

  // ============ Budget Operations ============

  /// Match budget to expense criteria
  /// POST /api/v1/budgets/match
  Future<ApiResult<BudgetMatchResponse>> matchBudget({
    String? departmentId,
    String? costCenterId,
    String? categoryId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/budgets/match',
        data: {
          if (departmentId != null) 'departmentId': departmentId,
          if (costCenterId != null) 'costCenterId': costCenterId,
          if (categoryId != null) 'categoryId': categoryId,
        },
      );
      return ApiResult.success(BudgetMatchResponse.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    } catch (e) {
      return ApiResult.failure(ApiError(message: 'Failed to match budget: $e'));
    }
  }

  /// Check budget availability
  /// POST /api/v1/budgets/check
  Future<ApiResult<BudgetCheckResponse>> checkBudget({
    required String budgetId,
    required double expenseAmount,
    String expenseCurrency = 'IDR',
    String expenseType = 'reimbursement',
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/budgets/check',
        data: {
          'budgetId': budgetId,
          'expenseAmount': expenseAmount.toString(),
          'expenseCurrency': expenseCurrency,
          'expenseType': expenseType,
        },
      );
      return ApiResult.success(BudgetCheckResponse.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    } catch (e) {
      return ApiResult.failure(ApiError(message: 'Failed to check budget: $e'));
    }
  }

  /// Reserve budget amount (on expense submit)
  /// POST /api/v1/budgets/reserve
  Future<ApiResult<BudgetReserveResponse>> reserveBudget({
    required String budgetPeriodId,
    required String sourceType,
    required String sourceId,
    required double amount,
    String currency = 'IDR',
    String? requesterId,
    String? departmentId,
    String? categoryId,
    String? description,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/budgets/reserve',
        data: {
          'budgetPeriodId': budgetPeriodId,
          'sourceType': sourceType,
          'sourceId': sourceId,
          'amount': amount.toString(),
          'currency': currency,
          if (requesterId != null) 'requesterId': requesterId,
          if (departmentId != null) 'departmentId': departmentId,
          if (categoryId != null) 'categoryId': categoryId,
          if (description != null) 'description': description,
        },
      );
      return ApiResult.success(BudgetReserveResponse.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    } catch (e) {
      return ApiResult.failure(ApiError(message: 'Failed to reserve budget: $e'));
    }
  }

  /// Commit budget reservation (on approval)
  /// POST /api/v1/budgets/commit
  Future<ApiResult<BudgetCommitResponse>> commitBudget({
    required String budgetPeriodId,
    required String sourceType,
    required String sourceId,
    required double amount,
    String currency = 'IDR',
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/budgets/commit',
        data: {
          'budgetPeriodId': budgetPeriodId,
          'sourceType': sourceType,
          'sourceId': sourceId,
          'amount': amount.toString(),
          'currency': currency,
        },
      );
      return ApiResult.success(BudgetCommitResponse.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    } catch (e) {
      return ApiResult.failure(ApiError(message: 'Failed to commit budget: $e'));
    }
  }

  /// Release budget reservation (on rejection)
  /// POST /api/v1/budgets/release
  Future<ApiResult<BudgetReleaseResponse>> releaseBudget({
    required String budgetPeriodId,
    required String sourceType,
    required String sourceId,
    required double amount,
    String currency = 'IDR',
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/budgets/release',
        data: {
          'budgetPeriodId': budgetPeriodId,
          'sourceType': sourceType,
          'sourceId': sourceId,
          'amount': amount.toString(),
          'currency': currency,
        },
      );
      return ApiResult.success(BudgetReleaseResponse.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    } catch (e) {
      return ApiResult.failure(ApiError(message: 'Failed to release budget: $e'));
    }
  }

  // ============ Budget Analytics ============

  /// Get active budget period
  /// GET /api/v1/budgets/{id}/period
  Future<ApiResult<BudgetPeriodDTO>> getActivePeriod(String budgetId) async {
    try {
      final response = await _dio.get('/api/v1/budgets/$budgetId/period');
      return ApiResult.success(BudgetPeriodDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    } catch (e) {
      return ApiResult.failure(ApiError(message: 'Failed to get active period: $e'));
    }
  }

  /// Get budget utilization details
  /// GET /api/v1/budgets/{id}/utilization
  Future<ApiResult<BudgetUtilizationDTO>> getUtilization(String budgetId) async {
    try {
      final response = await _dio.get('/api/v1/budgets/$budgetId/utilization');
      return ApiResult.success(BudgetUtilizationDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    } catch (e) {
      return ApiResult.failure(ApiError(message: 'Failed to get utilization: $e'));
    }
  }

  /// Get budget trend (historical data)
  /// GET /api/v1/budgets/{id}/trend
  Future<ApiResult<BudgetTrendDTO>> getTrend(String budgetId, {int? periods}) async {
    try {
      final response = await _dio.get(
        '/api/v1/budgets/$budgetId/trend',
        queryParameters: {
          if (periods != null) 'periods': periods,
        },
      );
      return ApiResult.success(BudgetTrendDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    } catch (e) {
      return ApiResult.failure(ApiError(message: 'Failed to get trend: $e'));
    }
  }

  /// Get budget transaction history
  /// GET /api/v1/budgets/{id}/history
  Future<ApiResult<BudgetHistoryDTO>> getHistory(
    String budgetId, {
    int page = 1,
    int pageSize = 20,
    String? operation,
    String? sourceType,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/budgets/$budgetId/history',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          if (operation != null) 'operation': operation,
          if (sourceType != null) 'source_type': sourceType,
        },
      );
      return ApiResult.success(BudgetHistoryDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    } catch (e) {
      return ApiResult.failure(ApiError(message: 'Failed to get history: $e'));
    }
  }

  /// Get budget period status
  /// GET /api/v1/budgets/periods/{periodId}/status
  Future<ApiResult<BudgetPeriodStatusDTO>> getPeriodStatus(String periodId) async {
    try {
      final response = await _dio.get('/api/v1/budgets/periods/$periodId/status');
      return ApiResult.success(BudgetPeriodStatusDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    } catch (e) {
      return ApiResult.failure(ApiError(message: 'Failed to get period status: $e'));
    }
  }
}
