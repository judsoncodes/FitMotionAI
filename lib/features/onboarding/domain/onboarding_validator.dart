import 'models/onboarding_enums.dart';

class OnboardingValidator {
  static String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Age is required.';
    }
    final age = int.tryParse(value.trim());
    if (age == null || age < 13 || age > 120) {
      return 'Please enter a valid age between 13 and 120.';
    }
    return null;
  }

  static String? validateHeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Height is required.';
    }
    final height = double.tryParse(value.trim());
    if (height == null || height < 100 || height > 250) {
      return 'Please enter height between 100cm and 250cm.';
    }
    return null;
  }

  static String? validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Weight is required.';
    }
    final weight = double.tryParse(value.trim());
    if (weight == null || weight < 30 || weight > 300) {
      return 'Please enter weight between 30kg and 300kg.';
    }
    return null;
  }

  static String? validateSex(String? sex) {
    if (sex == null || sex.isEmpty) {
      return 'Please select a sex option.';
    }
    return null;
  }

  static String? validateFitnessLevel(FitnessLevel? level) {
    if (level == null) {
      return 'Please select your current fitness level.';
    }
    return null;
  }

  static String? validatePrimaryGoal(PrimaryGoal? goal) {
    if (goal == null) {
      return 'Please select a primary goal.';
    }
    return null;
  }

  static String? validateEquipment(List<EquipmentAccess> equipment) {
    if (equipment.isEmpty) {
      return 'Please select at least one equipment option.';
    }
    return null;
  }
}
