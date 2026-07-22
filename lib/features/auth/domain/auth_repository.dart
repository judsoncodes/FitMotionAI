import 'auth_state.dart';

abstract class AuthRepository {
  Future<AuthState> checkAuthState();
  Future<AuthState> login(String email, String password);
  Future<AuthState> signup(String email, String password);
  Future<void> logout();
}
