enum FitnessLevel {
  beginner('Beginner', 'New to structured movement or resuming after a long break'),
  intermediate('Intermediate', 'Consistently active for 6+ months with basic exercise form'),
  advanced('Advanced', 'High physical conditioning & familiar with complex movements');

  final String label;
  final String description;
  const FitnessLevel(this.label, this.description);
}

enum PrimaryGoal {
  weightLoss('Weight Loss', 'Burn fat and improve metabolic conditioning'),
  muscleGain('Muscle Gain', 'Hypertrophy & progressive overload strength'),
  endurance('Endurance', 'Cardiovascular stamina & work capacity'),
  generalFitness('General Fitness', 'Overall vitality, mobility, & functional strength'),
  rehab('Rehabilitation & Recovery', 'Active recovery, joint stability, & injury rehab');

  final String label;
  final String description;
  const PrimaryGoal(this.label, this.description);
}

enum EquipmentAccess {
  none('Bodyweight / No Equipment'),
  dumbbells('Dumbbells'),
  kettlebells('Kettlebells'),
  resistanceBands('Resistance Bands'),
  pullupBar('Pull-up Bar'),
  fullGym('Full Commercial Gym');

  final String label;
  const EquipmentAccess(this.label);
}

enum BodyPart {
  knee('Knee'),
  shoulder('Shoulder'),
  lowerBack('Lower Back'),
  ankle('Ankle'),
  wrist('Wrist'),
  hip('Hip'),
  neck('Neck'),
  elbow('Elbow');

  final String label;
  const BodyPart(this.label);
}

enum InjurySeverity {
  low('Low', 'Minor discomfort, light load adjustments needed'),
  medium('Medium', 'Moderate pain under specific joint angles/loads'),
  high('High', 'Severe limitation, strict exercise contraindication needed');

  final String label;
  final String description;
  const InjurySeverity(this.label, this.description);
}
