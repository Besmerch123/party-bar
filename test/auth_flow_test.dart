import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:party_bar/generated/l10n/app_localizations.dart';
import 'package:party_bar/models/auth.dart';
import 'package:party_bar/models/onboarding.dart';
import 'package:party_bar/providers/auth_provider.dart';
import 'package:party_bar/providers/bar_provider.dart';
import 'package:party_bar/providers/onboarding_provider.dart';
import 'package:party_bar/services/account_service.dart';
import 'package:party_bar/services/auth_service.dart';
import 'package:party_bar/theme/theme.dart';
import 'package:party_bar/widgets/auth/auth_barrier_sheet.dart';
import 'package:party_bar/widgets/auth/auth_controls.dart';
import 'package:party_bar/widgets/auth/auth_guard.dart';

/// Only the four members flow 03 ever reads. Anything else throwing is the
/// point: a test that quietly leans on the rest of `User` is a test that has
/// stopped describing this flow.
class _FakeUser implements fb.User {
  _FakeUser({this.uid = 'user-1', this.displayName, this.email, this.photoURL});

  @override
  final String uid;

  @override
  final String? displayName;

  @override
  final String? email;

  @override
  final String? photoURL;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} is not faked');
}

/// Never read by anything in the flow — the auth-state event is what the
/// provider actually listens to — but the service signature promises one.
class _FakeUserCredential implements fb.UserCredential {
  _FakeUserCredential(this.user);

  @override
  final fb.User? user;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} is not faked');
}

class _FakeAuthService extends AuthService {
  final _users = StreamController<fb.User?>.broadcast();

  /// What a successful Google sign-in produces.
  _FakeUser? googleUser;

  /// What an unsuccessful one produces instead.
  AuthFailure? googleFailure;

  fb.User? _current;

  @override
  fb.User? get currentUser => _current;

  @override
  Stream<fb.User?> get authStateChanges => _users.stream;

  /// Stands in for Firebase pushing an auth-state event.
  void emit(fb.User? user) {
    _current = user;
    _users.add(user);
  }

  @override
  Future<fb.UserCredential> signInWithGoogle() async {
    final failure = googleFailure;
    if (failure != null) throw failure;

    final user = googleUser ?? _FakeUser(displayName: 'Marta');
    emit(user);
    return _FakeUserCredential(user);
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    final current = _current;
    if (current == null) return;
    _current = _FakeUser(
      uid: current.uid,
      displayName: displayName ?? current.displayName,
      email: current.email,
      photoURL: photoUrl ?? current.photoURL,
    );
  }

  @override
  Future<void> signOut() async => emit(null);

  void dispose() => _users.close();
}

class _RecordingAccountService extends AccountService {
  Set<String>? claimedShelf;
  Set<DrinkVibe>? claimedVibes;
  String? claimedName;
  int claims = 0;

  @override
  Future<void> claimLocalState({
    required String uid,
    String? displayName,
    String? email,
    String? avatarUrl,
    Set<String> shelf = const {},
    Set<DrinkVibe> vibes = const {},
  }) async {
    claims++;
    claimedShelf = shelf;
    claimedVibes = vibes;
    claimedName = displayName;
  }
}

Widget _wrap(Widget child, AuthenticationProvider auth) {
  return ChangeNotifierProvider<AuthenticationProvider>.value(
    value: auth,
    child: MaterialApp(
      theme: AppTheme.dark,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('uk')],
      home: child,
    ),
  );
}

