import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository_impl.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthStateNotifier(this._authRepository) : super(AuthState.initial()) {
    checkAuthState();
  }

  Future<void> checkAuthState() async {
    state = AuthState.initial();
    state = await _authRepository.checkAuthState();
  }

  Future<void> login(String email, String password) async {
    state = await _authRepository.login(email, password);
  }

  Future<void> signup(String email, String password) async {
    state = await _authRepository.signup(email, password);
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = AuthState.unauthenticated();
  }
}

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(repository);
});
