import 'package:fit_motion_ai/features/recommendation/data/repositories/gemini_explanation_repository.dart';
import 'package:fit_motion_ai/features/workout/domain/models/workout_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late GeminiExplanationRepository repo;

  setUp(() {
    repo = GeminiExplanationRepositoryImpl();
  });

  group('GeminiExplanationRepository Unit Tests', () {
    final sampleExplanations = [
      const SelectionExplanation(
        exerciseId: 'ex_lateral_raise',
        exerciseName: 'Dumbbell Lateral Raise',
        actionType: 'substituted',
        reasonCode: 'INJURY_CONTRAINDICATION_SUBSTITUTE',
        details: 'Substituted original exercise Barbell Overhead Press due to reported shoulder discomfort.',
      ),
    ];

    test('Gracefully returns fallback structured ACARE details when Cloud Function is uninitialized or offline', () async {
      final result = await repo.fetchNaturalLanguageExplanations(sampleExplanations);
      expect(result['ex_lateral_raise'], equals(sampleExplanations.first.details));
    });
  });
}
