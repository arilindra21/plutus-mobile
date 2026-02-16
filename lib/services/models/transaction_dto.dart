/// Transaction DTO matching backend schema for card transactions
class TransactionDTO {
  final String id;
  final String organizationId;
  final String entityId;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String cardId;
  final String? cardLastFour;
  final String? cardName;
  final double amount;
  final String currency;
  final double? baseAmount;
  final String? baseCurrency;
  final double? exchangeRate;
  final String? merchantName;
  final String? merchantId;
  final String? merchantCategory;
  final String? mccCode;
  final String? mccDescription;
  final String? categoryId;
  final String? categoryName;
  final String? categoryCode;
  final int status;
  final String? statusName;
  final int receiptStatus;
  final String? receiptStatusName;
  final bool receiptRequired;
  final DateTime? receiptDueDate;
  final String? expenseId;
  final String? description;
  final String? notes;
  final DateTime transactionDate;
  final DateTime? settledAt;
  final String? referenceNumber;
  final String? authorizationCode;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TransactionDTO({
    required this.id,
    required this.organizationId,
    required this.entityId,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.cardId,
    this.cardLastFour,
    this.cardName,
    required this.amount,
    required this.currency,
    this.baseAmount,
    this.baseCurrency,
    this.exchangeRate,
    this.merchantName,
    this.merchantId,
    this.merchantCategory,
    this.mccCode,
    this.mccDescription,
    this.categoryId,
    this.categoryName,
    this.categoryCode,
    required this.status,
    this.statusName,
    this.receiptStatus = 1,
    this.receiptStatusName,
    this.receiptRequired = true,
    this.receiptDueDate,
    this.expenseId,
    this.description,
    this.notes,
    required this.transactionDate,
    this.settledAt,
    this.referenceNumber,
    this.authorizationCode,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
  });

