import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:party_bar/data/bar_catalogue_repository.dart';
import 'package:party_bar/data/cocktail_repository.dart';
import 'package:party_bar/generated/l10n/app_localizations.dart';
import 'package:party_bar/models/models.dart';
import 'package:party_bar/providers/auth_provider.dart';
import 'package:party_bar/providers/bar_provider.dart';
import 'package:party_bar/providers/explore_provider.dart';
import 'package:party_bar/providers/locale_provider.dart';
import 'package:party_bar/screens/bar/my_bar_screen.dart';
import 'package:party_bar/services/account_service.dart';
import 'package:party_bar/services/auth_service.dart';
import 'package:party_bar/services/elastic_service.dart';
import 'package:party_bar/theme/theme.dart';
import 'package:party_bar/utils/app_router.dart';
import 'package:party_bar/widgets/bar/bar_item_sheet.dart';
import 'package:party_bar/widgets/bar/bar_row.dart';

import 'support/harness.dart';

/// Flow 04 · screens 01, 03, 04 and the item sheet — the shelf a host
/// actually lives on. No Firebase anywhere here: the catalogue, the
/// cocktail feed and the signed-out auth state are all fakes, the same way
/// `bar_provider_test.dart` and `auth_flow_test.dart` stand them in.

class _FakeCatalogueSource implements BarCatalogueSource {
  _FakeCatalogueSource(this.entries);

  final List<BarCatalogueEntry> entries;

  @override
  Future<List<BarCatalogueEntry>> load() async => entries;
}

/// Only what [ExploreProvider] ever calls. `CocktailRepository` reaches for
/// Firestore in its own field initialisers, so this stands in as the
/// interface rather than a subclass — anything else it is asked for says so
/// loudly instead of quietly touching Firebase.
class _FakeCocktailRepository implements CocktailRepository {
  _FakeCocktailRepository([this.cocktails = const []]);

  final List<Cocktail> cocktails;

  @override
  Future<CocktailSearchResultWithData> searchCocktails({
    String? query,
    CocktailSearchFilters? filters,
    PaginationParams? pagination,
    CocktailSortOrder? sort,
  }) async => CocktailSearchResultWithData(
    cocktails: cocktails,
    total: cocktails.length,
    page: 1,
    pageSize: cocktails.length,
    totalPages: 1,
    hasNextPage: false,
    hasPreviousPage: false,
  );

  @override
  Future<void> clearCache() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} is not faked');
}

/// `AuthService` resolves Firebase lazily, so a plain subclass that never
/// calls the inherited members is safe to build without Firebase at all —
/// exactly how `auth_flow_test.dart` does it, just signed out throughout.
class _FakeAuthService extends AuthService {
  final _controller = StreamController<fb.User?>.broadcast();

  @override
  fb.User? get currentUser => null;

  @override
  Stream<fb.User?> get authStateChanges => _controller.stream;

  void dispose() => _controller.close();
}

BarCatalogueEntry _entry(
  String key, {
  BarSection section = BarSection.other,
  BarItemKind kind = BarItemKind.ingredient,
  Map<String, String>? title,
  int? cocktailCount,
}) => BarCatalogueEntry(
  key: barKey(key),
  kind: kind,
  section: section,
  title: title ?? {'en': key},
  cocktailCount: cocktailCount,
);

Ingredient _ingredient(String id, {int? unlocks}) =>
    Ingredient(id: id, title: {'en': id}, category: IngredientCategory.spirit, unlocks: unlocks);

Cocktail _cocktail(
  String id, {
  String title = '',
  List<Ingredient> ingredients = const [],
  int? popularity,
  String image = '',
}) => Cocktail(
  id: id,
  title: {'en': title.isEmpty ? id : title},
  description: const {'en': ''},
  image: image,
  categories: const [],
  ingredients: ingredients,
  equipments: const [],
  popularity: popularity,
);

Finder _bySemanticsLabel(String label) => find.byWidgetPredicate(
  (widget) => widget is Semantics && widget.properties.label == label,
);

