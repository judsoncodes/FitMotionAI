import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_state.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn? _googleSignIn;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? _initGoogleSignIn();

  static GoogleSignIn? _initGoogleSignIn() {
    try {
      return GoogleSignIn();
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<AuthState> get authStateChanges {
    try {
      return _firebaseAuth.authStateChanges().map((User? user) {
        if (user == null) {
          return AuthState.unauthenticated();
        }
        return AuthState.authenticated(
          userId: user.uid,
          email: user.email,
        );
      });
    } catch (_) {
      return Stream.value(AuthState.unauthenticated());
    }
  }

  @override
  AuthState get currentAuthState {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        return AuthState.authenticated(userId: user.uid, email: user.email);
      }
    } catch (_) {}
    return AuthState.unauthenticated();
  }

  @override
  Future<AuthState> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthFailure('Failed to retrieve user after sign in.');
      }

      return AuthState.authenticated(
        userId: user.uid,
        email: user.email,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromFirebaseCode(e.code);
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<AuthState> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthFailure('Failed to register user.');
      }

      if (displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
      }

      return AuthState.authenticated(
        userId: user.uid,
        email: user.email,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromFirebaseCode(e.code);
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<AuthState> signInWithGoogle() async {
    try {
      final googleInstance = _googleSignIn ?? GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleInstance.signIn();
      if (googleUser == null) {
        throw const AuthFailure('Google sign-in was cancelled by user.', code: 'canceled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw const AuthFailure('Failed to sign in with Google credential.');
      }

      return AuthState.authenticated(
        userId: user.uid,
        email: user.email,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromFirebaseCode(e.code);
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn?.signOut();
      await _firebaseAuth.signOut();
    } catch (_) {}
  }
}
