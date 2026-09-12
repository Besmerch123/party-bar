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
import 'package:party_bar/widgets/settings/measure_preview.dart';
import 'package:party_bar/widgets/settings/settings_rows.dart';
import 'package:party_bar/widgets/settings/text_prompt.dart';

/// Flow 09 — Settings & Profile. `settings_screen.dart`, `profile_screen.dart`
/// and `account_data_screen.dart` all built a `PartyService`/`AccountService`
/// inline with no way to hand them a fake, so three screens plus
/// `showDeleteAccountSheet` picked up a small optional constructor
/// parameter for exactly that (default null, current behaviour untouched —
/// see the class docs on each). `PartyService`'s own two fields moved from
/// eager to `late final`, matching the seam `AuthService`/`AccountService`
/// already use, so a fake that overrides its methods never has to touch
/// real Firestore just to be constructed.
///
/// Nothing here talks to Firestore: `AccountService` and `PartyService` are
/// only ever the fakes below, the same shape `my_bar_test.dart` and
/// `auth_flow_test.dart` use for `AuthService`.

class _FakeMetadata extends fb.UserMetadata {
  _FakeMetadata(DateTime creationTime) : super(creationTime.millisecondsSinceEpoch, null);
}

class _FakeUser implements fb.User {
  _FakeUser({DateTime? createdAt})
    : metadata = _FakeMetadata(createdAt ?? DateTime.utc(2026, 1, 1, 12));

  @override
  final String uid = 'user-1';
  @override
  final String? displayName = 'Marta';
  @override
  final String? email = 'marta.k@gmail.com';
  @override
  final String? photoURL = null;
  @override
  final fb.UserMetadata metadata;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} is not faked');
}

/// Already signed in the moment it is built — `currentUser` is never null —
/// which is what every Flow 09 screen in this file assumes of its audience.
class _FakeAuthService extends AuthService {
  _FakeAuthService(this._current);

  fb.User? _current;
  bool deleteSucceeds = true;
  final _controller = StreamController<fb.User?>.broadcast();

  @override
  fb.User? get currentUser => _current;

  @override
  Stream<fb.User?> get authStateChanges => _controller.stream;

  @override
  Future<void> signOut() async {
    _current = null;
    _controller.add(null);
  }

  @override
  Future<void> deleteAccount() async {
    if (!deleteSucceeds) {
      throw const AuthFailure(AuthFailureKind.requiresRecentLogin);
    }
    _current = null;
    _controller.add(null);
  }

  void dispose() => _controller.close();
}

/// Records every `updateProfile` call and lets a test push a profile onto
/// the same stream the screens read live.
class _FakeAccountService extends AccountService {
  final _profiles = <String, StreamController<User?>>{};
  final updates = <Map<String, dynamic>>[];
  bool deleteCalled = false;

  StreamController<User?> _controllerFor(String uid) =>
      _profiles.putIfAbsent(uid, () => StreamController<User?>.broadcast());

  void push(String uid, User? user) => _controllerFor(uid).add(user);

  @override
  Stream<User?> watchProfile(String uid) => _controllerFor(uid).stream;

  /// `ProfileScreen.initState` calls this directly rather than through the
  /// stream — never touched by production Firestore in this file either way.
  @override
  Future<User?> getProfile(String uid) async => null;

  @override
  Future<void> updateProfile(
    String uid, {
    String? name,
    List<String>? allergens,
    bool? notifyDrinkReady,
    bool? notifyNewOrder,
    bool? notifyRecapMorning,
  }) async {
    updates.add({
      'uid': uid,
      if (name != null) 'name': name,
      if (allergens != null) 'allergens': allergens,
      if (notifyDrinkReady != null) 'notifyDrinkReady': notifyDrinkReady,
      if (notifyNewOrder != null) 'notifyNewOrder': notifyNewOrder,
      if (notifyRecapMorning != null) 'notifyRecapMorning': notifyRecapMorning,
    });
  }

  @override
  Future<void> deleteAccountDoc(String uid) async {
    deleteCalled = true;
  }
}

class _FakePartyService extends PartyService {
  List<Party> hosted = const [];

  @override
  Stream<List<Party>> getHostedParties() => Stream.value(hosted);
}

