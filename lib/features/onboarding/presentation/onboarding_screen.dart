import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/app_button.dart';
import 'onboarding_providers.dart';
import 'widgets/step_availability.dart';
import 'widgets/step_basic_info.dart';
import 'widgets/step_fitness_goal.dart';
import 'widgets/step_health_disclosure.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final List<Widget> _steps = const [
    StepBasicInfo(),
    StepFitnessGoal(),
    StepAvailability(),
    StepHealthDisclosure(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() async {
    if (_currentStep < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Submit Profile
      final success =
          await ref.read(onboardingFormStateProvider.notifier).submitProfile();
      if (success && mounted) {
        context.go('/home');
      } else if (mounted) {
        final err = ref.read(onboardingFormStateProvider).errorMessage;
        if (err != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  void _previousPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final formState = ref.watch(onboardingFormStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${AppStrings.onboardingHeaderTitle} (${_currentStep + 1}/4)'),
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
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator Bar
            LinearProgressIndicator(
              value: (_currentStep + 1) / _steps.length,
              backgroundColor: theme.colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),

            // PageView Container
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentStep = index);
                },
                children: _steps
                    .map((step) => Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: step,
                        ))
                    .toList(),
              ),
            ),

            // Footer Navigation Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(color: theme.colorScheme.surfaceVariant),
                ),
              ),
              child: Row(
                children: [
                  if (_currentStep > 0) ...[
                    Expanded(
                      flex: 1,
                      child: AppButton(
                        text: AppStrings.backStep,
                        variant: AppButtonVariant.outlined,
                        onPressed: formState.isSubmitting ? null : _previousPage,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      text: _currentStep == _steps.length - 1
                          ? AppStrings.completeOnboarding
                          : AppStrings.nextStep,
                      icon: _currentStep == _steps.length - 1
                          ? Icons.check_circle_outline
                          : Icons.arrow_forward_rounded,
                      isLoading: formState.isSubmitting,
                      onPressed: formState.isSubmitting ? null : _nextPage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
