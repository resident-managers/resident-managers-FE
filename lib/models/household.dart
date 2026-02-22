import 'resident.dart';

class Household {
  final String id;
  final String? householdCode; // code
  final String address;
  final Resident? head;
  final List<HouseholdMember>? members;

  Household({
    required this.id,
    this.householdCode,
    required this.address,
    this.head,
    this.members,
  });

  factory Household.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'];
    final members = rawMembers is List
        ? rawMembers
              .whereType<Map>()
              .map(
                (m) => HouseholdMember.fromJson(Map<String, dynamic>.from(m)),
              )
              .toList()
        : null;

    return Household(
      id: json['id']?.toString() ?? '',
      householdCode: json['code']?.toString(),
      address: json['address']?.toString() ?? '',
      head: json['head'] is Map
          ? Resident.fromJson(Map<String, dynamic>.from(json['head'] as Map))
          : null,
      members: members,
    );
  }
}

class HouseholdMember {
  final Resident resident;
  final String relationship;

  HouseholdMember({required this.resident, required this.relationship});

  factory HouseholdMember.fromJson(Map<String, dynamic> json) {
    final residentJson = json['resident'] is Map
        ? Map<String, dynamic>.from(json['resident'] as Map)
        : json;

    return HouseholdMember(
      resident: Resident.fromJson(residentJson),
      relationship: json['relationship']?.toString() ?? '',
    );
  }
}
