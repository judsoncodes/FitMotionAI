import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../../exercise/data/repositories/exercise_repository_impl.dart';
import '../../exercise/domain/repositories/exercise_repository.dart';
import '../../onboarding/presentation/onboarding_providers.dart';
import '../../recovery/presentation/recovery_providers.dart';
import '../../workout/data/repositories/workout_plan_repository_impl.dart';
import '../../workout/domain/models/workout_plan.dart';
import '../../workout/domain/repositories/workout_plan_repository.dart';
import '../domain/services/recommendation_service.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepositoryImpl();
});

final workoutPlanRepositoryProvider = Provider<WorkoutPlanRepository>((ref) {
  return WorkoutPlanRepositoryImpl();
});

final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  return RecommendationService(
    userRepository: ref.watch(userRepositoryProvider),
    exerciseRepository: ref.watch(exerciseRepositoryProvider),
    workoutPlanRepository: ref.watch(workoutPlanRepositoryProvider),
    recoverySignalService: ref.watch(recoverySignalServiceProvider),
  );
});

final activeWorkoutPlanStreamProvider = StreamProvider<WorkoutPlan?>((ref) {
  final authState = ref.watch(authStateChangesProvider).value;
  if (authState == null || !authState.isAuthenticated || authState.userId == null) {
    return Stream.value(null);
  }
  final repo = ref.watch(workoutPlanRepositoryProvider);
  return repo.activeWorkoutPlanStream(authState.userId!);
});

enum WorkoutPlanStatus { idle, generating, ready, error }

class WorkoutPlanState {
  final WorkoutPlanStatus status;
  final WorkoutPlan? plan;
  final String? errorMessage;

  const WorkoutPlanState({
    this.status = WorkoutPlanStatus.idle,
    this.plan,
    this.errorMessage,
  });

  WorkoutPlanState copyWith({
    WorkoutPlanStatus? status,
    WorkoutPlan? plan,
    String? errorMessage,
  }) {
    return WorkoutPlanState(
      status: status ?? this.status,
      plan: plan ?? this.plan,
      errorMessage: errorMessage,
    );
  }
}

class WorkoutPlanViewModel extends StateNotifier<WorkoutPlanState> {
  final RecommendationService _recommendationService;
  final Ref _ref;

  WorkoutPlanViewModel(this._recommendationService, this._ref)
      : super(const WorkoutPlanState());

  Future<bool> generatePlan() async {
    final authState = _ref.read(authViewModelProvider).authState;
    if (!authState.isAuthenticated || authState.userId == null) {
      state = state.copyWith(
        status: WorkoutPlanStatus.error,
        errorMessage: 'User is not logged in.',
      );
      return false;
    }

    state = state.copyWith(status: WorkoutPlanStatus.generating, errorMessage: null);

    try {
      final plan = await _recommendationService.generatePlanForUser(authState.userId!);
      state = state.copyWith(status: WorkoutPlanStatus.ready, plan: plan);
      return true;
    } on ProfileNotFoundException catch (e) {
      state = state.copyWith(
        status: WorkoutPlanStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: WorkoutPlanStatus.error,
        errorMessage: 'Failed to generate plan: ${e.toString()}',
      );
      return false;
    }
  }
}

final workoutPlanViewModelProvider =
    StateNotifierProvider<WorkoutPlanViewModel, WorkoutPlanState>((ref) {
  final service = ref.watch(recommendationServiceProvider);
  return WorkoutPlanViewModel(service, ref);
});
