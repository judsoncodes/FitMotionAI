import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/recovery_log.dart';
import '../../domain/repositories/recovery_log_repository.dart';

class RecoveryLogRepositoryImpl implements RecoveryLogRepository {
  final FirebaseFirestore _firestore;
  final Map<String, List<RecoveryLog>> _memoryCache = {};

  RecoveryLogRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _logsCollection =>
      _firestore.collection('recoveryLogs');

  @override
  Future<void> saveRecoveryLog(RecoveryLog log) async {
    final userLogs = _memoryCache.putIfAbsent(log.userId, () => []);
    userLogs.insert(0, log);

    try {
      await _logsCollection.doc(log.id).set(log.toMap());
    } catch (_) {
      // Memory fallback if Firestore native SDK is uninitialized/offline
    }
  }

  @override
  Future<List<RecoveryLog>> getRecentRecoveryLogs(String userId, {int limit = 10}) async {
    try {
      final query = await _logsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      if (query.docs.isNotEmpty) {
        final logs = query.docs.map((doc) => RecoveryLog.fromMap(doc.data())).toList();
        _memoryCache[userId] = logs;
        return logs;
      }
    } catch (_) {}

    final userLogs = _memoryCache[userId] ?? [];
    return userLogs.take(limit).toList();
  }
}