  factory TransactionDTO.fromJson(Map<String, dynamic> json) {
    // Handle nil UUID from API (expenseId = "00000000-0000-0000-0000-000000000000")
    String? expenseId = json['expenseId'];
    if (expenseId == '00000000-0000-0000-0000-000000000000') {
      expenseId = null;
    }

    return TransactionDTO(
      id: json['id'] ?? '',
      organizationId: json['organizationId'] ?? '',
      entityId: json['entityId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'],
      userEmail: json['userEmail'],
      cardId: json['cardId'] ?? '',
      cardLastFour: json['cardLastFour'],
      cardName: json['cardName'],
      // API uses originalAmount/originalCurrency, fallback to amount/currency
      amount: _parseDouble(json['originalAmount'] ?? json['amount']),
      currency: json['originalCurrency'] ?? json['currency'] ?? 'IDR',
      baseAmount: _parseDoubleNullable(json['baseAmount']),
      baseCurrency: json['baseCurrency'],
      exchangeRate: _parseDoubleNullable(json['exchangeRate']),
      merchantName: json['merchantName'],
      merchantId: json['merchantId'],
      merchantCategory: json['merchantCategory'],
      mccCode: json['mccCode'],
      mccDescription: json['mccDescription'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      categoryCode: json['categoryCode'],
      status: json['status'] ?? 0,
      statusName: json['statusName'],
      // receiptStatus: 0=not required, 1=pending, 2=uploaded, 3=verified, 4=missing
      // If receiptPrompt is false, receipt is not required (status 0)
      receiptStatus: json['receiptStatus'] ?? (json['receiptPrompt'] == false ? 0 : 1),
      receiptStatusName: json['receiptStatusName'],
      // API uses receiptPrompt instead of receiptRequired
      receiptRequired: json['receiptRequired'] ?? json['receiptPrompt'] ?? false,
      receiptDueDate: json['receiptDueDate'] != null
          ? DateTime.tryParse(json['receiptDueDate'])
          : null,
      expenseId: expenseId,
      description: json['description'],
      notes: json['notes'],
      transactionDate:
          DateTime.tryParse(json['transactionDate'] ?? '') ?? DateTime.now(),
      // API uses postedDate instead of settledAt
      settledAt: json['settledAt'] != null
          ? DateTime.tryParse(json['settledAt'])
          : (json['postedDate'] != null
              ? DateTime.tryParse(json['postedDate'])
              : null),
      // API uses referenceId instead of referenceNumber
      referenceNumber: json['referenceNumber'] ?? json['referenceId'],
      authorizationCode: json['authorizationCode'],
      metadata: json['metadata'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'entityId': entityId,
      'userId': userId,
      'userName': userName,
      'cardId': cardId,
      'cardLastFour': cardLastFour,
      'amount': amount,
      'currency': currency,
      'merchantName': merchantName,
      'categoryId': categoryId,
      'status': status,
      'receiptStatus': receiptStatus,
      'expenseId': expenseId,
      'transactionDate': transactionDate.toIso8601String(),
    };
  }

  /// Check if this transaction needs a receipt uploaded
  bool get needsReceipt =>
      receiptRequired && receiptStatus == 1 && expenseId == null;

  /// Check if receipt is overdue
  bool get isReceiptOverdue {
    if (!needsReceipt || receiptDueDate == null) return false;
    return DateTime.now().isAfter(receiptDueDate!);
  }

  /// Get display name for merchant
  String get merchant => merchantName ?? 'Unknown Merchant';

  /// Get display name for category
  String get category => categoryName ?? mccDescription ?? 'Uncategorized';

  /// Get card display (last 4 digits)
  String get cardDisplay => cardLastFour != null ? '•••• $cardLastFour' : '';

  /// Get formatted date string
  String get formattedDate {
    return '${transactionDate.day.toString().padLeft(2, '0')}/${transactionDate.month.toString().padLeft(2, '0')}/${transactionDate.year}';
  }

  /// Check if linked to an expense
  bool get hasExpense => expenseId != null && expenseId!.isNotEmpty;

  /// Get receipt status label
  String get receiptStatusLabel {
    switch (receiptStatus) {
      case 0:
        return 'Not Required';
      case 1:
        return 'Pending';
      case 2:
        return 'Uploaded';
      case 3:
        return 'Verified';
      case 4:
        return 'Missing';
      default:
        return 'Unknown';
    }
  }
}

/// Transaction list filter parameters
class TransactionListParams {
  final int page;
  final int pageSize;
  final String sortBy;
  final String sortOrder;
  final int? status;
  final int? receiptStatus;
  final bool? needsReceipt;
  final String? cardId;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? search;

  TransactionListParams({
    this.page = 1,
    this.pageSize = 20,
    this.sortBy = 'transaction_date',
    this.sortOrder = 'desc',
    this.status,
    this.receiptStatus,
    this.needsReceipt,
    this.cardId,
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
    if (receiptStatus != null) params['receipt_status'] = receiptStatus;
    if (needsReceipt != null) params['needs_receipt'] = needsReceipt;
    if (cardId != null) params['card_id'] = cardId;
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

/// Link transaction to expense request
class LinkExpenseRequest {
  final String expenseId;

  LinkExpenseRequest({required this.expenseId});

  Map<String, dynamic> toJson() => {'expenseId': expenseId};
}

/// Transaction summary for dashboard
class TransactionSummary {
  final int totalCount;
  final int pendingReceiptCount;
  final int overdueReceiptCount;
  final double totalAmount;
  final String currency;

  TransactionSummary({
    required this.totalCount,
    required this.pendingReceiptCount,
    required this.overdueReceiptCount,
    required this.totalAmount,
    required this.currency,
  });

  factory TransactionSummary.fromJson(Map<String, dynamic> json) {
    return TransactionSummary(
      totalCount: json['totalCount'] ?? 0,
      pendingReceiptCount: json['pendingReceiptCount'] ?? 0,
      overdueReceiptCount: json['overdueReceiptCount'] ?? 0,
      totalAmount: TransactionDTO._parseDouble(json['totalAmount']),
      currency: json['currency'] ?? 'IDR',
    );
  }

  bool get hasPendingReceipts => pendingReceiptCount > 0;
  bool get hasOverdueReceipts => overdueReceiptCount > 0;
}
