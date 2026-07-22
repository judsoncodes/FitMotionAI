import '../../../workout/domain/models/workout_plan.dart';
import 'injury_substitution_step.dart';

class VolumeAdjustmentStep {
  /// Adjusts set/rep volume and rest periods based on recoveryIntensityScore (0.0 - 1.0)
  static List<ExerciseEntry> execute(
    List<ResolvedExercise> resolvedExercises,
    double recoveryIntensityScore,
  ) {
    final entries = <ExerciseEntry>[];

    // Low recovery (< 0.4) -> Limit max exercises to 3 to prevent overtraining
    final activeList = (recoveryIntensityScore < 0.4 && resolvedExercises.length > 3)
        ? resolvedExercises.take(3).toList()
        : resolvedExercises;

    for (int i = 0; i < activeList.length; i++) {
      final resolved = activeList[i];
      final ex = resolved.exercise;
      final originalExplanation = resolved.explanation;

      int sets = ex.defaultSets;
      int reps = ex.defaultReps;
      int? duration = ex.defaultDurationSeconds;
      int rest = ex.restSeconds;
      SelectionExplanation updatedExplanation = originalExplanation;

      if (recoveryIntensityScore < 0.4) {
        // Low recovery adjustment
        sets = (ex.defaultSets > 2) ? 2 : ex.defaultSets;
        reps = (ex.defaultReps * 0.75).round().clamp(5, 20);
        if (duration != null) {
          duration = (duration * 0.75).round();
        }
        rest = ex.restSeconds + 30; // Longer rest for active recovery

        updatedExplanation = SelectionExplanation(
          exerciseId: originalExplanation.exerciseId,
          exerciseName: originalExplanation.exerciseName,
          actionType: 'volume_adjusted',
          reasonCode: 'LOW_RECOVERY_SCORE_REDUCED_VOLUME',
          details:
              '${originalExplanation.details} [Volume Scaled: Sets reduced from ${ex.defaultSets} to $sets, Reps from ${ex.defaultReps} to $reps, Rest increased by +30s due to low recovery score (${recoveryIntensityScore.toStringAsFixed(2)})].',
        );
      } else if (recoveryIntensityScore > 0.7) {
        // High recovery -> Maintain safe full volume
        updatedExplanation = SelectionExplanation(
          exerciseId: originalExplanation.exerciseId,
          exerciseName: originalExplanation.exerciseName,
          actionType: originalExplanation.actionType,
          reasonCode: originalExplanation.reasonCode,
          details:
              '${originalExplanation.details} [Peak recovery score (${recoveryIntensityScore.toStringAsFixed(2)}): Full prescribed progressive overload volume].',
        );
      }

      entries.add(ExerciseEntry(
        exerciseId: ex.id,
        exerciseName: ex.name,
        prescribedSets: sets,
        prescribedReps: reps,
        prescribedDurationSeconds: duration,
        restSeconds: rest,
        order: i + 1,
        explanation: updatedExplanation,
      ));
    }

    return entries;
  }
}
