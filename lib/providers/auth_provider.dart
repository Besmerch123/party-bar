import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth.dart';
import '../models/onboarding.dart';
import '../services/account_service.dart';
import '../services/auth_service.dart';
import 'bar_provider.dart';
import 'onboarding_provider.dart';

/// State for the whole of flow 03.
///
/// The flow is short but it spans screens — an address typed on one, a link
/// opened on another, a name asked on a third — so what carries between them
/// lives here rather than in navigation arguments a cold link would not have.
class AuthenticationProvider extends ChangeNotifier {
  AuthenticationProvider({
    AuthService? authService,
    AccountService? accountService,
  }) : _authService = authService ?? AuthService(),
       _accountService = accountService ?? AccountService() {
    _subscription = _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  /// A sign-in link is good for 15 minutes, once.
  static const linkLifetime = Duration(minutes: 15);

  /// How long the resend button stays asleep. Long enough that a slow mail
  /// server is not mistaken for a failure.
  static const resendCooldown = Duration(seconds: 45);

  static const _guestNameKey = 'guest_display_name';
  static const _claimPromptKey = 'auth_claim_prompt_seen';

  final AuthService _authService;
  final AccountService _accountService;

  late final StreamSubscription<fb.User?> _subscription;

  fb.User? _user;
  bool _isBusy = false;
  AuthFailure? _failure;
  String? _pendingEmail;
  DateTime? _linkSentAt;
  String? _guestName;
  bool _claimPromptSeen = false;
  bool _justSignedIn = false;
  bool _initialized = false;
  bool _resolved = false;

  fb.User? get user => _user;

  bool get isAuthenticated => _user != null;

  /// False until Firebase has said who, if anyone, is signed in on this
  /// device. Guards wait on it rather than flashing a barrier at someone who
  /// turns out to have been signed in all along.
  bool get isResolved => _resolved;

  /// Work is in flight. Every entry point sets it, so one spinner rule covers
  /// the flow.
  bool get isBusy => _isBusy;

  AuthFailure? get failure => _failure;

  /// The address a link was sent to, and the one [signInWithEmailCode]
  /// verifies against. Survives moving between screens 03, 04 and 07.
  String? get pendingEmail => _pendingEmail;

  DateTime? get linkSentAt => _linkSentAt;

  /// When the resend button wakes up, or null if nothing has been sent.
  DateTime? get resendAvailableAt => _linkSentAt?.add(resendCooldown);

  /// The name other people at a party see. Providers hand us one; the email
  /// lane has to ask for it on screen 05.
  String get displayName => (_user?.displayName ?? '').trim();

  /// Screen 05 exists only for people who arrived without a name.
  bool get needsDisplayName => isAuthenticated && displayName.isEmpty;

  /// Set for the one screen after a sign-in, so the destination can say
  /// "signed in as ..." without every screen tracking it.
  bool get justSignedIn => _justSignedIn;

  /// Ordering as a guest needs a name and nothing else. It lives on the phone
  /// so a guest is asked once, not once per round.
  String? get guestName => _guestName;

  /// Screen 09 asks once per person, ever. It is a polite offer, not a funnel.
  bool get claimPromptSeen => _claimPromptSeen;

  /// True while the guest lane should still be offered the chance to keep
  /// what a party produced.
  bool get canPromptClaim => !isAuthenticated && !_claimPromptSeen;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    _user = _authService.currentUser;
    _resolved = true;

    final prefs = await SharedPreferences.getInstance();
    _guestName = prefs.getString(_guestNameKey);
    _claimPromptSeen = prefs.getBool(_claimPromptKey) ?? false;

    notifyListeners();
  }

  void _onAuthStateChanged(fb.User? user) {
    final wasSignedOut = _user == null;
    _user = user;
    _resolved = true;

    if (user != null && wasSignedOut) {
      _justSignedIn = true;
      // Claiming is deliberately not awaited: the person is signed in already
      // and the screen behind them should come back now, not after a write.
      unawaited(_claimLocalState(user));
    }

    notifyListeners();
  }

  // --------------------------------------------------------------- providers

  /// Google. Returns true when someone is signed in at the end of it.
  Future<bool> signInWithGoogle() =>
      _attempt(() => _authService.signInWithGoogle());

  // -------------------------------------------------------------- email lane

  /// Screen 03 to 04. Remembers the address, because the link that comes back
  /// does not carry it.
  Future<bool> sendSignInLink(String email) {
    final address = email.trim();

    return _attempt(() async {
      await _authService.sendSignInLink(address);
      _pendingEmail = address;
      _linkSentAt = DateTime.now();
    });
  }

