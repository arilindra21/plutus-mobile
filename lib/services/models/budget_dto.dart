// Budget DTOs matching backend schema
// Based on internal/handler/schema/budget.go

// ============ Budget Core DTOs ============

/// Budget item in list response
class BudgetItemDTO {
  final String id;
  final String code;
  final String name;
  final double budgetAmount;
  final String budgetCurrency;
  final String renewalPeriod;
  final bool hardSpendingCap;
  final int warningThreshold;
  final bool isActive;
  final DateTime createdAt;

  // Scope references (denormalized names)
  final String? departmentId;
  final String? departmentName;
  final String? costCenterId;
  final String? costCenterName;
  final String? categoryId;
  final String? categoryName;

  // Utilization (may be included in list)
  final double? spentAmount;
  final double? pendingAmount;
  final double? reservedAmount;
  final double? availableAmount;
  final double? utilizationPct;

  BudgetItemDTO({
    required this.id,
    required this.code,
    required this.name,
    required this.budgetAmount,
    this.budgetCurrency = 'IDR',
    required this.renewalPeriod,
    this.hardSpendingCap = false,
    this.warningThreshold = 80,
    this.isActive = true,
    required this.createdAt,
    this.departmentId,
    this.departmentName,
    this.costCenterId,
    this.costCenterName,
    this.categoryId,
    this.categoryName,
    this.spentAmount,
    this.pendingAmount,
    this.reservedAmount,
    this.availableAmount,
    this.utilizationPct,
  });

  factory BudgetItemDTO.fromJson(Map<String, dynamic> json) {
    return BudgetItemDTO(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      budgetAmount: _parseDouble(json['budgetAmount']),
      budgetCurrency: json['budgetCurrency'] ?? 'IDR',
      renewalPeriod: json['renewalPeriod'] ?? 'monthly',
      hardSpendingCap: json['hardSpendingCap'] ?? false,
      warningThreshold: json['warningThreshold'] ?? 80,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      departmentId: json['departmentId'],
      departmentName: json['departmentName'],
      costCenterId: json['costCenterId'],
      costCenterName: json['costCenterName'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      spentAmount: _parseDoubleNullable(json['spentAmount']),
      pendingAmount: _parseDoubleNullable(json['pendingAmount']),
      reservedAmount: _parseDoubleNullable(json['reservedAmount']),
      availableAmount: _parseDoubleNullable(json['availableAmount']),
      utilizationPct: _parseDoubleNullable(json['utilizationPct']),
    );
  }

  // Computed getters
  double get usedAmount => spentAmount ?? 0;
  double get allocatedAmount => budgetAmount;
  double get remainingAmount => (availableAmount ?? budgetAmount) - (spentAmount ?? 0);
  double get usagePercent => utilizationPct ?? (budgetAmount > 0 ? ((spentAmount ?? 0) / budgetAmount) * 100 : 0);
  bool get isOverBudget => (spentAmount ?? 0) > budgetAmount;
  String get period => renewalPeriod;
  DateTime get startDate => createdAt;
  DateTime get endDate => createdAt.add(const Duration(days: 30));
}

/// Budget list response
class BudgetListResponse {
  final List<BudgetItemDTO> budgets;
  final int total;
  final int page;
  final int perPage;

  BudgetListResponse({
    required this.budgets,
    required this.total,
    required this.page,
    required this.perPage,
  });

