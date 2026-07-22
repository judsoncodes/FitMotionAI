import 'package:fit_motion_ai/features/recovery/domain/models/recovery_log.dart';
import 'package:fit_motion_ai/features/recovery/domain/repositories/recovery_log_repository.dart';
import 'package:fit_motion_ai/features/recovery/presentation/recovery_providers.dart';
import 'package:fit_motion_ai/features/workout/presentation/post_workout_feedback_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRecoveryLogRepo extends Mock implements RecoveryLogRepository {}
class FakeRecoveryLog extends Fake implements RecoveryLog {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRecoveryLog());
  });

  testWidgets('PostWorkoutFeedbackScreen renders difficulty selector and pain toggle', (tester) async {
    final mockRepo = MockRecoveryLogRepo();
    when(() => mockRepo.saveRecoveryLog(any())).thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recoveryLogRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(
          home: PostWorkoutFeedbackScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Post-Workout Recovery Feedback'), findsOneWidget);
    expect(find.text('Overall Workout Difficulty'), findsOneWidget);
    expect(find.text('Did you experience joint pain or discomfort?'), findsOneWidget);

    // Toggle pain switch
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text('Affected Body Part'), findsOneWidget);
    expect(find.text('Discomfort Severity'), findsOneWidget);
  });
}
