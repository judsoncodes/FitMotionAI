import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/models/onboarding_enums.dart';
import '../onboarding_providers.dart';

class StepFitnessGoal extends ConsumerWidget {
  const StepFitnessGoal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(onboardingFormStateProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.onboardingStep2Title,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.onboardingStep2Subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Fitness Level Selector
          Text('Current Fitness Level', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          ...FitnessLevel.values.map((level) {
            final isSelected = state.fitnessLevel == level;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                padding: const EdgeInsets.all(16),
                onTap: () {
                  ref
                      .read(onboardingFormStateProvider.notifier)
                      .updateFitnessAndGoal(level: level);
                },
                child: Row(
                  children: [
                    Radio<FitnessLevel>(
                      value: level,
                      groupValue: state.fitnessLevel,
                      onChanged: (val) {
                        if (val != null) {
                          ref
                              .read(onboardingFormStateProvider.notifier)
                              .updateFitnessAndGoal(level: val);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            level.label,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? theme.colorScheme.primary : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            level.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // Primary Goal Selector
          Text('Primary Coaching Goal', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          ...PrimaryGoal.values.map((goal) {
            final isSelected = state.primaryGoal == goal;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                padding: const EdgeInsets.all(16),
                onTap: () {
                  ref
                      .read(onboardingFormStateProvider.notifier)
                      .updateFitnessAndGoal(goal: goal);
                },
                child: Row(
                  children: [
                    Radio<PrimaryGoal>(
                      value: goal,
                      groupValue: state.primaryGoal,
                      onChanged: (val) {
                        if (val != null) {
                          ref
                              .read(onboardingFormStateProvider.notifier)
                              .updateFitnessAndGoal(goal: val);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.label,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? theme.colorScheme.primary : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            goal.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
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
    );
  }
}