  factory BudgetListResponse.fromJson(Map<String, dynamic> json) {
    final listData = json['budgets'] ?? json['data'] ?? [];
    return BudgetListResponse(
      budgets: (listData as List<dynamic>)
          .map((e) => BudgetItemDTO.fromJson(e))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      perPage: json['perPage'] ?? 20,
    );
  }
}

/// Detailed budget response
class BudgetDetailDTO {
  final String id;
  final String organizationId;
  final String entityId;
  final String code;
  final String name;
  final String? description;
  final double budgetAmount;
  final String budgetCurrency;
  final String? departmentId;
  final String? costCenterId;
  final String? categoryId;
  final String renewalPeriod;
  final int? periodStartDay;
  final int? fiscalYearStart;
  final bool hardSpendingCap;
  final int warningThreshold;
  final int criticalThreshold;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  BudgetDetailDTO({
    required this.id,
    required this.organizationId,
    required this.entityId,
    required this.code,
    required this.name,
    this.description,
    required this.budgetAmount,
    this.budgetCurrency = 'IDR',
    this.departmentId,
    this.costCenterId,
    this.categoryId,
    required this.renewalPeriod,
    this.periodStartDay,
    this.fiscalYearStart,
    this.hardSpendingCap = false,
    this.warningThreshold = 80,
    this.criticalThreshold = 90,
    this.isActive = true,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BudgetDetailDTO.fromJson(Map<String, dynamic> json) {
    return BudgetDetailDTO(
      id: json['id'] ?? '',
      organizationId: json['organizationId'] ?? '',
      entityId: json['entityId'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      budgetAmount: _parseDouble(json['budgetAmount']),
      budgetCurrency: json['budgetCurrency'] ?? 'IDR',
      departmentId: json['departmentId'],
      costCenterId: json['costCenterId'],
      categoryId: json['categoryId'],
      renewalPeriod: json['renewalPeriod'] ?? 'monthly',
      periodStartDay: json['periodStartDay'],
      fiscalYearStart: json['fiscalYearStart'],
      hardSpendingCap: json['hardSpendingCap'] ?? false,
      warningThreshold: json['warningThreshold'] ?? 80,
      criticalThreshold: json['criticalThreshold'] ?? 90,
      isActive: json['isActive'] ?? true,
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

// ============ Budget Period DTOs ============

/// Budget period with current status
class BudgetPeriodDTO {
  final String id;
  final String budgetId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String periodLabel;
  final double budgetAmount;
  final String budgetCurrency;
  final double spentAmount;
  final double pendingAmount;
  final double reservedAmount;
  final double availableAmount;
  final double utilizationPct;
  final DateTime? warningBreachedAt;
  final DateTime? criticalBreachedAt;
  final DateTime? overspentAt;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  BudgetPeriodDTO({
    required this.id,
    required this.budgetId,
    required this.periodStart,
    required this.periodEnd,
    required this.periodLabel,
    required this.budgetAmount,
    this.budgetCurrency = 'IDR',
    required this.spentAmount,
    required this.pendingAmount,
    required this.reservedAmount,
    required this.availableAmount,
    required this.utilizationPct,
    this.warningBreachedAt,
    this.criticalBreachedAt,
    this.overspentAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BudgetPeriodDTO.fromJson(Map<String, dynamic> json) {
    return BudgetPeriodDTO(
      id: json['id'] ?? '',
      budgetId: json['budgetId'] ?? '',
      periodStart: DateTime.tryParse(json['periodStart'] ?? '') ?? DateTime.now(),
      periodEnd: DateTime.tryParse(json['periodEnd'] ?? '') ?? DateTime.now(),
      periodLabel: json['periodLabel'] ?? '',
      budgetAmount: _parseDouble(json['budgetAmount']),
      budgetCurrency: json['budgetCurrency'] ?? 'IDR',
      spentAmount: _parseDouble(json['spentAmount']),
      pendingAmount: _parseDouble(json['pendingAmount']),
      reservedAmount: _parseDouble(json['reservedAmount']),
      availableAmount: _parseDouble(json['availableAmount']),
      utilizationPct: _parseDouble(json['utilizationPct']),
      warningBreachedAt: json['warningBreachedAt'] != null
          ? DateTime.tryParse(json['warningBreachedAt'])
          : null,
      criticalBreachedAt: json['criticalBreachedAt'] != null
          ? DateTime.tryParse(json['criticalBreachedAt'])
          : null,
      overspentAt: json['overspentAt'] != null
          ? DateTime.tryParse(json['overspentAt'])
          : null,
      status: json['status'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  bool get isOverBudget => overspentAt != null;
  bool get isWarning => warningBreachedAt != null;
  bool get isCritical => criticalBreachedAt != null;
}

/// Budget period status
class BudgetPeriodStatusDTO {
  final String budgetPeriodId;
  final String budgetId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String periodLabel;
  final double budgetAmount;
  final String budgetCurrency;
  final double spentAmount;
  final double pendingAmount;
  final double reservedAmount;
  final double availableAmount;
  final double utilizationPct;
  final String healthStatus; // healthy, warning, overspent
  final DateTime? overspentAt;
  final int status;

  BudgetPeriodStatusDTO({
    required this.budgetPeriodId,
    required this.budgetId,
    required this.periodStart,
    required this.periodEnd,
    required this.periodLabel,
    required this.budgetAmount,
    this.budgetCurrency = 'IDR',
    required this.spentAmount,
    required this.pendingAmount,
    required this.reservedAmount,
    required this.availableAmount,
    required this.utilizationPct,
    required this.healthStatus,
    this.overspentAt,
    required this.status,
  });

  factory BudgetPeriodStatusDTO.fromJson(Map<String, dynamic> json) {
    return BudgetPeriodStatusDTO(
      budgetPeriodId: json['budgetPeriodId'] ?? '',
      budgetId: json['budgetId'] ?? '',
      periodStart: DateTime.tryParse(json['periodStart'] ?? '') ?? DateTime.now(),
      periodEnd: DateTime.tryParse(json['periodEnd'] ?? '') ?? DateTime.now(),
      periodLabel: json['periodLabel'] ?? '',
      budgetAmount: _parseDouble(json['budgetAmount']),
      budgetCurrency: json['budgetCurrency'] ?? 'IDR',
      spentAmount: _parseDouble(json['spentAmount']),
      pendingAmount: _parseDouble(json['pendingAmount']),
      reservedAmount: _parseDouble(json['reservedAmount']),
      availableAmount: _parseDouble(json['availableAmount']),
      utilizationPct: _parseDouble(json['utilizationPct']),
      healthStatus: json['healthStatus'] ?? 'healthy',
      overspentAt: json['overspentAt'] != null
          ? DateTime.tryParse(json['overspentAt'])
          : null,
      status: json['status'] ?? 0,
    );
  }
}

// ============ Budget Analytics DTOs ============

/// Utilization breakdown item
class BudgetUtilizationBreakdown {
  final String id;
  final String name;
  final double spentAmount;
  final double pendingAmount;
  final double totalAmount;
  final double percentage;

  BudgetUtilizationBreakdown({
    required this.id,
    required this.name,
    required this.spentAmount,
    required this.pendingAmount,
    required this.totalAmount,
    required this.percentage,
  });

  factory BudgetUtilizationBreakdown.fromJson(Map<String, dynamic> json) {
    return BudgetUtilizationBreakdown(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      spentAmount: _parseDouble(json['spentAmount']),
      pendingAmount: _parseDouble(json['pendingAmount']),
      totalAmount: _parseDouble(json['totalAmount']),
      percentage: _parseDouble(json['percentage']),
    );
  }
}

/// Budget utilization details
class BudgetUtilizationDTO {
  final String budgetId;
  final String budgetName;
  final String periodId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double budgetAmount;
  final double spentAmount;
  final double pendingAmount;
  final double reservedAmount;
  final double availableAmount;
  final double utilizationPct;
  final List<BudgetUtilizationBreakdown> byCategory;
  final List<BudgetUtilizationBreakdown> byUser;
  final List<BudgetUtilizationBreakdown> byDate;

  BudgetUtilizationDTO({
    required this.budgetId,
    required this.budgetName,
    required this.periodId,
    required this.periodStart,
    required this.periodEnd,
    required this.budgetAmount,
    required this.spentAmount,
    required this.pendingAmount,
    required this.reservedAmount,
    required this.availableAmount,
    required this.utilizationPct,
    this.byCategory = const [],
    this.byUser = const [],
    this.byDate = const [],
  });

  factory BudgetUtilizationDTO.fromJson(Map<String, dynamic> json) {
    return BudgetUtilizationDTO(
      budgetId: json['budgetId'] ?? '',
      budgetName: json['budgetName'] ?? '',
      periodId: json['periodId'] ?? '',
      periodStart: DateTime.tryParse(json['periodStart'] ?? '') ?? DateTime.now(),
      periodEnd: DateTime.tryParse(json['periodEnd'] ?? '') ?? DateTime.now(),
      budgetAmount: _parseDouble(json['budgetAmount']),
      spentAmount: _parseDouble(json['spentAmount']),
      pendingAmount: _parseDouble(json['pendingAmount']),
      reservedAmount: _parseDouble(json['reservedAmount']),
      availableAmount: _parseDouble(json['availableAmount']),
      utilizationPct: _parseDouble(json['utilizationPct']),
      byCategory: (json['byCategory'] as List<dynamic>?)
              ?.map((e) => BudgetUtilizationBreakdown.fromJson(e))
              .toList() ??
          [],
      byUser: (json['byUser'] as List<dynamic>?)
              ?.map((e) => BudgetUtilizationBreakdown.fromJson(e))
              .toList() ??
          [],
      byDate: (json['byDate'] as List<dynamic>?)
              ?.map((e) => BudgetUtilizationBreakdown.fromJson(e))
              .toList() ??
          [],
    );
  }

  bool get isOverBudget => spentAmount > budgetAmount;
  double get remainingAmount => availableAmount;
}

/// Trend data point
class BudgetTrendDataPoint {
  final String period;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double budgetAmount;
  final double spentAmount;
  final double pendingAmount;
  final double utilizationPct;

  BudgetTrendDataPoint({
    required this.period,
    required this.periodStart,
    required this.periodEnd,
    required this.budgetAmount,
    required this.spentAmount,
    required this.pendingAmount,
    required this.utilizationPct,
  });

  factory BudgetTrendDataPoint.fromJson(Map<String, dynamic> json) {
    return BudgetTrendDataPoint(
      period: json['period'] ?? '',
      periodStart: DateTime.tryParse(json['periodStart'] ?? '') ?? DateTime.now(),
      periodEnd: DateTime.tryParse(json['periodEnd'] ?? '') ?? DateTime.now(),
      budgetAmount: _parseDouble(json['budgetAmount']),
      spentAmount: _parseDouble(json['spentAmount']),
      pendingAmount: _parseDouble(json['pendingAmount']),
      utilizationPct: _parseDouble(json['utilizationPct']),
    );
  }
}

/// Budget trend response
class BudgetTrendDTO {
  final String budgetId;
  final String budgetName;
  final List<BudgetTrendDataPoint> dataPoints;
  final int totalPeriods;

  BudgetTrendDTO({
    required this.budgetId,
    required this.budgetName,
    required this.dataPoints,
    required this.totalPeriods,
  });

  factory BudgetTrendDTO.fromJson(Map<String, dynamic> json) {
    return BudgetTrendDTO(
      budgetId: json['budgetId'] ?? '',
      budgetName: json['budgetName'] ?? '',
      dataPoints: (json['dataPoints'] as List<dynamic>?)
              ?.map((e) => BudgetTrendDataPoint.fromJson(e))
              .toList() ??
          [],
      totalPeriods: json['totalPeriods'] ?? 0,
    );
  }
}

// ============ Budget History DTOs ============

/// Budget transaction item in history
class BudgetTransactionItem {
  final String id;
  final String budgetPeriodId;
  final String sourceType; // expense, transaction, adjustment
  final String sourceId;
  final String operation; // add_pending, commit, release, reserve, release_reserve, adjust
  final double amount;
  final String currency;
  final String? requesterId;
  final String? departmentId;
  final String? categoryId;
  final String? description;
  final String? notes;
  final String? createdBy;
  final DateTime createdAt;

  BudgetTransactionItem({
    required this.id,
    required this.budgetPeriodId,
    required this.sourceType,
    required this.sourceId,
    required this.operation,
    required this.amount,
    this.currency = 'IDR',
    this.requesterId,
    this.departmentId,
    this.categoryId,
    this.description,
    this.notes,
    this.createdBy,
    required this.createdAt,
  });

  factory BudgetTransactionItem.fromJson(Map<String, dynamic> json) {
    return BudgetTransactionItem(
      id: json['id'] ?? '',
      budgetPeriodId: json['budgetPeriodId'] ?? '',
      sourceType: json['sourceType'] ?? '',
      sourceId: json['sourceId'] ?? '',
      operation: json['operation'] ?? '',
      amount: _parseDouble(json['amount']),
      currency: json['currency'] ?? 'IDR',
      requesterId: json['requesterId'],
      departmentId: json['departmentId'],
      categoryId: json['categoryId'],
      description: json['description'],
      notes: json['notes'],
      createdBy: json['createdBy'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  String get operationLabel {
    switch (operation) {
      case 'add_pending':
        return 'Pending';
      case 'commit':
        return 'Committed';
      case 'release':
        return 'Released';
      case 'reserve':
        return 'Reserved';
      case 'release_reserve':
        return 'Released Reserve';
      case 'adjust':
        return 'Adjusted';
      default:
        return operation;
    }
  }

  bool get isDebit => operation == 'commit' || operation == 'reserve' || operation == 'add_pending';
}

/// Budget history summary
class BudgetHistorySummary {
  final int totalTransactions;
  final Map<String, double> totalAmount;
  final Map<String, int> operationCounts;

  BudgetHistorySummary({
    required this.totalTransactions,
    required this.totalAmount,
    required this.operationCounts,
  });

  factory BudgetHistorySummary.fromJson(Map<String, dynamic> json) {
    return BudgetHistorySummary(
      totalTransactions: json['totalTransactions'] ?? 0,
      totalAmount: (json['totalAmount'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, _parseDouble(v))) ??
          {},
      operationCounts: (json['operationCounts'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v is int ? v : 0)) ??
          {},
    );
  }
}

/// Budget history response
class BudgetHistoryDTO {
  final String budgetId;
  final String budgetName;
  final String budgetCode;
  final List<BudgetTransactionItem> transactions;
  final int totalCount;
  final int page;
  final int pageSize;
  final BudgetHistorySummary? summary;

  BudgetHistoryDTO({
    required this.budgetId,
    required this.budgetName,
    required this.budgetCode,
    required this.transactions,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    this.summary,
  });

  factory BudgetHistoryDTO.fromJson(Map<String, dynamic> json) {
    return BudgetHistoryDTO(
      budgetId: json['budgetId'] ?? '',
      budgetName: json['budgetName'] ?? '',
      budgetCode: json['budgetCode'] ?? '',
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((e) => BudgetTransactionItem.fromJson(e))
              .toList() ??
          [],
      totalCount: json['totalCount'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      summary: json['summary'] != null
          ? BudgetHistorySummary.fromJson(json['summary'])
          : null,
    );
  }
}

// ============ Budget Operation DTOs ============

/// Budget match response
class BudgetMatchResponse {
  final BudgetMatchItem? budget;
  final int matchSpecificity;

  BudgetMatchResponse({
    this.budget,
    required this.matchSpecificity,
  });

  factory BudgetMatchResponse.fromJson(Map<String, dynamic> json) {
    return BudgetMatchResponse(
      budget: json['budget'] != null ? BudgetMatchItem.fromJson(json['budget']) : null,
      matchSpecificity: json['matchSpecificity'] ?? 0,
    );
  }
}

/// Matched budget item
class BudgetMatchItem {
  final String id;
  final String code;
  final String name;
  final double budgetAmount;
  final String budgetCurrency;
  final String? departmentId;
  final String? costCenterId;
  final String? categoryId;
  final bool hardSpendingCap;

  BudgetMatchItem({
    required this.id,
    required this.code,
    required this.name,
    required this.budgetAmount,
    this.budgetCurrency = 'IDR',
    this.departmentId,
    this.costCenterId,
    this.categoryId,
    this.hardSpendingCap = false,
  });

  factory BudgetMatchItem.fromJson(Map<String, dynamic> json) {
    return BudgetMatchItem(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      budgetAmount: _parseDouble(json['budgetAmount']),
      budgetCurrency: json['budgetCurrency'] ?? 'IDR',
      departmentId: json['departmentId'],
      costCenterId: json['costCenterId'],
      categoryId: json['categoryId'],
      hardSpendingCap: json['hardSpendingCap'] ?? false,
    );
  }
}

/// Budget check response
class BudgetCheckResponse {
  final String budgetId;
  final String budgetCode;
  final String budgetName;
  final double budgetAmount;
  final String budgetCurrency;
  final double spentAmount;
  final double pendingAmount;
  final double reservedAmount;
  final double availableAmount;
  final double utilizationPct;
  final bool warningBreached;
  final bool criticalBreached;
  final bool overspent;
  final DateTime? overspentAt;
  final double expenseAmount;
  final bool wouldExceed;
  final bool hardCapEnabled;
  final bool canProceed;
  final String? reason;
  final DateTime checkedAt;

  BudgetCheckResponse({
    required this.budgetId,
    required this.budgetCode,
    required this.budgetName,
    required this.budgetAmount,
    this.budgetCurrency = 'IDR',
    required this.spentAmount,
    required this.pendingAmount,
    required this.reservedAmount,
    required this.availableAmount,
    required this.utilizationPct,
    required this.warningBreached,
    required this.criticalBreached,
    required this.overspent,
    this.overspentAt,
    required this.expenseAmount,
    required this.wouldExceed,
    required this.hardCapEnabled,
    required this.canProceed,
    this.reason,
    required this.checkedAt,
  });

  factory BudgetCheckResponse.fromJson(Map<String, dynamic> json) {
    return BudgetCheckResponse(
      budgetId: json['budgetId'] ?? '',
      budgetCode: json['budgetCode'] ?? '',
      budgetName: json['budgetName'] ?? '',
      budgetAmount: _parseDouble(json['budgetAmount']),
      budgetCurrency: json['budgetCurrency'] ?? 'IDR',
      spentAmount: _parseDouble(json['spentAmount']),
      pendingAmount: _parseDouble(json['pendingAmount']),
      reservedAmount: _parseDouble(json['reservedAmount']),
      availableAmount: _parseDouble(json['availableAmount']),
      utilizationPct: _parseDouble(json['utilizationPct']),
      warningBreached: json['warningBreached'] ?? false,
      criticalBreached: json['criticalBreached'] ?? false,
      overspent: json['overspent'] ?? false,
      overspentAt: json['overspentAt'] != null
          ? DateTime.tryParse(json['overspentAt'])
          : null,
      expenseAmount: _parseDouble(json['expenseAmount']),
      wouldExceed: json['wouldExceed'] ?? false,
      hardCapEnabled: json['hardCapEnabled'] ?? false,
      canProceed: json['canProceed'] ?? true,
      reason: json['reason'],
      checkedAt: DateTime.tryParse(json['checkedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Budget reserve response
class BudgetReserveResponse {
  final String budgetPeriodId;
  final String budgetId;
  final String transactionId;
  final double newPendingAmount;
  final double availableAmount;
  final DateTime reservedAt;

  BudgetReserveResponse({
    required this.budgetPeriodId,
    required this.budgetId,
    required this.transactionId,
    required this.newPendingAmount,
    required this.availableAmount,
    required this.reservedAt,
  });

  factory BudgetReserveResponse.fromJson(Map<String, dynamic> json) {
    return BudgetReserveResponse(
      budgetPeriodId: json['budgetPeriodId'] ?? '',
      budgetId: json['budgetId'] ?? '',
      transactionId: json['transactionId'] ?? '',
      newPendingAmount: _parseDouble(json['newPendingAmount']),
      availableAmount: _parseDouble(json['availableAmount']),
      reservedAt: DateTime.tryParse(json['reservedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Budget commit response
class BudgetCommitResponse {
  final String budgetPeriodId;
  final String budgetId;
  final String transactionId;
  final double newSpentAmount;
  final double newPendingAmount;
  final double availableAmount;
  final DateTime committedAt;

  BudgetCommitResponse({
    required this.budgetPeriodId,
    required this.budgetId,
    required this.transactionId,
    required this.newSpentAmount,
    required this.newPendingAmount,
    required this.availableAmount,
    required this.committedAt,
  });

  factory BudgetCommitResponse.fromJson(Map<String, dynamic> json) {
    return BudgetCommitResponse(
      budgetPeriodId: json['budgetPeriodId'] ?? '',
      budgetId: json['budgetId'] ?? '',
      transactionId: json['transactionId'] ?? '',
      newSpentAmount: _parseDouble(json['newSpentAmount']),
      newPendingAmount: _parseDouble(json['newPendingAmount']),
      availableAmount: _parseDouble(json['availableAmount']),
      committedAt: DateTime.tryParse(json['committedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Budget release response
class BudgetReleaseResponse {
  final String budgetPeriodId;
  final String budgetId;
  final String transactionId;
  final double newPendingAmount;
  final double availableAmount;
  final DateTime releasedAt;

  BudgetReleaseResponse({
    required this.budgetPeriodId,
    required this.budgetId,
    required this.transactionId,
    required this.newPendingAmount,
    required this.availableAmount,
    required this.releasedAt,
  });

  factory BudgetReleaseResponse.fromJson(Map<String, dynamic> json) {
    return BudgetReleaseResponse(
      budgetPeriodId: json['budgetPeriodId'] ?? '',
      budgetId: json['budgetId'] ?? '',
      transactionId: json['transactionId'] ?? '',
      newPendingAmount: _parseDouble(json['newPendingAmount']),
      availableAmount: _parseDouble(json['availableAmount']),
      releasedAt: DateTime.tryParse(json['releasedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

// ============ Request DTOs ============

/// Create budget request
class CreateBudgetRequest {
  final String code;
  final String name;
  final String? description;
  final double budgetAmount;
  final String budgetCurrency;
  final String? departmentId;
  final String? costCenterId;
  final String? categoryId;
  final String renewalPeriod;
  final int? periodStartDay;
  final int? fiscalYearStart;
  final bool hardSpendingCap;
  final int warningThreshold;
  final int criticalThreshold;
  final bool isActive;

  CreateBudgetRequest({
    required this.code,
    required this.name,
    this.description,
    required this.budgetAmount,
    this.budgetCurrency = 'IDR',
    this.departmentId,
    this.costCenterId,
    this.categoryId,
    this.renewalPeriod = 'monthly',
    this.periodStartDay,
    this.fiscalYearStart,
    this.hardSpendingCap = false,
    this.warningThreshold = 80,
    this.criticalThreshold = 90,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      if (description != null) 'description': description,
      'budgetAmount': budgetAmount.toString(),
      'budgetCurrency': budgetCurrency,
      if (departmentId != null) 'departmentId': departmentId,
      if (costCenterId != null) 'costCenterId': costCenterId,
      if (categoryId != null) 'categoryId': categoryId,
      'renewalPeriod': renewalPeriod,
      if (periodStartDay != null) 'periodStartDay': periodStartDay,
      if (fiscalYearStart != null) 'fiscalYearStart': fiscalYearStart,
      'hardSpendingCap': hardSpendingCap,
      'warningThreshold': warningThreshold,
      'criticalThreshold': criticalThreshold,
      'isActive': isActive,
    };
  }
}

/// Update budget request
class UpdateBudgetRequest {
  final String? code;
  final String? name;
  final String? description;
  final double? budgetAmount;
  final String? budgetCurrency;
  final String? departmentId;
  final String? costCenterId;
  final String? categoryId;
  final String? renewalPeriod;
  final int? periodStartDay;
  final int? fiscalYearStart;
  final bool? hardSpendingCap;
  final int? warningThreshold;
  final int? criticalThreshold;
  final bool? isActive;

  UpdateBudgetRequest({
    this.code,
    this.name,
    this.description,
    this.budgetAmount,
    this.budgetCurrency,
    this.departmentId,
    this.costCenterId,
    this.categoryId,
    this.renewalPeriod,
    this.periodStartDay,
    this.fiscalYearStart,
    this.hardSpendingCap,
    this.warningThreshold,
    this.criticalThreshold,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (budgetAmount != null) 'budgetAmount': budgetAmount.toString(),
      if (budgetCurrency != null) 'budgetCurrency': budgetCurrency,
      if (departmentId != null) 'departmentId': departmentId,
      if (costCenterId != null) 'costCenterId': costCenterId,
      if (categoryId != null) 'categoryId': categoryId,
      if (renewalPeriod != null) 'renewalPeriod': renewalPeriod,
      if (periodStartDay != null) 'periodStartDay': periodStartDay,
      if (fiscalYearStart != null) 'fiscalYearStart': fiscalYearStart,
      if (hardSpendingCap != null) 'hardSpendingCap': hardSpendingCap,
      if (warningThreshold != null) 'warningThreshold': warningThreshold,
      if (criticalThreshold != null) 'criticalThreshold': criticalThreshold,
      if (isActive != null) 'isActive': isActive,
    };
  }
}

// ============ Helper Functions ============

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

double? _parseDoubleNullable(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
