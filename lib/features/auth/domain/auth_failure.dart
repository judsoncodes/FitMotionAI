import '../../../core/constants/app_strings.dart';

class AuthFailure implements Exception {
  final String message;
  final String? code;

  const AuthFailure(this.message, {this.code});

  factory AuthFailure.fromFirebaseCode(String code) {
    switch (code) {
      case 'invalid-email':
        return AuthFailure(AppStrings.errorInvalidEmail, code: code);
      case 'user-not-found':
      case 'user-not-registered':
        return AuthFailure(AppStrings.errorUserNotFound, code: code);
      case 'wrong-password':
      case 'invalid-credential':
        return AuthFailure(AppStrings.errorWrongPassword, code: code);
      case 'email-already-in-use':
        return AuthFailure(AppStrings.errorEmailInUse, code: code);
      case 'weak-password':
        return AuthFailure(AppStrings.errorWeakPassword, code: code);
      case 'network-request-failed':
        return AuthFailure(AppStrings.errorNetworkFailed, code: code);
      case 'popup-closed-by-user':
      case 'canceled':
        return AuthFailure(AppStrings.errorGoogleSignInFailed, code: code);
      default:
        return AuthFailure('${AppStrings.errorGenericAuth} ($code)', code: code);
    }
  }

  @override
  String toString() => message;
}
