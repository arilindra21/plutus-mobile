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

/// Approval history item from /api/v1/approvals/history
class ApprovalHistoryDTO {
  final String id;
  final String action; // approved, rejected, returned, submitted, created, edited
  final String actorId;
  final String actorName;
  final String? actorEmail;
  final String expenseId;
  final String? refId;
  final String? merchant;
  final double amount;
  final String? currency;
  final String? category;
  final String? categoryIcon;
  final String? comment;
  final DateTime createdAt;

  ApprovalHistoryDTO({
    required this.id,
    required this.action,
    required this.actorId,
    required this.actorName,
    this.actorEmail,
    required this.expenseId,
    this.refId,
    this.merchant,
    required this.amount,
    this.currency,
    this.category,
    this.categoryIcon,
    this.comment,
    required this.createdAt,
  });

  factory ApprovalHistoryDTO.fromJson(Map<String, dynamic> json) {
    return ApprovalHistoryDTO(
      id: json['id'] ?? '',
      action: json['action'] ?? json['decision'] ?? 'unknown',
      actorId: json['actor_id'] ?? json['approver_id'] ?? json['user_id'] ?? '',
      actorName: json['actor_name'] ?? json['approver_name'] ?? json['user_name'] ?? 'Unknown',
      actorEmail: json['actor_email'] ?? json['approver_email'],
      expenseId: json['expense_id'] ?? '',
      refId: json['ref_id'] ?? json['expense_ref_id'],
      merchant: json['merchant'] ?? json['merchant_name'],
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'IDR',
      category: json['category'] ?? json['category_name'],
      categoryIcon: json['category_icon'],
      comment: json['comment'] ?? json['comments'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  /// Get display action text
  String get actionDisplay {
    switch (action.toLowerCase()) {
      case 'approved':
      case 'approve':
        return 'Approved';
      case 'rejected':
      case 'reject':
        return 'Rejected';
      case 'returned':
      case 'return':
        return 'Returned for Revision';
      case 'submitted':
      case 'submit':
        return 'Submitted';
      case 'created':
      case 'create':
        return 'Created';
      case 'edited':
      case 'edit':
        return 'Edited';
      default:
        return action;
    }
  }

  /// Get formatted ref ID
  String get formattedRefId {
    if (refId != null && refId!.isNotEmpty) return refId!;
    if (expenseId.length >= 8) {
      return 'EXP-${expenseId.substring(0, 8).toUpperCase()}';
    }
    return 'EXP-$expenseId';
  }
}

/// Audit log item from /reports/audit-log (for Team Activity screen)
class AuditLogDTO {
  final String id;
  final String eventType; // expense.submitted, approval.approved, etc.
  final String action; // create, update, delete, approve, reject, return, submit
  final String targetType; // expense, user, approval_task, workflow_run
  final String targetId;
  final String? actorType; // user, system, webhook, api
  final String? actorId;
  final String? actorName;
  final String? actorEmail;
  final String? ipAddress;
  final String? requestId;
  final List<String>? changedFields;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  // Enriched expense data (populated after lookup)
  ExpenseDTO? _expense;
  bool _hasPermission = true; // Assume user has permission unless proven otherwise

  ExpenseDTO? get expense => _expense;
  bool get hasPermission => _hasPermission;

  AuditLogDTO({
    required this.id,
    required this.eventType,
    required this.action,
    required this.targetType,
    required this.targetId,
    this.actorType,
    this.actorId,
    this.actorName,
    this.actorEmail,
    this.ipAddress,
    this.requestId,
    this.changedFields,
    this.metadata,
    required this.createdAt,
  });

  /// Enrich with expense details
  void enrichWithExpense(ExpenseDTO expense) {
    _expense = expense;
    _hasPermission = true;
  }

  /// Mark as no permission
  void markNoPermission() {
    _hasPermission = false;
  }

  factory AuditLogDTO.fromJson(Map<String, dynamic> json) {
    return AuditLogDTO(
      id: json['id'] ?? '',
      eventType: json['eventType'] ?? json['event_type'] ?? '',
      action: json['action'] ?? '',
      targetType: json['targetType'] ?? json['target_type'] ?? '',
      targetId: json['targetId'] ?? json['target_id'] ?? '',
      actorType: json['actorType'] ?? json['actor_type'],
      actorId: json['actorId'] ?? json['actor_id'],
      actorName: json['actorName'] ?? json['actor_name'],
      actorEmail: json['actorEmail'] ?? json['actor_email'],
      ipAddress: json['ipAddress'] ?? json['ip_address'],
      requestId: json['requestId'] ?? json['request_id'],
      changedFields: json['changedFields'] != null || json['changed_fields'] != null
          ? List<String>.from(json['changedFields'] ?? json['changed_fields'] ?? [])
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
    );
  }

  /// Get display action text
  String get actionDisplay {
    switch (action.toLowerCase()) {
      case 'approve':
      case 'approved':
        return 'Approved';
      case 'reject':
      case 'rejected':
        return 'Rejected';
      case 'return':
      case 'returned':
        return 'Returned';
      case 'submit':
      case 'submitted':
        return 'Submitted';
      case 'create':
      case 'created':
        return 'Created';
      case 'update':
      case 'updated':
        return 'Edited';
      case 'delete':
      case 'deleted':
        return 'Deleted';
      default:
        return action.isNotEmpty ? action[0].toUpperCase() + action.substring(1) : action;
    }
  }

  /// Get expense reference from enriched expense or metadata or targetId
  String get expenseRef {
    // Try enriched expense first
    if (_expense != null) {
      final expenseIdShort = _expense!.id.length >= 8
          ? _expense!.id.substring(0, 8).toUpperCase()
          : _expense!.id.toUpperCase();
      return 'EXP-$expenseIdShort';
    }
    // Try to get from metadata
    if (metadata != null) {
      final refId = metadata!['refId'] ?? metadata!['ref_id'] ?? metadata!['expenseRef'];
      if (refId != null) return refId.toString();
    }
    // Fallback to target ID
    if (targetId.length >= 8) {
      return 'EXP-${targetId.substring(0, 8).toUpperCase()}';
    }
    return 'EXP-$targetId';
  }

  /// Get amount from enriched expense or metadata
  double get amount {
    // Try enriched expense first
    if (_expense != null) {
      return _expense!.originalAmount;
    }
    // Try metadata
    if (metadata != null) {
      final amt = metadata!['amount'] ?? metadata!['originalAmount'] ?? metadata!['original_amount'];
      if (amt != null) return (amt as num).toDouble();
    }
    return 0;
  }

  /// Get merchant from enriched expense or metadata
  String get merchant {
    // Try enriched expense first
    if (_expense != null && _expense!.merchant.isNotEmpty) {
      return _expense!.merchant;
    }
    // Try metadata
    if (metadata != null) {
      return metadata!['merchant'] ?? metadata!['merchantName'] ?? metadata!['merchant_name'] ?? 'Unknown';
    }
    return 'Unknown';
  }

  /// Get description from enriched expense or metadata
  String? get description {
    // Try enriched expense first
    if (_expense != null && _expense!.description != null && _expense!.description!.isNotEmpty) {
      return _expense!.description;
    }
    // Try metadata
    if (metadata != null) {
      return metadata!['description'] ?? metadata!['comments'] ?? metadata!['comment'];
    }
    return null;
  }

  /// Get category from enriched expense or metadata
  String get category {
    // Try enriched expense first
    if (_expense != null) {
      final cat = _expense!.categoryName ?? _expense!.category;
      if (cat.isNotEmpty) return cat;
    }
    // Try metadata
    if (metadata != null) {
      return metadata!['category'] ?? metadata!['categoryName'] ?? metadata!['category_name'] ?? 'Other';
    }
    return 'Other';
  }

  /// Get category icon from enriched expense or metadata
  String get categoryIcon {
    // Try enriched expense first
    if (_expense != null && _expense!.categoryIcon != null && _expense!.categoryIcon!.isNotEmpty) {
      return _expense!.categoryIcon!;
    }
    // Try metadata
    if (metadata != null) {
      return metadata!['categoryIcon'] ?? metadata!['category_icon'] ?? '📋';
    }
    return '📋';
  }

  /// Get formatted date for display
  String get formattedDate {
    if (_expense != null) {
      return _expense!.formattedDate;
    }
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}
