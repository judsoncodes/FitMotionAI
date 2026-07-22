import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'firebase_options.dart';

void main() async {
  // 1. Ensure Flutter engine bindings are initialized before async tasks
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase SDK before mounting Riverpod ProviderScope or UI
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kIsWeb) {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: false,
        experimentalAutoDetectLongPolling: true,
      );
    }
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  // 3. Mount ProviderScope and MaterialApp only after Firebase setup completes
  runApp(
    const ProviderScope(
      child: FitMotionApp(),
    ),
  );
}

class FitMotionApp extends ConsumerWidget {
  const FitMotionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
