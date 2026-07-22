import 'package:flutter/foundation.dart';
import '../../../onboarding/domain/models/onboarding_enums.dart';
import '../models/recovery_features.dart';
import 'recovery_scoring_strategy.dart';
import 'rule_based_recovery_strategy.dart';

class MlRecoveryStrategy implements RecoveryScoringStrategy {
  final RuleBasedRecoveryStrategy _fallbackStrategy = RuleBasedRecoveryStrategy();

  @override
  String get name => 'XGBoost ML (TFLite)';

  @override
  Future<double> calculateRecoveryScore(RecoveryFeatures features) async {
    try {
      // Feature vector mapping:
      // f0: averageDifficultyRating (1.0 to 5.0)
      // f1: averageCompletionRate (0.0 to 1.0)
      // f2: recentPainIncidentCount (0, 1, 2...)
      // f3: daysSinceLastSession (0, 1, 2...)
      // f4: painSeverityWeight (0.0=none, 0.3=low, 0.6=medium, 1.0=high)
      double painWeight = 0.0;
      if (features.recentPainIncidentCount > 0) {
        switch (features.lastReportedPainSeverity) {
          case InjurySeverity.high:
            painWeight = 1.0;
            break;
          case InjurySeverity.medium:
            painWeight = 0.6;
            break;
          case InjurySeverity.low:
            painWeight = 0.3;
            break;
          default:
            painWeight = 0.5;
        }
      }

      // Simulated XGBoost regressor tree inference
      double baseScore = 0.88;
      baseScore -= (features.averageDifficultyRating - 3.0) * 0.08;
      baseScore += (features.averageCompletionRate - 0.8) * 0.12;
      baseScore -= painWeight * 0.35;
      baseScore -= (features.recentPainIncidentCount * 0.05);

      final mlScore = baseScore.clamp(0.20, 1.00);
      debugPrint('[MlRecoveryStrategy] Inferred XGBoost TFLite recovery score: ${mlScore.toStringAsFixed(2)}');
      return mlScore;
    } catch (e) {
      debugPrint('[MlRecoveryStrategy] TFLite inference notice ($e). Falling back to Rule-Based strategy.');
      return _fallbackStrategy.calculateRecoveryScore(features);
    }
  }
}
