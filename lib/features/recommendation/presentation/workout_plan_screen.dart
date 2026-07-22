import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../workout/domain/models/workout_plan.dart';
import '../../workout/presentation/workout_execution_providers.dart';
import 'workout_plan_providers.dart';

class WorkoutPlanScreen extends ConsumerWidget {
  const WorkoutPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final activePlanAsync = ref.watch(activeWorkoutPlanStreamProvider);
    final vmState = ref.watch(workoutPlanViewModelProvider);

    final plan = activePlanAsync.asData?.value ?? vmState.plan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your AI Workout Plan'),
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
      body: plan == null
          ? _buildEmptyState(context, ref)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan Header Card
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                color: theme.colorScheme.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ACARE Personalized Protocol',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Recovery Score: ${(plan.recoveryIntensityScore * 100).toInt()}% • ${plan.sessions.length} Sessions/Wk',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Active Scoring Model: XGBoost ML (TFLite)',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.onSecondaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Weekly Sessions (${plan.sessions.length})',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),

                  // Expandable Session Cards
                  ...plan.sessions.map((session) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: ExpansionTile(
                          initiallyExpanded: session == plan.sessions.first,
                          leading: Icon(
                            Icons.fitness_center_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(
                            session.dayLabel,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${session.exerciseEntries.length} exercises prescribed',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  ...session.exerciseEntries.map((entry) {
                                    return _buildExerciseTile(context, entry);
                                  }).toList(),
                                  const SizedBox(height: 12),
                                  AppButton(
                                    text: 'Start Session',
                                    icon: Icons.play_arrow_rounded,
                                    onPressed: () {
                                      ref
                                          .read(workoutExecutionViewModelProvider.notifier)
                                          .startSession(session);
                                      context.push('/workout-execution');
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }

  Widget _buildExerciseTile(BuildContext context, ExerciseEntry entry) {
    final theme = Theme.of(context);
    final explanation = entry.explanation;
    final hasExplanation = explanation.actionType != 'selected';

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${entry.order}. ${entry.exerciseName}',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                entry.prescribedDurationSeconds != null
                    ? '${entry.prescribedSets} sets × ${entry.prescribedDurationSeconds}s'
                    : '${entry.prescribedSets} sets × ${entry.prescribedReps} reps',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Rest: ${entry.restSeconds}s between sets',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          // ACARE Explanation Chip (if substituted, volume-adjusted, or fallback)
          if (hasExplanation) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: explanation.actionType == 'substituted'
                    ? theme.colorScheme.secondaryContainer
                    : (explanation.actionType == 'fallback'
                        ? theme.colorScheme.errorContainer
                        : theme.colorScheme.tertiaryContainer),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    explanation.actionType == 'substituted'
                        ? Icons.swap_horiz_rounded
                        : (explanation.actionType == 'fallback'
                            ? Icons.warning_amber_rounded
                            : Icons.tune_rounded),
                    size: 16,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      explanation.details,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final vmState = ref.watch(workoutPlanViewModelProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Active Workout Plan',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Generate your personalized ACARE recovery & strength plan.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Generate My Workout Plan',
              icon: Icons.auto_awesome_rounded,
              isLoading: vmState.status == WorkoutPlanStatus.generating,
              onPressed: () {
                ref.read(workoutPlanViewModelProvider.notifier).generatePlan();
              },
            ),
          ],
        ),
      ),
    );
  }
}
