/// Category DTO matching backend schema
class CategoryDTO {
  final String id;
  final String name;
  final String code;
  final String? description;
  final String? icon;
  final String? parentId;
  final bool isActive;
  final double? limitAmount;
  final String? limitPeriod;
  final Map<String, dynamic>? fields;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CategoryDTO({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.icon,
    this.parentId,
    this.isActive = true,
    this.limitAmount,
    this.limitPeriod,
    this.fields,
    required this.createdAt,
    this.updatedAt,
  });

  factory CategoryDTO.fromJson(Map<String, dynamic> json) {
    return CategoryDTO(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'],
      icon: json['icon'],
      // API may return 'parentCategoryId' or 'parentId'
      parentId: json['parentCategoryId'] ?? json['parentId'],
      isActive: json['isActive'] ?? true,
      limitAmount: _parseDoubleNullable(json['limitAmount'] ?? json['maxAmount']),
      limitPeriod: json['limitPeriod'],
      fields: json['fields'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  static double? _parseDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'icon': icon,
      'parentId': parentId,
      'isActive': isActive,
      'limitAmount': limitAmount?.toString(),
      'limitPeriod': limitPeriod,
      'fields': fields,
    };
  }
}

/// Department DTO
class DepartmentDTO {
  final String id;
  final String name;
  final String code;
  final String? parentId;
  final String? headId;
  final String? headName;
  final bool isActive;
  final DateTime createdAt;

  DepartmentDTO({
    required this.id,
    required this.name,
    required this.code,
    this.parentId,
    this.headId,
    this.headName,
    this.isActive = true,
    required this.createdAt,
  });

  factory DepartmentDTO.fromJson(Map<String, dynamic> json) {
    return DepartmentDTO(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      parentId: json['parentId'],
      headId: json['headId'],
      headName: json['headName'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Cost Center DTO
class CostCenterDTO {
  final String id;
  final String name;
  final String code;
  final String? description;
  final bool isActive;
  final DateTime createdAt;

  CostCenterDTO({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.isActive = true,
    required this.createdAt,
  });

  factory CostCenterDTO.fromJson(Map<String, dynamic> json) {
    return CostCenterDTO(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Vendor/Merchant DTO
class VendorDTO {
  final String id;
  final String name;
  final String? code;
  final String? category;
  final String? address;
  final String? phone;
  final String? email;
  final String? taxId;
  final bool isActive;
  final DateTime createdAt;

  VendorDTO({
    required this.id,
    required this.name,
    this.code,
    this.category,
    this.address,
    this.phone,
    this.email,
    this.taxId,
    this.isActive = true,
    required this.createdAt,
  });

  factory VendorDTO.fromJson(Map<String, dynamic> json) {
    return VendorDTO(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'],
      category: json['category'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      taxId: json['taxId'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Budget DTO
class BudgetDTO {
  final String id;
  final String name;
  final String? code;
  final String? departmentId;
  final String? departmentName;
  final String? categoryId;
  final String? categoryName;
  final double allocatedAmount;
  final double usedAmount;
  final String currency;
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;

  BudgetDTO({
    required this.id,
    required this.name,
    this.code,
    this.departmentId,
    this.departmentName,
    this.categoryId,
    this.categoryName,
    required this.allocatedAmount,
    required this.usedAmount,
    this.currency = 'IDR',
    required this.period,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    required this.createdAt,
  });

  factory BudgetDTO.fromJson(Map<String, dynamic> json) {
    return BudgetDTO(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'],
      departmentId: json['departmentId'],
      departmentName: json['departmentName'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      allocatedAmount: _parseDouble(json['allocatedAmount']),
      usedAmount: _parseDouble(json['usedAmount']),
      currency: json['currency'] ?? 'IDR',
      period: json['period'] ?? 'monthly',
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  double get remainingAmount => allocatedAmount - usedAmount;
  double get usagePercent =>
      allocatedAmount > 0 ? (usedAmount / allocatedAmount) * 100 : 0;
  bool get isOverBudget => usedAmount > allocatedAmount;
}
