import 'auth_state.dart';

abstract class AuthRepository {
  /// Stream of authentication state changes
  Stream<AuthState> get authStateChanges;

  /// Get current auth state snapshot
  AuthState get currentAuthState;

  /// Sign in with email and password
  Future<AuthState> signInWithEmail({
    required String email,
    required String password,
  });

  /// Register new user with email, password, and optional display name
  Future<AuthState> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  /// Sign in via Google OAuth
  Future<AuthState> signInWithGoogle();

  /// Sign out current user
  Future<void> signOut();
}
