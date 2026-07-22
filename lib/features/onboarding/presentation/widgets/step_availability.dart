import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/models/onboarding_enums.dart';
import '../onboarding_providers.dart';

class StepAvailability extends ConsumerWidget {
  const StepAvailability({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(onboardingFormStateProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.onboardingStep3Title,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.onboardingStep3Subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Days Per Week Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppStrings.daysPerWeekLabel, style: theme.textTheme.labelLarge),
                    Text(
                      '${state.daysPerWeek} days/wk',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: state.daysPerWeek.toDouble(),
                  min: 1,
                  max: 7,
                  divisions: 6,
                  label: '${state.daysPerWeek} days',
                  onChanged: (val) {
                    ref
                        .read(onboardingFormStateProvider.notifier)
                        .updateAvailability(daysPerWeek: val.round());
                  },
                ),
                const SizedBox(height: 20),

                // Session Duration Minutes
                Text(AppStrings.sessionDurationLabel, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: state.sessionDurationMinutes,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.timer_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 15, child: Text('15 Minutes (Express Recovery)')),
                    DropdownMenuItem(value: 30, child: Text('30 Minutes (Standard Session)')),
                    DropdownMenuItem(value: 45, child: Text('45 Minutes (Full Session)')),
                    DropdownMenuItem(value: 60, child: Text('60 Minutes (Deep Conditioning)')),
                    DropdownMenuItem(value: 90, child: Text('90 Minutes (Endurance Athlete)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      ref
                          .read(onboardingFormStateProvider.notifier)
                          .updateAvailability(sessionDurationMinutes: val);
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Equipment Access Checkboxes
          Text(AppStrings.equipmentLabel, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          ...EquipmentAccess.values.map((equipment) {
            final isChecked = state.equipmentAccess.contains(equipment);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                onTap: () {
                  ref
                      .read(onboardingFormStateProvider.notifier)
                      .toggleEquipment(equipment);
                },
                child: CheckboxListTile(
                  value: isChecked,
                  title: Text(equipment.label, style: theme.textTheme.bodyLarge),
                  activeColor: theme.colorScheme.primary,
                  onChanged: (_) {
                    ref
                        .read(onboardingFormStateProvider.notifier)
                        .toggleEquipment(equipment);
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
