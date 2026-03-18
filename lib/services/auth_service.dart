import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/errors/app_exceptions.dart';
import '../core/extensions/string_extensions.dart';

/// Handles all Firebase Authentication operations for Platform.
/// Supports Google Sign-In and Email/Password auth.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ── Stream ────────────────────────────────────────────────────────────────

  /// Stream of auth state changes — emits User or null
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Currently signed-in Firebase user
  User? get currentUser => _auth.currentUser;

  /// Current user ID — throws if not signed in
  String get currentUserId {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException('Not authenticated.');
    return user.uid;
  }

  // ── Google Sign-In ────────────────────────────────────────────────────────

  /// Signs in with Google. Returns the Firebase User on success.
  Future<User> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw const AuthException('Sign in cancelled.');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      if (result.user == null) throw const AuthException('Sign in failed.');
      return result.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromCode(e.code);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw const AuthException('Google sign in failed. Please try again.');
    }
  }

  // ── Email / Password ──────────────────────────────────────────────────────

  /// Signs in with email and password.
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (result.user == null) throw const AuthException('Sign in failed.');
      return result.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromCode(e.code);
    }
  }

  /// Creates a new account with email and password.
  Future<User> createAccountWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (result.user == null) throw const AuthException('Account creation failed.');

      // Set a display name derived from email
      await result.user!.updateDisplayName(email.trim().toDisplayName);

      return result.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromCode(e.code);
    }
  }

  /// Sends a password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromCode(e.code);
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  /// Signs out from Firebase and Google.
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw const AuthException('Sign out failed. Please try again.');
    }
  }

  // ── Account Deletion ──────────────────────────────────────────────────────

  /// Deletes the current Firebase Auth account.
  /// Firestore cleanup is handled separately in FirestoreService.
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw const AuthException('Not authenticated.');
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw const AuthException(
          'Please sign out and sign in again before deleting your account.',
        );
      }
      throw AuthException.fromCode(e.code);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns true if the current user signed in with Google.
  bool get isGoogleUser {
    final user = _auth.currentUser;
    if (user == null) return false;
    return user.providerData.any((p) => p.providerId == 'google.com');
  }

  /// Returns the display name for the current user.
  /// Falls back to email-derived name if no display name is set.
  String get currentUserDisplayName {
    final user = _auth.currentUser;
    if (user == null) return '';
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    return (user.email ?? '').toDisplayName;
  }
}
