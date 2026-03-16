class TemporaryAbsence {
  final String id;
  final String destination;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? reason;
  final DateTime? createdAt;

  TemporaryAbsence({
    required this.id,
    required this.destination,
    this.fromDate,
    this.toDate,
    this.reason,
    this.createdAt,
  });

  factory TemporaryAbsence.fromJson(Map<String, dynamic> json) {
    return TemporaryAbsence(
      id: json['id']?.toString() ?? '',
      destination: json['destination']?.toString() ?? '',
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
