import '../../../exercise/domain/models/exercise.dart';
import '../../../onboarding/domain/models/onboarding_enums.dart';
import '../../../onboarding/domain/models/user_profile.dart';

class DifficultyGoalSelectionStep {
  /// Selects candidate exercises tailored to user's fitness level & primary goal
  static List<Exercise> execute(List<Exercise> filteredLibrary, UserProfile profile) {
    if (filteredLibrary.isEmpty) return [];

    // Filter exercises matching difficulty tier or lower
    final maxTier = profile.fitnessLevel;
    final suitableExercises = filteredLibrary.where((ex) {
      if (maxTier == FitnessLevel.beginner) {
        return ex.difficultyTier == FitnessLevel.beginner;
      } else if (maxTier == FitnessLevel.intermediate) {
        return ex.difficultyTier == FitnessLevel.beginner ||
            ex.difficultyTier == FitnessLevel.intermediate;
      }
      return true;
    }).toList();

    // Target muscle group balance based on primary goal
    final List<String> targetGroups;
    switch (profile.primaryGoal) {
      case PrimaryGoal.weightLoss:
      case PrimaryGoal.endurance:
        targetGroups = ['legs', 'chest', 'back', 'cardio', 'core'];
        break;
      case PrimaryGoal.muscleGain:
        targetGroups = ['chest', 'back', 'legs', 'shoulders', 'arms'];
        break;
      case PrimaryGoal.rehab:
        targetGroups = ['legs', 'back', 'core', 'full_body'];
        break;
      case PrimaryGoal.generalFitness:
      default:
        targetGroups = ['legs', 'chest', 'back', 'shoulders', 'core'];
        break;
    }

    final candidates = <Exercise>[];
    for (final group in targetGroups) {
      final groupMatches = suitableExercises.where((e) => e.muscleGroup == group).toList();
      if (groupMatches.isNotEmpty) {
        candidates.add(groupMatches.first);
      } else {
        // Fall back to any exercise in library if group matches unavailable
        final anyGroup = filteredLibrary.where((e) => e.muscleGroup == group).firstOrNull;
        if (anyGroup != null) candidates.add(anyGroup);
      }
    }

    return candidates.isNotEmpty ? candidates : suitableExercises.take(4).toList();
  }
}
