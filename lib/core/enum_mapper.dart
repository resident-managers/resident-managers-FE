import '../models/resident.dart';

class EnumMapper {
  static String? relationshipToVietnamese(String? rawValue, Gender gender) {
    final value = rawValue?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }

    switch (value.toUpperCase()) {
      case 'HEAD':
      case 'HOUSEHOLD_HEAD':
        return 'Chủ hộ';
      case 'SPOUSE':
        return gender == Gender.nu ? 'Vợ' : 'Chồng';
      case 'CHILD':
        return 'Con';
      case 'PARENT':
        return gender == Gender.nu ? 'Mẹ' : 'Bố';
      case 'GRANDPARENT':
        return gender == Gender.nu ? 'Bà' : 'Ông';
      case 'GRANDCHILD':
        return 'Cháu';
      case 'SIBLING':
        return 'Anh/Chị/Em';
      case 'OTHER':
        return 'Khác';
      default:
        return value;
    }
  }
}