GoRouter _router(Widget home) => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => home),
    GoRoute(
      path: AppRoutes.barSearch,
      builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
    ),
    GoRoute(
      path: AppRoutes.shoppingList,
      builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
    ),
    GoRoute(
      path: '${AppRoutes.cocktailDetails}/:id',
      builder: (context, state) =>
          Scaffold(body: Text('cocktail-${state.pathParameters['id']}')),
    ),
  ],
);

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
  });

  Future<BarProvider> buildBar({
    List<BarCatalogueEntry> catalogue = const [],
  }) async {
    final bar = BarProvider(catalogue: _FakeCatalogueSource(catalogue));
    await bar.initialize();
    return bar;
  }

  Future<ExploreProvider> buildExplore({List<Cocktail> cocktails = const []}) async {
    final explore = ExploreProvider(repository: _FakeCocktailRepository(cocktails));
    await explore.initialize();
    return explore;
  }

  Future<AuthenticationProvider> buildAuth() async {
    final auth = AuthenticationProvider(
      authService: _FakeAuthService(),
      accountService: AccountService(),
    );
    await auth.initialize();
    return auth;
  }

  Future<void> pump(
    WidgetTester tester, {
    required Widget home,
    required BarProvider bar,
    required ExploreProvider explore,
    required AuthenticationProvider auth,
    Size size = const Size(390, 844),
    double textScale = 1.0,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()),
          ChangeNotifierProvider<BarProvider>.value(value: bar),
          ChangeNotifierProvider<ExploreProvider>.value(value: explore),
          ChangeNotifierProvider<AuthenticationProvider>.value(value: auth),
        ],
        child: MaterialApp.router(
          theme: AppTheme.dark,
          routerConfig: _router(home),
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
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('01 · the empty shelf', () {
    testWidgets('offers the twelve starters, and Add all stocks every one', (
      tester,
    ) async {
      final bar = await buildBar();
      final explore = await buildExplore();
      final auth = await buildAuth();

      // Tall enough that all twelve starter rows are mounted at once rather
      // than lazily built as the list scrolls — this test counts them.
      await pump(
        tester,
        home: const MyBarScreen(),
        bar: bar,
        explore: explore,
        auth: auth,
        size: const Size(390, 2400),
      );

      expect(find.byType(BarRow), findsNWidgets(12));
      expect(find.text(l10n.barEmptyBody), findsOneWidget);

      await tester.tap(find.text(l10n.barAddAll));
      await tester.pumpAndSettle();

      expect(bar.shelf.length, 12);
      // Every starter is on the shelf now, so the latch lets go and the
      // screen moves on to the real shelf (03) — the empty body is gone.
      expect(find.text(l10n.barEmptyBody), findsNothing);
    });

    testWidgets("tapping one starter's add stocks it and stays on starters", (
      tester,
    ) async {
      final bar = await buildBar();
      final explore = await buildExplore();
      final auth = await buildAuth();

      await pump(
        tester,
        home: const MyBarScreen(),
        bar: bar,
        explore: explore,
        auth: auth,
        size: const Size(390, 2400),
      );

      await tester.tap(_bySemanticsLabel('${l10n.barAddItem} (Gin)'));
      await tester.pumpAndSettle();

      expect(bar.shelf.contains(barKey('gin')), isTrue);
      expect(bar.shelf.length, 1);
      // Still eleven left to add — the latch keeps the starter list up.
      expect(find.text(l10n.barEmptyBody), findsOneWidget);
      expect(find.byType(BarRow), findsNWidgets(12));
    });
  });

  group('03 · the shelf', () {
    Future<BarProvider> stockedBar() async {
      final bar = await buildBar();
      await bar.addEntries([
        _entry('gin-x', section: BarSection.spirits),
        _entry('vodka-x', section: BarSection.spirits),
        _entry('lime-x', section: BarSection.fresh),
        _entry('shaker-x', section: BarSection.tools, kind: BarItemKind.equipment),
      ]);
      return bar;
    }

    testWidgets('groups stocked rows by section, with a header count each', (
      tester,
    ) async {
      final bar = await stockedBar();
      final explore = await buildExplore();
      final auth = await buildAuth();

      await pump(tester, home: const MyBarScreen(), bar: bar, explore: explore, auth: auth);

      expect(
        find.text('${l10n.barGroupSpirits} · 2'.toUpperCase()),
        findsOneWidget,
      );
      expect(find.text('${l10n.barGroupFresh} · 1'.toUpperCase()), findsOneWidget);
      expect(find.text('${l10n.barGroupTools} · 1'.toUpperCase()), findsOneWidget);
      expect(find.text('${l10n.barFilterAll} 4'), findsOneWidget);
    });

    testWidgets('the trailing check marks an item ran out and moves it down', (
      tester,
    ) async {
      final bar = await stockedBar();
      final explore = await buildExplore();
      final auth = await buildAuth();

      await pump(tester, home: const MyBarScreen(), bar: bar, explore: explore, auth: auth);

      await tester.tap(_bySemanticsLabel(l10n.barMarkRanOut('lime-x')));
      await tester.pumpAndSettle();

      expect(bar.itemFor(barKey('lime-x'))!.isStocked, isFalse);
      // Fresh had only the one bottle, and it just ran out — the group
      // itself drops out of the unfiltered shelf entirely.
      expect(find.text('${l10n.barGroupFresh} · 1'.toUpperCase()), findsNothing);
      expect(
        find.text('${l10n.barRanOutGroup} · 1'.toUpperCase()),
        findsOneWidget,
      );
      expect(find.text(l10n.barRanOutGroup), findsWidgets);
    });

    testWidgets("the ran-out row's pill adds it to the shopping list", (
      tester,
    ) async {
      final bar = await stockedBar();
      await bar.markRanOut(barKey('lime-x'));
      final explore = await buildExplore();
      final auth = await buildAuth();

      await pump(tester, home: const MyBarScreen(), bar: bar, explore: explore, auth: auth);

      expect(bar.isOnList(barKey('lime-x')), isFalse);

      await tester.tap(find.text(l10n.barAddToList));
      await tester.pumpAndSettle();

      expect(bar.isOnList(barKey('lime-x')), isTrue);
      final entry = bar.shoppingList.firstWhere((e) => e.key == barKey('lime-x'));
      expect(entry.reason, ShoppingReason.ranOut);
      expect(find.text(l10n.barOnYourList), findsOneWidget);
    });
  });

  group('04 · filtered by chip', () {
    testWidgets(
      'selecting Fresh and Tools shows both groups filtered, ran-out inline, and the fresh info card',
      (tester) async {
        final bar = await buildBar();
        await bar.addEntries([
          _entry('vodka-x', section: BarSection.spirits),
          _entry('shaker-x', section: BarSection.tools, kind: BarItemKind.equipment),
          _entry('lime-x', section: BarSection.fresh),
        ]);
        await bar.markRanOut(barKey('lime-x'));
        final explore = await buildExplore();
        final auth = await buildAuth();

        await pump(tester, home: const MyBarScreen(), bar: bar, explore: explore, auth: auth);

        // Fresh has nothing stocked (its one item ran out), so the chip
        // must still appear — bare, with no "0" — because the section is
        // not empty, just entirely out.
        expect(find.text(l10n.barSectionFresh), findsOneWidget);
        expect(find.text('${l10n.barSectionTools} 1'), findsOneWidget);

        // The chip row scrolls horizontally, so a chip past the fold has to
        // be scrolled into view before it can actually receive a tap.
        await tester.ensureVisible(find.text(l10n.barSectionFresh));
        await tester.tap(find.text(l10n.barSectionFresh));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('${l10n.barSectionTools} 1'));
        await tester.tap(find.text('${l10n.barSectionTools} 1'));
        await tester.pumpAndSettle();

        expect(find.text('${l10n.barGroupFresh} · 1'.toUpperCase()), findsOneWidget);
        expect(find.text('${l10n.barGroupTools} · 1'.toUpperCase()), findsOneWidget);
        expect(find.text(l10n.barNotInYourBar), findsOneWidget);
        expect(find.text(l10n.barFreshInfo), findsOneWidget);

        // Filtered mode never shows the standalone RAN OUT group or its
        // "add to list" pill — the ran-out row sits inline instead.
        expect(find.textContaining(l10n.barRanOutGroup), findsNothing);
        expect(find.byType(BarPillAction), findsNothing);
      },
    );
  });

  group('05 · the item sheet', () {
    Widget launcher(String key) => Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () => showBarItemSheet(context, key),
          child: const Text('open'),
        ),
      ),
    );

    testWidgets('the switch flips stocked status', (tester) async {
      final bar = await buildBar();
      await bar.addEntry(_entry('gin-x', section: BarSection.spirits));
      final explore = await buildExplore();
      final auth = await buildAuth();
      final key = barKey('gin-x');

      await pump(tester, home: launcher(key), bar: bar, explore: explore, auth: auth);
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text(l10n.barSheetOnShelf), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(bar.itemFor(key)!.isStocked, isFalse);
    });

    testWidgets('a saved note shows on the row', (tester) async {
      final bar = await buildBar();
      await bar.addEntry(_entry('gin-x', section: BarSection.spirits));
      final explore = await buildExplore();
      final auth = await buildAuth();
      final key = barKey('gin-x');

      await pump(tester, home: launcher(key), bar: bar, explore: explore, auth: auth);
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text(l10n.barSheetNoteAdd), findsOneWidget);

      await tester.tap(find.text(l10n.barSheetNoteAdd));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Bombay Sapphire');
      await tester.tap(find.text(l10n.barSheetNoteSave));
      await tester.pumpAndSettle();

      expect(bar.itemFor(key)!.note, 'Bombay Sapphire');
      expect(find.text('Bombay Sapphire'), findsOneWidget);
    });

    testWidgets('removing offers an undo that restores the item', (tester) async {
      final bar = await buildBar();
      await bar.addEntry(_entry('gin-x', section: BarSection.spirits));
      await bar.setNote(barKey('gin-x'), 'Bombay Sapphire');
      final explore = await buildExplore();
      final auth = await buildAuth();
      final key = barKey('gin-x');

      await pump(tester, home: launcher(key), bar: bar, explore: explore, auth: auth);
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.barSheetRemove));
      await tester.pumpAndSettle();

      expect(bar.itemFor(key), isNull);
      expect(find.text(l10n.barRemoved('gin-x')), findsOneWidget);

      await tester.tap(find.text(l10n.barUndo));
      await tester.pumpAndSettle();

      expect(bar.itemFor(key), isNotNull);
      expect(bar.itemFor(key)!.note, 'Bombay Sapphire');
      expect(bar.itemFor(key)!.isStocked, isTrue);
    });

    testWidgets('closes itself if the item disappears from under it', (tester) async {
      final bar = await buildBar();
      await bar.addEntry(_entry('gin-x', section: BarSection.spirits));
      final explore = await buildExplore();
      final auth = await buildAuth();
      final key = barKey('gin-x');

      await pump(tester, home: launcher(key), bar: bar, explore: explore, auth: auth);
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text(l10n.barSheetOnShelf), findsOneWidget);

      await bar.removeItem(key);
      await tester.pumpAndSettle();

      expect(find.text(l10n.barSheetOnShelf), findsNothing);
    });
  });

  group('layout holds under a narrow phone and a bumped text scale', () {
    const sizes = testSizes;
    const scales = standardTextScales;

    Future<BarProvider> layoutBar() async {
      final bar = await buildBar();
      await bar.addEntries([
        _entry(
          'a-considerably-long-bottle-name',
          section: BarSection.spirits,
          cocktailCount: 46,
        ),
        _entry('vodka-x', section: BarSection.spirits),
        _entry('lime-x', section: BarSection.fresh),
        _entry('shaker-x', section: BarSection.tools, kind: BarItemKind.equipment),
      ]);
      await bar.setNote(barKey('vodka-x'), 'A rather long note about where this lives');
      await bar.markRanOut(barKey('lime-x'));
      await bar.addToList(
        _entry('lime-x', section: BarSection.fresh),
        reason: ShoppingReason.ranOut,
      );
      return bar;
    }

    for (final MapEntry(key: device, value: size) in sizes.entries) {
      for (final scale in scales) {
        testWidgets('01 empty shelf on a $device at ${scale}x text', (tester) async {
          final bar = await buildBar();
          final explore = await buildExplore();
          final auth = await buildAuth();

          await pump(
            tester,
            home: const MyBarScreen(),
            bar: bar,
            explore: explore,
            auth: auth,
            size: size,
            textScale: scale,
          );

          expect(tester.takeException(), isNull);
        });

        testWidgets('03 the shelf on a $device at ${scale}x text', (tester) async {
          final bar = await layoutBar();
          final explore = await buildExplore(
            cocktails: [_cocktail('gin-tonic', ingredients: [_ingredient('gin')])],
          );
          final auth = await buildAuth();

          await pump(
            tester,
            home: const MyBarScreen(),
            bar: bar,
            explore: explore,
            auth: auth,
            size: size,
            textScale: scale,
          );

          expect(tester.takeException(), isNull);
        });

        testWidgets('04 filtered on a $device at ${scale}x text', (tester) async {
          final bar = await layoutBar();
          final explore = await buildExplore();
          final auth = await buildAuth();

          await pump(
            tester,
            home: const MyBarScreen(),
            bar: bar,
            explore: explore,
            auth: auth,
            size: size,
            textScale: scale,
          );

          await tester.ensureVisible(find.text(l10n.barSectionFresh));
          await tester.tap(find.text(l10n.barSectionFresh));
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.text('${l10n.barSectionTools} 1'));
          await tester.tap(find.text('${l10n.barSectionTools} 1'));
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        });

        testWidgets('05 the item sheet on a $device at ${scale}x text', (tester) async {
          final bar = await buildBar();
          await bar.addEntry(
            _entry('a-considerably-long-bottle-name', section: BarSection.spirits),
          );
          await bar.setNote(
            barKey('a-considerably-long-bottle-name'),
            'A rather long note about where this bottle actually lives',
          );
          final key = barKey('a-considerably-long-bottle-name');
          final onShelf = _ingredient('a-considerably-long-bottle-name');
          final explore = await buildExplore(
            cocktails: [
              _cocktail('one', title: 'Gin and Tonic', ingredients: [onShelf]),
              _cocktail('two', title: 'Midnight Orchard', ingredients: [onShelf]),
              _cocktail('three', title: 'Negroni', ingredients: [onShelf]),
            ],
          );
          final auth = await buildAuth();

          await pump(
            tester,
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showBarItemSheet(context, key),
                  child: const Text('open'),
                ),
              ),
            ),
            bar: bar,
            explore: explore,
            auth: auth,
            size: size,
            textScale: scale,
          );

          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}
