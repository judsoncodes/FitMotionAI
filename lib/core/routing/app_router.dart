import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_providers.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/presentation/onboarding_providers.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';

import '../../features/recommendation/presentation/workout_plan_screen.dart';
import '../../features/workout/presentation/post_workout_feedback_screen.dart';
import '../../features/workout/presentation/workout_execution_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authStateAsync = ref.watch(authStateChangesProvider);
  final userProfileAsync = ref.watch(userProfileProvider);

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/workout-plan',
        name: 'workout-plan',
        builder: (context, state) => const WorkoutPlanScreen(),
      ),
      GoRoute(
        path: '/workout-execution',
        name: 'workout-execution',
        builder: (context, state) => const WorkoutExecutionScreen(),
      ),
      GoRoute(
        path: '/post-workout-feedback',
        name: 'post-workout-feedback',
        builder: (context, state) => const PostWorkoutFeedbackScreen(),
      ),
    ],
    redirect: (context, state) {
      final isSplash = state.matchedLocation == '/splash';
      final isLoggingIn =
          state.matchedLocation == '/login' || state.matchedLocation == '/signup';
      final isOnboarding = state.matchedLocation == '/onboarding';

      final authState = authStateAsync.asData?.value ?? ref.watch(authViewModelProvider).authState;

      final isAuthenticated = authState.isAuthenticated;
      if (!isAuthenticated) {
        if (isLoggingIn) return null;
        return '/login';
      }

      // User is authenticated, check profile onboarding status
      final userProfile = userProfileAsync.asData?.value;
      final onboardingComplete = userProfile?.onboardingComplete ?? false;

      if (!onboardingComplete) {
        if (isOnboarding) return null;
        return '/onboarding';
      }

      // User is authenticated and onboarding is complete
      if (isSplash || isLoggingIn || isOnboarding) {
        return '/home';
      }

      return null;
    },
  );
});
