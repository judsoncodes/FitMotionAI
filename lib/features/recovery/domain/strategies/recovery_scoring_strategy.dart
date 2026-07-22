import '../models/recovery_features.dart';

abstract class RecoveryScoringStrategy {
  /// Name of the strategy (e.g. "Rule-Based Heuristic" or "XGBoost ML (TFLite)")
  String get name;

  /// Calculates recovery intensity score (0.20 to 1.00) from RecoveryFeatures
  Future<double> calculateRecoveryScore(RecoveryFeatures features);
}
