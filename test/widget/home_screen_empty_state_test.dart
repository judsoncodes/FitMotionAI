import 'package:fit_motion_ai/features/auth/domain/auth_repository.dart';
import 'package:fit_motion_ai/features/auth/domain/auth_state.dart';
import 'package:fit_motion_ai/features/auth/presentation/auth_providers.dart';
import 'package:fit_motion_ai/features/exercise/domain/repositories/exercise_repository.dart';
import 'package:fit_motion_ai/features/home/presentation/home_screen.dart';
import 'package:fit_motion_ai/features/onboarding/domain/models/onboarding_enums.dart';
import 'package:fit_motion_ai/features/onboarding/domain/models/user_profile.dart';
import 'package:fit_motion_ai/features/onboarding/domain/repositories/user_repository.dart';
import 'package:fit_motion_ai/features/onboarding/presentation/onboarding_providers.dart';
import 'package:fit_motion_ai/features/recommendation/domain/services/recommendation_service.dart';
import 'package:fit_motion_ai/features/recommendation/presentation/workout_plan_providers.dart';
import 'package:fit_motion_ai/features/workout/domain/repositories/workout_plan_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepo extends Mock implements AuthRepository {}
class MockUserRepo extends Mock implements UserRepository {}
class MockExRepo extends Mock implements ExerciseRepository {}
class MockPlanRepo extends Mock implements WorkoutPlanRepository {}

void main() {
  testWidgets('HomeScreen renders empty-state CTA button when no active plan exists', (tester) async {
    final dummyProfile = UserProfile(
      uid: 'user_001',
      email: 'test@fitmotion.ai',
      displayName: 'Test Athlete',
      createdAt: DateTime.now(),
      age: 28,
      sex: 'male',
      heightCm: 175,
      weightKg: 70,
      fitnessLevel: FitnessLevel.intermediate,
      primaryGoal: PrimaryGoal.generalFitness,
      daysPerWeek: 3,
      sessionDurationMinutes: 45,
      equipmentAccess: const [EquipmentAccess.dumbbells],
      hasInjuries: false,
      injuryDetails: const [],
      onboardingComplete: true,
      lastActive: DateTime.now(),
    );

    final mockAuthRepo = MockAuthRepo();
    when(() => mockAuthRepo.currentAuthState).thenReturn(
      AuthState.authenticated(userId: 'user_001', email: 'test@fitmotion.ai'),
    );
    when(() => mockAuthRepo.authStateChanges).thenAnswer(
      (_) => Stream.value(AuthState.authenticated(userId: 'user_001', email: 'test@fitmotion.ai')),
    );

    final service = RecommendationService(
      userRepository: MockUserRepo(),
      exerciseRepository: MockExRepo(),
      workoutPlanRepository: MockPlanRepo(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepo),
          userProfileProvider.overrideWith((ref) => Stream.value(dummyProfile)),
          activeWorkoutPlanStreamProvider.overrideWith((ref) => Stream.value(null)),
          workoutPlanViewModelProvider.overrideWith((ref) => WorkoutPlanViewModel(service, ref)),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Welcome, Test Athlete!'), findsOneWidget);
    expect(find.text('No Active Plan Generated'), findsOneWidget);
    expect(find.text('Generate My First Plan'), findsOneWidget);
  });
}
