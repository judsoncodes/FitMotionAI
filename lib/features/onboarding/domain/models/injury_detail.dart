import 'onboarding_enums.dart';

class InjuryDetail {
  final BodyPart bodyPart;
  final InjurySeverity severity;
  final String notes;

  const InjuryDetail({
    required this.bodyPart,
    required this.severity,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'bodyPart': bodyPart.name,
      'severity': severity.name,
      'notes': notes,
    };
  }

  factory InjuryDetail.fromMap(Map<String, dynamic> map) {
    return InjuryDetail(
      bodyPart: BodyPart.values.firstWhere(
        (e) => e.name == map['bodyPart'],
        orElse: () => BodyPart.knee,
      ),
      severity: InjurySeverity.values.firstWhere(
        (e) => e.name == map['severity'],
        orElse: () => InjurySeverity.low,
      ),
      notes: map['notes'] ?? '',
    );
  }
}
