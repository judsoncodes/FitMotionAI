import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/workout_plan.dart';

class WorkoutExecutionState {
  final WorkoutSession? session;
  final int currentExerciseIndex;
  final Map<int, Set<int>> completedSets;
  final Map<int, bool> exerciseSkipped;
  final bool isTimerRunning;
  final int timerSecondsRemaining;

  const WorkoutExecutionState({
    this.session,
    this.currentExerciseIndex = 0,
    this.completedSets = const {},
    this.exerciseSkipped = const {},
    this.isTimerRunning = false,
    this.timerSecondsRemaining = 0,
  });

  ExerciseEntry? get currentExercise {
    if (session == null || currentExerciseIndex >= session!.exerciseEntries.length) {
      return null;
    }
    return session!.exerciseEntries[currentExerciseIndex];
  }

  bool get isLastExercise {
    if (session == null) return true;
    return currentExerciseIndex >= session!.exerciseEntries.length - 1;
  }

  WorkoutExecutionState copyWith({
    WorkoutSession? session,
    int? currentExerciseIndex,
    Map<int, Set<int>>? completedSets,
    Map<int, bool>? exerciseSkipped,
    bool? isTimerRunning,
    int? timerSecondsRemaining,
  }) {
    return WorkoutExecutionState(
      session: session ?? this.session,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      completedSets: completedSets ?? this.completedSets,
      exerciseSkipped: exerciseSkipped ?? this.exerciseSkipped,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      timerSecondsRemaining: timerSecondsRemaining ?? this.timerSecondsRemaining,
    );
  }
}

class WorkoutExecutionViewModel extends StateNotifier<WorkoutExecutionState> {
  Timer? _timer;

  WorkoutExecutionViewModel() : super(const WorkoutExecutionState());

  void startSession(WorkoutSession session) {
    _timer?.cancel();
    final firstEntry = session.exerciseEntries.isNotEmpty ? session.exerciseEntries.first : null;
    final initialTimer = firstEntry?.prescribedDurationSeconds ?? 0;

    state = WorkoutExecutionState(
      session: session,
      currentExerciseIndex: 0,
      completedSets: {},
      exerciseSkipped: {},
      isTimerRunning: false,
      timerSecondsRemaining: initialTimer,
    );
  }

  void toggleSetCompleted(int setIndex) {
    final currentSets = Set<int>.from(state.completedSets[state.currentExerciseIndex] ?? {});
    if (currentSets.contains(setIndex)) {
      currentSets.remove(setIndex);
    } else {
      currentSets.add(setIndex);
    }

    final newCompletedMap = Map<int, Set<int>>.from(state.completedSets);
    newCompletedMap[state.currentExerciseIndex] = currentSets;
    state = state.copyWith(completedSets: newCompletedMap);
  }

  void skipCurrentExercise() {
    final newSkippedMap = Map<int, bool>.from(state.exerciseSkipped);
    newSkippedMap[state.currentExerciseIndex] = true;
    state = state.copyWith(exerciseSkipped: newSkippedMap);
    nextExercise();
  }

  void nextExercise() {
    _timer?.cancel();
    if (state.isLastExercise) return;

    final nextIndex = state.currentExerciseIndex + 1;
    final nextExercise = state.session?.exerciseEntries[nextIndex];
    final nextTimer = nextExercise?.prescribedDurationSeconds ?? 0;

    state = state.copyWith(
      currentExerciseIndex: nextIndex,
      isTimerRunning: false,
      timerSecondsRemaining: nextTimer,
    );
  }

  void previousExercise() {
    _timer?.cancel();
    if (state.currentExerciseIndex <= 0) return;

    final prevIndex = state.currentExerciseIndex - 1;
    final prevExercise = state.session?.exerciseEntries[prevIndex];
    final prevTimer = prevExercise?.prescribedDurationSeconds ?? 0;

    state = state.copyWith(
      currentExerciseIndex: prevIndex,
      isTimerRunning: false,
      timerSecondsRemaining: prevTimer,
    );
  }

  void toggleTimer() {
    if (state.isTimerRunning) {
      _timer?.cancel();
      state = state.copyWith(isTimerRunning: false);
    } else {
      state = state.copyWith(isTimerRunning: true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (state.timerSecondsRemaining <= 1) {
          _timer?.cancel();
          state = state.copyWith(isTimerRunning: false, timerSecondsRemaining: 0);
        } else {
          state = state.copyWith(timerSecondsRemaining: state.timerSecondsRemaining - 1);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final workoutExecutionViewModelProvider =
    StateNotifierProvider<WorkoutExecutionViewModel, WorkoutExecutionState>((ref) {
  return WorkoutExecutionViewModel();
});
