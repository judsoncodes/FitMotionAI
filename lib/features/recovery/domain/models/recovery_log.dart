import '../../../onboarding/domain/models/onboarding_enums.dart';

class RecoveryLog {
  final String id;
  final String userId;
  final DateTime timestamp;
  final int overallDifficulty;
  final double completionRate;
  final bool hasPain;
  final BodyPart? painBodyPart;
  final InjurySeverity? painSeverity;

  const RecoveryLog({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.overallDifficulty,
    required this.completionRate,
    required this.hasPain,
    this.painBodyPart,
    this.painSeverity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'overallDifficulty': overallDifficulty,
      'completionRate': completionRate,
      'hasPain': hasPain,
      'painBodyPart': painBodyPart?.name,
      'painSeverity': painSeverity?.name,
    };
  }

  factory RecoveryLog.fromMap(Map<String, dynamic> map) {
    return RecoveryLog(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      overallDifficulty: map['overallDifficulty'] ?? 3,
      completionRate: (map['completionRate'] as num?)?.toDouble() ?? 1.0,
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
    );
  }
}
