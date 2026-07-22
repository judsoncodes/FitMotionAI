import 'dart:math';

import '../../exercise/domain/models/exercise.dart';
import '../../onboarding/domain/models/user_profile.dart';
import '../../workout/domain/models/workout_plan.dart';
import 'steps/difficulty_goal_selection_step.dart';
import 'steps/equipment_filter_step.dart';
import 'steps/injury_substitution_step.dart';
import 'steps/volume_adjustment_step.dart';

/// ACARE: Adaptive Context-Aware Recommendation Engine
/// Standalone pure-Dart service with 0 UI / Firestore dependencies.
class AcareEngine {
  /// Generates a safe, explainable, personalized WorkoutPlan for a user profile
  static WorkoutPlan generateWorkoutPlan({
    required UserProfile profile,
    required List<Exercise> exerciseLibrary,
    required double recoveryIntensityScore,
    List<dynamic> recentFeedbackHistory = const [],
  }) {
    final clampedScore = recoveryIntensityScore.clamp(0.0, 1.0);

    // Step 1: Filter library by available equipment
    final equipmentFiltered = EquipmentFilterStep.execute(exerciseLibrary, profile);

    // Step 2: Select candidate exercises matching difficulty tier & primary goal
    final candidateExercises = DifficultyGoalSelectionStep.execute(equipmentFiltered, profile);

    // Step 3: Injury Contraindication Check & Substitution Chain Traversal
    final resolvedExercises = InjurySubstitutionStep.execute(
      candidateExercises,
      exerciseLibrary,
      profile,
    );

    // Step 4: Volume & Intensity Adjustment based on Recovery Score
    final exerciseEntries = VolumeAdjustmentStep.execute(resolvedExercises, clampedScore);

    // Step 5: Build Sessions based on User Availability (daysPerWeek)
    final sessions = <WorkoutSession>[];
    final int sessionCount = profile.daysPerWeek.clamp(1, 7);

    for (int day = 1; day <= sessionCount; day++) {
      final sessionLabel = _generateDayLabel(day, profile.primaryGoal.label);
      
      // Collect explanations for session entries
      sessions.add(WorkoutSession(
        id: 'session_${day}_${DateTime.now().millisecondsSinceEpoch}',
        dayLabel: sessionLabel,
        exerciseEntries: exerciseEntries,
      ));
    }

    // Collect global explanations for downstream Gemini natural language generation
    final globalExplanations = exerciseEntries.map((e) => e.explanation).toList();

    return WorkoutPlan(
      id: 'plan_${profile.uid}_${DateTime.now().millisecondsSinceEpoch}',
      userId: profile.uid,
      generatedAt: DateTime.now(),
      status: 'active',
      recoveryIntensityScore: clampedScore,
      sessions: sessions,
      globalExplanations: globalExplanations,
    );
  }

  static String _generateDayLabel(int dayNumber, String goalLabel) {
    switch (dayNumber) {
      case 1:
        return 'Day 1 - Upper Body & Core Focus ($goalLabel)';
      case 2:
        return 'Day 2 - Lower Body & Stability ($goalLabel)';
      case 3:
        return 'Day 3 - Full-Body Conditioning ($goalLabel)';
      case 4:
        return 'Day 4 - Active Recovery & Mobility ($goalLabel)';
      case 5:
        return 'Day 5 - Hypertrophy & Strength ($goalLabel)';
      case 6:
        return 'Day 6 - Endurance & Capacity ($goalLabel)';
      default:
        return 'Day $dayNumber - Personalized Session ($goalLabel)';
    }
  }
}
