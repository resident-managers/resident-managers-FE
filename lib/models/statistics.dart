class ResidentStatistics {
  final int totalResidents;
  final int totalHouseholds;
  final int maleCount;
  final int femaleCount;
  final int permanentCount;
  final int temporaryCount;
  final int absentCount;
  final int movedOutCount;
  final int activeTemporaryResidences;
  final int activeTemporaryAbsences;

  ResidentStatistics({
    this.totalResidents = 0,
    this.totalHouseholds = 0,
    this.maleCount = 0,
    this.femaleCount = 0,
    this.permanentCount = 0,
    this.temporaryCount = 0,
    this.absentCount = 0,
    this.movedOutCount = 0,
    this.activeTemporaryResidences = 0,
    this.activeTemporaryAbsences = 0,
  });

  factory ResidentStatistics.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '0') ?? 0;
    return ResidentStatistics(
      totalResidents: toInt(json['totalResidents']),
      totalHouseholds: toInt(json['totalHouseholds']),
      maleCount: toInt(json['maleCount']),
      femaleCount: toInt(json['femaleCount']),
      permanentCount: toInt(json['permanentCount']),
      temporaryCount: toInt(json['temporaryCount']),
      absentCount: toInt(json['absentCount']),
      movedOutCount: toInt(json['movedOutCount']),
      activeTemporaryResidences: toInt(json['activeTemporaryResidences']),
      activeTemporaryAbsences: toInt(json['activeTemporaryAbsences']),
    );
  }
}
