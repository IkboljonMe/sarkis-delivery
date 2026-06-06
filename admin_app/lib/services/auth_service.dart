import 'package:firebase_auth/firebase_auth.dart';

/// Wraps Firebase Email/Password Authentication for the single admin account.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_messageFor(e.code));
    } catch (e) {
      throw Exception('Sign-in failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  String _messageFor(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Неверный email / Invalid email';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Неверный логин или пароль / Wrong credentials';
      case 'too-many-requests':
        return 'Слишком много попыток / Too many attempts';
      default:
        return 'Ошибка входа / Login error';
    }
  }
}
