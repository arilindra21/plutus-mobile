/// Base Financial Instrument
abstract class FinancialInstrument {
  String get id;
  String get type;
  String get name;
  double get balance;
  double get limit;
  String get currency;
  String get status;

  double get remaining => limit - balance;
  double get usagePercent => limit > 0 ? (balance / limit) * 100 : 0;
}

/// Wallet Model
class Wallet implements FinancialInstrument {
  @override
  final String id;
  @override
  final String type = 'wallet';
  @override
  final String name;
  @override
  final double balance;
  @override
  final double limit;
  @override
  final String currency;
  @override
  final String status;

  Wallet({
    required this.id,
    required this.name,
    required this.balance,
    required this.limit,
    this.currency = 'IDR',
    this.status = 'active',
  });

  @override
  double get remaining => limit - balance;

  @override
  double get usagePercent => limit > 0 ? (balance / limit) * 100 : 0;

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      id: map['id'] as String,
      name: map['name'] as String,
      balance: (map['balance'] as num).toDouble(),
      limit: (map['limit'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'IDR',
      status: map['status'] as String? ?? 'active',
    );
  }
}

/// Corporate Card Model
class CorporateCard implements FinancialInstrument {
  @override
  final String id;
  @override
  final String type = 'card';
  @override
  final String name;
  final String lastFour;
  @override
  final double balance;
  @override
  final double limit;
  @override
  final String currency;
  @override
  final String status;
  final String cardNetwork;
  final String holderName;
  final String expiryDate;

  CorporateCard({
    required this.id,
    required this.name,
    required this.lastFour,
    required this.balance,
    required this.limit,
    this.currency = 'IDR',
    this.status = 'active',
    required this.cardNetwork,
    this.holderName = 'Card Holder',
    this.expiryDate = '12/28',
  });

  @override
  double get remaining => limit - balance;

  @override
  double get usagePercent => limit > 0 ? (balance / limit) * 100 : 0;

  factory CorporateCard.fromMap(Map<String, dynamic> map) {
    return CorporateCard(
      id: map['id'] as String,
      name: map['name'] as String,
      lastFour: map['lastFour'] as String,
      balance: (map['balance'] as num).toDouble(),
      limit: (map['limit'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'IDR',
      status: map['status'] as String? ?? 'active',
      cardNetwork: map['cardNetwork'] as String,
    );
  }
}

/// Department Budget Model
class Budget implements FinancialInstrument {
  @override
  final String id;
  @override
  final String type = 'budget';
  @override
  final String name;
  final String department;
  @override
  final double balance;
  @override
  final double limit;
  @override
  final String currency;
  @override
  final String status;
  final String period;

  Budget({
    required this.id,
    required this.name,
    required this.department,
    required this.balance,
    required this.limit,
    this.currency = 'IDR',
    this.status = 'active',
    required this.period,
  });

  @override
  double get remaining => limit - balance;

  @override
  double get usagePercent => limit > 0 ? (balance / limit) * 100 : 0;

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as String,
      name: map['name'] as String,
      department: map['department'] as String,
      balance: (map['balance'] as num).toDouble(),
      limit: (map['limit'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'IDR',
      status: map['status'] as String? ?? 'active',
      period: map['period'] as String,
    );
  }
}
