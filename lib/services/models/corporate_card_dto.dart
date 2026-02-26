/// Corporate Card representation
///
/// This DTO represents a corporate card used for expense payments.
class CorporateCardDTO {
  final String id;
  final String lastFourDigits;
  final String cardholderName;
  final String bankName;
  final DateTime? expiryDate;
  final bool isActive;

  CorporateCardDTO({
    required this.id,
    required this.lastFourDigits,
    required this.cardholderName,
    required this.bankName,
    this.expiryDate,
    this.isActive = true,
  });

  factory CorporateCardDTO.fromJson(Map<String, dynamic> json) {
    return CorporateCardDTO(
      id: json['id'] ?? json['cardId'] ?? '',
      lastFourDigits: json['lastFourDigits'] ?? json['last4'] ?? '',
      cardholderName: json['cardholderName'] ?? '',
      bankName: json['bankName'] ?? '',
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lastFourDigits': lastFourDigits,
      'cardholderName': cardholderName,
      'bankName': bankName,
      'expiryDate': expiryDate?.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Display label for UI
  String get displayLabel => '$bankName •••• $lastFourDigits';

  /// Alias for backward compatibility
  CorporateCard get toCard => CorporateCard(
        id: id,
        lastFourDigits: lastFourDigits,
        cardholderName: cardholderName,
        bankName: bankName,
        expiryDate: expiryDate,
        isActive: isActive,
      );
}

/// Legacy CorporateCard alias for backward compatibility
///
/// Use CorporateCardDTO for new code. This alias exists only for
/// compatibility with existing provider code.
class CorporateCard {
  final String id;
  final String lastFourDigits;
  final String cardholderName;
  final String bankName;
  final DateTime? expiryDate;
  final bool isActive;

  CorporateCard({
    required this.id,
    required this.lastFourDigits,
    required this.cardholderName,
    required this.bankName,
    this.expiryDate,
    this.isActive = true,
  });

  /// Create from CorporateCardDTO
  factory CorporateCard.fromDto(CorporateCardDTO dto) {
    return CorporateCard(
      id: dto.id,
      lastFourDigits: dto.lastFourDigits,
      cardholderName: dto.cardholderName,
      bankName: dto.bankName,
      expiryDate: dto.expiryDate,
      isActive: dto.isActive,
    );
  }

  /// Display label for UI
  String get displayLabel => '$bankName •••• $lastFourDigits';
}
