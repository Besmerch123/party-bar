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
import 'package:party_bar/models/models.dart';
import 'package:party_bar/providers/auth_provider.dart';
import 'package:party_bar/providers/bar_provider.dart';
import 'package:party_bar/providers/locale_provider.dart';
import 'package:party_bar/providers/measure_unit_provider.dart';
import 'package:party_bar/screens/settings/account_data_screen.dart';
import 'package:party_bar/screens/settings/language_screen.dart';
import 'package:party_bar/screens/settings/measures_screen.dart';
import 'package:party_bar/screens/settings/notifications_screen.dart';
import 'package:party_bar/screens/settings/profile_screen.dart';
import 'package:party_bar/screens/settings/settings_screen.dart';
import 'package:party_bar/services/account_service.dart';
import 'package:party_bar/services/auth_service.dart';
import 'package:party_bar/services/party_service.dart';
import 'package:party_bar/theme/theme.dart';
import 'package:party_bar/utils/app_router.dart';
import 'package:party_bar/widgets/settings/delete_account_sheet.dart';

import 'support/harness.dart';

/// Flow 09's screens at a narrow phone and at a bumped text scale — the same
/// convention `my_bar_test.dart` and `party_recap_layout_test.dart` use.
/// Nothing here talks to Firestore: `AccountService`/`PartyService` are
/// always the fakes below, injected through the seam described in
/// `settings_flow_test.dart`'s file doc.

const _sizes = testSizes;
const _textScales = standardTextScales;

const _delegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

class _FakeMetadata extends fb.UserMetadata {
  _FakeMetadata(DateTime creationTime)
    : super(creationTime.millisecondsSinceEpoch, null);
}

class _FakeUser implements fb.User {
  @override
  final String uid = 'user-1';
  @override
  final String? displayName = 'Kateryna Oleksandrivna';
  @override
  final String? email = 'kateryna.oleksandrivna@example.com';
  @override
  final String? photoURL = null;
  @override
  final fb.UserMetadata metadata = _FakeMetadata(DateTime.utc(2026, 1, 1, 12));

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} is not faked');
}

class _FakeAuthService extends AuthService {
  _FakeAuthService(this._current);

  final fb.User? _current;
  final _controller = StreamController<fb.User?>.broadcast();

  @override
  fb.User? get currentUser => _current;

  @override
  Stream<fb.User?> get authStateChanges => _controller.stream;

  void dispose() => _controller.close();
}

class _FakeAccountService extends AccountService {
  @override
  Stream<User?> watchProfile(String uid) => Stream.value(
    User(
      id: uid,
      name: 'Kateryna Oleksandrivna',
      allergens: const ['Peanuts', 'Shellfish', 'Tree nuts'],
      createdAt: DateTime(2026, 1, 1),
      lastLoginAt: DateTime(2026, 1, 1),
    ),
  );

  @override
  Future<User?> getProfile(String uid) async => User(
    id: uid,
    name: 'Marta',
    createdAt: DateTime(2026, 1, 1),
    lastLoginAt: DateTime(2026, 1, 1),
  );
}

class _FakePartyService extends PartyService {
  List<Party> hosted = const [];

  @override
  Stream<List<Party>> getHostedParties() => Stream.value(hosted);
}

