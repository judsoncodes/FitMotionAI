import 'package:fit_motion_ai/features/exercise/domain/repositories/exercise_repository.dart';
import 'package:fit_motion_ai/features/onboarding/domain/repositories/user_repository.dart';
import 'package:fit_motion_ai/features/recommendation/domain/services/recommendation_service.dart';
import 'package:fit_motion_ai/features/recommendation/presentation/workout_plan_providers.dart';
import 'package:fit_motion_ai/features/recommendation/presentation/workout_plan_screen.dart';
import 'package:fit_motion_ai/features/workout/domain/models/workout_plan.dart';
import 'package:fit_motion_ai/features/workout/domain/repositories/workout_plan_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepo extends Mock implements UserRepository {}
class MockExRepo extends Mock implements ExerciseRepository {}
class MockPlanRepo extends Mock implements WorkoutPlanRepository {}

void main() {
  testWidgets('WorkoutPlanScreen renders session cards and ACARE substitution explanation chips', (tester) async {
    final mockPlan = WorkoutPlan(
      id: 'plan_123',
      userId: 'user_001',
      generatedAt: DateTime.now(),
      recoveryIntensityScore: 0.7,
      globalExplanations: const [],
      sessions: [
        WorkoutSession(
          id: 's1',
          dayLabel: 'Day 1 - Upper Body Focus',
          exerciseEntries: [
            const ExerciseEntry(
              exerciseId: 'ex_lateral_raise',
              exerciseName: 'Dumbbell Lateral Raise',
              prescribedSets: 3,
              prescribedReps: 12,
              restSeconds: 45,
              order: 1,
              explanation: SelectionExplanation(
                exerciseId: 'ex_lateral_raise',
                exerciseName: 'Dumbbell Lateral Raise',
                actionType: 'substituted',
                reasonCode: 'INJURY_CONTRAINDICATION_SUBSTITUTE',
                details: 'Substituted original exercise Barbell Overhead Press due to reported shoulder discomfort.',
              ),
            ),
          ],
        ),
      ],
    );

    final service = RecommendationService(
      userRepository: MockUserRepo(),
      exerciseRepository: MockExRepo(),
      workoutPlanRepository: MockPlanRepo(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          workoutPlanViewModelProvider.overrideWith(
            (ref) => WorkoutPlanViewModel(service, ref)
              ..state = WorkoutPlanState(status: WorkoutPlanStatus.ready, plan: mockPlan),
          ),
          activeWorkoutPlanStreamProvider.overrideWith(
            (ref) => Stream.value(mockPlan),
          ),
        ],
        child: const MaterialApp(
          home: WorkoutPlanScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Your AI Workout Plan'), findsOneWidget);
    expect(find.text('Day 1 - Upper Body Focus'), findsOneWidget);
    expect(find.text('1. Dumbbell Lateral Raise'), findsOneWidget);
    expect(find.textContaining('Substituted original exercise Barbell Overhead Press'), findsOneWidget);
  });
}
