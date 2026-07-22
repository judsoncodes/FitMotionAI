import '../../../onboarding/domain/models/onboarding_enums.dart';
import '../models/recovery_features.dart';
import 'recovery_scoring_strategy.dart';

class RuleBasedRecoveryStrategy implements RecoveryScoringStrategy {
  @override
  String get name => 'Rule-Based Baseline';

  @override
  Future<double> calculateRecoveryScore(RecoveryFeatures features) async {
    double score = 0.85;

    // 1. Pain Penalty
    if (features.recentPainIncidentCount > 0) {
      final severity = features.lastReportedPainSeverity ?? InjurySeverity.medium;
      switch (severity) {
        case InjurySeverity.high:
          score -= 0.40;
          break;
        case InjurySeverity.medium:
          score -= 0.25;
          break;
        case InjurySeverity.low:
          score -= 0.15;
          break;
      }
    }

    // 2. High Workout Difficulty Penalty
    if (features.averageDifficultyRating >= 4.5) {
      score -= 0.20;
    } else if (features.averageDifficultyRating >= 4.0) {
      score -= 0.10;
    } else if (features.averageDifficultyRating <= 2.0 && features.recentPainIncidentCount == 0) {
      score += 0.10;
    }

    // 3. Low Completion Rate Penalty
    if (features.averageCompletionRate < 0.6) {
      score -= 0.15;
    } else if (features.averageCompletionRate >= 0.9 &&
        features.averageDifficultyRating <= 3.0 &&
        features.recentPainIncidentCount == 0) {
      score += 0.05;
    }

    return score.clamp(0.20, 1.00);
  }
}
