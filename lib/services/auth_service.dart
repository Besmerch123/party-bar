import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/auth.dart';

/// Firebase Authentication, in the shape flow 03 needs it.
///
/// There is no password anywhere in this product. Two lanes reach an account:
/// a provider (Google today, Apple when [kAppleSignInEnabled] flips) and a
/// single-use email link. Everything that can go wrong is translated into an
/// [AuthFailure] here, so no screen ever has to read a Firebase error code.
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

  /// Where a sign-in link lands. Firebase requires an https continue URL even
  /// when the link is meant to be handled in the app.
  ///
  /// TODO(flow-03): the link only completes on a device once the app claims
  /// this URL — an intent-filter on Android, associated domains on iOS — and
  /// something forwards the incoming URI to [completeSignInFromLink]. Until
  /// then the mail arrives and opens the web handler, not the app.
  static const _linkContinueUrl =
      'https://party-bar.firebaseapp.com/finish-sign-in';

  static const _androidPackage = 'com.example.party_bar';
  static const _iosBundle = 'com.example.partyBar';

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// True when the signed-in person arrived through a provider that already
  /// told us their name — the email lane is the only one that has to ask.
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

  /// Send the single-use sign-in link. Valid for 15 minutes, one use.
  Future<void> sendSignInLink(String email) async {
    try {
      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: ActionCodeSettings(
          url: _linkContinueUrl,
          handleCodeInApp: true,
          androidPackageName: _androidPackage,
          androidInstallApp: true,
          androidMinimumVersion: '21',
          iOSBundleId: _iosBundle,
        ),
      );
    } on FirebaseAuthException catch (e) {
      throw _translate(e);
    } catch (e) {
      throw _translateUnknown(e);
    }
  }

  bool isSignInLink(String link) => _auth.isSignInWithEmailLink(link);

  /// Finish the email lane from the link that was mailed out.
  ///
  /// The address is not carried in the link — it is the one this device
  /// asked for, remembered by the provider.
  Future<UserCredential> completeSignInFromLink({
    required String email,
    required String link,
  }) async {
    try {
      return await _auth.signInWithEmailLink(email: email, emailLink: link);
    } on FirebaseAuthException catch (e) {
      throw _translate(e);
    } catch (e) {
      throw _translateUnknown(e);
    }
  }

  /// The cross-device fallback: the 6-digit code the same mail carries.
  ///
  /// Firebase Auth has no email one-time code of its own, so this leans on a
  /// callable that verifies the code and mints a custom token.
  ///
  /// TODO(flow-03): `verifyEmailCode` is not deployed in functions/ yet. Until
  /// it is, this surfaces as a plain sign-in failure rather than signing
  /// anyone in.
  Future<UserCredential> signInWithEmailCode({
    required String email,
    required String code,
  }) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'verifyEmailCode',
      );
      final result = await callable.call<Map<String, dynamic>>({
        'email': email,
        'code': code,
      });

      final token = result.data['token'] as String?;
      if (token == null || token.isEmpty) {
        throw const AuthFailure(AuthFailureKind.expiredLink);
      }

      return await _auth.signInWithCustomToken(token);
    } on AuthFailure {
      rethrow;
    } on FirebaseFunctionsException catch (e) {
      // The backend says "wrong or stale code" the same way the link does.
      if (e.code == 'invalid-argument' || e.code == 'deadline-exceeded') {
        throw const AuthFailure(AuthFailureKind.expiredLink);
      }
      throw _translateUnknown(e);
    } on FirebaseAuthException catch (e) {
      throw _translate(e);
    } catch (e) {
      throw _translateUnknown(e);
    }
  }

  /// The name and face other people at a party see. Set once by the email
  /// lane; providers hand us both already.
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

  AuthFailure _translate(FirebaseAuthException e) {
    return switch (e.code) {
      'invalid-action-code' || 'expired-action-code' => AuthFailure(
        AuthFailureKind.expiredLink,
        detail: e.code,
      ),
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
