import 'package:fit_motion_ai/features/exercise/data/exercise_seed_data.dart';
import 'package:fit_motion_ai/features/exercise/domain/repositories/exercise_repository.dart';
import 'package:fit_motion_ai/features/onboarding/domain/models/onboarding_enums.dart';
import 'package:fit_motion_ai/features/onboarding/domain/models/user_profile.dart';
import 'package:fit_motion_ai/features/onboarding/domain/repositories/user_repository.dart';
import 'package:fit_motion_ai/features/recommendation/domain/services/recommendation_service.dart';
import 'package:fit_motion_ai/features/workout/domain/models/workout_plan.dart';
import 'package:fit_motion_ai/features/workout/domain/repositories/workout_plan_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}
class MockExerciseRepository extends Mock implements ExerciseRepository {}
class MockWorkoutPlanRepository extends Mock implements WorkoutPlanRepository {}
class FakeWorkoutPlan extends Fake implements WorkoutPlan {}

void main() {
  late MockUserRepository mockUserRepository;
  late MockExerciseRepository mockExerciseRepository;
  late MockWorkoutPlanRepository mockWorkoutPlanRepository;
  late RecommendationService service;

  setUpAll(() {
    registerFallbackValue(FakeWorkoutPlan());
  });

  setUp(() {
    mockUserRepository = MockUserRepository();
    mockExerciseRepository = MockExerciseRepository();
    mockWorkoutPlanRepository = MockWorkoutPlanRepository();

    service = RecommendationService(
      userRepository: mockUserRepository,
      exerciseRepository: mockExerciseRepository,
      workoutPlanRepository: mockWorkoutPlanRepository,
    );
  });

  group('RecommendationService Orchestration Tests', () {
    test('generatePlanForUser fetches profile and library, runs ACARE, and persists plan', () async {
      final dummyProfile = UserProfile(
        uid: 'user_999',
        email: 'athlete@fitmotion.ai',
        displayName: 'Athlete',
        createdAt: DateTime.now(),
        age: 26,
        sex: 'female',
        heightCm: 165,
        weightKg: 60,
        fitnessLevel: FitnessLevel.intermediate,
        primaryGoal: PrimaryGoal.muscleGain,
        daysPerWeek: 4,
        sessionDurationMinutes: 45,
        equipmentAccess: const [EquipmentAccess.dumbbells],
        hasInjuries: false,
        injuryDetails: const [],
        onboardingComplete: true,
        lastActive: DateTime.now(),
      );

      when(() => mockUserRepository.getUserProfile('user_999'))
          .thenAnswer((_) async => dummyProfile);
      when(() => mockExerciseRepository.getExerciseLibrary())
          .thenAnswer((_) async => ExerciseSeedData.exercises);
      when(() => mockWorkoutPlanRepository.saveWorkoutPlan(any()))
          .thenAnswer((_) async {});

      final plan = await service.generatePlanForUser('user_999');

      expect(plan.userId, equals('user_999'));
      expect(plan.sessions.isNotEmpty, isTrue);
      // TODO: Step 5 - Replace hardcoded 0.7 score with XGBoost model
      expect(plan.recoveryIntensityScore, equals(0.85));

      verify(() => mockUserRepository.getUserProfile('user_999')).called(1);
      verify(() => mockExerciseRepository.getExerciseLibrary()).called(1);
      verify(() => mockWorkoutPlanRepository.saveWorkoutPlan(any())).called(1);
    });

    test('generatePlanForUser throws ProfileNotFoundException if user profile missing', () async {
      when(() => mockUserRepository.getUserProfile('missing_user'))
          .thenAnswer((_) async => null);

      expect(
        () => service.generatePlanForUser('missing_user'),
        throwsA(isA<ProfileNotFoundException>()),
      );
    });
  });
}
