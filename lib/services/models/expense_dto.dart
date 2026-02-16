/// Expense DTO matching backend schema
class ExpenseDTO {
  final String id;
  final String organizationId;
  final String entityId;
  final String requesterId;
  final String? requesterName;
  final double originalAmount;
  final String originalCurrency;
  final double? baseAmount;
  final String? baseCurrency;
  final double? exchangeRate;
  final String categoryId;
  final String? categoryName;
  final String? categoryCode;
  final String? categoryIcon;
  final Map<String, dynamic>? categoryFields;
  final String? departmentId;
  final String? departmentName;
  final String? costCenterId;
  final String? costCenterName;
  final String expenseType;
  final DateTime expenseDate;
  final int status;
  final String? statusName;
  final String? statusReason; // Reason for return/rejection
  final int? receiptStatus;
  final String? receiptStatusName;
  final bool receiptRequired;
  final DateTime? receiptDueDate;
  final int? policyStatus;
  final String? policyStatusName;
  final List<PolicyFlagDTO>? policyFlags;
  final String? workflowRunId;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final DateTime? completedAt;
  final bool? requiresEmployeeRepayment;
  final double? repaymentAmount;
  final String? repaymentStatus;
  final String? description;
  final String? vendorId;
  final String? vendorName;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final List<ReceiptDTO>? receipts;

  ExpenseDTO({
    required this.id,
    required this.organizationId,
    required this.entityId,
    required this.requesterId,
    this.requesterName,
    required this.originalAmount,
    required this.originalCurrency,
    this.baseAmount,
    this.baseCurrency,
    this.exchangeRate,
    required this.categoryId,
    this.categoryName,
    this.categoryCode,
    this.categoryIcon,
    this.categoryFields,
    this.departmentId,
    this.departmentName,
    this.costCenterId,
    this.costCenterName,
    required this.expenseType,
    required this.expenseDate,
    required this.status,
    this.statusName,
    this.statusReason,
    this.receiptStatus,
    this.receiptStatusName,
    this.receiptRequired = false,
    this.receiptDueDate,
    this.policyStatus,
    this.policyStatusName,
    this.policyFlags,
    this.workflowRunId,
    this.submittedAt,
    this.approvedAt,
    this.completedAt,
    this.requiresEmployeeRepayment,
    this.repaymentAmount,
    this.repaymentStatus,
    this.description,
    this.vendorId,
    this.vendorName,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.receipts,
  });

