import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../onboarding/domain/models/onboarding_enums.dart';
import '../../recovery/domain/models/recovery_log.dart';
import '../../recovery/presentation/recovery_providers.dart';
import '../domain/models/completion_record.dart';
import 'workout_execution_providers.dart';

class PostWorkoutFeedbackScreen extends ConsumerStatefulWidget {
  const PostWorkoutFeedbackScreen({super.key});

  @override
  ConsumerState<PostWorkoutFeedbackScreen> createState() => _PostWorkoutFeedbackScreenState();
}

class _PostWorkoutFeedbackScreenState extends ConsumerState<PostWorkoutFeedbackScreen> {
  int _difficulty = 3;
  bool _hasPain = false;
  BodyPart _selectedBodyPart = BodyPart.knee;
  InjurySeverity _selectedSeverity = InjurySeverity.medium;
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submitFeedback() async {
    setState(() => _isSubmitting = true);

    final execState = ref.read(workoutExecutionViewModelProvider);
    final session = execState.session;
    final authViewModel = ref.read(authViewModelProvider);
    final userId = authViewModel.authState.userId ?? 'demo_user_001';

    final totalExercises = session?.exerciseEntries.length ?? 1;
    final completedSetsMap = execState.completedSets;
    final exercisesCompletedCount = completedSetsMap.values.where((s) => s.isNotEmpty).length;
    final completionRate = exercisesCompletedCount / totalExercises;

    final record = CompletionRecord(
      id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: session?.id ?? 's1',
      userId: userId,
      completedAt: DateTime.now(),
      overallDifficulty: _difficulty,
      completionRate: completionRate,
      exercisesCompleted: exercisesCompletedCount,
      exercisesTotal: totalExercises,
      hasPain: _hasPain,
      painBodyPart: _hasPain ? _selectedBodyPart : null,
      painSeverity: _hasPain ? _selectedSeverity : null,
      painNotes: _hasPain && _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    final recoveryLog = RecoveryLog(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      timestamp: DateTime.now(),
      overallDifficulty: _difficulty,
      completionRate: completionRate,
      hasPain: _hasPain,
      painBodyPart: _hasPain ? _selectedBodyPart : null,
      painSeverity: _hasPain ? _selectedSeverity : null,
    );

    // Save log to recovery log repository
    await ref.read(recoveryLogRepositoryProvider).saveRecoveryLog(recoveryLog);

    if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_hasPain
              ? 'Feedback submitted. ACARE has updated recovery signals for ${_selectedBodyPart.label}.'
              : 'Workout complete! Recovery signals updated.'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post-Workout Recovery Feedback'),
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
            Text('Session Complete! 🎉', style: theme.textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'How did that workout feel? Your feedback refines ACARE\'s next training recommendations.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // 1. Overall Difficulty Selector Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overall Workout Difficulty', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(5, (index) {
                      final val = index + 1;
                      final isSelected = _difficulty == val;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            label: Text('$val'),
                            selected: isSelected,
                            selectedColor: theme.colorScheme.primaryContainer,
                            onSelected: (selected) {
                              if (selected) setState(() => _difficulty = val);
                            },
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _difficulty == 1
                        ? '1 - Very Light / Recovery'
                        : (_difficulty == 3
                            ? '3 - Moderate / Target Intensity'
                            : (_difficulty == 5 ? '5 - Extreme / Exhausting' : 'Difficulty: $_difficulty')),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. Pain Incident Reporting Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: const Text('Did you experience joint pain or discomfort?'),
                    subtitle: const Text('ACARE will substitute contraindicated exercises next time.'),
                    value: _hasPain,
                    activeColor: theme.colorScheme.error,
                    onChanged: (val) => setState(() => _hasPain = val),
                  ),

                  if (_hasPain) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    Text('Affected Body Part', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: BodyPart.values.map((part) {
                        return ChoiceChip(
                          label: Text(part.label),
                          selected: _selectedBodyPart == part,
                          selectedColor: theme.colorScheme.errorContainer,
                          onSelected: (sel) {
                            if (sel) setState(() => _selectedBodyPart = part);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text('Discomfort Severity', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Row(
                      children: InjurySeverity.values.map((sev) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ChoiceChip(
                              label: Text(sev.label),
                              selected: _selectedSeverity == sev,
                              onSelected: (sel) {
                                if (sel) setState(() => _selectedSeverity = sev);
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Optional details (e.g. pain during pressing)',
                        prefixIcon: Icon(Icons.note_alt_outlined),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            AppButton(
              text: _hasPain ? 'Submit Pain & Adapt Next Plan' : 'Submit Feedback',
              icon: Icons.send_rounded,
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : _submitFeedback,
            ),
          ],
        ),
      ),
    );
  }
}
