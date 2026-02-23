import 'package:dio/dio.dart';
import 'dio_client.dart';
import 'api_result.dart';
import '../models/category_dto.dart';

/// Parameters for listing vendors
class VendorListParams {
  final int page;
  final int pageSize;
  final String? search;
  final bool? isBlocked;
  final bool? hasExternalId;
  final String? merchantCategoryId;
  final String? expenseCategoryId;
  final String sortBy;
  final String sortOrder;

  VendorListParams({
    this.page = 1,
    this.pageSize = 100,
    this.search,
    this.isBlocked,
    this.hasExternalId,
    this.merchantCategoryId,
    this.expenseCategoryId,
    this.sortBy = 'name',
    this.sortOrder = 'asc',
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      'sort_by': sortBy,
      'sort_order': sortOrder,
    };

    if (search != null && search!.isNotEmpty) {
      params['search'] = search;
    }
    if (isBlocked != null) {
      params['is_blocked'] = isBlocked;
    }
    if (hasExternalId != null) {
      params['has_external_id'] = hasExternalId;
    }
    if (merchantCategoryId != null && merchantCategoryId!.isNotEmpty) {
      params['merchant_category_id'] = merchantCategoryId;
    }
    if (expenseCategoryId != null && expenseCategoryId!.isNotEmpty) {
      params['expense_category_id'] = expenseCategoryId;
    }

    return params;
  }
}

/// Paginated vendor result
class VendorPaginatedResult {
  final List<VendorDTO> vendors;
  final int total;
  final int page;
  final int pageSize;

  VendorPaginatedResult({
    required this.vendors,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory VendorPaginatedResult.fromJson(Map<String, dynamic> json) {
    final vendorsList = json['vendors'] as List<dynamic>? ?? [];
    return VendorPaginatedResult(
      vendors: vendorsList.map((e) => VendorDTO.fromJson(e)).toList(),
      total: json['total'] ?? json['pagination']?['total'] ?? 0,
      page: json['page'] ?? json['pagination']?['page'] ?? 1,
      pageSize: json['page_size'] ?? json['pagination']?['pageSize'] ?? 20,
    );
  }
}

/// Service for vendor API operations
class VendorService {
  final Dio _dio = DioClient().dio;

  /// List vendors with pagination and filters
  Future<ApiResult<VendorPaginatedResult>> listVendors([
    VendorListParams? params,
  ]) async {
    try {
      final queryParams = params?.toQueryParams() ?? VendorListParams().toQueryParams();

      final response = await _dio.get(
        '/api/v1/vendors',
        queryParameters: queryParams,
      );

      return ApiResult.success(VendorPaginatedResult.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Get single vendor by ID
  Future<ApiResult<VendorDTO>> getVendor(String id) async {
    try {
      final response = await _dio.get('/api/v1/vendors/$id');
      return ApiResult.success(VendorDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Search vendors by name
  Future<ApiResult<List<VendorDTO>>> searchVendors(String query) async {
    final result = await listVendors(VendorListParams(
      search: query,
      pageSize: 20,
      isBlocked: false, // Only show unblocked vendors
    ));

    if (result.isSuccess) {
      return ApiResult.success(result.data!.vendors);
    }
    return ApiResult.failure(result.error!);
  }

  /// Get all unblocked vendors for dropdown
  Future<ApiResult<List<VendorDTO>>> getActiveVendors() async {
    final result = await listVendors(VendorListParams(
      pageSize: 200,
      isBlocked: false,
      sortBy: 'name',
      sortOrder: 'asc',
    ));

    if (result.isSuccess) {
      return ApiResult.success(result.data!.vendors);
    }
    return ApiResult.failure(result.error!);
  }
}
