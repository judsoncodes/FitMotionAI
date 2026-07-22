import '../../../onboarding/domain/models/onboarding_enums.dart';
import '../models/recovery_features.dart';
import '../models/recovery_log.dart';
import '../repositories/recovery_log_repository.dart';
import '../strategies/ml_recovery_strategy.dart';
import '../strategies/recovery_scoring_strategy.dart';

class RecoverySignalService {
  final RecoveryLogRepository _repository;
  final RecoveryScoringStrategy _strategy;

  RecoverySignalService(
    this._repository, {
    RecoveryScoringStrategy? strategy,
  }) : _strategy = strategy ?? MlRecoveryStrategy();

  String get activeStrategyName => _strategy.name;

  /// Extracts normalized feature vector from recent recovery logs
  Future<RecoveryFeatures> extractRecoveryFeatures(String userId) async {
    final logs = await _repository.getRecentRecoveryLogs(userId, limit: 5);
    if (logs.isEmpty) {
      return RecoveryFeatures.initial();
    }

    final avgDifficulty =
        logs.map((l) => l.overallDifficulty).reduce((a, b) => a + b) / logs.length;
    final avgCompletion =
        logs.map((l) => l.completionRate).reduce((a, b) => a + b) / logs.length;
    final painLogs = logs.where((l) => l.hasPain).toList();

    final daysSinceLast = DateTime.now().difference(logs.first.timestamp).inDays;

    return RecoveryFeatures(
      averageDifficultyRating: avgDifficulty,
      averageCompletionRate: avgCompletion,
      recentPainIncidentCount: painLogs.length,
      daysSinceLastSession: daysSinceLast < 0 ? 0 : daysSinceLast,
      lastReportedPainBodyPart: painLogs.isNotEmpty ? painLogs.first.painBodyPart : null,
      lastReportedPainSeverity: painLogs.isNotEmpty ? painLogs.first.painSeverity : null,
    );
  }

  /// Computes recovery intensity score using active strategy (ML or Rule-Based)
  Future<double> computeRecoveryScore(String userId) async {
    final features = await extractRecoveryFeatures(userId);
    return _strategy.calculateRecoveryScore(features);
  }

  /// Pure deterministic rule-based score calculation logic
  double computeScoreFromFeatures(RecoveryFeatures features) {
    double score = 0.85;

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

    if (features.averageDifficultyRating >= 4.5) {
      score -= 0.20;
    } else if (features.averageDifficultyRating >= 4.0) {
      score -= 0.10;
    } else if (features.averageDifficultyRating <= 2.0 && features.recentPainIncidentCount == 0) {
      score += 0.10;
    }

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
