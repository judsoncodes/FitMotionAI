import 'package:fit_motion_ai/features/onboarding/domain/models/onboarding_enums.dart';
import 'package:fit_motion_ai/features/recovery/domain/models/recovery_features.dart';
import 'package:fit_motion_ai/features/recovery/domain/models/recovery_log.dart';
import 'package:fit_motion_ai/features/recovery/domain/repositories/recovery_log_repository.dart';
import 'package:fit_motion_ai/features/recovery/domain/services/recovery_signal_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRecoveryLogRepository extends Mock implements RecoveryLogRepository {}

void main() {
  late MockRecoveryLogRepository mockRepo;
  late RecoverySignalService service;

  setUp(() {
    mockRepo = MockRecoveryLogRepository();
    service = RecoverySignalService(mockRepo);
  });

  group('RecoverySignalService Unit Tests', () {
    test('Healthy user with 100% completion & low difficulty scores 0.90+', () async {
      final logs = [
        RecoveryLog(
          id: '1',
          userId: 'u1',
          timestamp: DateTime.now(),
          overallDifficulty: 2,
          completionRate: 1.0,
          hasPain: false,
        ),
      ];

      when(() => mockRepo.getRecentRecoveryLogs('u1', limit: 5))
          .thenAnswer((_) async => logs);

      final score = await service.computeRecoveryScore('u1');
      expect(score, greaterThanOrEqualTo(0.90));
    });

    test('Recent moderate pain report reduces recovery score by 0.25', () {
      const features = RecoveryFeatures(
        averageDifficultyRating: 3.0,
        averageCompletionRate: 1.0,
        recentPainIncidentCount: 1,
        daysSinceLastSession: 1,
        lastReportedPainBodyPart: BodyPart.shoulder,
        lastReportedPainSeverity: InjurySeverity.medium,
      );

      final score = service.computeScoreFromFeatures(features);
      expect(score, equals(0.60)); // 0.85 baseline - 0.25 penalty
    });

    test('Severe pain report reduces recovery score to 0.45', () {
      const features = RecoveryFeatures(
        averageDifficultyRating: 3.0,
        averageCompletionRate: 1.0,
        recentPainIncidentCount: 1,
        daysSinceLastSession: 1,
        lastReportedPainBodyPart: BodyPart.knee,
        lastReportedPainSeverity: InjurySeverity.high,
      );

      final score = service.computeScoreFromFeatures(features);
      expect(score, closeTo(0.45, 0.01)); // 0.85 baseline - 0.40 penalty
    });

    test('High difficulty rating (5.0) applies difficulty penalty', () {
      const features = RecoveryFeatures(
        averageDifficultyRating: 5.0,
        averageCompletionRate: 1.0,
        recentPainIncidentCount: 0,
        daysSinceLastSession: 1,
      );

      final score = service.computeScoreFromFeatures(features);
      expect(score, closeTo(0.65, 0.01)); // 0.85 - 0.20 penalty
    });
  });
}
