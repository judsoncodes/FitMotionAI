import '../../../exercise/domain/models/exercise.dart';
import '../../../onboarding/domain/models/onboarding_enums.dart';
import '../../../onboarding/domain/models/user_profile.dart';

class EquipmentFilterStep {
  /// Filters exercise library down to exercises achievable with user's equipment.
  static List<Exercise> execute(List<Exercise> library, UserProfile profile) {
    final userGear = Set<EquipmentAccess>.from(profile.equipmentAccess);
    // Bodyweight (none) is always available
    userGear.add(EquipmentAccess.none);

    return library.where((exercise) {
      // Exercise is valid if user has at least one matching equipment option required
      if (exercise.equipmentRequired.contains(EquipmentAccess.none)) return true;
      return exercise.equipmentRequired.any((req) => userGear.contains(req));
    }).toList();
  }
}
