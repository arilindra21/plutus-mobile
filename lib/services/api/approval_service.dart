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
}