  factory ExpenseDTO.fromJson(Map<String, dynamic> json) {
    return ExpenseDTO(
      id: json['id'] ?? '',
      organizationId: json['organizationId'] ?? '',
      entityId: json['entityId'] ?? '',
      requesterId: json['requesterId'] ?? '',
      requesterName: json['requesterName'],
      originalAmount: _parseDouble(json['originalAmount']),
      originalCurrency: json['originalCurrency'] ?? 'IDR',
      baseAmount: _parseDoubleNullable(json['baseAmount']),
      baseCurrency: json['baseCurrency'],
      exchangeRate: _parseDoubleNullable(json['exchangeRate']),
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'],
      categoryCode: json['categoryCode'],
      categoryIcon: json['categoryIcon'],
      categoryFields: json['categoryFields'],
      departmentId: json['departmentId'],
      departmentName: json['departmentName'],
      costCenterId: json['costCenterId'],
      costCenterName: json['costCenterName'],
      expenseType: json['expenseType'] ?? 'reimbursement',
      expenseDate: DateTime.tryParse(json['expenseDate'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 0,
      statusName: json['statusName'],
      statusReason: json['statusReason'],
      receiptStatus: json['receiptStatus'],
      receiptStatusName: json['receiptStatusName'],
      receiptRequired: json['receiptRequired'] ?? false,
      receiptDueDate: json['receiptDueDate'] != null
          ? DateTime.tryParse(json['receiptDueDate'])
          : null,
      policyStatus: json['policyStatus'],
      policyStatusName: json['policyStatusName'],
      policyFlags: _parsePolicyFlags(json['policyFlags']),
      workflowRunId: json['workflowRunId'],
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'])
          : null,
      approvedAt: json['approvedAt'] != null
          ? DateTime.tryParse(json['approvedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'])
          : null,
      requiresEmployeeRepayment: json['requiresEmployeeRepayment'],
      repaymentAmount: _parseDoubleNullable(json['repaymentAmount']),
      repaymentStatus: json['repaymentStatus'],
      description: json['description'],
      vendorId: json['vendorId'],
      // API returns 'merchantName' instead of 'vendorName'
      vendorName: json['vendorName'] ?? json['merchantName'],
      metadata: json['metadata'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      createdBy: json['createdBy'],
      receipts: (json['receipts'] as List<dynamic>?)
          ?.map((r) => ReceiptDTO.fromJson(r))
          .toList(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static double? _parseDoubleNullable(dynamic value) {
    if (value == null) return null;
    return _parseDouble(value);
  }

  /// Parse policyFlags - handles both string array and object array
  static List<PolicyFlagDTO>? _parsePolicyFlags(dynamic value) {
    if (value == null) return null;
    if (value is! List) return null;

    return (value as List<dynamic>).map((f) {
      if (f is String) {
        // API returns just the flag code as string
        return PolicyFlagDTO(
          id: '',
          code: f,
          name: f,
          severity: 'warning',
        );
      } else if (f is Map<String, dynamic>) {
        // API returns full object
        return PolicyFlagDTO.fromJson(f);
      }
      return PolicyFlagDTO(id: '', code: '', name: '', severity: 'info');
    }).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'entityId': entityId,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'originalAmount': originalAmount,
      'originalCurrency': originalCurrency,
      'baseAmount': baseAmount,
      'baseCurrency': baseCurrency,
      'exchangeRate': exchangeRate,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryCode': categoryCode,
      'categoryFields': categoryFields,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'costCenterId': costCenterId,
      'costCenterName': costCenterName,
      'expenseType': expenseType,
      'expenseDate': expenseDate.toIso8601String(),
      'status': status,
      'statusName': statusName,
      'receiptStatus': receiptStatus,
      'receiptStatusName': receiptStatusName,
      'receiptRequired': receiptRequired,
      'description': description,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'metadata': metadata,
    };
  }

  /// Check if receipt is missing
  bool get missingReceipt =>
      receiptRequired && (receipts == null || receipts!.isEmpty);

  /// Get display name for merchant
  String get merchant => vendorName ?? 'Unknown Merchant';

  /// Get display name for category
  String get category => categoryName ?? 'Uncategorized';

  /// Get formatted date string
  String get formattedDate {
    return '${expenseDate.day.toString().padLeft(2, '0')}/${expenseDate.month.toString().padLeft(2, '0')}/${expenseDate.year}';
  }

  /// Alias for requesterName used in approval context
  String get submitterName => requesterName ?? 'Unknown';

  /// Get submitter email (derived from metadata or placeholder)
  String get submitterEmail => (metadata?['requesterEmail'] as String?) ?? '';
}

/// Create expense request - matches API schema
class CreateExpenseRequest {
  final double originalAmount;
  final String originalCurrency;
  final String categoryId;
  final DateTime expenseDate;
  final String? description;
  final String expenseType;
  final String? departmentId;
  final String? costCenterId;
  final String? merchantId;
  final String? merchantName;
  final Map<String, dynamic>? categoryFields;
  final Map<String, dynamic>? metadata;
  final String? parentExpenseId;
  final bool submitForApproval;
  final String? transactionId;

  CreateExpenseRequest({
    required this.originalAmount,
    this.originalCurrency = 'IDR',
    required this.categoryId,
    required this.expenseDate,
    this.description,
    this.expenseType = 'reimbursement',
    this.departmentId,
    this.costCenterId,
    this.merchantId,
    this.merchantName,
    this.categoryFields,
    this.metadata,
    this.parentExpenseId,
    this.submitForApproval = false,
    this.transactionId,
  });

  Map<String, dynamic> toJson() {
    // Format date as RFC 3339 with UTC timezone
    final utcDate = expenseDate.toUtc();
    final dateStr = '${utcDate.toIso8601String().split('.')[0]}Z';

    final map = <String, dynamic>{
      'originalAmount': originalAmount.toString(),
      'originalCurrency': originalCurrency,
      'categoryId': categoryId,
      'expenseDate': dateStr,
      'expenseType': expenseType,
    };

    if (description != null && description!.isNotEmpty) map['description'] = description;
    if (departmentId != null) map['departmentId'] = departmentId;
    if (costCenterId != null) map['costCenterId'] = costCenterId;
    if (merchantId != null) map['merchantId'] = merchantId;
    if (merchantName != null && merchantName!.isNotEmpty) map['merchantName'] = merchantName;
    if (categoryFields != null) map['categoryFields'] = categoryFields;
    if (metadata != null) map['metadata'] = metadata;
    if (parentExpenseId != null) map['parentExpenseId'] = parentExpenseId;
    if (submitForApproval) map['submitForApproval'] = submitForApproval;
    if (transactionId != null) map['transactionId'] = transactionId;

    return map;
  }
}

/// Update expense request - matches API schema
/// Note: expenseType, originalAmount, originalCurrency cannot be changed after creation
class UpdateExpenseRequest {
  final String? categoryId;
  final DateTime? expenseDate;
  final String? description;
  final String? departmentId;
  final String? costCenterId;
  final String? merchantId;
  final String? merchantName;
  final Map<String, dynamic>? categoryFields;
  final Map<String, dynamic>? metadata;

  UpdateExpenseRequest({
    this.categoryId,
    this.expenseDate,
    this.description,
    this.departmentId,
    this.costCenterId,
    this.merchantId,
    this.merchantName,
    this.categoryFields,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (categoryId != null) map['categoryId'] = categoryId;
    if (expenseDate != null) {
      // Format date as RFC 3339 date only (YYYY-MM-DD)
      final date = expenseDate!;
      map['expenseDate'] = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
    if (description != null) map['description'] = description;
    if (departmentId != null) map['departmentId'] = departmentId;
    if (costCenterId != null) map['costCenterId'] = costCenterId;
    if (merchantId != null) map['merchantId'] = merchantId;
    if (merchantName != null) map['merchantName'] = merchantName;
    if (categoryFields != null) map['categoryFields'] = categoryFields;
    if (metadata != null) map['metadata'] = metadata;
    return map;
  }
}

/// Receipt DTO
class ReceiptDTO {
  final String id;
  final String expenseId;
  final String? fileName;
  final String? fileType;
  final String? fileUrl;
  final String? thumbnailUrl;
  final int? fileSize;
  final String? status;
  final DateTime? verifiedAt;
  final String? verifiedBy;
  final DateTime createdAt;

  ReceiptDTO({
    required this.id,
    required this.expenseId,
    this.fileName,
    this.fileType,
    this.fileUrl,
    this.thumbnailUrl,
    this.fileSize,
    this.status,
    this.verifiedAt,
    this.verifiedBy,
    required this.createdAt,
  });

  factory ReceiptDTO.fromJson(Map<String, dynamic> json) {
    return ReceiptDTO(
      id: json['id'] ?? '',
      expenseId: json['expenseId'] ?? '',
      fileName: json['fileName'],
      fileType: json['fileType'],
      fileUrl: json['fileUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      fileSize: json['fileSize'],
      status: json['status'],
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.tryParse(json['verifiedAt'])
          : null,
      verifiedBy: json['verifiedBy'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Policy flag DTO
class PolicyFlagDTO {
  final String id;
  final String code;
  final String name;
  final String severity;
  final String? message;
  final String? resolution;

  PolicyFlagDTO({
    required this.id,
    required this.code,
    required this.name,
    required this.severity,
    this.message,
    this.resolution,
  });

  factory PolicyFlagDTO.fromJson(Map<String, dynamic> json) {
    return PolicyFlagDTO(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      severity: json['severity'] ?? 'warning',
      message: json['message'],
      resolution: json['resolution'],
    );
  }
}

/// Expense list filter parameters
class ExpenseListParams {
  final int page;
  final int pageSize;
  final String sortBy;
  final String sortOrder;
  final int? status;
  final List<int>? statuses;
  final String? requesterId;
  final String? categoryId;
  final String? departmentId;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? search;

  ExpenseListParams({
    this.page = 1,
    this.pageSize = 20,
    this.sortBy = 'created_at',
    this.sortOrder = 'desc',
    this.status,
    this.statuses,
    this.requesterId,
    this.categoryId,
    this.departmentId,
    this.dateFrom,
    this.dateTo,
    this.search,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      'sort_by': sortBy,
      'sort_order': sortOrder,
    };

    if (status != null) params['status'] = status;
    if (statuses != null && statuses!.isNotEmpty) {
      params['statuses'] = statuses!.join(',');
    }
    if (requesterId != null) params['requester_id'] = requesterId;
    if (categoryId != null) params['category_id'] = categoryId;
    if (departmentId != null) params['department_id'] = departmentId;
    if (dateFrom != null) {
      final utc = dateFrom!.toUtc();
      params['date_from'] = '${utc.toIso8601String().split('.')[0]}Z';
    }
    if (dateTo != null) {
      final utc = dateTo!.toUtc();
      params['date_to'] = '${utc.toIso8601String().split('.')[0]}Z';
    }
    if (search != null && search!.isNotEmpty) params['search'] = search;

    return params;
  }
}
