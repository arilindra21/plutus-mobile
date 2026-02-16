import 'expense_dto.dart';

/// Approval task from the inbox
class ApprovalTaskDTO {
  final String id;
  final String workflowRunId;
  final String expenseId;
  final String stepId;
  final String? stepName;
  final String approverId;
  final String? approverName;
  final String status;
  final String? decision;
  final String? comment;
  final DateTime? decidedAt;
  final DateTime createdAt;
  final ExpenseDTO? expense;

  // Direct fields from API (not nested in expense)
  final String? _requesterId;
  final String? _requesterName;
  final String? _requesterEmail;
  final double? _amount;
  final String? _currency;
  final String? _categoryName;
  final String? _description;
  final String? _merchantName;

  ApprovalTaskDTO({
    required this.id,
    required this.workflowRunId,
    required this.expenseId,
    required this.stepId,
    this.stepName,
    required this.approverId,
    this.approverName,
    required this.status,
    this.decision,
    this.comment,
    this.decidedAt,
    required this.createdAt,
    this.expense,
    String? requesterId,
    String? requesterName,
    String? requesterEmail,
    double? amount,
    String? currency,
    String? categoryName,
    String? description,
    String? merchantName,
  })  : _requesterId = requesterId,
        _requesterName = requesterName,
        _requesterEmail = requesterEmail,
        _amount = amount,
        _currency = currency,
        _categoryName = categoryName,
        _description = description,
        _merchantName = merchantName;

  factory ApprovalTaskDTO.fromJson(Map<String, dynamic> json) {
    // Helper to safely convert to string
    String? safeString(dynamic value) {
      if (value == null) return null;
      return value.toString();
    }

    // Helper to safely parse double
    double? safeDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    // Parse expense if present (for backward compatibility)
    ExpenseDTO? expense;
    if (json['expense'] != null) {
      expense = ExpenseDTO.fromJson(json['expense']);
    }

    return ApprovalTaskDTO(
      id: safeString(json['id']) ?? '',
      workflowRunId: safeString(json['workflowRunId']) ?? '',
      // API uses 'targetId' for the expense ID
      expenseId: safeString(json['expenseId']) ?? safeString(json['targetId']) ?? '',
      stepId: safeString(json['stepId']) ?? '',
      stepName: safeString(json['stepName']),
      approverId: safeString(json['approverId']) ?? '',
      approverName: safeString(json['approverName']),
      // API returns status as int, but also provides statusName
      status: safeString(json['statusName']) ?? safeString(json['status']) ?? 'pending',
      decision: safeString(json['decision']),
      comment: safeString(json['comment']) ?? safeString(json['comments']),
      decidedAt: json['decidedAt'] != null
          ? DateTime.tryParse(json['decidedAt'].toString())
          : (json['decisionAt'] != null
              ? DateTime.tryParse(json['decisionAt'].toString())
              : null),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      expense: expense,
      // Direct fields from API (not nested)
      requesterId: safeString(json['requesterId']),
      requesterName: safeString(json['requesterName']),
      requesterEmail: safeString(json['requesterEmail']),
      amount: safeDouble(json['amount']),
      currency: safeString(json['currency']),
      categoryName: safeString(json['categoryName']),
      description: safeString(json['description']),
      merchantName: safeString(json['merchantName']),
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => decision == 'approved';
  bool get isRejected => decision == 'rejected';
  bool get isReturned => decision == 'returned';

  // Convenience getters - check direct fields first, then expense
  String get requesterName {
    // First check direct field from API
    final name = _requesterName;
    if (name != null && name.isNotEmpty) {
      return name;
    }
    // Then try from expense
    final expenseName = expense?.requesterName;
    if (expenseName != null && expenseName.isNotEmpty) {
      return expenseName;
    }
    return ''; // Return empty so UI can do lookup
  }

  String get requesterId {
    final id = _requesterId;
    if (id != null && id.isNotEmpty) {
      return id;
    }
    return expense?.requesterId ?? '';
  }

  String get requesterEmail {
    final email = _requesterEmail;
    if (email != null && email.isNotEmpty) {
      return email;
    }
    return expense?.submitterEmail ?? '';
  }

  String get merchant {
    final name = _merchantName;
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return expense?.merchant ?? 'Unknown Vendor';
  }

  String get category {
    final name = _categoryName;
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return expense?.category ?? 'Other';
  }

  String? get categoryIcon => expense?.categoryIcon;

  double get amount {
    final amt = _amount;
    if (amt != null && amt > 0) {
      return amt;
    }
    return expense?.originalAmount ?? 0.0;
  }

  String get currency {
    final curr = _currency;
    if (curr != null && curr.isNotEmpty) {
      return curr;
    }
    return expense?.originalCurrency ?? 'IDR';
  }

  String? get description {
    final desc = _description;
    if (desc != null && desc.isNotEmpty) {
      return desc;
    }
    return expense?.description;
  }

  DateTime get expenseDate => expense?.expenseDate ?? createdAt;

  String get formattedDate {
    final date = expenseDate;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

/// Approval inbox summary
class ApprovalInboxSummary {
  final int pendingCount;
  final int approvedCount;
  final int rejectedCount;
  final int returnedCount;
  final int totalCount;

  ApprovalInboxSummary({
    required this.pendingCount,
    required this.approvedCount,
    required this.rejectedCount,
    required this.returnedCount,
    required this.totalCount,
  });

  factory ApprovalInboxSummary.fromJson(Map<String, dynamic> json) {
    return ApprovalInboxSummary(
      pendingCount: json['pendingCount'] ?? 0,
      approvedCount: json['approvedCount'] ?? 0,
      rejectedCount: json['rejectedCount'] ?? 0,
      returnedCount: json['returnedCount'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
    );
  }
}

/// Approval decision request
class ApprovalDecisionRequest {
  final String? comment;

  ApprovalDecisionRequest({this.comment});

  Map<String, dynamic> toJson() {
    return {
      if (comment != null && comment!.isNotEmpty) 'comments': comment,
    };
  }
}

/// Bulk approval request
class BulkApprovalRequest {
  final List<String> taskIds;
  final String? comment;

  BulkApprovalRequest({
    required this.taskIds,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'taskIds': taskIds,
      if (comment != null && comment!.isNotEmpty) 'comments': comment,
    };
  }
}

/// Approval inbox filter parameters
class ApprovalInboxParams {
  final int page;
  final int pageSize;
  final String sortBy;
  final String sortOrder;
  final String? status;
  final String? decision;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  ApprovalInboxParams({
    this.page = 1,
    this.pageSize = 20,
    this.sortBy = 'created_at',
    this.sortOrder = 'desc',
    this.status,
    this.decision,
    this.dateFrom,
    this.dateTo,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      'sort_by': sortBy,
      'sort_order': sortOrder,
    };

    if (status != null) params['status'] = status;
    if (decision != null) params['decision'] = decision;
    if (dateFrom != null) params['date_from'] = dateFrom!.toIso8601String();
    if (dateTo != null) params['date_to'] = dateTo!.toIso8601String();

    return params;
  }
}
