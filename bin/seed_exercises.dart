import 'package:fit_motion_ai/features/exercise/data/exercise_seed_data.dart';

void main() {
  print('====================================================');
  print('FitMotionAI Exercise Library Seeder');
  print('Total exercises defined: ${ExerciseSeedData.exercises.length}');
  print('====================================================');

  for (final ex in ExerciseSeedData.exercises) {
    print('Id: ${ex.id.padRight(28)} | Group: ${ex.muscleGroup.padRight(10)} | Tier: ${ex.difficultyTier.name.padRight(12)} | Substitutes: ${ex.substituteExerciseIds.length}');
  }

  print('\n[INFO] Exercise dataset compiled cleanly with substitution chains and contraindication tags.');
}
