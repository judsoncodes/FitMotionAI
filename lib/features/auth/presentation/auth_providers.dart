import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository_impl.dart';
import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

class AuthViewModelState {
  final AuthState authState;
  final bool isLoading;
  final String? errorMessage;

  const AuthViewModelState({
    required this.authState,
    this.isLoading = false,
    this.errorMessage,
  });

  factory AuthViewModelState.initial() => AuthViewModelState(
        authState: AuthState.initial(),
      );

  AuthViewModelState copyWith({
    AuthState? authState,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthViewModelState(
      authState: authState ?? this.authState,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthViewModel extends StateNotifier<AuthViewModelState> {
  final AuthRepository _repository;

  AuthViewModel(this._repository)
      : super(AuthViewModelState(authState: _repository.currentAuthState));

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<bool> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final authState = await _repository.signInWithEmail(
        email: email,
        password: password,
      );
      state = state.copyWith(authState: authState, isLoading: false);
      return true;
    } on AuthFailure catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> signUpWithEmail(String email, String password, {String? displayName}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final authState = await _repository.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = state.copyWith(authState: authState, isLoading: false);
      return true;
    } on AuthFailure catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final authState = await _repository.signInWithGoogle();
      state = state.copyWith(authState: authState, isLoading: false);
      return true;
    } on AuthFailure catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Google Sign-In failed: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> signInAsDemoUser() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final demoState = AuthState.authenticated(
      userId: 'demo_user_001',
      email: 'demo.athlete@fitmotion.ai',
    );
    state = state.copyWith(authState: demoState, isLoading: false);
    return true;
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _repository.signOut();
    state = AuthViewModelState(authState: AuthState.unauthenticated());
  }
}

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthViewModelState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthViewModel(repository);
});
