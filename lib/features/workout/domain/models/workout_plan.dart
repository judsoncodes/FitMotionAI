class SelectionExplanation {
  final String exerciseId;
  final String exerciseName;
  final String actionType; // 'selected' | 'substituted' | 'volume_adjusted' | 'fallback'
  final String reasonCode;
  final String details;

  const SelectionExplanation({
    required this.exerciseId,
    required this.exerciseName,
    required this.actionType,
    required this.reasonCode,
    required this.details,
  });

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'actionType': actionType,
      'reasonCode': reasonCode,
      'details': details,
    };
  }

  factory SelectionExplanation.fromMap(Map<String, dynamic> map) {
    return SelectionExplanation(
      exerciseId: map['exerciseId'] ?? '',
      exerciseName: map['exerciseName'] ?? '',
      actionType: map['actionType'] ?? 'selected',
      reasonCode: map['reasonCode'] ?? '',
      details: map['details'] ?? '',
    );
  }
}

class CompletionRecord {
  final bool completed;
  final int? difficultyRating; // 1-5
  final bool painReported;
  final String? painDetails;

  const CompletionRecord({
    this.completed = false,
    this.difficultyRating,
    this.painReported = false,
    this.painDetails,
  });

  Map<String, dynamic> toMap() {
    return {
      'completed': completed,
      'difficultyRating': difficultyRating,
      'painReported': painReported,
      'painDetails': painDetails,
    };
  }

  factory CompletionRecord.fromMap(Map<String, dynamic> map) {
    return CompletionRecord(
      completed: map['completed'] ?? false,
      difficultyRating: (map['difficultyRating'] as num?)?.toInt(),
      painReported: map['painReported'] ?? false,
      painDetails: map['painDetails'],
    );
  }
}

class ExerciseEntry {
  final String exerciseId;
  final String exerciseName;
  final int prescribedSets;
  final int prescribedReps;
  final int? prescribedDurationSeconds;
  final int restSeconds;
  final int order;
  final SelectionExplanation explanation;

  const ExerciseEntry({
    required this.exerciseId,
    required this.exerciseName,
    required this.prescribedSets,
    required this.prescribedReps,
    this.prescribedDurationSeconds,
    required this.restSeconds,
    required this.order,
    required this.explanation,
  });

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'prescribedSets': prescribedSets,
      'prescribedReps': prescribedReps,
      'prescribedDurationSeconds': prescribedDurationSeconds,
      'restSeconds': restSeconds,
      'order': order,
      'explanation': explanation.toMap(),
    };
  }

  factory ExerciseEntry.fromMap(Map<String, dynamic> map) {
    return ExerciseEntry(
      exerciseId: map['exerciseId'] ?? '',
      exerciseName: map['exerciseName'] ?? '',
      prescribedSets: (map['prescribedSets'] as num?)?.toInt() ?? 3,
      prescribedReps: (map['prescribedReps'] as num?)?.toInt() ?? 10,
      prescribedDurationSeconds: (map['prescribedDurationSeconds'] as num?)?.toInt(),
      restSeconds: (map['restSeconds'] as num?)?.toInt() ?? 60,
      order: (map['order'] as num?)?.toInt() ?? 0,
      explanation: SelectionExplanation.fromMap(
          Map<String, dynamic>.from(map['explanation'] ?? {})),
    );
  }
}

class WorkoutSession {
  final String id;
  final String dayLabel; // e.g. "Day 1 - Upper Body Focus"
  final List<ExerciseEntry> exerciseEntries;
  final CompletionRecord completionRecord;

  const WorkoutSession({
    required this.id,
    required this.dayLabel,
    required this.exerciseEntries,
    this.completionRecord = const CompletionRecord(),
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dayLabel': dayLabel,
      'exerciseEntries': exerciseEntries.map((e) => e.toMap()).toList(),
      'completionRecord': completionRecord.toMap(),
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'] ?? '',
      dayLabel: map['dayLabel'] ?? '',
      exerciseEntries: (map['exerciseEntries'] as List<dynamic>?)
              ?.map((e) => ExerciseEntry.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      completionRecord: CompletionRecord.fromMap(
          Map<String, dynamic>.from(map['completionRecord'] ?? {})),
    );
  }
}

class WorkoutPlan {
  final String id;
  final String userId;
  final DateTime generatedAt;
  final String status; // 'active' | 'completed' | 'archived'
  final double recoveryIntensityScore;
  final List<WorkoutSession> sessions;
  final List<SelectionExplanation> globalExplanations;

  const WorkoutPlan({
    required this.id,
    required this.userId,
    required this.generatedAt,
    this.status = 'active',
    required this.recoveryIntensityScore,
    required this.sessions,
    required this.globalExplanations,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'generatedAt': generatedAt.toIso8601String(),
      'status': status,
      'recoveryIntensityScore': recoveryIntensityScore,
      'sessions': sessions.map((s) => s.toMap()).toList(),
      'globalExplanations': globalExplanations.map((e) => e.toMap()).toList(),
    };
  }

  factory WorkoutPlan.fromMap(Map<String, dynamic> map) {
    return WorkoutPlan(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      generatedAt: map['generatedAt'] != null
          ? DateTime.parse(map['generatedAt'])
          : DateTime.now(),
      status: map['status'] ?? 'active',
      recoveryIntensityScore: (map['recoveryIntensityScore'] as num?)?.toDouble() ?? 1.0,
      sessions: (map['sessions'] as List<dynamic>?)
              ?.map((s) => WorkoutSession.fromMap(Map<String, dynamic>.from(s)))
              .toList() ??
          [],
      globalExplanations: (map['globalExplanations'] as List<dynamic>?)
              ?.map((e) => SelectionExplanation.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
    );
  }
}
