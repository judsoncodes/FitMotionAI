import '../../../onboarding/domain/models/onboarding_enums.dart';

class CompletionRecord {
  final String id;
  final String sessionId;
  final String userId;
  final DateTime completedAt;
  final int overallDifficulty; // 1 (Too Easy) to 5 (Too Hard)
  final double completionRate; // 0.0 to 1.0
  final int exercisesCompleted;
  final int exercisesTotal;
  final bool hasPain;
  final BodyPart? painBodyPart;
  final InjurySeverity? painSeverity;
  final String? painNotes;

  const CompletionRecord({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.completedAt,
    required this.overallDifficulty,
    required this.completionRate,
    required this.exercisesCompleted,
    required this.exercisesTotal,
    required this.hasPain,
    this.painBodyPart,
    this.painSeverity,
    this.painNotes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'userId': userId,
      'completedAt': completedAt.toIso8601String(),
      'overallDifficulty': overallDifficulty,
      'completionRate': completionRate,
      'exercisesCompleted': exercisesCompleted,
      'exercisesTotal': exercisesTotal,
      'hasPain': hasPain,
      'painBodyPart': painBodyPart?.name,
      'painSeverity': painSeverity?.name,
      'painNotes': painNotes,
    };
  }

  factory CompletionRecord.fromMap(Map<String, dynamic> map) {
    return CompletionRecord(
      id: map['id'] ?? '',
      sessionId: map['sessionId'] ?? '',
      userId: map['userId'] ?? '',
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : DateTime.now(),
      overallDifficulty: map['overallDifficulty'] ?? 3,
      completionRate: (map['completionRate'] as num?)?.toDouble() ?? 1.0,
      exercisesCompleted: map['exercisesCompleted'] ?? 0,
      exercisesTotal: map['exercisesTotal'] ?? 0,
      hasPain: map['hasPain'] ?? false,
      painBodyPart: map['painBodyPart'] != null
          ? BodyPart.values.firstWhere(
              (e) => e.name == map['painBodyPart'],
              orElse: () => BodyPart.knee,
            )
          : null,
      painSeverity: map['painSeverity'] != null
          ? InjurySeverity.values.firstWhere(
              (e) => e.name == map['painSeverity'],
              orElse: () => InjurySeverity.medium,
            )
          : null,
      painNotes: map['painNotes'],
    );
  }
}
