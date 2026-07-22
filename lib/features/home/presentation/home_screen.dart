import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../onboarding/presentation/onboarding_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final authViewModel = ref.watch(authViewModelProvider);
    final profileAsync = ref.watch(userProfileProvider);

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
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (err, stack) => Center(child: Text('Error loading profile: $err')),
        data: (profile) {
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
                  'UID: ${authViewModel.authState.userId ?? "Unknown"} • Email: ${authViewModel.authState.email ?? "N/A"}',
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
                              'AI Recovery Engine Active',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Goal: ${profile?.primaryGoal.label ?? "General Fitness"} • Level: ${profile?.fitnessLevel.label ?? "Beginner"}',
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

                const SizedBox(height: 20),

                // User Profile Overview Card
                if (profile != null) ...[
                  Text('Personalized Bio Profile', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _profileTile(
                          context,
                          icon: Icons.straighten_rounded,
                          label: 'Metrics',
                          value: '${profile.heightCm.toStringAsFixed(0)} cm • ${profile.weightKg.toStringAsFixed(0)} kg • Age ${profile.age} (${profile.sex})',
                        ),
                        const Divider(height: 20),
                        _profileTile(
                          context,
                          icon: Icons.calendar_month_outlined,
                          label: 'Schedule & Gear',
                          value: '${profile.daysPerWeek} days/wk • ${profile.sessionDurationMinutes} min/session • ${profile.equipmentAccess.length} gear types',
                        ),
                        const Divider(height: 20),
                        _profileTile(
                          context,
                          icon: Icons.shield_outlined,
                          label: 'ACARE Safety Status',
                          value: profile.hasInjuries
                              ? '${profile.injuryDetails.length} Injury Contraindications Active'
                              : 'No Active Injuries / Fully Cleared',
                          valueColor: profile.hasInjuries ? theme.colorScheme.error : theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                Text('Quick Actions', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: AppCard(
                        padding: const EdgeInsets.all(16),
                        onTap: () {},
                        child: Column(
                          children: [
                            Icon(Icons.fitness_center, color: theme.colorScheme.primary, size: 32),
                            const SizedBox(height: 8),
                            Text('Start Workout', style: theme.textTheme.labelLarge),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppCard(
                        padding: const EdgeInsets.all(16),
                        onTap: () {},
                        child: Column(
                          children: [
                            Icon(Icons.healing_rounded, color: theme.colorScheme.secondary, size: 32),
                            const SizedBox(height: 8),
                            Text('Recovery Protocol', style: theme.textTheme.labelLarge),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

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

  Widget _profileTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelMedium),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
