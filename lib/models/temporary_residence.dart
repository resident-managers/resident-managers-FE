class TemporaryResidence {
  final String id;
  final String address;
  final String? hostName;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? reason;
  final DateTime? createdAt;

  TemporaryResidence({
    required this.id,
    required this.address,
    this.hostName,
    this.fromDate,
    this.toDate,
    this.reason,
    this.createdAt,
  });

  factory TemporaryResidence.fromJson(Map<String, dynamic> json) {
    return TemporaryResidence(
      id: json['id']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      hostName: json['hostName']?.toString(),
      fromDate: json['fromDate'] != null ? DateTime.tryParse(json['fromDate'].toString()) : null,
      toDate: json['toDate'] != null ? DateTime.tryParse(json['toDate'].toString()) : null,
      reason: json['reason']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  bool get isActive {
    if (fromDate == null) return false;
    final now = DateTime.now();
    if (fromDate!.isAfter(now)) return false;
    if (toDate != null && toDate!.isBefore(now)) return false;
    return true;
  }
}
