import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;
  final GoogleSignIn _google = GoogleSignIn.instance;
  bool _initialized = false;

  Stream<User?> get session => _auth.authStateChanges();

  Future<void> _initializeGoogle() async {
    if (_initialized) return;
    await _google.initialize();
    _initialized = true;
  }

  Future<void> signIn() async {
    await _initializeGoogle();
    final account = await _google.authenticate();
    final token = account.authentication.idToken;
    if (token == null) throw StateError('Missing Google ID token');
    await _auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: token),
    );
  }

  Future<void> signOut() async {
    try {
      await _initializeGoogle();
      await _google.signOut();
    } finally {
      await _auth.signOut();
    }
  }
}
