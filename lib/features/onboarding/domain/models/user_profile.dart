import 'injury_detail.dart';
import 'onboarding_enums.dart';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;

  // Fitness Profile Metrics (Required baseline)
  final int age;
  final String sex; // 'male' | 'female' | 'other'
  final double heightCm;
  final double weightKg;
  final FitnessLevel fitnessLevel;
  final PrimaryGoal primaryGoal;

  // Availability & Gear
  final int daysPerWeek;
  final int sessionDurationMinutes;
  final List<EquipmentAccess> equipmentAccess;

  // Health Disclosure (Sensitive - ACARE filtering)
  final bool hasInjuries;
  final List<InjuryDetail> injuryDetails;
  final String? medicalConditions;

  // Metadata
  final bool onboardingComplete;
  final DateTime lastActive;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
    required this.age,
    required this.sex,
    required this.heightCm,
    required this.weightKg,
    required this.fitnessLevel,
    required this.primaryGoal,
    required this.daysPerWeek,
    required this.sessionDurationMinutes,
    required this.equipmentAccess,
    required this.hasInjuries,
    required this.injuryDetails,
    this.medicalConditions,
    required this.onboardingComplete,
    required this.lastActive,
  });

  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    DateTime? createdAt,
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
    bool? onboardingComplete,
    DateTime? lastActive,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
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
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt.toIso8601String(),
      'age': age,
      'sex': sex,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'fitnessLevel': fitnessLevel.name,
      'primaryGoal': primaryGoal.name,
      'daysPerWeek': daysPerWeek,
      'sessionDurationMinutes': sessionDurationMinutes,
      'equipmentAccess': equipmentAccess.map((e) => e.name).toList(),
      'hasInjuries': hasInjuries,
      'injuryDetails': injuryDetails.map((e) => e.toMap()).toList(),
      'medicalConditions': medicalConditions,
      'onboardingComplete': onboardingComplete,
      'lastActive': lastActive.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      age: (map['age'] as num?)?.toInt() ?? 25,
      sex: map['sex'] ?? 'male',
      heightCm: (map['heightCm'] as num?)?.toDouble() ?? 170.0,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 70.0,
      fitnessLevel: FitnessLevel.values.firstWhere(
        (e) => e.name == map['fitnessLevel'],
        orElse: () => FitnessLevel.beginner,
      ),
      primaryGoal: PrimaryGoal.values.firstWhere(
        (e) => e.name == map['primaryGoal'],
        orElse: () => PrimaryGoal.generalFitness,
      ),
      daysPerWeek: (map['daysPerWeek'] as num?)?.toInt() ?? 3,
      sessionDurationMinutes: (map['sessionDurationMinutes'] as num?)?.toInt() ?? 45,
      equipmentAccess: (map['equipmentAccess'] as List<dynamic>?)
              ?.map((e) => EquipmentAccess.values.firstWhere(
                    (eq) => eq.name == e,
                    orElse: () => EquipmentAccess.none,
                  ))
              .toList() ??
          [EquipmentAccess.none],
      hasInjuries: map['hasInjuries'] ?? false,
      injuryDetails: (map['injuryDetails'] as List<dynamic>?)
              ?.map((e) => InjuryDetail.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      medicalConditions: map['medicalConditions'],
      onboardingComplete: map['onboardingComplete'] ?? false,
      lastActive: map['lastActive'] != null
          ? DateTime.parse(map['lastActive'])
          : DateTime.now(),
    );
  }
}
