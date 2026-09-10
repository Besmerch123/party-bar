/// What the app was in the middle of when it had to ask for an account.
///
/// Auth is never a front gate in this product — it is an interruption, and
/// only for the three things that genuinely need an owner. The reason travels
/// with the interruption so the barrier can name what is at stake and the
/// button at the end can name the thing you were already doing.
enum AuthReason {
  /// Creating a party. Needs an owner so a link can point at it.
  hostParty,

  /// Saving a cocktail. Needs an owner so the list survives a new phone.
  saveCocktail,

  /// Editing My Bar. Needs an owner so the shelf follows you.
  editBar,

  /// Cold entry — the profile tab, or a guarded route opened directly.
  /// Nothing is waiting behind it.
  cold,
}

/// Sign-in providers the product offers.
///
/// Apple is designed for and deliberately dark: it needs a paid developer
/// account and a native capability this build does not have yet, so
/// [AuthProviderKind.apple] is drawn nowhere while [kAppleSignInEnabled] is
/// false. Flipping that flag is the whole of turning it on in the UI.
enum AuthProviderKind { google, apple, email }

/// Apple sign-in is designed but not wired. See [AuthProviderKind.apple].
const bool kAppleSignInEnabled = false;

/// Why a sign-in attempt did not end with a signed-in person.
///
/// Only four of these are worth writing copy for; the rest collapse into
/// [AuthFailureKind.unknown] rather than leaking a Firebase error code into
/// a sentence someone has to read.
enum AuthFailureKind {
  /// The provider sheet was dismissed. Silent — back to where you were, no
  /// error, no toast.
  cancelled,

  /// A sign-in link that is past its 15 minutes, or has already been used.
  expiredLink,

  /// This address exists, but under a different provider. Never a dead end:
  /// [AuthFailure.email] carries the address so the screen can offer the
  /// provider that does work.
  differentProvider,

  /// No connection. The draft is on the device either way.
  offline,

  /// Anything else.
  unknown,
}

/// A sign-in attempt that did not complete.
class AuthFailure implements Exception {
  const AuthFailure(this.kind, {this.email, this.detail});

  final AuthFailureKind kind;

  /// Set for [AuthFailureKind.differentProvider] — the address already in use.
  final String? email;

  /// Underlying message, for logs. Never shown.
  final String? detail;

  /// A dismissed provider sheet is not a failure anyone should be told about.
  bool get isSilent => kind == AuthFailureKind.cancelled;

  @override
  String toString() =>
      'AuthFailure(${kind.name}${detail == null ? '' : ': $detail'})';
}
