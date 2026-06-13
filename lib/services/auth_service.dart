import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';

class AuthService {
  FirebaseAuth? _authInstance;
  bool _useDemoMode = !isFirebaseInitialized;

  // Lazily retrieve Firebase Auth instance only if configured
  FirebaseAuth get _auth {
    if (_authInstance == null && isFirebaseInitialized) {
      _authInstance = FirebaseAuth.instance;
    }
    return _authInstance!;
  }

  void enableDemoMode() {
    _useDemoMode = true;
  }

  bool get isDemoMode => _useDemoMode;

  // Stream of User Auth State
  Stream<User?> get authStateChanges {
    if (_useDemoMode || !isFirebaseInitialized) {
      return Stream.value(null);
    }
    try {
      return _auth.authStateChanges();
    } catch (e) {
      _useDemoMode = true;
      return Stream.value(null);
    }
  }

  // Sign In
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    if (_useDemoMode || !isFirebaseInitialized || email.startsWith('demo')) {
      _useDemoMode = true;
      return null; // Signals successful login in demo mode
    }
    
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      _useDemoMode = true;
      return null;
    }
  }

  // Register
  Future<UserCredential?> createUserWithEmailAndPassword(String email, String password) async {
    if (_useDemoMode || !isFirebaseInitialized) {
      return null;
    }
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      _useDemoMode = true;
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    if (_useDemoMode || !isFirebaseInitialized) {
      _useDemoMode = false;
      return;
    }
    await _auth.signOut();
  }

  // Get current user email
  String get currentUserEmail {
    if (_useDemoMode || !isFirebaseInitialized) {
      return 'admin@acroma.net (Demo Mode)';
    }
    return _auth.currentUser?.email ?? 'Unknown User';
  }

  // Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    if (_useDemoMode || !isFirebaseInitialized) return;
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      _useDemoMode = true;
    }
  }
}
