import '../../../exercise/domain/repositories/exercise_repository.dart';
import '../../../onboarding/domain/models/injury_detail.dart';
import '../../../onboarding/domain/models/onboarding_enums.dart';
import '../../../onboarding/domain/models/user_profile.dart';
import '../../../onboarding/domain/repositories/user_repository.dart';
import '../../../recovery/domain/services/recovery_signal_service.dart';
import '../../../workout/domain/models/workout_plan.dart';
import '../../../workout/domain/repositories/workout_plan_repository.dart';
import '../acare_engine.dart';

class ProfileNotFoundException implements Exception {
  final String message;
  const ProfileNotFoundException(this.message);
  @override
  String toString() => message;
}

class RecommendationService {
  final UserRepository _userRepository;
  final ExerciseRepository _exerciseRepository;
  final WorkoutPlanRepository _workoutPlanRepository;
  final RecoverySignalService? _recoverySignalService;

  RecommendationService({
    required UserRepository userRepository,
    required ExerciseRepository exerciseRepository,
    required WorkoutPlanRepository workoutPlanRepository,
    RecoverySignalService? recoverySignalService,
  })  : _userRepository = userRepository,
        _exerciseRepository = exerciseRepository,
        _workoutPlanRepository = workoutPlanRepository,
        _recoverySignalService = recoverySignalService;

  /// Orchestrates generating a new WorkoutPlan using ACARE rules engine
  Future<WorkoutPlan> generatePlanForUser(String userId) async {
    // 1. Fetch User Profile
    UserProfile? profile = await _userRepository.getUserProfile(userId);
    if (profile == null) {
      throw const ProfileNotFoundException('User profile not found. Please complete onboarding first.');
    }

    // 2. Fetch Exercise Library Reference Dataset
    final exerciseLibrary = await _exerciseRepository.getExerciseLibrary();
    if (exerciseLibrary.isEmpty) {
      throw Exception('Exercise library is empty. Unable to generate plan.');
    }

    // 3. Compute Rule-Based Adaptive Recovery Signal
    // TODO: Step 6 - Upgrade rule-based baseline recovery score to XGBoost/TFLite model
    double recoveryIntensityScore = 0.85;
    if (_recoverySignalService != null) {
      recoveryIntensityScore = await _recoverySignalService!.computeRecoveryScore(userId);

      // Check if recent recovery feedback contains a reported pain body part
      final features = await _recoverySignalService!.extractRecoveryFeatures(userId);
      if (features.lastReportedPainBodyPart != null) {
        final painPart = features.lastReportedPainBodyPart!;
        final severity = features.lastReportedPainSeverity ?? InjurySeverity.medium;

        final existingInjuries = List<InjuryDetail>.from(profile.injuryDetails);
        final alreadyLogged = existingInjuries.any((i) => i.bodyPart == painPart);

        if (!alreadyLogged) {
          existingInjuries.add(InjuryDetail(
            bodyPart: painPart,
            severity: severity,
            notes: 'Reported during recent workout session feedback',
          ));

          profile = profile.copyWith(
            hasInjuries: true,
            injuryDetails: existingInjuries,
          );
        }
      }
    }

    // 4. ACARE Pipeline Execution
    final plan = AcareEngine.generateWorkoutPlan(
      profile: profile,
      exerciseLibrary: exerciseLibrary,
      recoveryIntensityScore: recoveryIntensityScore,
    );

    // 5. Persist generated plan to Cloud Firestore
    await _workoutPlanRepository.saveWorkoutPlan(plan);

    return plan;
  }
}
