enum Gender {
  nam,
  nu,
  khac;

  String toVnString() {
    switch (this) {
      case Gender.nam:
        return 'Nam';
      case Gender.nu:
        return 'Nữ';
      case Gender.khac:
        return 'Khác';
    }
  }

  static Gender fromVnString(String value) {
    switch (value.toLowerCase()) {
      case 'male':
      case 'nam':
        return Gender.nam;
      case 'female':
      case 'nu':
      case 'nữ':
        return Gender.nu;
      default:
        return Gender.khac;
    }
  }
}

class ResidentHousehold {
  final String id;
  final String? code;
  final String? address;
  final String? headName;
  final List<ResidentHouseholdMember> members;

  const ResidentHousehold({
    required this.id,
    this.code,
    this.address,
    this.headName,
    this.members = const [],
  });

  factory ResidentHousehold.fromJson(Map<String, dynamic> json) {
    final head = _asMap(json['head']) ?? _firstMap(json['head']);
    final membersRaw = json['members'];
    final members = <ResidentHouseholdMember>[];
    if (membersRaw is List) {
      for (final item in membersRaw) {
        final map = _asMap(item);
        if (map != null) {
          members.add(ResidentHouseholdMember.fromJson(map));
        }
      }
    }

    return ResidentHousehold(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString(),
      address: json['address']?.toString(),
      headName: head?['fullName']?.toString(),
      members: members,
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static Map<String, dynamic>? _firstMap(dynamic value) {
    if (value is List && value.isNotEmpty && value.first is Map) {
      return Map<String, dynamic>.from(value.first as Map);
    }
    return null;
  }

  String? relationshipOf(String residentId) {
    for (final member in members) {
      if (member.id == residentId) {
        return member.relationship;
      }
    }
    return null;
  }
}

class ResidentHouseholdMember {
  final String id;
  final String? relationship;

  const ResidentHouseholdMember({required this.id, this.relationship});

  factory ResidentHouseholdMember.fromJson(Map<String, dynamic> json) {
    return ResidentHouseholdMember(
      id: json['id']?.toString() ?? '',
      relationship: json['relationship']?.toString(),
    );
  }
}

class Resident {
  final String id;
  final String fullName;
  final Gender gender;
  final DateTime? birthDate;
  final String? phone;
  final String? identityCard; // CCCD
  final String? address;
  final String? occupation;
  final String? ethnicity; // Dan toc
  final String? religion;
  final String? educationLevel;
  final String? notes;
  final DateTime? createdAt;
  final ResidentHousehold? household;
  final String? relationship;

  Resident({
    required this.id,
    required this.fullName,
    required this.gender,
    this.birthDate,
    this.phone,
    this.identityCard,
    this.address,
    this.occupation,
    this.ethnicity,
    this.religion,
    this.educationLevel,
    this.notes,
    this.createdAt,
    this.household,
    this.relationship,
  });

  factory Resident.fromJson(Map<String, dynamic> json) {
    final rawGender =
        (json['gender'] ?? json['gioiTinh'] ?? json['gioi_tinh'] ?? '')
            .toString();
    final householdJson =
        ResidentHousehold._asMap(json['household']) ??
        ResidentHousehold._firstMap(json['household']);

    return Resident(
      id: json['id']?.toString() ?? '',
      fullName: (json['fullName'] ?? json['hoTen'] ?? json['ho_ten'] ?? '')
          .toString(),
      gender: Gender.fromVnString(rawGender),
      birthDate: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'].toString())
          : (json['ngaySinh'] != null
                ? DateTime.tryParse(json['ngaySinh'].toString())
                : null),
      phone: (json['phone'] ?? json['soDienThoai'] ?? json['so_dien_thoai'])
          ?.toString(),
      identityCard: (json['nationalId'] ?? json['cccd'])?.toString(),
      address: (json['address'] ?? json['diaChi'] ?? json['dia_chi'])
          ?.toString(),
      occupation:
          (json['occupation'] ?? json['ngheNghiep'] ?? json['nghe_nghiep'])
              ?.toString(),
      ethnicity: (json['ethnicity'] ?? json['danToc'] ?? json['dan_toc'])
          ?.toString(),
      religion: (json['religion'] ?? json['tonGiao'] ?? json['ton_giao'])
          ?.toString(),
      educationLevel:
          (json['educationLevel'] ?? json['trinhDoHv'] ?? json['trinh_do_hv'])
              ?.toString(),
      relationship: (json['relationship'] ?? json['quanHe'] ?? json['quan_he'])
          ?.toString(),
      notes: (json['note'] ?? json['ghiChu'] ?? json['ghi_chu'])?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      household: householdJson != null
          ? ResidentHousehold.fromJson(householdJson)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hoTen': fullName,
      'gioiTinh': gender.name.toUpperCase(),
      'ngaySinh': birthDate?.toIso8601String().split('T')[0],
      'soDienThoai': phone,
      'cccd': identityCard,
      'diaChi': address,
      'ngheNghiep': occupation,
      'danToc': ethnicity,
      'tonGiao': religion,
      'trinhDoHv': educationLevel,
      'quanHe': relationship,
      'ghiChu': notes,
    };
  }
}
