import '../models/recovery_log.dart';

abstract class RecoveryLogRepository {
  /// Save a new recovery log entry
  Future<void> saveRecoveryLog(RecoveryLog log);

  /// Fetch recent N recovery logs for a user
  Future<List<RecoveryLog>> getRecentRecoveryLogs(String userId, {int limit = 10});
}
