import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/auth.dart';

/// Firebase Authentication, in the shape flow 03 needs it.
///
/// There is no password anywhere in this product. The only lane to an
/// account is a provider — Google today, Apple when [kAppleSignInEnabled]
/// flips. Everything that can go wrong is translated into an [AuthFailure]
/// here, so no screen ever has to read a Firebase error code.
class AuthService {
  AuthService({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
    : _authOverride = auth,
      _googleSignInOverride = googleSignIn;

  final FirebaseAuth? _authOverride;
  final GoogleSignIn? _googleSignInOverride;

  // Resolved on first use rather than in the constructor, so a subclass that
  // overrides every method — a test double — never touches a Firebase
  // instance that was never initialized. Still one instance each: signing out
  // of Google has to reach the object that signed in.
  late final FirebaseAuth _auth = _authOverride ?? FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn =
      _googleSignInOverride ?? GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// True when the signed-in person's provider already told us their name.
  bool get hasDisplayName => (currentUser?.displayName ?? '').trim().isNotEmpty;

  /// Google, the one provider that is live.
  Future<UserCredential> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();

      // A dismissed sheet is a decision, not an error. It travels as a silent
      // failure so the caller can go back to exactly where it was.
      if (googleUser == null) {
        throw const AuthFailure(AuthFailureKind.cancelled);
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on AuthFailure {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw _translate(e);
    } catch (e) {
      throw _translateUnknown(e);
    }
  }

  /// The name and face other people at a party see. Providers hand us both
  /// already; this exists for the rare one that does not.
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      if (displayName != null) await user.updateDisplayName(displayName);
      if (photoUrl != null) await user.updatePhotoURL(photoUrl);
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw _translate(e);
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut().catchError((_) => null),
    ]);
  }

  /// Flow 09 · screen 07's one-way door. The Firestore side of the account
  /// is the caller's problem — this only ever touches the sign-in itself.
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _translate(e);
    }
  }

  AuthFailure _translate(FirebaseAuthException e) {
    return switch (e.code) {
      'account-exists-with-different-credential' ||
      'email-already-in-use' => AuthFailure(
        AuthFailureKind.differentProvider,
        email: e.email,
        detail: e.code,
      ),
      'network-request-failed' => AuthFailure(
        AuthFailureKind.offline,
        detail: e.code,
      ),
      'web-context-canceled' ||
      'canceled' => AuthFailure(AuthFailureKind.cancelled, detail: e.code),
      'requires-recent-login' => AuthFailure(
        AuthFailureKind.requiresRecentLogin,
        detail: e.code,
      ),
      _ => AuthFailure(
        AuthFailureKind.unknown,
        detail: '${e.code}: ${e.message}',
      ),
    };
  }

  AuthFailure _translateUnknown(Object error) {
    if (error is AuthFailure) return error;

    // Platform channels and the Google plugin report a dead network as a
    // socket error rather than a Firebase code, and the type lives in dart:io,
    // which this file stays clear of.
    final text = error.toString().toLowerCase();
    if (text.contains('socketexception') ||
        text.contains('network is unreachable') ||
        text.contains('failed host lookup')) {
      return AuthFailure(AuthFailureKind.offline, detail: error.toString());
    }
    return AuthFailure(AuthFailureKind.unknown, detail: error.toString());
  }
}
