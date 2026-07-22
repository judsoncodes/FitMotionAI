import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../onboarding/presentation/onboarding_providers.dart';
import '../../recommendation/presentation/workout_plan_providers.dart';
import '../../recovery/presentation/recovery_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final authViewModel = ref.watch(authViewModelProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final activePlanAsync = ref.watch(activeWorkoutPlanStreamProvider);
    final vmState = ref.watch(workoutPlanViewModelProvider);

    final plan = activePlanAsync.asData?.value ?? vmState.plan;
    final isGenerating = vmState.status == WorkoutPlanStatus.generating;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard - ${AppConstants.appName}'),
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
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              ref.read(authViewModelProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final profile = profileAsync.value;
          final displayName = profile?.displayName.isNotEmpty == true
              ? profile!.displayName
              : (authViewModel.authState.email?.split('@').first ?? 'Athlete');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $displayName!',
                  style: theme.textTheme.headlineLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'UID: ${authViewModel.authState.userId ?? "Unknown"} • Goal: ${profile?.primaryGoal.label ?? "General Fitness"}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),

                // AI Recovery Status Card
                AppCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.psychology_rounded,
                          color: theme.colorScheme.primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ACARE Engine Status',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Recovery Score Model: ${ref.watch(useMlModelProvider) ? "XGBoost ML (TFLite)" : "Rule-Based Baseline"}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'Use ML Model',
                                  style: theme.textTheme.labelMedium,
                                ),
                                const SizedBox(width: 8),
                                Switch(
                                  value: ref.watch(useMlModelProvider),
                                  onChanged: (val) {
                                    ref.read(useMlModelProvider.notifier).state = val;
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // WORKOUT PLAN STATE SECTION
                if (isGenerating) ...[
                  // Skeleton Loading State
                  AppCard(
                    child: Column(
                      children: [
                        const CircularProgressIndicator.adaptive(),
                        const SizedBox(height: 16),
                        Text(
                          'ACARE is assembling your injury-aware workout plan...',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ] else if (plan != null) ...[
                  // Active Plan Summary Card
                  Text('Today\'s Active Workout Plan', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              plan.sessions.first.dayLabel,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Chip(
                              label: Text('${plan.sessions.first.exerciseEntries.length} Exercises'),
                              backgroundColor: theme.colorScheme.primaryContainer,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          text: 'View Full Workout Plan',
                          icon: Icons.calendar_today_rounded,
                          onPressed: () => context.push('/workout-plan'),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Empty State CTA Card
                  Text('Your Workout Plan', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No Active Plan Generated',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap below to let ACARE construct your personalized, injury-safe training protocol.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          text: 'Generate My First Plan',
                          icon: Icons.auto_awesome_rounded,
                          onPressed: () async {
                            final success = await ref
                                .read(workoutPlanViewModelProvider.notifier)
                                .generatePlan();
                            if (success && context.mounted) {
                              context.push('/workout-plan');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                AppButton(
                  text: 'Sign Out',
                  variant: AppButtonVariant.outlined,
                  icon: Icons.logout_rounded,
                  onPressed: () {
                    ref.read(authViewModelProvider.notifier).signOut();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
