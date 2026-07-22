import '../../../onboarding/domain/models/onboarding_enums.dart';

class RecoveryFeatures {
  final double averageDifficultyRating; // 1.0 to 5.0
  final double averageCompletionRate; // 0.0 to 1.0
  final int recentPainIncidentCount;
  final int daysSinceLastSession;
  final BodyPart? lastReportedPainBodyPart;
  final InjurySeverity? lastReportedPainSeverity;

  const RecoveryFeatures({
    required this.averageDifficultyRating,
    required this.averageCompletionRate,
    required this.recentPainIncidentCount,
    required this.daysSinceLastSession,
    this.lastReportedPainBodyPart,
    this.lastReportedPainSeverity,
  });

  factory RecoveryFeatures.initial() {
    return const RecoveryFeatures(
      averageDifficultyRating: 3.0,
      averageCompletionRate: 1.0,
      recentPainIncidentCount: 0,
      daysSinceLastSession: 1,
    );
  }
}