void main() {
  late _FakeAuthService authService;
  late _RecordingAccountService accountService;

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    authService = _FakeAuthService();
    accountService = _RecordingAccountService();
  });

  tearDown(() => authService.dispose());

  AuthenticationProvider build() => AuthenticationProvider(
    authService: authService,
    accountService: accountService,
  );

  group('the barrier is an interruption, not a gate', () {
    testWidgets('a dismissed provider sheet says nothing at all', (
      tester,
    ) async {
      authService.googleFailure = const AuthFailure(AuthFailureKind.cancelled);
      final auth = build();
      await auth.initialize();

      final signedIn = await auth.signInWithGoogle();

      expect(signedIn, isFalse);
      expect(auth.failure?.kind, AuthFailureKind.cancelled);
      expect(
        auth.failure!.isSilent,
        isTrue,
        reason: 'backing out of the Google sheet is a decision, not an error',
      );

      await tester.pumpWidget(
        _wrap(Scaffold(body: AuthFailureNotice(failure: auth.failure)), auth),
      );

      expect(find.byType(Row), findsNothing);
    });

    testWidgets('the guard waits for Firebase before accusing anyone', (
      tester,
    ) async {
      final auth = build();

      await tester.pumpWidget(
        _wrap(const AuthGuard(child: Text('the party')), auth),
      );

      expect(
        find.byType(CircularProgressIndicator),
        findsOneWidget,
        reason: 'a restored session must not flash the barrier on the way in',
      );

      authService.emit(_FakeUser(displayName: 'Marta'));
      await tester.pump();

      expect(find.text('the party'), findsOneWidget);
    });

    testWidgets('the barrier argues for the thing it interrupted', (
      tester,
    ) async {
      final auth = build();
      await auth.initialize();

      await tester.pumpWidget(
        _wrap(
          const Scaffold(
            body: SingleChildScrollView(
              child: AuthBarrierSheet(
                reason: AuthReason.hostParty,
                embedded: true,
              ),
            ),
          ),
          auth,
        ),
      );

      expect(find.text('Parties need an owner'), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          const Scaffold(
            body: SingleChildScrollView(
              child: AuthBarrierSheet(
                reason: AuthReason.editBar,
                embedded: true,
              ),
            ),
          ),
          auth,
        ),
      );

      expect(find.text('Don’t lose this shelf'), findsOneWidget);
    });

    testWidgets('Apple is designed but not offered', (tester) async {
      final auth = build();
      await auth.initialize();

      await tester.pumpWidget(
        _wrap(
          const Scaffold(
            body: SingleChildScrollView(
              child: AuthBarrierSheet(
                reason: AuthReason.hostParty,
                embedded: true,
              ),
            ),
          ),
          auth,
        ),
      );

      expect(find.text('Continue with Google'), findsOneWidget);
      expect(
        find.text('Continue with Apple'),
        findsNothing,
        reason: 'kAppleSignInEnabled is false, so the lane is drawn nowhere',
      );
    });
  });

  group('signing in claims what the device was already holding', () {
    test('the shelf and the vibe move into the account', () async {
      SharedPreferences.setMockInitialValues({
        BarProvider.shelfKey: ['gin', 'lime'],
        OnboardingProvider.vibesKey: [DrinkVibe.values.first.name],
      });

      final auth = build();
      await auth.initialize();

      await auth.signInWithGoogle();
      // The claim is deliberately not awaited by the sign-in, so let it land.
      await Future<void>.delayed(Duration.zero);

      expect(accountService.claims, 1);
      expect(accountService.claimedShelf, {'gin', 'lime'});
      expect(accountService.claimedVibes, {DrinkVibe.values.first});
    });

    test('a failed claim never breaks a sign-in that worked', () async {
      final auth = AuthenticationProvider(
        authService: authService,
        accountService: _ExplodingAccountService(),
      );
      await auth.initialize();

      await expectLater(auth.signInWithGoogle(), completion(isTrue));
      await Future<void>.delayed(Duration.zero);

      expect(auth.isAuthenticated, isTrue);
    });
  });

  group('the name screen', () {
    test('only the nameless lane owes screen 05', () async {
      final auth = build();
      await auth.initialize();

      authService.googleUser = _FakeUser(displayName: '');
      await auth.signInWithGoogle();
      expect(auth.needsDisplayName, isTrue);

      expect(await auth.saveDisplayName('  Marta  '), isTrue);
      expect(auth.displayName, 'Marta');
      expect(auth.needsDisplayName, isFalse);
    });

    test('a provider that hands us a name skips it', () async {
      final auth = build();
      await auth.initialize();

      authService.googleUser = _FakeUser(displayName: 'Marta');
      await auth.signInWithGoogle();

      expect(auth.needsDisplayName, isFalse);
    });
  });

  group('the guest lane never touches auth', () {
    test('a phone remembers whose it is', () async {
      final auth = build();
      await auth.initialize();

      await auth.setGuestName(' Marta ');
      expect(auth.guestName, 'Marta');

      final next = AuthenticationProvider(
        authService: _FakeAuthService(),
        accountService: accountService,
      );
      await next.initialize();
      expect(next.guestName, 'Marta');
    });

    test('an empty name is not a name', () async {
      final auth = build();
      await auth.initialize();

      await auth.setGuestName('   ');
      expect(auth.guestName, isNull);
    });

    test('the claim prompt is offered once, ever', () async {
      final auth = build();
      await auth.initialize();

      expect(auth.canPromptClaim, isTrue);

      await auth.markClaimPromptSeen();
      expect(auth.canPromptClaim, isFalse);

      final next = AuthenticationProvider(
        authService: _FakeAuthService(),
        accountService: accountService,
      );
      await next.initialize();
      expect(
        next.canPromptClaim,
        isFalse,
        reason: 'once ever means it does not come back on the next launch',
      );
    });

    test('there is nothing to claim once there is an account', () async {
      final auth = build();
      await auth.initialize();

      await auth.signInWithGoogle();

      expect(auth.canPromptClaim, isFalse);
    });
  });

  group('the confirmation is shown once', () {
    test('and acknowledged rather than left standing', () async {
      final auth = build();
      await auth.initialize();

      await auth.signInWithGoogle();
      expect(auth.justSignedIn, isTrue);

      auth.acknowledgeSignIn();
      expect(auth.justSignedIn, isFalse);
    });
  });
}

class _ExplodingAccountService extends AccountService {
  @override
  Future<void> claimLocalState({
    required String uid,
    String? displayName,
    String? email,
    String? avatarUrl,
    Set<String> shelf = const {},
    Set<DrinkVibe> vibes = const {},
  }) async => throw StateError('firestore is unreachable');
}
