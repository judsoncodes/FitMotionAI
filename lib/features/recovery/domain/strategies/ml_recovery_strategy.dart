import 'package:flutter/foundation.dart';
import '../../../onboarding/domain/models/onboarding_enums.dart';
import '../models/recovery_features.dart';
import 'recovery_scoring_strategy.dart';
import 'rule_based_recovery_strategy.dart';

class DecisionStump {
  final int feature;
  final double threshold;
  final double leftVal;
  final double rightVal;

  const DecisionStump({
    required this.feature,
    required this.threshold,
    required this.leftVal,
    required this.rightVal,
  });
}

class MlRecoveryStrategy implements RecoveryScoringStrategy {
  final RuleBasedRecoveryStrategy _fallbackStrategy = RuleBasedRecoveryStrategy();

  // Trained Gradient Boosted Decision Tree Ensemble (20 trees) exported from scripts/train_recovery_model.js
  static const double _baseVal = 0.7807866666666657;
  static const double _learningRate = 0.1;

  static const List<DecisionStump> _trees = [
    DecisionStump(feature: 2, threshold: 0.5, leftVal: 0.082905, rightVal: -0.188915),
    DecisionStump(feature: 2, threshold: 0.5, leftVal: 0.074614, rightVal: -0.170023),
    DecisionStump(feature: 2, threshold: 0.5, leftVal: 0.067153, rightVal: -0.153021),
    DecisionStump(feature: 4, threshold: 0.45, leftVal: 0.043757, rightVal: -0.194917),
    DecisionStump(feature: 2, threshold: 0.5, leftVal: 0.056062, rightVal: -0.127748),
    DecisionStump(feature: 0, threshold: 2.915, leftVal: 0.086376, rightVal: -0.073087),
    DecisionStump(feature: 4, threshold: 0.45, leftVal: 0.036459, rightVal: -0.162409),
    DecisionStump(feature: 0, threshold: 3.485, leftVal: 0.059829, rightVal: -0.088814),
    DecisionStump(feature: 2, threshold: 0.5, leftVal: 0.046564, rightVal: -0.106105),
    DecisionStump(feature: 0, threshold: 2.915, leftVal: 0.071503, rightVal: -0.060502),
    DecisionStump(feature: 4, threshold: 0.45, leftVal: 0.030296, rightVal: -0.134956),
    DecisionStump(feature: 0, threshold: 3.675, leftVal: 0.045497, rightVal: -0.081324),
    DecisionStump(feature: 2, threshold: 0.5, leftVal: 0.038632, rightVal: -0.088032),
    DecisionStump(feature: 0, threshold: 2.535, leftVal: 0.073889, rightVal: -0.042319),
    DecisionStump(feature: 4, threshold: 0.45, leftVal: 0.025167, rightVal: -0.112108),
    DecisionStump(feature: 0, threshold: 3.675, leftVal: 0.038260, rightVal: -0.068389),
    DecisionStump(feature: 2, threshold: 0.5, leftVal: 0.032070, rightVal: -0.073079),
    DecisionStump(feature: 0, threshold: 2.345, leftVal: 0.070495, rightVal: -0.032292),
    DecisionStump(feature: 4, threshold: 0.80, leftVal: 0.011125, rightVal: -0.194274),
    DecisionStump(feature: 0, threshold: 4.055, leftVal: 0.025855, rightVal: -0.075208),
  ];

  @override
  String get name => 'Gradient Boosted Trees (ML)';

  @override
  Future<double> calculateRecoveryScore(RecoveryFeatures features) async {
    try {
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

      final featureVector = [
        features.averageDifficultyRating,
        features.averageCompletionRate,
        features.recentPainIncidentCount.toDouble(),
        features.daysSinceLastSession.toDouble(),
        painWeight,
      ];

      // Evaluate 20 Gradient Boosted Decision Trees
      double score = _baseVal;
      for (final stump in _trees) {
        final val = featureVector[stump.feature];
        score += _learningRate * (val <= stump.threshold ? stump.leftVal : stump.rightVal);
      }

      final mlScore = score.clamp(0.20, 1.00);
      debugPrint('[MlRecoveryStrategy] Evaluated 20 Gradient Boosted Decision Trees -> Score: ${mlScore.toStringAsFixed(2)}');
      return mlScore;
    } catch (e) {
      debugPrint('[MlRecoveryStrategy] Notice ($e). Falling back to Rule-Based strategy.');
      return _fallbackStrategy.calculateRecoveryScore(features);
    }
  }
}
