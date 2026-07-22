import '../domain/auth_repository.dart';
import '../domain/auth_state.dart';

/// Stubbed AuthRepository implementation for Phase 1.
/// Real Firebase Auth integration will occur in Phase 2.
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<AuthState> checkAuthState() async {
    // Simulate brief check delay
    await Future.delayed(const Duration(milliseconds: 800));
    return AuthState.unauthenticated();
  }

  @override
  Future<AuthState> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return AuthState.authenticated(userId: 'stub_user_123', email: email);
  }

  @override
  Future<AuthState> signup(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return AuthState.authenticated(userId: 'stub_user_123', email: email);
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
