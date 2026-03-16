class SocialInsurance {
  final String id;
  final String code;
  final String? employer;
  final DateTime? enrolledDate;
  final String? insuranceType; // COMPULSORY, VOLUNTARY
  final String? status; // ACTIVE, RESERVED, PENSION, STOPPED
  final DateTime? createdAt;

  SocialInsurance({
    required this.id,
    required this.code,
    this.employer,
    this.enrolledDate,
    this.insuranceType,
    this.status,
    this.createdAt,
  });

  factory SocialInsurance.fromJson(Map<String, dynamic> json) {
    return SocialInsurance(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      employer: json['employer']?.toString(),
      enrolledDate: json['enrolledDate'] != null ? DateTime.tryParse(json['enrolledDate'].toString()) : null,
      insuranceType: json['insuranceType']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  String get insuranceTypeVn {
    switch (insuranceType) {
      case 'COMPULSORY': return 'Bắt buộc';
      case 'VOLUNTARY': return 'Tự nguyện';
      default: return insuranceType ?? '-';
    }
  }

  String get statusVn {
    switch (status) {
      case 'ACTIVE': return 'Đang tham gia';
      case 'RESERVED': return 'Bảo lưu';
      case 'PENSION': return 'Hưu trí';
      case 'STOPPED': return 'Dừng đóng';
      default: return status ?? '-';
    }
  }
}
