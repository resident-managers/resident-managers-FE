class HealthInsurance {
  final String id;
  final String code;
  final String? healthcareFacility;
  final DateTime? issuedDate;
  final DateTime? expiryDate;
  final DateTime? createdAt;

  HealthInsurance({
    required this.id,
    required this.code,
    this.healthcareFacility,
    this.issuedDate,
    this.expiryDate,
    this.createdAt,
  });

  factory HealthInsurance.fromJson(Map<String, dynamic> json) {
    return HealthInsurance(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      healthcareFacility: json['healthcareFacility']?.toString(),
      issuedDate: json['issuedDate'] != null ? DateTime.tryParse(json['issuedDate'].toString()) : null,
      expiryDate: json['expiryDate'] != null ? DateTime.tryParse(json['expiryDate'].toString()) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }
}
