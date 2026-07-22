enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
}

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? email;

  const AuthState({
    required this.status,
    this.userId,
    this.email,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);
  factory AuthState.unauthenticated() => const AuthState(status: AuthStatus.unauthenticated);
  factory AuthState.authenticated({required String userId, String? email}) =>
      AuthState(status: AuthStatus.authenticated, userId: userId, email: email);

  bool get isAuthenticated => status == AuthStatus.authenticated;
}
