import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_card.dart';
import '../onboarding_providers.dart';

class StepBasicInfo extends ConsumerStatefulWidget {
  const StepBasicInfo({super.key});

  @override
  ConsumerState<StepBasicInfo> createState() => _StepBasicInfoState();
}

class _StepBasicInfoState extends ConsumerState<StepBasicInfo> {
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingFormStateProvider);
    _ageController = TextEditingController(text: state.age.toString());
    _heightController = TextEditingController(text: state.heightCm.toStringAsFixed(0));
    _weightController = TextEditingController(text: state.weightKg.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _update() {
    final age = int.tryParse(_ageController.text) ?? 25;
    final height = double.tryParse(_heightController.text) ?? 170.0;
    final weight = double.tryParse(_weightController.text) ?? 70.0;

    ref.read(onboardingFormStateProvider.notifier).updateBasicInfo(
          age: age,
          heightCm: height,
          weightKg: weight,
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
            AppStrings.onboardingStep1Title,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.onboardingStep1Subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Age Input
                Text(AppStrings.ageLabel, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _update(),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.cake_outlined),
                    hintText: 'e.g. 28',
                  ),
                ),
                const SizedBox(height: 20),

                // Sex Selection
                Text(AppStrings.sexLabel, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'male', label: Text('Male'), icon: Icon(Icons.male)),
                    ButtonSegment(value: 'female', label: Text('Female'), icon: Icon(Icons.female)),
                    ButtonSegment(value: 'other', label: Text('Other')),
                  ],
                  selected: {state.sex},
                  onSelectionChanged: (val) {
                    ref.read(onboardingFormStateProvider.notifier).updateBasicInfo(sex: val.first);
                  },
                ),
                const SizedBox(height: 20),

                // Height Input (cm)
                Text(AppStrings.heightLabel, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _update(),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.height_rounded),
                    hintText: 'e.g. 175',
                    suffixText: 'cm',
                  ),
                ),
                const SizedBox(height: 20),

                // Weight Input (kg)
                Text(AppStrings.weightLabel, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _update(),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.monitor_weight_outlined),
                    hintText: 'e.g. 72',
                    suffixText: 'kg',
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
