import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/workout_plan.dart';
import '../../domain/repositories/workout_plan_repository.dart';

class WorkoutPlanRepositoryImpl implements WorkoutPlanRepository {
  final FirebaseFirestore _firestore;
  final Map<String, WorkoutPlan> _memoryCache = {};

  WorkoutPlanRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _plansCollection =>
      _firestore.collection('workoutPlans');

  @override
  Future<void> saveWorkoutPlan(WorkoutPlan plan) async {
    _memoryCache[plan.userId] = plan;
    try {
      await _plansCollection.doc(plan.id).set(
            plan.toMap(),
            SetOptions(merge: true),
          );
    } catch (_) {
      // In-memory fallback
    }
  }

  @override
  Future<WorkoutPlan?> getActiveWorkoutPlan(String userId) async {
    if (_memoryCache.containsKey(userId)) {
      return _memoryCache[userId];
    }

    try {
      final query = await _plansCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final plan = WorkoutPlan.fromMap(query.docs.first.data());
        _memoryCache[userId] = plan;
        return plan;
      }
    } catch (_) {
      // Fallback
    }

    return _memoryCache[userId];
  }

  @override
  Stream<WorkoutPlan?> activeWorkoutPlanStream(String userId) {
    try {
      return _plansCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .snapshots()
          .map<WorkoutPlan?>((snapshot) {
            if (snapshot.docs.isNotEmpty) {
              final plan = WorkoutPlan.fromMap(snapshot.docs.first.data());
              _memoryCache[userId] = plan;
              return plan;
            }
            return _memoryCache[userId];
          })
          .timeout(
            const Duration(seconds: 3),
            onTimeout: (sink) {
              sink.add(_memoryCache[userId]);
            },
          )
          .handleError((_) => _memoryCache[userId]);
    } catch (_) {
      return Stream.value(_memoryCache[userId]);
    }
  }
}