Party _party(String id, {required PartyStatus status}) => Party(
  id: id,
  name: "Kate's Fortieth Birthday Party",
  hostId: 'user-1',
  hostName: 'Marta',
  availableCocktailIds: const [],
  joinCode: 'ABC123',
  status: status,
  createdAt: DateTime(2026, 9, 1),
);

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpPlain(
    WidgetTester tester,
    Widget home, {
    required Size size,
    required double textScale,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<LocaleProvider>(
            create: (_) => LocaleProvider(),
          ),
          ChangeNotifierProvider<MeasureUnitProvider>(
            create: (_) => MeasureUnitProvider(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: _delegates,
          supportedLocales: const [Locale('en'), Locale('uk')],
          builder: (context, widget) => MediaQuery.withClampedTextScaling(
            minScaleFactor: textScale,
            maxScaleFactor: textScale,
            child: widget!,
          ),
          home: home,
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> pumpRouted(
    WidgetTester tester,
    Widget home, {
    required AuthenticationProvider auth,
    required Size size,
    required double textScale,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final bar = BarProvider();
    await bar.initialize();

    final router = GoRouter(
      initialLocation: '/subject',
      routes: [
        GoRoute(path: '/subject', builder: (context, state) => home),
        GoRoute(
          path: AppRoutes.settings,
          builder: (context, state) =>
              const Scaffold(body: Text('settings-index')),
        ),
        GoRoute(
          path: AppRoutes.settingsLanguage,
          builder: (context, state) =>
              const Scaffold(body: Text('language-screen')),
        ),
        GoRoute(
          path: '${AppRoutes.activePartyHost}/:id',
          builder: (context, state) =>
              Scaffold(body: Text('host-${state.pathParameters['id']}')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthenticationProvider>.value(value: auth),
          ChangeNotifierProvider<BarProvider>.value(value: bar),
          ChangeNotifierProvider<LocaleProvider>(
            create: (_) => LocaleProvider(),
          ),
          ChangeNotifierProvider<MeasureUnitProvider>(
            create: (_) => MeasureUnitProvider(),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.dark,
          localizationsDelegates: _delegates,
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

  Future<AuthenticationProvider> buildAuth(_FakeAuthService authService) async {
    final auth = AuthenticationProvider(
      authService: authService,
      accountService: _FakeAccountService(),
    );
    await auth.initialize();
    return auth;
  }

  group('screens that work with no account: language', () {
    for (final MapEntry(key: device, value: size) in _sizes.entries) {
      for (final scale in _textScales) {
        testWidgets('language screen on a $device at ${scale}x text', (
          tester,
        ) async {
          await pumpPlain(
            tester,
            const LanguageScreen(),
            size: size,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
        });

        testWidgets('measures screen on a $device at ${scale}x text', (
          tester,
        ) async {
          await pumpPlain(
            tester,
            const MeasuresScreen(),
            size: size,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group(
    'screens that need an account, with a long name, email and allergen list',
    () {
      for (final MapEntry(key: device, value: size) in _sizes.entries) {
        for (final scale in _textScales) {
          testWidgets('notifications screen on a $device at ${scale}x text', (
            tester,
          ) async {
            final authService = _FakeAuthService(_FakeUser());
            final auth = await buildAuth(authService);
            addTearDown(authService.dispose);

            await pumpRouted(
              tester,
              NotificationsScreen(accountService: _FakeAccountService()),
              auth: auth,
              size: size,
              textScale: scale,
            );
            expect(tester.takeException(), isNull);
          });

          testWidgets(
            'settings index, signed out, on a $device at ${scale}x text',
            (tester) async {
              final authService = _FakeAuthService(null);
              final auth = await buildAuth(authService);
              addTearDown(authService.dispose);
              await auth.setGuestName('Oleksandra Marchenko');

              await pumpRouted(
                tester,
                SettingsScreen(
                  accountService: _FakeAccountService(),
                  partyService: _FakePartyService(),
                ),
                auth: auth,
                size: size,
                textScale: scale,
              );
              expect(tester.takeException(), isNull);
            },
          );

          testWidgets(
            'profile screen, with three allergens, on a $device at ${scale}x text',
            (tester) async {
              final authService = _FakeAuthService(_FakeUser());
              final auth = await buildAuth(authService);
              addTearDown(authService.dispose);
              final parties = _FakePartyService()
                ..hosted = [_party('ended-1', status: PartyStatus.ended)];

              await pumpRouted(
                tester,
                ProfileScreen(
                  accountService: _FakeAccountService(),
                  partyService: parties,
                ),
                auth: auth,
                size: size,
                textScale: scale,
              );
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    },
  );

  group('account & data and the signed-in settings index', () {
    for (final MapEntry(key: device, value: size) in _sizes.entries) {
      for (final scale in _textScales) {
        testWidgets(
          'account & data screen, with a live party, on a $device at ${scale}x text',
          (tester) async {
            final authService = _FakeAuthService(_FakeUser());
            final auth = await buildAuth(authService);
            addTearDown(authService.dispose);
            final parties = _FakePartyService()
              ..hosted = [_party('live-1', status: PartyStatus.active)];

            await pumpRouted(
              tester,
              AccountDataScreen(partyService: parties),
              auth: auth,
              size: size,
              textScale: scale,
            );
            expect(tester.takeException(), isNull);
          },
        );

        testWidgets(
          'the sign-out-blocked dialog on a $device at ${scale}x text',
          (tester) async {
            final authService = _FakeAuthService(_FakeUser());
            final auth = await buildAuth(authService);
            addTearDown(authService.dispose);
            final parties = _FakePartyService()
              ..hosted = [_party('live-1', status: PartyStatus.active)];

            await pumpRouted(
              tester,
              AccountDataScreen(partyService: parties),
              auth: auth,
              size: size,
              textScale: scale,
            );
            final l10n = await AppLocalizations.delegate.load(
              const Locale('en'),
            );
            // Small phone + bumped text scale pushes the Logout row below
            // the list's default build extent — scroll it into view first.
            await tester.scrollUntilVisible(find.text(l10n.logout), 200);
            await tester.tap(find.text(l10n.logout));
            await tester.pumpAndSettle();

            expect(tester.takeException(), isNull);
          },
        );

        testWidgets(
          'settings index, signed in, on a $device at ${scale}x text',
          (tester) async {
            final authService = _FakeAuthService(_FakeUser());
            final auth = await buildAuth(authService);
            addTearDown(authService.dispose);

            await pumpRouted(
              tester,
              SettingsScreen(
                accountService: _FakeAccountService(),
                partyService: _FakePartyService()
                  ..hosted = [_party('ended-1', status: PartyStatus.ended)],
              ),
              auth: auth,
              size: size,
              textScale: scale,
            );
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  });

  group('the delete-account sheet, manifest and all', () {
    for (final MapEntry(key: device, value: size) in _sizes.entries) {
      for (final scale in _textScales) {
        testWidgets('on a $device at ${scale}x text', (tester) async {
          tester.view
            ..physicalSize = size
            ..devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          final bar = BarProvider();
          await bar.initialize();
          final authService = _FakeAuthService(_FakeUser());
          addTearDown(authService.dispose);
          final auth = AuthenticationProvider(
            authService: authService,
            accountService: _FakeAccountService(),
          );
          await auth.initialize();
          final parties = _FakePartyService()
            ..hosted = [_party('ended-1', status: PartyStatus.ended)];

          await tester.pumpWidget(
            MultiProvider(
              providers: [
                ChangeNotifierProvider<AuthenticationProvider>.value(
                  value: auth,
                ),
                ChangeNotifierProvider<BarProvider>.value(value: bar),
              ],
              child: MaterialApp(
                theme: AppTheme.dark,
                localizationsDelegates: _delegates,
                supportedLocales: const [Locale('en'), Locale('uk')],
                builder: (context, widget) => MediaQuery.withClampedTextScaling(
                  minScaleFactor: scale,
                  maxScaleFactor: scale,
                  child: widget!,
                ),
                home: Scaffold(
                  body: Builder(
                    builder: (context) => TextButton(
                      onPressed: () => showDeleteAccountSheet(
                        context,
                        partyService: parties,
                      ),
                      child: const Text('open'),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}