  /// Screens 04 and 07. Same address, fresh link.
  Future<bool> resendSignInLink() {
    final address = _pendingEmail;
    if (address == null) return Future.value(false);
    return sendSignInLink(address);
  }

  /// Screen 03 reached from "wrong address" or "use a different address".
  void forgetPendingEmail() {
    _pendingEmail = null;
    _linkSentAt = null;
    _failure = null;
    notifyListeners();
  }

  /// Completing the email lane from the link itself.
  ///
  /// TODO(flow-03): nothing calls this yet — the incoming URI has to be handed
  /// to it by a deep-link listener the app does not register.
  Future<bool> completeSignInFromLink(String link) {
    final address = _pendingEmail;
    if (address == null || !_authService.isSignInLink(link)) {
      _fail(const AuthFailure(AuthFailureKind.expiredLink));
      return Future.value(false);
    }

    return _attempt(
      () => _authService.completeSignInFromLink(email: address, link: link),
    );
  }

  /// The cross-device fallback on screen 04.
  Future<bool> signInWithEmailCode(String code) {
    final address = _pendingEmail;
    if (address == null) return Future.value(false);

    return _attempt(
      () => _authService.signInWithEmailCode(email: address, code: code),
    );
  }

  // ----------------------------------------------------------------- profile

  /// Screen 05. The name is the whole of the profile at this point.
  Future<bool> saveDisplayName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;

    final saved = await _attempt(
      () => _authService.updateProfile(displayName: trimmed),
    );

    if (saved) {
      // updateDisplayName does not push a new auth-state event, so the
      // reloaded user has to be picked up by hand.
      final refreshed = _authService.currentUser;
      if (refreshed != null) {
        _user = refreshed;
        unawaited(_claimLocalState(refreshed));
      }
      notifyListeners();
    }

    return saved;
  }

  // -------------------------------------------------------------- guest lane

  /// Screen 08. No account is created, nothing leaves the phone.
  Future<void> setGuestName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    _guestName = trimmed;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_guestNameKey, trimmed);
  }

  /// Screen 09, shown or dismissed. Either way it does not come back.
  Future<void> markClaimPromptSeen() async {
    if (_claimPromptSeen) return;

    _claimPromptSeen = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_claimPromptKey, true);
  }

  // --------------------------------------------------------------------- out

  Future<void> signOut() async {
    await _authService.signOut();
    _pendingEmail = null;
    _linkSentAt = null;
    _justSignedIn = false;
    notifyListeners();
  }

  /// Consumed by the screen that shows the "signed in as ..." confirmation, so
  /// the chip appears once rather than on every rebuild for the rest of the
  /// session.
  void acknowledgeSignIn() {
    if (!_justSignedIn) return;
    _justSignedIn = false;
    notifyListeners();
  }

  void clearFailure() {
    if (_failure == null) return;
    _failure = null;
    notifyListeners();
  }

  // ----------------------------------------------------------------- private

  /// One shape for every attempt: busy on, failure cleared, run, translate.
  Future<bool> _attempt(Future<void> Function() action) async {
    _isBusy = true;
    _failure = null;
    notifyListeners();

    try {
      await action();
      return true;
    } on AuthFailure catch (e) {
      _failure = e;
      return false;
    } catch (e) {
      _failure = AuthFailure(AuthFailureKind.unknown, detail: e.toString());
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  void _fail(AuthFailure failure) {
    _failure = failure;
    notifyListeners();
  }

  /// Everything flow 01 collected on this device, folded into the account.
  ///
  /// Read straight from the preference keys [BarProvider] and
  /// [OnboardingProvider] write, rather than holding references to them: this
  /// runs once, off an auth event, and has no business rebuilding when a
  /// bottle is ticked.
  Future<void> _claimLocalState(fb.User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final shelf = (prefs.getStringList(BarProvider.shelfKey) ?? const [])
          .toSet();
      final vibes =
          (prefs.getStringList(OnboardingProvider.vibesKey) ?? const [])
              .map(
                (name) => DrinkVibe.values
                    .where((vibe) => vibe.name == name)
                    .firstOrNull,
              )
              .whereType<DrinkVibe>()
              .toSet();

      await _accountService.claimLocalState(
        uid: user.uid,
        displayName: user.displayName,
        email: user.email,
        avatarUrl: user.photoURL,
        shelf: shelf,
        vibes: vibes,
      );
    } catch (e) {
      // A failed claim must never break a sign-in that already succeeded. The
      // shelf is still on the phone, and the next sign-in tries again.
      debugPrint('Could not claim local state: $e');
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
