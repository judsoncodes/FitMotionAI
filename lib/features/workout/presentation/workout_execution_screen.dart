import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import 'workout_execution_providers.dart';

class WorkoutExecutionScreen extends ConsumerWidget {
  const WorkoutExecutionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final execState = ref.watch(workoutExecutionViewModelProvider);
    final execNotifier = ref.read(workoutExecutionViewModelProvider.notifier);

    final session = execState.session;
    final exercise = execState.currentExercise;

    if (session == null || exercise == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workout Execution')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No active session selected.'),
              const SizedBox(height: 16),
              AppButton(
                text: 'Back to Workout Plan',
                onPressed: () => context.go('/workout-plan'),
              ),
            ],
          ),
        ),
      );
    }

    final totalExercises = session.exerciseEntries.length;
    final currentIndex = execState.currentExerciseIndex;
    final completedSets = execState.completedSets[currentIndex] ?? {};
    final isTimed = exercise.prescribedDurationSeconds != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(session.dayLabel),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Bar & Step Label
            LinearProgressIndicator(
              value: (currentIndex + 1) / totalExercises,
              backgroundColor: theme.colorScheme.surfaceVariant,
              color: theme.colorScheme.primary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exercise ${currentIndex + 1} of $totalExercises',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => execNotifier.skipCurrentExercise(),
                  icon: const Icon(Icons.skip_next_rounded, size: 18),
                  label: const Text('Skip'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Exercise Overview Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.exerciseName,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          isTimed
                              ? '${exercise.prescribedSets} sets × ${exercise.prescribedDurationSeconds}s'
                              : '${exercise.prescribedSets} sets × ${exercise.prescribedReps} reps',
                        ),
                        backgroundColor: theme.colorScheme.primaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text('Rest: ${exercise.restSeconds}s'),
                        backgroundColor: theme.colorScheme.secondaryContainer,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Timed Exercise Timer Box
            if (isTimed) ...[
              AppCard(
                child: Column(
                  children: [
                    Text(
                      'Timer: ${execState.timerSecondsRemaining}s',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: execState.isTimerRunning ? 'Pause Timer' : 'Start Timer',
                      icon: execState.isTimerRunning
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      variant: execState.isTimerRunning
                          ? AppButtonVariant.outlined
                          : AppButtonVariant.primary,
                      onPressed: () => execNotifier.toggleTimer(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Set Completion Checklist Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set Completion Tracker',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(exercise.prescribedSets, (setIndex) {
                    final isDone = completedSets.contains(setIndex);
                    return CheckboxListTile(
                      title: Text(
                        'Set ${setIndex + 1}: ${isTimed ? "${exercise.prescribedDurationSeconds}s duration" : "${exercise.prescribedReps} reps"}',
                        style: TextStyle(
                          decoration: isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      value: isDone,
                      activeColor: theme.colorScheme.primary,
                      onChanged: (val) => execNotifier.toggleSetCompleted(setIndex),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Form Cues Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_rounded, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('Form Cues', style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...['Maintain neutral spine & engaged core', 'Control the movement tempo on descent', 'Breathe out on exertion']
                      .map((cue) => Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_outline_rounded,
                                    size: 16, color: theme.colorScheme.secondary),
                                const SizedBox(width: 8),
                                Expanded(child: Text(cue, style: theme.textTheme.bodyMedium)),
                              ],
                            ),
                          )),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Bottom Navigation Actions
            Row(
              children: [
                if (currentIndex > 0) ...[
                  Expanded(
                    child: AppButton(
                      text: 'Previous',
                      variant: AppButtonVariant.outlined,
                      icon: Icons.arrow_back_rounded,
                      onPressed: () => execNotifier.previousExercise(),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: AppButton(
                    text: execState.isLastExercise ? 'Complete Session' : 'Next Exercise',
                    icon: execState.isLastExercise
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_rounded,
                    onPressed: () {
                      if (execState.isLastExercise) {
                        context.go('/post-workout-feedback');
                      } else {
                        execNotifier.nextExercise();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
