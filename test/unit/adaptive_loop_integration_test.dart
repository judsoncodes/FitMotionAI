import 'package:fit_motion_ai/features/exercise/data/exercise_seed_data.dart';
import 'package:fit_motion_ai/features/exercise/domain/repositories/exercise_repository.dart';
import 'package:fit_motion_ai/features/onboarding/domain/models/onboarding_enums.dart';
import 'package:fit_motion_ai/features/onboarding/domain/models/user_profile.dart';
import 'package:fit_motion_ai/features/onboarding/domain/repositories/user_repository.dart';
import 'package:fit_motion_ai/features/recommendation/domain/services/recommendation_service.dart';
import 'package:fit_motion_ai/features/recovery/domain/models/recovery_log.dart';
import 'package:fit_motion_ai/features/recovery/domain/repositories/recovery_log_repository.dart';
import 'package:fit_motion_ai/features/recovery/domain/services/recovery_signal_service.dart';
import 'package:fit_motion_ai/features/workout/domain/models/workout_plan.dart';
import 'package:fit_motion_ai/features/workout/domain/repositories/workout_plan_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepo extends Mock implements UserRepository {}
class MockExRepo extends Mock implements ExerciseRepository {}
class MockPlanRepo extends Mock implements WorkoutPlanRepository {}
class MockRecoveryLogRepo extends Mock implements RecoveryLogRepository {}
class FakeWorkoutPlan extends Fake implements WorkoutPlan {}

void main() {
  late MockUserRepo mockUserRepo;
  late MockExRepo mockExRepo;
  late MockPlanRepo mockPlanRepo;
  late MockRecoveryLogRepo mockRecoveryRepo;

  late RecoverySignalService recoverySignalService;
  late RecommendationService recommendationService;

  setUpAll(() {
    registerFallbackValue(FakeWorkoutPlan());
  });

  setUp(() {
    mockUserRepo = MockUserRepo();
    mockExRepo = MockExRepo();
    mockPlanRepo = MockPlanRepo();
    mockRecoveryRepo = MockRecoveryLogRepo();

    recoverySignalService = RecoverySignalService(mockRecoveryRepo);
    recommendationService = RecommendationService(
      userRepository: mockUserRepo,
      exerciseRepository: mockExRepo,
      workoutPlanRepository: mockPlanRepo,
      recoverySignalService: recoverySignalService,
    );
  });

  test('Closed Adaptive Loop: Workout pain feedback dynamically lowers recovery score & substitutes exercises', () async {
    final initialProfile = UserProfile(
      uid: 'user_adaptive_01',
      email: 'adaptive@fitmotion.ai',
      displayName: 'Adaptive Athlete',
      createdAt: DateTime.now(),
      age: 26,
      sex: 'male',
      heightCm: 178,
      weightKg: 74,
      fitnessLevel: FitnessLevel.intermediate,
      primaryGoal: PrimaryGoal.muscleGain,
      daysPerWeek: 4,
      sessionDurationMinutes: 45,
      equipmentAccess: const [EquipmentAccess.dumbbells, EquipmentAccess.fullGym],
      hasInjuries: false,
      injuryDetails: const [],
      onboardingComplete: true,
      lastActive: DateTime.now(),
    );

    when(() => mockUserRepo.getUserProfile('user_adaptive_01'))
        .thenAnswer((_) async => initialProfile);
    when(() => mockExRepo.getExerciseLibrary())
        .thenAnswer((_) async => ExerciseSeedData.exercises);
    when(() => mockPlanRepo.saveWorkoutPlan(any()))
        .thenAnswer((_) async {});
    when(() => mockRecoveryRepo.getRecentRecoveryLogs('user_adaptive_01', limit: 5))
        .thenAnswer((_) async => []);

    // 1. First Plan Generation (No pain history)
    final plan1 = await recommendationService.generatePlanForUser('user_adaptive_01');
    expect(plan1.recoveryIntensityScore, closeTo(0.90, 0.05));

    // 2. Simulate User Finishing Session & Reporting Moderate Knee Pain
    final painLog = RecoveryLog(
      id: 'log_knee_01',
      userId: 'user_adaptive_01',
      timestamp: DateTime.now(),
      overallDifficulty: 4,
      completionRate: 1.0,
      hasPain: true,
      painBodyPart: BodyPart.knee,
      painSeverity: InjurySeverity.medium,
    );

    when(() => mockRecoveryRepo.getRecentRecoveryLogs('user_adaptive_01', limit: 5))
        .thenAnswer((_) async => [painLog]);

    // 3. Regenerate Plan After Pain Feedback
    final plan2 = await recommendationService.generatePlanForUser('user_adaptive_01');

    // 4. Assert: Recovery Score decreased to ~0.56 AND knee exercises substituted!
    expect(plan2.recoveryIntensityScore, closeTo(0.56, 0.05));

    // Verify at least one exercise entry has ACARE substitution explanation
    final allEntries = plan2.sessions.expand((s) => s.exerciseEntries);
    final substitutedKneeEntries = allEntries.where((e) =>
        e.explanation.actionType == 'substituted' ||
        e.explanation.details.contains('knee'));

    expect(substitutedKneeEntries.isNotEmpty, isTrue);
  });
}
