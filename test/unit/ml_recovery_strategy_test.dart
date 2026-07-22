import 'package:fit_motion_ai/features/onboarding/domain/models/onboarding_enums.dart';
import 'package:fit_motion_ai/features/recovery/domain/models/recovery_features.dart';
import 'package:fit_motion_ai/features/recovery/domain/strategies/ml_recovery_strategy.dart';
import 'package:fit_motion_ai/features/recovery/domain/strategies/rule_based_recovery_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MlRecoveryStrategy mlStrategy;
  late RuleBasedRecoveryStrategy ruleStrategy;

  setUp(() {
    mlStrategy = MlRecoveryStrategy();
    ruleStrategy = RuleBasedRecoveryStrategy();
  });

  group('ML vs Rule-Based Strategy Unit Tests', () {
    test('Strategy names match contract declarations', () {
      expect(mlStrategy.name, equals('XGBoost ML (TFLite)'));
      expect(ruleStrategy.name, equals('Rule-Based Baseline'));
    });

    test('MlRecoveryStrategy computes continuous score for healthy features', () async {
      const features = RecoveryFeatures(
        averageDifficultyRating: 2.0,
        averageCompletionRate: 1.0,
        recentPainIncidentCount: 0,
        daysSinceLastSession: 1,
      );

      final score = await mlStrategy.calculateRecoveryScore(features);
      expect(score, greaterThanOrEqualTo(0.90));
      expect(score, lessThanOrEqualTo(1.00));
    });

    test('MlRecoveryStrategy reduces score smoothly on severe shoulder pain report', () async {
      const features = RecoveryFeatures(
        averageDifficultyRating: 3.5,
        averageCompletionRate: 0.9,
        recentPainIncidentCount: 1,
        daysSinceLastSession: 1,
        lastReportedPainBodyPart: BodyPart.shoulder,
        lastReportedPainSeverity: InjurySeverity.high,
      );

      final mlScore = await mlStrategy.calculateRecoveryScore(features);
      final ruleScore = await ruleStrategy.calculateRecoveryScore(features);

      expect(mlScore, lessThan(0.60));
      expect(ruleScore, lessThan(0.60));
      // Proves alignment between baseline and ML model predictions
      expect((mlScore - ruleScore).abs(), lessThan(0.15));
    });
  });
}
