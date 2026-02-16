/// Expense/Transaction Model
class Expense {
  final int? id;
  final String merchant;
  final String category;
  final double amount;
  final String date;
  final int status;
  final String icon;
  final String? notes;
  final bool missingReceipt;
  final String? cardId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Attachment> attachments;
  final String? submittedBy;
  final String? submitterInitials;

  Expense({
    this.id,
    required this.merchant,
    required this.category,
    required this.amount,
    required this.date,
    this.status = 0,
    required this.icon,
    this.notes,
    this.missingReceipt = false,
    this.cardId,
    this.createdAt,
    this.updatedAt,
    this.attachments = const [],
    this.submittedBy,
    this.submitterInitials,
  });

  Expense copyWith({
    int? id,
    String? merchant,
    String? category,
    double? amount,
    String? date,
    int? status,
    String? icon,
    String? notes,
    bool? missingReceipt,
    String? cardId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Attachment>? attachments,
    String? submittedBy,
    String? submitterInitials,
  }) {
    return Expense(
      id: id ?? this.id,
      merchant: merchant ?? this.merchant,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      status: status ?? this.status,
      icon: icon ?? this.icon,
      notes: notes ?? this.notes,
      missingReceipt: missingReceipt ?? this.missingReceipt,
      cardId: cardId ?? this.cardId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attachments: attachments ?? this.attachments,
      submittedBy: submittedBy ?? this.submittedBy,
      submitterInitials: submitterInitials ?? this.submitterInitials,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'merchant': merchant,
      'category': category,
      'amount': amount,
      'date': date,
      'status': status,
      'icon': icon,
      'notes': notes,
      'missing_receipt': missingReceipt ? 1 : 0,
      'card_id': cardId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'submitted_by': submittedBy,
      'submitter_initials': submitterInitials,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      merchant: map['merchant'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: map['date'] as String,
      status: map['status'] as int? ?? 0,
      icon: map['icon'] as String? ?? '📋',
      notes: map['notes'] as String?,
      missingReceipt: (map['missing_receipt'] as int? ?? 0) == 1,
      cardId: map['card_id'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      submittedBy: map['submitted_by'] as String?,
      submitterInitials: map['submitter_initials'] as String?,
    );
  }
}

/// Attachment Model
class Attachment {
  final int? id;
  final int expenseId;
  final String fileName;
  final String fileType;
  final String data;
  final String? thumbnail;
  final DateTime? createdAt;

  Attachment({
    this.id,
    required this.expenseId,
    required this.fileName,
    required this.fileType,
    required this.data,
    this.thumbnail,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'expense_id': expenseId,
      'file_name': fileName,
      'file_type': fileType,
      'data': data,
      'thumbnail': thumbnail,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory Attachment.fromMap(Map<String, dynamic> map) {
    return Attachment(
      id: map['id'] as int?,
      expenseId: map['expense_id'] as int,
      fileName: map['file_name'] as String,
      fileType: map['file_type'] as String,
      data: map['data'] as String,
      thumbnail: map['thumbnail'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }
}
