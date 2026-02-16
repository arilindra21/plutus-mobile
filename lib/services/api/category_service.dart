import 'package:dio/dio.dart';
import 'dio_client.dart';
import 'api_result.dart';
import '../models/category_dto.dart';

/// Service for category, department, vendor, and budget operations
class CategoryService {
  final Dio _dio = DioClient().dio;

  // ============ Categories ============

  /// List all categories
  Future<ApiResult<List<CategoryDTO>>> listCategories({
    bool activeOnly = true,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/categories',
        queryParameters: {
          if (activeOnly) 'is_active': true,
        },
      );

      final data = response.data;
      print('Categories API response keys: ${data.keys.toList()}');

      // API returns 'categories' key, not 'data'
      final listData = data['categories'] ?? data['data'];
      print('Categories listData type: ${listData?.runtimeType}, length: ${listData?.length}');

      final items = (listData as List<dynamic>?)
              ?.map((e) => CategoryDTO.fromJson(e))
              .toList() ??
          [];

      print('Parsed categories count: ${items.length}');
      return ApiResult.success(items);
    } on DioException catch (e) {
      print('Categories API error: ${e.message}');
      return ApiResult.fromDioError(e);
    } catch (e, stackTrace) {
      print('Categories parsing error: $e');
      print('Stack trace: $stackTrace');
      return ApiResult.failure(ApiError(message: 'Failed to parse categories: $e'));
    }
  }

  /// Get single category
  Future<ApiResult<CategoryDTO>> getCategory(String id) async {
    try {
      final response = await _dio.get('/api/v1/categories/$id');
      return ApiResult.success(CategoryDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  // ============ Departments ============

  /// List all departments
  Future<ApiResult<List<DepartmentDTO>>> listDepartments({
    bool activeOnly = true,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/departments',
        queryParameters: {
          if (activeOnly) 'is_active': true,
        },
      );

      final data = response.data;
      // API may return 'departments' key, not 'data'
      final listData = data['departments'] ?? data['data'];
      final items = (listData as List<dynamic>?)
              ?.map((e) => DepartmentDTO.fromJson(e))
              .toList() ??
          [];

      return ApiResult.success(items);
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Get single department
  Future<ApiResult<DepartmentDTO>> getDepartment(String id) async {
    try {
      final response = await _dio.get('/api/v1/departments/$id');
      return ApiResult.success(DepartmentDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  // ============ Cost Centers ============

  /// List all cost centers
  Future<ApiResult<List<CostCenterDTO>>> listCostCenters({
    bool activeOnly = true,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/cost-centers',
        queryParameters: {
          if (activeOnly) 'is_active': true,
        },
      );

      final data = response.data;
      // API may return 'costCenters' or 'cost_centers' key, not 'data'
      final listData = data['costCenters'] ?? data['cost_centers'] ?? data['data'];
      final items = (listData as List<dynamic>?)
              ?.map((e) => CostCenterDTO.fromJson(e))
              .toList() ??
          [];

      return ApiResult.success(items);
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  // ============ Vendors ============

  /// List all vendors
  Future<ApiResult<List<VendorDTO>>> listVendors({
    bool activeOnly = true,
    String? search,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/vendors',
        queryParameters: {
          if (activeOnly) 'is_active': true,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      final data = response.data;
      // API may return 'vendors' key, not 'data'
      final listData = data['vendors'] ?? data['data'];
      final items = (listData as List<dynamic>?)
              ?.map((e) => VendorDTO.fromJson(e))
              .toList() ??
          [];

      return ApiResult.success(items);
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Get single vendor
  Future<ApiResult<VendorDTO>> getVendor(String id) async {
    try {
      final response = await _dio.get('/api/v1/vendors/$id');
      return ApiResult.success(VendorDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Create new vendor
  Future<ApiResult<VendorDTO>> createVendor({
    required String name,
    String? code,
    String? category,
    String? address,
    String? phone,
    String? email,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/vendors',
        data: {
          'name': name,
          if (code != null) 'code': code,
          if (category != null) 'category': category,
          if (address != null) 'address': address,
          if (phone != null) 'phone': phone,
          if (email != null) 'email': email,
        },
      );
      return ApiResult.success(VendorDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  // ============ Budgets ============

  /// List all budgets
  Future<ApiResult<List<BudgetDTO>>> listBudgets({
    bool activeOnly = true,
    String? departmentId,
    String? categoryId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/budgets',
        queryParameters: {
          if (activeOnly) 'is_active': true,
          if (departmentId != null) 'department_id': departmentId,
          if (categoryId != null) 'category_id': categoryId,
        },
      );

      final data = response.data;
      // API may return 'budgets' key, not 'data'
      final listData = data['budgets'] ?? data['data'];
      final items = (listData as List<dynamic>?)
              ?.map((e) => BudgetDTO.fromJson(e))
              .toList() ??
          [];

      return ApiResult.success(items);
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Get single budget
  Future<ApiResult<BudgetDTO>> getBudget(String id) async {
    try {
      final response = await _dio.get('/api/v1/budgets/$id');
      return ApiResult.success(BudgetDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }
}
