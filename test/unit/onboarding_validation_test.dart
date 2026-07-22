import 'package:fit_motion_ai/features/onboarding/domain/models/onboarding_enums.dart';
import 'package:fit_motion_ai/features/onboarding/domain/onboarding_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnboardingValidator Unit Tests', () {
    test('Age validation - valid range (13 to 120)', () {
      expect(OnboardingValidator.validateAge('25'), isNull);
      expect(OnboardingValidator.validateAge('13'), isNull);
      expect(OnboardingValidator.validateAge('120'), isNull);

      expect(OnboardingValidator.validateAge(''), isNotNull);
      expect(OnboardingValidator.validateAge('12'), isNotNull);
      expect(OnboardingValidator.validateAge('121'), isNotNull);
      expect(OnboardingValidator.validateAge('abc'), isNotNull);
    });

    test('Height validation - valid range (100cm to 250cm)', () {
      expect(OnboardingValidator.validateHeight('175'), isNull);
      expect(OnboardingValidator.validateHeight('100'), isNull);
      expect(OnboardingValidator.validateHeight('250'), isNull);

      expect(OnboardingValidator.validateHeight(''), isNotNull);
      expect(OnboardingValidator.validateHeight('99'), isNotNull);
      expect(OnboardingValidator.validateHeight('251'), isNotNull);
      expect(OnboardingValidator.validateHeight('xyz'), isNotNull);
    });

    test('Weight validation - valid range (30kg to 300kg)', () {
      expect(OnboardingValidator.validateWeight('70'), isNull);
      expect(OnboardingValidator.validateWeight('30'), isNull);
      expect(OnboardingValidator.validateWeight('300'), isNull);

      expect(OnboardingValidator.validateWeight(''), isNotNull);
      expect(OnboardingValidator.validateWeight('29'), isNotNull);
      expect(OnboardingValidator.validateWeight('301'), isNotNull);
    });

    test('Sex validation', () {
      expect(OnboardingValidator.validateSex('male'), isNull);
      expect(OnboardingValidator.validateSex('female'), isNull);
      expect(OnboardingValidator.validateSex(''), isNotNull);
      expect(OnboardingValidator.validateSex(null), isNotNull);
    });

    test('Fitness level & primary goal validation', () {
      expect(OnboardingValidator.validateFitnessLevel(FitnessLevel.intermediate), isNull);
      expect(OnboardingValidator.validateFitnessLevel(null), isNotNull);

      expect(OnboardingValidator.validatePrimaryGoal(PrimaryGoal.weightLoss), isNull);
      expect(OnboardingValidator.validatePrimaryGoal(null), isNotNull);
    });

    test('Equipment access validation', () {
      expect(OnboardingValidator.validateEquipment([EquipmentAccess.dumbbells]), isNull);
      expect(OnboardingValidator.validateEquipment([]), isNotNull);
    });
  });
}
