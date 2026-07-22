import 'package:fit_motion_ai/features/auth/domain/auth_failure.dart';
import 'package:fit_motion_ai/features/auth/domain/auth_repository.dart';
import 'package:fit_motion_ai/features/auth/domain/auth_state.dart';
import 'package:fit_motion_ai/features/auth/presentation/auth_providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late AuthViewModel viewModel;

  setUp(() {
    mockRepository = MockAuthRepository();
    when(() => mockRepository.currentAuthState)
        .thenReturn(AuthState.unauthenticated());
    viewModel = AuthViewModel(mockRepository);
  });

  group('AuthViewModel Unit Tests', () {
    test('Initial state is unauthenticated and not loading', () {
      expect(viewModel.state.authState.isAuthenticated, isFalse);
      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.errorMessage, null);
    });

    test('Successful login updates state to authenticated', () async {
      when(() => mockRepository.signInWithEmail(
            email: 'test@fitmotion.ai',
            password: 'Password123!',
          )).thenAnswer((_) async => AuthState.authenticated(
            userId: 'user_123',
            email: 'test@fitmotion.ai',
          ));

      final success = await viewModel.signInWithEmail(
        'test@fitmotion.ai',
        'Password123!',
      );

      expect(success, isTrue);
      expect(viewModel.state.authState.isAuthenticated, isTrue);
      expect(viewModel.state.authState.userId, 'user_123');
      expect(viewModel.state.errorMessage, null);
      expect(viewModel.state.isLoading, isFalse);
    });

    test('Failed login with wrong credentials surfaces human-readable error message', () async {
      when(() => mockRepository.signInWithEmail(
            email: 'test@fitmotion.ai',
            password: 'WrongPassword',
          )).thenThrow(AuthFailure.fromFirebaseCode('wrong-password'));

      final success = await viewModel.signInWithEmail(
        'test@fitmotion.ai',
        'WrongPassword',
      );

      expect(success, isFalse);
      expect(viewModel.state.authState.isAuthenticated, isFalse);
      expect(viewModel.state.errorMessage, contains('Incorrect password'));
      expect(viewModel.state.isLoading, isFalse);
    });

    test('Failed signup with existing email surfaces email conflict error', () async {
      when(() => mockRepository.signUpWithEmail(
            email: 'existing@fitmotion.ai',
            password: 'Password123!',
            displayName: 'Athlete',
          )).thenThrow(AuthFailure.fromFirebaseCode('email-already-in-use'));

      final success = await viewModel.signUpWithEmail(
        'existing@fitmotion.ai',
        'Password123!',
        displayName: 'Athlete',
      );

      expect(success, isFalse);
      expect(viewModel.state.authState.isAuthenticated, isFalse);
      expect(viewModel.state.errorMessage, contains('already exists'));
      expect(viewModel.state.isLoading, isFalse);
    });

    test('Sign out resets state to unauthenticated', () async {
      when(() => mockRepository.signOut()).thenAnswer((_) async {});

      await viewModel.signOut();

      expect(viewModel.state.authState.isAuthenticated, isFalse);
      expect(viewModel.state.errorMessage, null);
    });
  });
}
