import 'package:dio/dio.dart';
import 'dio_client.dart';
import 'api_result.dart';
import '../models/approval_dto.dart';

/// Service for approval workflow operations
class ApprovalService {
  final Dio _dio = DioClient().dio;

  /// Get approval inbox with pagination and filters
  Future<ApiResult<PaginatedResult<ApprovalTaskDTO>>> getInbox(
    ApprovalInboxParams params,
  ) async {
    try {
      final response = await _dio.get(
        '/api/v1/approvals/inbox',
        queryParameters: params.toQueryParams(),
      );

      final data = response.data;
      // API returns 'tasks' key for approval inbox
      final tasksData = data['tasks'] ?? data['data'];
      final items = (tasksData as List<dynamic>?)
              ?.map((e) => ApprovalTaskDTO.fromJson(e))
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

  /// Get approval inbox summary counts
  Future<ApiResult<ApprovalInboxSummary>> getInboxSummary() async {
    try {
      final response = await _dio.get('/api/v1/approvals/inbox/summary');
      return ApiResult.success(ApprovalInboxSummary.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Approve a task
  Future<ApiResult<ApprovalTaskDTO>> approve(
    String taskId, {
    String? comment,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/approvals/$taskId/approve',
        data: ApprovalDecisionRequest(comment: comment).toJson(),
      );
      return ApiResult.success(ApprovalTaskDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Reject a task
  Future<ApiResult<ApprovalTaskDTO>> reject(
    String taskId, {
    required String comment,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/approvals/$taskId/reject',
        data: ApprovalDecisionRequest(comment: comment).toJson(),
      );
      return ApiResult.success(ApprovalTaskDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Return a task for revision
  Future<ApiResult<ApprovalTaskDTO>> returnForRevision(
    String taskId, {
    required String comment,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/approvals/$taskId/return',
        data: ApprovalDecisionRequest(comment: comment).toJson(),
      );
      return ApiResult.success(ApprovalTaskDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Bulk approve multiple tasks
  Future<ApiResult<List<ApprovalTaskDTO>>> bulkApprove(
    List<String> taskIds, {
    String? comment,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/approvals/bulk-approve',
        data: BulkApprovalRequest(taskIds: taskIds, comment: comment).toJson(),
      );

      final items = (response.data['data'] as List<dynamic>?)
              ?.map((e) => ApprovalTaskDTO.fromJson(e))
              .toList() ??
          [];

      return ApiResult.success(items);
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Bulk reject multiple tasks
  Future<ApiResult<List<ApprovalTaskDTO>>> bulkReject(
    List<String> taskIds, {
    required String comment,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/approvals/bulk-reject',
        data: BulkApprovalRequest(taskIds: taskIds, comment: comment).toJson(),
      );

      final items = (response.data['data'] as List<dynamic>?)
              ?.map((e) => ApprovalTaskDTO.fromJson(e))
              .toList() ??
          [];

      return ApiResult.success(items);
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Bulk return multiple tasks for revision
  Future<ApiResult<List<ApprovalTaskDTO>>> bulkReturn(
    List<String> taskIds, {
    required String comment,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/approvals/bulk-return',
        data: BulkApprovalRequest(taskIds: taskIds, comment: comment).toJson(),
      );

      final items = (response.data['data'] as List<dynamic>?)
              ?.map((e) => ApprovalTaskDTO.fromJson(e))
              .toList() ??
          [];

      return ApiResult.success(items);
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Get pending approvals count
  Future<ApiResult<int>> getPendingCount() async {
    final result = await getInboxSummary();
    if (result.isSuccess) {
      return ApiResult.success(result.data!.pendingCount);
    }
    return ApiResult.failure(result.error!);
  }

  /// Get approval history for a specific target (expense, transaction, cash_advance)
  Future<ApiResult<PaginatedResult<ApprovalHistoryDTO>>> getHistory({
    required String targetType,
    required String targetId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/approvals/history',
        queryParameters: {
          'target_type': targetType,
          'target_id': targetId,
        },
      );

      final data = response.data;
      final historyData = data['history'] ?? data['data'] ?? [];
      final items = (historyData as List<dynamic>)
          .map((e) => ApprovalHistoryDTO.fromJson(e))
          .toList();

      return ApiResult.success(PaginatedResult(
        data: items,
        pagination: PaginationMeta(
          page: 1,
          pageSize: items.length,
          totalCount: items.length,
          totalPages: 1,
          hasNext: false,
          hasPrev: false,
        ),
      ));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Get audit log / activity history (for Team Activity screen)
  Future<ApiResult<PaginatedResult<AuditLogDTO>>> getAuditLog({
    int page = 1,
    int pageSize = 20,
    String? action,
    String? targetType,
    String? actorId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      if (action != null) queryParams['action'] = action;
      if (targetType != null) queryParams['target_type'] = targetType;
      if (actorId != null) queryParams['actor_id'] = actorId;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _dio.get(
        '/reports/audit-log',
        queryParameters: queryParams,
      );

      final data = response.data;
      final logsData = data['auditLogs'] ?? data['audit_logs'] ?? data['data'] ?? [];
      final items = (logsData as List<dynamic>)
          .map((e) => AuditLogDTO.fromJson(e))
          .toList();

      final total = data['totalEntries'] ?? data['total_entries'] ?? items.length;
      final totalPagesCalc = (total / pageSize).ceil();
      final pagination = PaginationMeta(
        page: page,
        pageSize: pageSize,
        totalCount: total,
        totalPages: totalPagesCalc > 0 ? totalPagesCalc : 1,
        hasNext: page < totalPagesCalc,
        hasPrev: page > 1,
      );

      return ApiResult.success(PaginatedResult(
        data: items,
        pagination: pagination,
      ));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }
}