Party _party(
  String id, {
  required PartyStatus status,
  String name = "Kate's Birthday",
}) => Party(
  id: id,
  name: name,
  hostId: 'user-1',
  hostName: 'Marta',
  availableCocktailIds: const [],
  joinCode: 'ABC123',
  status: status,
  createdAt: DateTime(2026, 9, 1),
);

const _delegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
  });

  /// No auth, no router — for the two screens flow 09 says work with no
  /// account at all.
  Future<void> pumpPlain(
    WidgetTester tester,
    Widget home, {
    LocaleProvider? locale,
    MeasureUnitProvider? measure,
  }) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<LocaleProvider>.value(value: locale ?? LocaleProvider()),
          ChangeNotifierProvider<MeasureUnitProvider>.value(
            value: measure ?? MeasureUnitProvider(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: _delegates,
          supportedLocales: const [Locale('en'), Locale('uk')],
          home: home,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// A real router with just enough stub destinations to prove a tap
  /// actually navigated, the way `auth_layout_test.dart` does for flow 03.
  Future<GoRouter> pumpRouted(
    WidgetTester tester,
    Widget home, {
    required AuthenticationProvider auth,
    BarProvider? bar,
  }) async {
    final router = GoRouter(
      initialLocation: '/subject',
      routes: [
        GoRoute(path: '/subject', builder: (context, state) => home),
        GoRoute(
          path: AppRoutes.settings,
          builder: (context, state) => const Scaffold(body: Text('settings-index')),
        ),
        GoRoute(
          path: AppRoutes.explore,
          builder: (context, state) => const Scaffold(body: Text('explore-screen')),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const Scaffold(body: Text('profile-screen')),
        ),
        GoRoute(
          path: AppRoutes.settingsLanguage,
          builder: (context, state) => const Scaffold(body: Text('language-screen')),
        ),
        GoRoute(
          path: AppRoutes.settingsMeasures,
          builder: (context, state) => const Scaffold(body: Text('measures-screen')),
        ),
        GoRoute(
          path: AppRoutes.settingsNotifications,
          builder: (context, state) => const Scaffold(body: Text('notifications-screen')),
        ),
        GoRoute(
          path: AppRoutes.settingsAccount,
          builder: (context, state) => const Scaffold(body: Text('account-screen')),
        ),
        GoRoute(
          path: AppRoutes.partyNights,
          builder: (context, state) => const Scaffold(body: Text('nights-screen')),
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
          ChangeNotifierProvider<BarProvider>.value(value: bar ?? BarProvider()),
          ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()),
          ChangeNotifierProvider<MeasureUnitProvider>(create: (_) => MeasureUnitProvider()),
        ],
        child: MaterialApp.router(
          theme: AppTheme.dark,
          localizationsDelegates: _delegates,
          supportedLocales: const [Locale('en'), Locale('uk')],
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  Future<AuthenticationProvider> buildAuth(
    _FakeAuthService authService,
    _FakeAccountService accountService,
  ) async {
    final auth = AuthenticationProvider(authService: authService, accountService: accountService);
    await auth.initialize();
    return auth;
  }

  group('04 · language', () {
    testWidgets('English is on by default and both languages are offered', (tester) async {
      final locale = LocaleProvider();
      await locale.initialize();

      await pumpPlain(tester, const LanguageScreen(), locale: locale);

      expect(find.text('English'), findsOneWidget);
      expect(find.text('Українська'), findsOneWidget);
      expect(find.text(l10n.settingsLanguageFollowsPhone), findsOneWidget);
    });

    testWidgets(
      'picking Ukrainian hands the choice to the device, and a later manual '
      'pick wins over "follow my phone"',
      (tester) async {
        final locale = LocaleProvider();
        await locale.initialize();

        await pumpPlain(tester, const LanguageScreen(), locale: locale);

        await tester.tap(find.text('Українська'));
        await tester.pumpAndSettle();

        expect(locale.currentLocale, SupportedLocale.uk);
        expect(locale.followsSystem, isFalse);

        // The test platform's own locale is English, so flipping the switch
        // back on hands the choice back to the device and lands on English.
        await tester.tap(find.text(l10n.settingsLanguageFollowsPhone));
        await tester.pumpAndSettle();

        expect(locale.followsSystem, isTrue);
        expect(locale.currentLocale, SupportedLocale.en);

        await tester.tap(find.text('Українська'));
        await tester.pumpAndSettle();

        expect(
          locale.followsSystem,
          isFalse,
          reason: 'picking a language by hand always wins over following the phone',
        );
        expect(locale.currentLocale, SupportedLocale.uk);
      },
    );
  });

  group('05 · measures', () {
    testWidgets('ml is the default preview', (tester) async {
      final unit = MeasureUnitProvider();
      await unit.initialize();

      await pumpPlain(tester, const MeasuresScreen(), measure: unit);

      // "oz" itself is still printed as the segment control's own code label
      // even while ml is selected, so this checks the actual preview amount
      // rather than the word "oz" appearing anywhere on screen.
      expect(find.textContaining('40 ml'), findsOneWidget);
    });

    testWidgets('tapping OZ changes what the whole preview renders', (tester) async {
      final unit = MeasureUnitProvider();
      await unit.initialize();

      await pumpPlain(tester, const MeasuresScreen(), measure: unit);

      await tester.tap(find.text(l10n.measureUnitOz));
      await tester.pumpAndSettle();

      expect(unit.unit, MeasureUnit.oz);
      expect(
        find.textContaining('40 ml'),
        findsNothing,
        reason: 'the ml amount is gone once the unit actually changed',
      );
      expect(find.textContaining('oz'), findsWidgets);

      final fresh = MeasureUnitProvider();
      await fresh.initialize();
      expect(fresh.unit, MeasureUnit.oz, reason: 'the pick persists past this screen');
    });
  });

  group('measurePreviewSummary and MeasurePreviewList', () {
    test('the index summary reads in ml, then in oz once switched', () {
      final ml = measurePreviewSummary(l10n, MeasureUnit.ml);
      final oz = measurePreviewSummary(l10n, MeasureUnit.oz);

      expect(ml, contains('40 ml'));
      expect(oz, isNot(contains('40 ml')));
      expect(oz, contains('oz'));
    });

    testWidgets('MeasureUnitSegment reports the tapped unit', (tester) async {
      MeasureUnit? picked;
      await pumpPlain(
        tester,
        Scaffold(
          body: MeasureUnitSegment(
            unit: MeasureUnit.ml,
            onChanged: (value) => picked = value,
          ),
        ),
      );

      await tester.tap(find.text(l10n.measureUnitOz));
      await tester.pumpAndSettle();

      expect(picked, MeasureUnit.oz);
    });
  });

  group('settings_rows widgets', () {
    testWidgets('SettingsRow shows its value and fires onTap, no chevron with none given', (
      tester,
    ) async {
      var tapped = 0;
      await pumpPlain(
        tester,
        Scaffold(
          body: SettingsRowGroup(
            children: [
              SettingsRow(
                icon: Icons.translate,
                label: 'Language',
                value: 'English',
                onTap: () => tapped++,
              ),
              const SettingsRow(icon: Icons.info_outline, label: 'About', value: '1.0.0'),
            ],
          ),
        ),
      );

      expect(find.text('Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      // Only the tappable row gets a chevron.
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      await tester.tap(find.text('Language'));
      expect(tapped, 1);
    });

    testWidgets('SettingsToggleRow flips on a tap anywhere on the row', (tester) async {
      var value = false;
      await pumpPlain(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: SettingsToggleRow(
              title: 'Your drink is ready',
              subtitle: 'Sent once, when it hits the bar.',
              value: value,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      );

      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);

      await tester.tap(find.text('Your drink is ready'));
      await tester.pumpAndSettle();

      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    });

    testWidgets('SettingsInfoRow and the group item both render their text', (tester) async {
      await pumpPlain(
        tester,
        const Scaffold(
          body: Column(
            children: [
              SettingsInfoRow(icon: Icons.group_outlined, text: 'Guests never see this'),
              SettingsInfoRowGroupItem(icon: Icons.block, text: 'Never a second in one night'),
            ],
          ),
        ),
      );

      expect(find.text('Guests never see this'), findsOneWidget);
      expect(find.text('Never a second in one night'), findsOneWidget);
    });
  });

  group('text_prompt', () {
    Future<String?> openPrompt(
      WidgetTester tester, {
      String initialValue = '',
      String? hint,
    }) async {
      String? result;
      await pumpPlain(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await promptForText(
                  context,
                  title: 'Change your name',
                  initialValue: initialValue,
                  hint: hint,
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('Save returns the edited text, pre-filled with the initial value', (
      tester,
    ) async {
      String? saved;
      await pumpPlain(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                saved = await promptForText(context, title: 'Change your name', initialValue: 'Kate');
              },
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Kate'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Katya');
      await tester.tap(find.text(l10n.save));
      await tester.pumpAndSettle();

      expect(saved, 'Katya');
    });

    testWidgets('Cancel returns null and keeps the typed text out of it', (tester) async {
      final saved = await openPrompt(tester);
      expect(saved, isNull);
    });

    testWidgets('submitting from the keyboard returns the text too', (tester) async {
      String? saved;
      await pumpPlain(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                saved = await promptForText(context, title: 'Add an allergen');
              },
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Peanuts');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(saved, 'Peanuts');
    });
  });

  group("06 · notifications — three switches, nothing to send them yet", () {
    testWidgets('with no profile document yet, two default on and one defaults off', (
      tester,
    ) async {
      final authService = _FakeAuthService(_FakeUser());
      final accountService = _FakeAccountService();
      final auth = await buildAuth(authService, accountService);
      addTearDown(authService.dispose);

      await pumpRouted(
        tester,
        NotificationsScreen(accountService: accountService),
        auth: auth,
      );

      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches.length, 3);
      expect(switches[0].value, isTrue, reason: 'drink ready defaults on');
      expect(switches[1].value, isTrue, reason: 'new order defaults on');
      expect(switches[2].value, isFalse, reason: 'the morning recap defaults off');
    });

    testWidgets('flipping the recap switch writes exactly that field', (tester) async {
      final authService = _FakeAuthService(_FakeUser());
      final accountService = _FakeAccountService();
      final auth = await buildAuth(authService, accountService);
      addTearDown(authService.dispose);

      await pumpRouted(
        tester,
        NotificationsScreen(accountService: accountService),
        auth: auth,
      );

      await tester.tap(find.text(l10n.settingsNotifyRecap));
      await tester.pumpAndSettle();

      expect(accountService.updates, [
        {'uid': 'user-1', 'notifyRecapMorning': true},
      ]);
    });

    testWidgets('a profile pushed onto the live stream updates the switches', (tester) async {
      final authService = _FakeAuthService(_FakeUser());
      final accountService = _FakeAccountService();
      final auth = await buildAuth(authService, accountService);
      addTearDown(authService.dispose);

      await pumpRouted(
        tester,
        NotificationsScreen(accountService: accountService),
        auth: auth,
      );

      accountService.push(
        'user-1',
        User(
          id: 'user-1',
          name: 'Marta',
          notifyDrinkReady: false,
          notifyNewOrder: false,
          notifyRecapMorning: true,
          createdAt: DateTime(2026, 1, 1),
          lastLoginAt: DateTime(2026, 1, 1),
        ),
      );
      await tester.pumpAndSettle();

      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches[0].value, isFalse);
      expect(switches[1].value, isFalse);
      expect(switches[2].value, isTrue);
    });
  });

  group('07 · account & data — the one-way door', () {
    testWidgets('shows the email and when the account started', (tester) async {
      final authService = _FakeAuthService(_FakeUser(createdAt: DateTime.utc(2025, 3, 4, 12)));
      final accountService = _FakeAccountService();
      final auth = await buildAuth(authService, accountService);
      addTearDown(authService.dispose);

      await pumpRouted(
        tester,
        AccountDataScreen(partyService: _FakePartyService()),
        auth: auth,
      );

      expect(find.text('marta.k@gmail.com'), findsOneWidget);
      expect(find.textContaining('Mar 4, 2025'), findsOneWidget);
    });

    testWidgets('signs out and returns to the settings index when nothing is live', (
      tester,
    ) async {
      final authService = _FakeAuthService(_FakeUser());
      final accountService = _FakeAccountService();
      final auth = await buildAuth(authService, accountService);
      addTearDown(authService.dispose);
      final parties = _FakePartyService()
        ..hosted = [_party('ended-1', status: PartyStatus.ended)];

      await pumpRouted(tester, AccountDataScreen(partyService: parties), auth: auth);

      await tester.tap(find.text(l10n.logout));
      await tester.pumpAndSettle();

      expect(auth.isAuthenticated, isFalse);
      expect(find.text('settings-index'), findsOneWidget);
    });

    testWidgets('sign-out is refused while a hosted party is still live', (tester) async {
      final authService = _FakeAuthService(_FakeUser());
      final accountService = _FakeAccountService();
      final auth = await buildAuth(authService, accountService);
      addTearDown(authService.dispose);
      final parties = _FakePartyService()
        ..hosted = [_party('live-1', status: PartyStatus.active)];

      await pumpRouted(tester, AccountDataScreen(partyService: parties), auth: auth);

      await tester.tap(find.text(l10n.logout));
      await tester.pumpAndSettle();

      expect(find.text(l10n.settingsSignOutBlockedTitle), findsOneWidget);
      expect(
        auth.isAuthenticated,
        isTrue,
        reason: "there is nowhere for the live party's queue to go once the "
            'host who could see it signs out',
      );

      await tester.tap(find.text(l10n.settingsSignOutBlockedAction));
      await tester.pumpAndSettle();

      expect(find.text('host-live-1'), findsOneWidget, reason: 'taken straight to the live party');
      expect(auth.isAuthenticated, isTrue, reason: 'still never signed out');
    });

    testWidgets('cancelling the block leaves the account screen exactly as it was', (
      tester,
    ) async {
      final authService = _FakeAuthService(_FakeUser());
      final accountService = _FakeAccountService();
      final auth = await buildAuth(authService, accountService);
      addTearDown(authService.dispose);
      final parties = _FakePartyService()
        ..hosted = [_party('live-1', status: PartyStatus.paused)];

      await pumpRouted(tester, AccountDataScreen(partyService: parties), auth: auth);

      await tester.tap(find.text(l10n.logout));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.cancel));
      await tester.pumpAndSettle();

      expect(find.text(l10n.settingsSignOutBlockedTitle), findsNothing);
      expect(auth.isAuthenticated, isTrue);
      expect(find.text(l10n.settingsAccountData), findsOneWidget);
    });
  });

  group("delete_account_sheet — the sheet behind screen 07's other door", () {
    Future<void> openSheet(
      WidgetTester tester, {
      required AuthenticationProvider auth,
      required BarProvider bar,
      PartyService? partyService,
    }) async {
      // The sheet's manifest, confirm field and two buttons need more height
      // than the test window's default — a real phone, not the overflow.
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthenticationProvider>.value(value: auth),
            ChangeNotifierProvider<BarProvider>.value(value: bar),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            localizationsDelegates: _delegates,
            supportedLocales: const [Locale('en'), Locale('uk')],
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showDeleteAccountSheet(context, partyService: partyService),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('the confirm button stays off until DELETE is typed, case and all', (
      tester,
    ) async {
      final authService = _FakeAuthService(_FakeUser());
      final auth = await buildAuth(authService, _FakeAccountService());
      addTearDown(authService.dispose);
      final bar = BarProvider();
      await bar.initialize();

      await openSheet(tester, auth: auth, bar: bar, partyService: _FakePartyService());

      // `ElevatedButton.icon` builds a private subclass of `ElevatedButton`,
      // so `find.byType`/`widgetWithText` (exact-type match) never find it —
      // `byWidgetPredicate`'s `is` check does.
      Finder confirmButtonFinder() => find.ancestor(
        of: find.text(l10n.settingsDeleteConfirm),
        matching: find.byWidgetPredicate((w) => w is ElevatedButton),
      );

      expect(tester.widget<ElevatedButton>(confirmButtonFinder()).onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'delete');
      await tester.pumpAndSettle();

      expect(tester.widget<ElevatedButton>(confirmButtonFinder()).onPressed, isNotNull);
    });

    testWidgets('"Keep my account" closes the sheet with false and deletes nothing', (
      tester,
    ) async {
      final authService = _FakeAuthService(_FakeUser());
      final accountService = _FakeAccountService();
      final auth = await buildAuth(authService, accountService);
      addTearDown(authService.dispose);
      final bar = BarProvider();
      await bar.initialize();
      await bar.add('gin');

      await openSheet(tester, auth: auth, bar: bar, partyService: _FakePartyService());
      await tester.tap(find.text(l10n.settingsDeleteKeep));
      await tester.pumpAndSettle();

      expect(find.text(l10n.settingsDeleteTitle), findsNothing);
      expect(accountService.deleteCalled, isFalse);
      expect(bar.holdsKey('gin'), isTrue);
      expect(auth.isAuthenticated, isTrue);
    });

    testWidgets('typing DELETE and confirming deletes the account', (tester) async {
      final authService = _FakeAuthService(_FakeUser());
      final accountService = _FakeAccountService();
      final auth = await buildAuth(authService, accountService);
      addTearDown(authService.dispose);
      final bar = BarProvider();
      await bar.initialize();
      await bar.add('gin');

      await openSheet(tester, auth: auth, bar: bar, partyService: _FakePartyService());

      await tester.enterText(find.byType(TextField), 'DELETE');
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.settingsDeleteConfirm));
      await tester.pumpAndSettle();

      expect(accountService.deleteCalled, isTrue);
      expect(auth.isAuthenticated, isFalse);
      expect(bar.holdsKey('gin'), isFalse, reason: 'the shelf is cleared as part of deleting');
      expect(find.text(l10n.settingsDeleteTitle), findsNothing, reason: 'the sheet closes itself');
    });
  });

  group('01/02 · the settings index and profile — smoke, signed in and out', () {
    testWidgets('signed out: no account rows, sign-in hero and the guest name card', (
      tester,
    ) async {
      final authService = _FakeAuthService(null);
      final accountService = _FakeAccountService();
      final auth = await buildAuth(authService, accountService);
      addTearDown(authService.dispose);
      await auth.setGuestName('Sam');

      await pumpRouted(
        tester,
        SettingsScreen(accountService: accountService, partyService: _FakePartyService()),
        auth: auth,
      );

      expect(find.text(l10n.settingsSignIn), findsOneWidget);
      expect(find.text('Sam'), findsOneWidget);
      expect(find.text(l10n.hostYourNights), findsNothing);
      expect(find.text(l10n.settingsAccountData), findsNothing);
    });

    testWidgets('signed in: tapping Language navigates to the language screen', (tester) async {
      final authService = _FakeAuthService(_FakeUser());
      final accountService = _FakeAccountService();
      final auth = await buildAuth(authService, accountService);
      addTearDown(authService.dispose);

      await pumpRouted(
        tester,
        SettingsScreen(accountService: accountService, partyService: _FakePartyService()),
        auth: auth,
      );

      expect(find.text('Marta'), findsOneWidget);
      expect(find.text(l10n.hostYourNights), findsOneWidget);

      // The value beside it depends on LocaleProvider's own init state
      // ("Follow my phone" until initialize() resolves), so this taps the
      // row by its stable label instead.
      await tester.tap(find.text(l10n.language));
      await tester.pumpAndSettle();
      expect(find.text('language-screen'), findsOneWidget);
    });

    testWidgets('profile screen: adding and removing an allergen updates the account', (
      tester,
    ) async {
      final authService = _FakeAuthService(_FakeUser());
      final accountService = _FakeAccountService();
      final auth = await buildAuth(authService, accountService);
      addTearDown(authService.dispose);

      await pumpRouted(
        tester,
        ProfileScreen(accountService: accountService, partyService: _FakePartyService()),
        auth: auth,
      );

      await tester.tap(find.text(l10n.profileAddAllergen));
      await tester.pumpAndSettle();
      // The name field is already on screen underneath, so this scopes to
      // the dialog's own field rather than `find.byType(TextField)` at large.
      await tester.enterText(
        find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextField)),
        'Peanuts',
      );
      await tester.tap(find.text(l10n.save));
      await tester.pumpAndSettle();

      expect(find.text('Peanuts'), findsOneWidget);
      expect(accountService.updates.last['allergens'], ['Peanuts']);

      await tester.tap(find.text('Peanuts'));
      await tester.pumpAndSettle();

      expect(find.text('Peanuts'), findsNothing);
      expect(accountService.updates.last['allergens'], <String>[]);
    });
  });
}
