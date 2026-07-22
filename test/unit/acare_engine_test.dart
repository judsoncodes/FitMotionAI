import 'package:fit_motion_ai/features/exercise/data/exercise_seed_data.dart';
import 'package:fit_motion_ai/features/exercise/domain/models/exercise.dart';
import 'package:fit_motion_ai/features/onboarding/domain/models/injury_detail.dart';
import 'package:fit_motion_ai/features/onboarding/domain/models/onboarding_enums.dart';
import 'package:fit_motion_ai/features/onboarding/domain/models/user_profile.dart';
import 'package:fit_motion_ai/features/recommendation/domain/acare_engine.dart';
import 'package:fit_motion_ai/features/recommendation/domain/steps/equipment_filter_step.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final seedLibrary = ExerciseSeedData.exercises;

  UserProfile createTestProfile({
    List<EquipmentAccess> equipment = const [EquipmentAccess.dumbbells],
    bool hasInjuries = false,
    List<InjuryDetail> injuryDetails = const [],
    FitnessLevel level = FitnessLevel.intermediate,
    PrimaryGoal goal = PrimaryGoal.generalFitness,
  }) {
    return UserProfile(
      uid: 'test_user_001',
      email: 'test@fitmotion.ai',
      displayName: 'Test Athlete',
      createdAt: DateTime.now(),
      age: 28,
      sex: 'male',
      heightCm: 178,
      weightKg: 75,
      fitnessLevel: level,
      primaryGoal: goal,
      daysPerWeek: 3,
      sessionDurationMinutes: 45,
      equipmentAccess: equipment,
      hasInjuries: hasInjuries,
      injuryDetails: injuryDetails,
      onboardingComplete: true,
      lastActive: DateTime.now(),
    );
  }

  group('ACARE Pipeline Unit Tests', () {
    test('1. Equipment filtering excludes inaccessible gear exercises', () {
      // User with ONLY bodyweight gear
      final bodyweightProfile = createTestProfile(equipment: [EquipmentAccess.none]);

      final filtered = EquipmentFilterStep.execute(seedLibrary, bodyweightProfile);

      expect(filtered.isNotEmpty, isTrue);
      for (final ex in filtered) {
        final requiresGym = ex.equipmentRequired.contains(EquipmentAccess.fullGym) ||
            ex.equipmentRequired.contains(EquipmentAccess.dumbbells);
        expect(requiresGym, isFalse,
            reason: 'Exercise ${ex.name} requires gear not owned by user.');
      }
    });

    test('2. Injury contraindication triggers correct substitution chain', () {
      // User with severe shoulder injury
      final injuredProfile = createTestProfile(
        equipment: [EquipmentAccess.fullGym, EquipmentAccess.dumbbells, EquipmentAccess.resistanceBands],
        hasInjuries: true,
        injuryDetails: const [
          InjuryDetail(
            bodyPart: BodyPart.shoulder,
            severity: InjurySeverity.high,
            notes: 'Rotator cuff pain',
          ),
        ],
      );

      final plan = AcareEngine.generateWorkoutPlan(
        profile: injuredProfile,
        exerciseLibrary: seedLibrary,
        recoveryIntensityScore: 0.8,
      );

      expect(plan.sessions.isNotEmpty, isTrue);
      final firstSession = plan.sessions.first;

      // Check no prescribed exercise has a shoulder contraindication
      for (final entry in firstSession.exerciseEntries) {
        final exerciseObj = seedLibrary.firstWhere((e) => e.id == entry.exerciseId);
        expect(exerciseObj.contraindications.contains(BodyPart.shoulder), isFalse,
            reason: 'Exercise ${entry.exerciseName} has a shoulder contraindication!');
      }

      // Check that at least one explanation indicates a substitution was performed
      final substitutionMade = plan.globalExplanations.any(
        (exp) => exp.actionType == 'substituted' || exp.actionType == 'fallback',
      );
      expect(substitutionMade, isTrue);
    });

    test('3. Low recovery score (<0.4) reduces volume and increases rest', () {
      final profile = createTestProfile();

      final planLow = AcareEngine.generateWorkoutPlan(
        profile: profile,
        exerciseLibrary: seedLibrary,
        recoveryIntensityScore: 0.2, // Low recovery score
      );

      final planHigh = AcareEngine.generateWorkoutPlan(
        profile: profile,
        exerciseLibrary: seedLibrary,
        recoveryIntensityScore: 0.9, // High recovery score
      );

      final lowEntries = planLow.sessions.first.exerciseEntries;
      final highEntries = planHigh.sessions.first.exerciseEntries;

      expect(lowEntries.first.prescribedSets, lessThanOrEqualTo(2));
      expect(lowEntries.first.restSeconds, greaterThan(highEntries.first.restSeconds));
      expect(lowEntries.first.explanation.actionType, equals('volume_adjusted'));
    });

    test('4. Full equipment, uninjured user gets unmodified plan', () {
      final healthyProfile = createTestProfile(
        equipment: [EquipmentAccess.fullGym, EquipmentAccess.dumbbells, EquipmentAccess.pullupBar],
        hasInjuries: false,
      );

      final plan = AcareEngine.generateWorkoutPlan(
        profile: healthyProfile,
        exerciseLibrary: seedLibrary,
        recoveryIntensityScore: 0.85,
      );

      expect(plan.sessions.length, equals(3));
      final entries = plan.sessions.first.exerciseEntries;
      expect(entries.isNotEmpty, isTrue);

      for (final entry in entries) {
        expect(entry.explanation.actionType, equals('selected'));
      }
    });

    test('5. Edge Case: Entire substitute chain is contraindicated -> safe fallback', () {
      // Craft a test exercise with ALL substitutes also contraindicated
      const testEx1 = Exercise(
        id: 'test_unsafe_1',
        name: 'Dangerous Press',
        muscleGroup: 'shoulders',
        difficultyTier: FitnessLevel.beginner,
        equipmentRequired: [EquipmentAccess.none],
        defaultSets: 3,
        defaultReps: 10,
        restSeconds: 60,
        contraindications: [BodyPart.shoulder],
        substituteExerciseIds: ['test_unsafe_2'],
        instructions: 'Test',
        formCues: [],
      );

      const testEx2 = Exercise(
        id: 'test_unsafe_2',
        name: 'Also Dangerous Raise',
        muscleGroup: 'shoulders',
        difficultyTier: FitnessLevel.beginner,
        equipmentRequired: [EquipmentAccess.none],
        defaultSets: 3,
        defaultReps: 10,
        restSeconds: 60,
        contraindications: [BodyPart.shoulder],
        substituteExerciseIds: [],
        instructions: 'Test 2',
        formCues: [],
      );

      const safeMobility = Exercise(
        id: 'ex_mobility_flow',
        name: 'Full-Body Joint Mobility Flow',
        muscleGroup: 'full_body',
        difficultyTier: FitnessLevel.beginner,
        equipmentRequired: [EquipmentAccess.none],
        defaultSets: 2,
        defaultReps: 1,
        restSeconds: 30,
        contraindications: [],
        substituteExerciseIds: [],
        instructions: 'Safe mobility flow',
        formCues: [],
      );

      final customLibrary = [testEx1, testEx2, safeMobility];

      final injuredProfile = createTestProfile(
        equipment: [EquipmentAccess.none],
        hasInjuries: true,
        injuryDetails: const [
          InjuryDetail(bodyPart: BodyPart.shoulder, severity: InjurySeverity.high, notes: 'Shoulder injury'),
        ],
      );

      final plan = AcareEngine.generateWorkoutPlan(
        profile: injuredProfile,
        exerciseLibrary: customLibrary,
        recoveryIntensityScore: 0.8,
      );

      final entries = plan.sessions.first.exerciseEntries;
      expect(entries.first.exerciseId, equals('ex_mobility_flow'));
      expect(entries.first.explanation.actionType, equals('fallback'));
      expect(entries.first.explanation.reasonCode, equals('FULL_SUBSTITUTION_CHAIN_EXHAUSTED'));
    });
  });
}
