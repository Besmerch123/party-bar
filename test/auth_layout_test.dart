import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:party_bar/generated/l10n/app_localizations.dart';
import 'package:party_bar/models/auth.dart';
import 'package:party_bar/models/onboarding.dart';
import 'package:party_bar/providers/auth_provider.dart';
import 'package:party_bar/providers/bar_provider.dart';
import 'package:party_bar/screens/auth/auth_barrier_screen.dart';
import 'package:party_bar/screens/auth/auth_screen.dart';
import 'package:party_bar/screens/auth/check_mail_screen.dart';
import 'package:party_bar/screens/auth/email_sign_in_screen.dart';
import 'package:party_bar/screens/auth/guest_name_screen.dart';
import 'package:party_bar/screens/auth/link_expired_screen.dart';
import 'package:party_bar/screens/auth/name_yourself_screen.dart';
import 'package:party_bar/services/account_service.dart';
import 'package:party_bar/services/auth_service.dart';
import 'package:party_bar/theme/theme.dart';
import 'package:party_bar/widgets/auth/auth_barrier_sheet.dart';
import 'package:party_bar/widgets/auth/claim_account_sheet.dart';
import 'package:party_bar/widgets/auth/signed_in_banner.dart';

/// Nine surfaces drawn at 390x844. They have to survive the two things that
/// actually break layouts in the field: a narrower phone, and someone who has
/// turned their text up.
const _sizes = <String, Size>{
  'iPhone 14 Pro': Size(390, 844),
  'small phone': Size(320, 568),
};

const _textScales = <double>[1.0, 1.4];

class _StubUser implements fb.User {
  @override
  String get uid => 'user-1';

  @override
  String? get displayName => 'Marta';

  @override
  String? get email => 'marta.k@gmail.com';

  @override
  String? get photoURL => null;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} is not faked');
}

/// Never reaches Firebase. The layout is the subject here, not the lane.
class _StubAuthService extends AuthService {
  final _users = StreamController<fb.User?>.broadcast();

  @override
  fb.User? get currentUser => null;

  @override
  Stream<fb.User?> get authStateChanges => _users.stream;

  @override
  Future<void> sendSignInLink(String email) async {}

  void dispose() => _users.close();
}

class _StubAccountService extends AccountService {
  @override
  Future<void> claimLocalState({
    required String uid,
    String? displayName,
    String? email,
    String? avatarUrl,
    Set<String> shelf = const {},
    Set<DrinkVibe> vibes = const {},
  }) async {}
}

void main() {
  late _StubAuthService authService;
  late AuthenticationProvider auth;

  setUp(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    authService = _StubAuthService();
    auth = AuthenticationProvider(
      authService: authService,
      accountService: _StubAccountService(),
    );
    await auth.initialize();

    // Screens 04 and 07 exist because a link went out; without one they
    // rightly bounce back to screen 03.
    await auth.sendSignInLink('marta.k@gmail.com');
  });

  tearDown(() => authService.dispose());

  /// Pumps [child] as the one route of a real router, because half of these
  /// screens read `redirect` and `reason` off the route they were opened on.
  Future<void> pump(
    WidgetTester tester,
    Widget child,
    Size size,
    double textScale,
  ) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: '/subject?reason=hostParty&redirect=%2Fparty%2Fcreate',
      routes: [GoRoute(path: '/subject', builder: (context, state) => child)],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthenticationProvider>.value(value: auth),
          ChangeNotifierProvider(create: (_) => BarProvider()),
        ],
        child: MaterialApp.router(
          theme: AppTheme.dark,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('uk')],
          builder: (context, widget) => MediaQuery.withClampedTextScaling(
            minScaleFactor: textScale,
            maxScaleFactor: textScale,
            child: widget!,
          ),
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
  }

  /// The surfaces, in the order the flow walks them. Sheets are given the
  /// scroll view their `show...` function wraps them in.
  final surfaces = <String, Widget>{
    '01 barrier': const AuthBarrierScreen(reason: AuthReason.hostParty),
    '01 barrier, as a sheet': const SingleChildScrollView(
      child: AuthBarrierSheet(reason: AuthReason.editBar),
    ),
    '02 providers': const AuthScreen(),
    '03 email entry': const EmailSignInScreen(),
    '04 check your mail': const CheckMailScreen(),
    '05 name yourself': const NameYourselfScreen(),
    '06 draft restored': const Scaffold(body: DraftRestoredRow()),
    '07 expired link': const LinkExpiredScreen(),
    '08 guest, name only': const GuestNameScreen(
      partyName: "Kate's Birthday",
      hostName: 'Kate',
    ),
    '08 guest, arrived cold': const GuestNameScreen(),
    '09 claim it later': const SingleChildScrollView(
      child: ClaimAccountSheet(
        partyName: "Kate's Birthday",
        drinkImageUrls: [],
        drinkCount: 4,
      ),
    ),
  };

  for (final entry in surfaces.entries) {
    for (final size in _sizes.entries) {
      for (final scale in _textScales) {
        testWidgets('${entry.key} holds at ${size.key}, text x$scale', (
          tester,
        ) async {
          await pump(tester, entry.value, size.value, scale);

          expect(tester.takeException(), isNull);

          // Disposing the tree before the test ends lets the screens that own
          // a ticking countdown cancel it, which is itself worth asserting.
          await tester.pumpWidget(const SizedBox.shrink());
        });
      }
    }
  }

  testWidgets('the confirmation chip is not shown to someone who was already '
      'signed in', (tester) async {
    await pump(
      tester,
      const Scaffold(body: SignedInChip()),
      _sizes.values.first,
      1.0,
    );

    expect(find.textContaining('Signed in as'), findsNothing);

    authService._users.add(_StubUser());
    // The auth-state event arrives as a stream event, so the provider has not
    // notified anyone yet on this frame.
    await tester.pump(Duration.zero);
    await tester.pump();

    expect(find.textContaining('Signed in as'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
