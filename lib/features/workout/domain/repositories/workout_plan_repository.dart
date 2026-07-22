import '../models/workout_plan.dart';

abstract class WorkoutPlanRepository {
  /// Save or update a workout plan in Cloud Firestore
  Future<void> saveWorkoutPlan(WorkoutPlan plan);

  /// Fetch active workout plan for user by UID
  Future<WorkoutPlan?> getActiveWorkoutPlan(String userId);

  /// Stream active workout plan for real-time UI updates
  Stream<WorkoutPlan?> activeWorkoutPlanStream(String userId);
}
