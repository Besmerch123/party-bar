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
/// The flow is short but it spans screens — a provider sheet on one, a name
/// asked on another — so what carries between them lives here rather than in
/// navigation arguments.
class AuthenticationProvider extends ChangeNotifier {
  AuthenticationProvider({
    AuthService? authService,
    AccountService? accountService,
  }) : _authService = authService ?? AuthService(),
       _accountService = accountService ?? AccountService() {
    _subscription = _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  static const _guestNameKey = 'guest_display_name';
  static const _claimPromptKey = 'auth_claim_prompt_seen';

  final AuthService _authService;
  final AccountService _accountService;

  late final StreamSubscription<fb.User?> _subscription;

  fb.User? _user;
  bool _isBusy = false;
  AuthFailure? _failure;
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

  /// The name other people at a party see. Providers usually hand us one;
  /// screen 05 asks for it when they don't.
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
