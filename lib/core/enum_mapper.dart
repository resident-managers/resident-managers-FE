import '../models/resident.dart';

class EnumMapper {
  static String? relationshipToVietnamese(String? rawValue, Gender gender) {
    final value = rawValue?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }

    switch (value.toLowerCase()) {
      case 'head':
      case 'household_head':
        return 'Chủ hộ';
      case 'spouse':
      case 'husband':
        return 'Chồng';
      case 'wife':
        return 'Vợ';
      case 'child':
      case 'son':
        return 'Con';
      case 'parent':
      case 'father':
        return 'Bố';
      case 'mother':
        return 'Mẹ';
      case 'older_brother':
        return 'Anh trai';
      case 'older_sister':
        return 'Chị gái';
      case 'younger_sibling':
      case 'sibling':
        return 'Em';
      default:
        return value;
    }
  }
}
