import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/models/injury_detail.dart';
import '../../domain/models/onboarding_enums.dart';
import '../onboarding_providers.dart';

class StepHealthDisclosure extends ConsumerStatefulWidget {
  const StepHealthDisclosure({super.key});

  @override
  ConsumerState<StepHealthDisclosure> createState() => _StepHealthDisclosureState();
}

class _StepHealthDisclosureState extends ConsumerState<StepHealthDisclosure> {
  late TextEditingController _medicalController;

  @override
  void initState() {
    super.initState();
    _medicalController = TextEditingController(
      text: ref.read(onboardingFormStateProvider).medicalConditions,
    );
  }

  @override
  void dispose() {
    _medicalController.dispose();
    super.dispose();
  }

  void _showAddInjuryDialog() {
    BodyPart selectedBodyPart = BodyPart.knee;
    InjurySeverity selectedSeverity = InjurySeverity.medium;
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            return AlertDialog(
              title: const Text('Add Injury / Limitation'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.bodyPartLabel, style: theme.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<BodyPart>(
                      value: selectedBodyPart,
                      items: BodyPart.values
                          .map((b) => DropdownMenuItem(value: b, child: Text(b.label)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedBodyPart = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(AppStrings.severityLabel, style: theme.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<InjurySeverity>(
                      value: selectedSeverity,
                      items: InjurySeverity.values
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text('${s.label} (${s.description})'),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedSeverity = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(AppStrings.injuryNotesLabel, style: theme.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'e.g., Pain during deep squats or overhead presses',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    ref.read(onboardingFormStateProvider.notifier).addInjuryDetail(
                          InjuryDetail(
                            bodyPart: selectedBodyPart,
                            severity: selectedSeverity,
                            notes: notesController.text,
                          ),
                        );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save Injury'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(onboardingFormStateProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.onboardingStep4Title,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.onboardingStep4Subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // Transparent Safety Microcopy Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.healthSafetyNoticeTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.healthSafetyNoticeBody,
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Has Injuries Switch
          AppCard(
            child: SwitchListTile(
              title: Text(
                AppStrings.hasInjuriesQuestion,
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(
                state.hasInjuries
                    ? 'Structured details will be sent to ACARE filtering'
                    : 'No active injuries or joint pain',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              value: state.hasInjuries,
              activeColor: theme.colorScheme.primary,
              onChanged: (val) {
                ref
                    .read(onboardingFormStateProvider.notifier)
                    .updateHealthDisclosure(hasInjuries: val);
              },
            ),
          ),

          if (state.hasInjuries) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Structured Injury List (${state.injuryDetails.length})',
                  style: theme.textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: _showAddInjuryDialog,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(AppStrings.addInjuryButton),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (state.injuryDetails.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'No injuries added yet. Click "+ Add Injury" to specify affected body parts.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

            ...state.injuryDetails.asMap().entries.map((entry) {
              final idx = entry.key;
              final injury = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: AppCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.healing_rounded,
                          color: theme.colorScheme.error,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${injury.bodyPart.label} • Severity: ${injury.severity.label}',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (injury.notes.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                injury.notes,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded),
                        color: theme.colorScheme.error,
                        onPressed: () {
                          ref
                              .read(onboardingFormStateProvider.notifier)
                              .removeInjuryDetail(idx);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],

          const SizedBox(height: 24),

          // Medical Conditions Free Text
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.medicalConditionsLabel, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                TextField(
                  controller: _medicalController,
                  maxLines: 3,
                  onChanged: (val) {
                    ref
                        .read(onboardingFormStateProvider.notifier)
                        .updateHealthDisclosure(medicalConditions: val);
                  },
                  decoration: const InputDecoration(
                    hintText: 'e.g., Asthma, hypertension, or recent surgical history...',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
