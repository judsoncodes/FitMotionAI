import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/repositories/user_repository_impl.dart';
import '../domain/models/injury_detail.dart';
import '../domain/models/onboarding_enums.dart';
import '../domain/models/user_profile.dart';
import '../domain/repositories/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl();
});

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final authState = ref.watch(authStateChangesProvider).value ?? ref.watch(authViewModelProvider).authState;
  if (!authState.isAuthenticated || authState.userId == null) {
    return Stream.value(null);
  }

  if (authState.userId == 'demo_user_001') {
    final now = DateTime.now();
    return Stream.value(
      UserProfile(
        uid: 'demo_user_001',
        email: 'demo.athlete@fitmotion.ai',
        displayName: 'Demo Athlete',
        createdAt: now,
        age: 27,
        sex: 'female',
        heightCm: 168,
        weightKg: 62,
        fitnessLevel: FitnessLevel.intermediate,
        primaryGoal: PrimaryGoal.muscleGain,
        daysPerWeek: 4,
        sessionDurationMinutes: 45,
        equipmentAccess: const [EquipmentAccess.dumbbells, EquipmentAccess.none],
        hasInjuries: true,
        injuryDetails: const [
          InjuryDetail(
            bodyPart: BodyPart.shoulder,
            severity: InjurySeverity.medium,
            notes: 'Right rotator cuff discomfort',
          ),
        ],
        onboardingComplete: true,
        lastActive: now,
      ),
    );
  }

  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.userProfileStream(authState.userId!);
});

class OnboardingFormState {
  final int age;
  final String sex;
  final double heightCm;
  final double weightKg;
  final FitnessLevel? fitnessLevel;
  final PrimaryGoal? primaryGoal;
  final int daysPerWeek;
  final int sessionDurationMinutes;
  final List<EquipmentAccess> equipmentAccess;
  final bool hasInjuries;
  final List<InjuryDetail> injuryDetails;
  final String medicalConditions;
  final bool isSubmitting;
  final String? errorMessage;

  const OnboardingFormState({
    this.age = 25,
    this.sex = 'male',
    this.heightCm = 170.0,
    this.weightKg = 70.0,
    this.fitnessLevel = FitnessLevel.beginner,
    this.primaryGoal = PrimaryGoal.generalFitness,
    this.daysPerWeek = 4,
    this.sessionDurationMinutes = 45,
    this.equipmentAccess = const [EquipmentAccess.dumbbells, EquipmentAccess.resistanceBands],
    this.hasInjuries = false,
    this.injuryDetails = const [],
    this.medicalConditions = '',
    this.isSubmitting = false,
    this.errorMessage,
  });

  OnboardingFormState copyWith({
    int? age,
    String? sex,
    double? heightCm,
    double? weightKg,
    FitnessLevel? fitnessLevel,
    PrimaryGoal? primaryGoal,
    int? daysPerWeek,
    int? sessionDurationMinutes,
    List<EquipmentAccess>? equipmentAccess,
    bool? hasInjuries,
    List<InjuryDetail>? injuryDetails,
    String? medicalConditions,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return OnboardingFormState(
      age: age ?? this.age,
      sex: sex ?? this.sex,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      sessionDurationMinutes: sessionDurationMinutes ?? this.sessionDurationMinutes,
      equipmentAccess: equipmentAccess ?? this.equipmentAccess,
      hasInjuries: hasInjuries ?? this.hasInjuries,
      injuryDetails: injuryDetails ?? this.injuryDetails,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

class OnboardingFormNotifier extends StateNotifier<OnboardingFormState> {
  final UserRepository _userRepository;
  final Ref _ref;

  OnboardingFormNotifier(this._userRepository, this._ref)
      : super(const OnboardingFormState());

  void updateBasicInfo({int? age, String? sex, double? heightCm, double? weightKg}) {
    state = state.copyWith(
      age: age,
      sex: sex,
      heightCm: heightCm,
      weightKg: weightKg,
    );
  }

  void updateFitnessAndGoal({FitnessLevel? level, PrimaryGoal? goal}) {
    state = state.copyWith(fitnessLevel: level, primaryGoal: goal);
  }

  void updateAvailability({
    int? daysPerWeek,
    int? sessionDurationMinutes,
    List<EquipmentAccess>? equipmentAccess,
  }) {
    state = state.copyWith(
      daysPerWeek: daysPerWeek,
      sessionDurationMinutes: sessionDurationMinutes,
      equipmentAccess: equipmentAccess,
    );
  }

  void toggleEquipment(EquipmentAccess equipment) {
    final current = List<EquipmentAccess>.from(state.equipmentAccess);
    if (current.contains(equipment)) {
      if (current.length > 1) current.remove(equipment);
    } else {
      current.add(equipment);
    }
    state = state.copyWith(equipmentAccess: current);
  }

  void updateHealthDisclosure({
    bool? hasInjuries,
    List<InjuryDetail>? injuryDetails,
    String? medicalConditions,
  }) {
    state = state.copyWith(
      hasInjuries: hasInjuries,
      injuryDetails: injuryDetails,
      medicalConditions: medicalConditions,
    );
  }

  void addInjuryDetail(InjuryDetail detail) {
    final updated = List<InjuryDetail>.from(state.injuryDetails)..add(detail);
    state = state.copyWith(hasInjuries: true, injuryDetails: updated);
  }

  void removeInjuryDetail(int index) {
    final updated = List<InjuryDetail>.from(state.injuryDetails)..removeAt(index);
    state = state.copyWith(
      hasInjuries: updated.isNotEmpty,
      injuryDetails: updated,
    );
  }

  Future<bool> submitProfile() async {
    final authState = _ref.read(authViewModelProvider).authState;
    if (!authState.isAuthenticated || authState.userId == null) {
      state = state.copyWith(errorMessage: 'User not authenticated.');
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final now = DateTime.now();
      final profile = UserProfile(
        uid: authState.userId!,
        email: authState.email ?? '',
        displayName: authState.email?.split('@').first ?? 'Athlete',
        createdAt: now,
        age: state.age,
        sex: state.sex,
        heightCm: state.heightCm,
        weightKg: state.weightKg,
        fitnessLevel: state.fitnessLevel ?? FitnessLevel.beginner,
        primaryGoal: state.primaryGoal ?? PrimaryGoal.generalFitness,
        daysPerWeek: state.daysPerWeek,
        sessionDurationMinutes: state.sessionDurationMinutes,
        equipmentAccess: state.equipmentAccess,
        hasInjuries: state.hasInjuries,
        injuryDetails: state.injuryDetails,
        medicalConditions: state.medicalConditions.isEmpty ? null : state.medicalConditions,
        onboardingComplete: true,
        lastActive: now,
      );

      await _userRepository.saveUserProfile(profile);
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to save profile: ${e.toString()}',
      );
      return false;
    }
  }
}

final onboardingFormStateProvider =
    StateNotifierProvider<OnboardingFormNotifier, OnboardingFormState>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return OnboardingFormNotifier(repository, ref);
});
