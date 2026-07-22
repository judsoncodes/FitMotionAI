import '../../../exercise/domain/models/exercise.dart';
import '../../../onboarding/domain/models/onboarding_enums.dart';
import '../../../onboarding/domain/models/user_profile.dart';
import '../../../workout/domain/models/workout_plan.dart';
import 'equipment_filter_step.dart';

class ResolvedExercise {
  final Exercise exercise;
  final SelectionExplanation explanation;

  const ResolvedExercise({
    required this.exercise,
    required this.explanation,
  });
}

class InjurySubstitutionStep {
  static List<ResolvedExercise> execute(
    List<Exercise> candidateExercises,
    List<Exercise> fullLibrary,
    UserProfile profile,
  ) {
    if (!profile.hasInjuries || profile.injuryDetails.isEmpty) {
      return candidateExercises.map((ex) {
        return ResolvedExercise(
          exercise: ex,
          explanation: SelectionExplanation(
            exerciseId: ex.id,
            exerciseName: ex.name,
            actionType: 'selected',
            reasonCode: 'DIRECT_SELECTION',
            details: 'Selected exercise directly matches user fitness goals and equipment.',
          ),
        );
      }).toList();
    }

    final injuredBodyParts = profile.injuryDetails.map((d) => d.bodyPart).toSet();
    final availableEquipment = Set<EquipmentAccess>.from(profile.equipmentAccess)..add(EquipmentAccess.none);

    final resolvedList = <ResolvedExercise>[];

    for (final candidate in candidateExercises) {
      // Check if candidate has contraindications
      final conflictingParts = candidate.contraindications.where((bp) => injuredBodyParts.contains(bp)).toList();

      if (conflictingParts.isEmpty) {
        resolvedList.add(ResolvedExercise(
          exercise: candidate,
          explanation: SelectionExplanation(
            exerciseId: candidate.id,
            exerciseName: candidate.name,
            actionType: 'selected',
            reasonCode: 'SAFE_EXERCISE',
            details: 'Exercise has no contraindications for user injury profile.',
          ),
        ));
        continue;
      }

      // Candidate is contraindicated -> Traverse substitution chain
      Exercise? validSubstitute;
      for (final subId in candidate.substituteExerciseIds) {
        final subMatch = fullLibrary.where((e) => e.id == subId).firstOrNull;
        if (subMatch == null) continue;

        // Check equipment compatibility
        final equipOk = subMatch.equipmentRequired.contains(EquipmentAccess.none) ||
            subMatch.equipmentRequired.any((eq) => availableEquipment.contains(eq));
        if (!equipOk) continue;

        // Check contraindications
        final subConflicts = subMatch.contraindications.where((bp) => injuredBodyParts.contains(bp)).toList();
        if (subConflicts.isEmpty) {
          validSubstitute = subMatch;
          break;
        }
      }

      if (validSubstitute != null) {
        resolvedList.add(ResolvedExercise(
          exercise: validSubstitute,
          explanation: SelectionExplanation(
            exerciseId: validSubstitute.id,
            exerciseName: validSubstitute.name,
            actionType: 'substituted',
            reasonCode: 'INJURY_CONTRAINDICATION_SUBSTITUTE',
            details:
                'Substituted original exercise "${candidate.name}" -> "${validSubstitute.name}" due to reported ${conflictingParts.map((e) => e.label).join(", ")} discomfort.',
          ),
        ));
      } else {
        // Edge Case: Entire substitute chain is contraindicated -> Fallback to safe mobility flow
        final fallback = fullLibrary.firstWhere(
          (e) => e.id == 'ex_mobility_flow' || e.id == 'ex_glute_bridge',
          orElse: () => fullLibrary.first,
        );

        resolvedList.add(ResolvedExercise(
          exercise: fallback,
          explanation: SelectionExplanation(
            exerciseId: fallback.id,
            exerciseName: fallback.name,
            actionType: 'fallback',
            reasonCode: 'FULL_SUBSTITUTION_CHAIN_EXHAUSTED',
            details:
                'Primary exercise "${candidate.name}" and all substitutes were contraindicated for ${conflictingParts.map((e) => e.label).join(", ")}. Fell back to safe mobility/active-recovery exercise.',
          ),
        ));
      }
    }

    return resolvedList;
  }
}
