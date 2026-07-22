import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/recovery_log_repository_impl.dart';
import '../domain/repositories/recovery_log_repository.dart';
import '../domain/services/recovery_signal_service.dart';
import '../domain/strategies/ml_recovery_strategy.dart';
import '../domain/strategies/recovery_scoring_strategy.dart';
import '../domain/strategies/rule_based_recovery_strategy.dart';

final recoveryLogRepositoryProvider = Provider<RecoveryLogRepository>((ref) {
  return RecoveryLogRepositoryImpl();
});

final useMlModelProvider = StateProvider<bool>((ref) => true);

final recoveryStrategyProvider = Provider<RecoveryScoringStrategy>((ref) {
  final useMl = ref.watch(useMlModelProvider);
  return useMl ? MlRecoveryStrategy() : RuleBasedRecoveryStrategy();
});

final recoverySignalServiceProvider = Provider<RecoverySignalService>((ref) {
  final repo = ref.watch(recoveryLogRepositoryProvider);
  final strategy = ref.watch(recoveryStrategyProvider);
  return RecoverySignalService(repo, strategy: strategy);
});
