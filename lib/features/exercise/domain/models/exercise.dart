import '../../../onboarding/domain/models/onboarding_enums.dart';

class Exercise {
  final String id;
  final String name;
  final String muscleGroup; // chest, back, legs, shoulders, arms, core, full_body, cardio
  final FitnessLevel difficultyTier;
  final List<EquipmentAccess> equipmentRequired;
  final int defaultSets;
  final int defaultReps;
  final int? defaultDurationSeconds;
  final int restSeconds;
  final List<BodyPart> contraindications;
  final List<String> substituteExerciseIds;
  final String instructions;
  final List<String> formCues;

  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.difficultyTier,
    required this.equipmentRequired,
    required this.defaultSets,
    required this.defaultReps,
    this.defaultDurationSeconds,
    required this.restSeconds,
    required this.contraindications,
    required this.substituteExerciseIds,
    required this.instructions,
    required this.formCues,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'muscleGroup': muscleGroup,
      'difficultyTier': difficultyTier.name,
      'equipmentRequired': equipmentRequired.map((e) => e.name).toList(),
      'defaultSets': defaultSets,
      'defaultReps': defaultReps,
      'defaultDurationSeconds': defaultDurationSeconds,
      'restSeconds': restSeconds,
      'contraindications': contraindications.map((c) => c.name).toList(),
      'substituteExerciseIds': substituteExerciseIds,
      'instructions': instructions,
      'formCues': formCues,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      muscleGroup: map['muscleGroup'] ?? 'full_body',
      difficultyTier: FitnessLevel.values.firstWhere(
        (e) => e.name == map['difficultyTier'],
        orElse: () => FitnessLevel.beginner,
      ),
      equipmentRequired: (map['equipmentRequired'] as List<dynamic>?)
              ?.map((e) => EquipmentAccess.values.firstWhere(
                    (eq) => eq.name == e,
                    orElse: () => EquipmentAccess.none,
                  ))
              .toList() ??
          [EquipmentAccess.none],
      defaultSets: (map['defaultSets'] as num?)?.toInt() ?? 3,
      defaultReps: (map['defaultReps'] as num?)?.toInt() ?? 10,
      defaultDurationSeconds: (map['defaultDurationSeconds'] as num?)?.toInt(),
      restSeconds: (map['restSeconds'] as num?)?.toInt() ?? 60,
      contraindications: (map['contraindications'] as List<dynamic>?)
              ?.map((c) => BodyPart.values.firstWhere(
                    (bp) => bp.name == c,
                    orElse: () => BodyPart.knee,
                  ))
              .toList() ??
          [],
      substituteExerciseIds: List<String>.from(map['substituteExerciseIds'] ?? []),
      instructions: map['instructions'] ?? '',
      formCues: List<String>.from(map['formCues'] ?? []),
    );
  }
}
