import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:party_bar/data/cocktail_repository.dart';
import 'package:party_bar/generated/l10n/app_localizations.dart';
import 'package:party_bar/models/models.dart';
import 'package:party_bar/providers/bar_provider.dart';
import 'package:party_bar/providers/explore_provider.dart';
import 'package:party_bar/providers/locale_provider.dart';
import 'package:party_bar/screens/bar/ran_out_screen.dart';
import 'package:party_bar/screens/explore/cocktail_details_screen.dart';
import 'package:party_bar/services/elastic_service.dart';
import 'package:party_bar/theme/theme.dart';
import 'package:party_bar/widgets/bar/two_away_sheet.dart';

/// Flow 04 screens 08 ("what ran out?") and 09 ("two away") — the one-time
/// upkeep checklist a party leaves behind, and the one other place outside
/// it a gap in the shelf is ever named. No Firebase reaches these tests: the
/// couple of cases that touch [ExploreProvider] hand it a fake repository
/// instead of the real, Firestore-backed one.

const _sizes = <String, Size>{
  'iPhone 14 Pro': Size(390, 844),
  'small phone': Size(320, 568),
};
const _textScales = <double>[1.0, 1.5];

/// The path `RanOutScreen._exit` falls back to when it cannot pop — kept as
/// a literal rather than importing the real `AppRoutes`, which drags in
/// every screen in the app just for one string.
const _myBarPath = '/bar';

String _titleCase(String id) => id.isEmpty ? id : id[0].toUpperCase() + id.substring(1);

Ingredient _ingredient(
  String id, {
  String? slug,
  IngredientCategory category = IngredientCategory.spirit,
}) => Ingredient(id: id, title: {'en': _titleCase(id)}, category: category, slug: slug);

Cocktail _cocktail(String id, {required List<Ingredient> ingredients}) => Cocktail(
  id: id,
  title: {'en': id},
  description: const {'en': ''},
  image: '',
  categories: const [],
  ingredients: ingredients,
  equipments: const [],
);

BarCatalogueEntry _entry(String name, BarSection section) => BarCatalogueEntry(
  key: barKey(name),
  kind: BarItemKind.ingredient,
  section: section,
  title: {'en': name},
);

/// [CocktailRepository] reaches into Firestore from its own field
/// initialisers, so a fake has to `implements` it rather than `extends` it —
/// `implements` never runs the real constructor, it only has to answer to
/// the same public shape. Only [searchCocktails] and [clearCache] are ever
/// actually called by [ExploreProvider] in these tests; the rest exist
/// purely so the class type-checks as a `CocktailRepository`.
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
  Future<Cocktail?> getCocktail(String id) async =>
      cocktails.where((cocktail) => cocktail.id == id).firstOrNull;

  @override
  Future<List<Cocktail>> getCocktailsByIds(
    List<String> ids, {
    SupportedLocale locale = SupportedLocale.en,
  }) async => cocktails.where((cocktail) => ids.contains(cocktail.id)).toList();

  @override
  Future<List<Cocktail>> getAllCocktails({
    SupportedLocale locale = SupportedLocale.en,
  }) async => cocktails;

  @override
  Future<List<(String id, CocktailDocument doc)>> getAllCocktailDocuments() async =>
      const [];

  @override
  Future<(String id, CocktailDocument doc)?> getCocktailDocument(String id) async =>
      null;

  @override
  Stream<List<(String id, CocktailDocument doc)>> streamCocktailDocuments() =>
      const Stream.empty();
}

void main() {
  late AppLocalizations en;

  setUpAll(() async {
    en = await AppLocalizations.delegate.load(const Locale('en'));
  });

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
  });

  const delegates = <LocalizationsDelegate<dynamic>>[
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  /// A plain host — no router — for anything that never needs `context.pop`
  /// or `context.go`: the two-away sheet (a modal route of its own) and the
  /// cocktail sheet's content, which only ever reads [BarProvider].
  Future<void> pumpPlain(
    WidgetTester tester,
    Widget child, {
    required BarProvider bar,
    ExploreProvider? explore,
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
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider.value(value: bar),
          if (explore != null) ChangeNotifierProvider.value(value: explore),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: delegates,
          supportedLocales: const [Locale('en'), Locale('uk')],
          builder: (context, widget) => MediaQuery.withClampedTextScaling(
            minScaleFactor: textScale,
            maxScaleFactor: textScale,
            child: widget!,
          ),
          home: child,
        ),
      ),
    );
    await tester.pump();
  }

  /// [RanOutScreen] itself calls `context.pop` / `context.canPop` /
  /// `context.go` — real go_router extensions — so it needs an actual
  /// [GoRouter] under it, not just a bare [Navigator]. The fallback route it
  /// lands on after "Update my bar" is a stand-in, not the real My bar tab.
  Future<void> pumpRanOut(
    WidgetTester tester, {
    required BarProvider bar,
    RanOutArgs? args,
    Size size = const Size(390, 844),
    double textScale = 1.0,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => RanOutScreen(args: args)),
        GoRoute(
          path: _myBarPath,
          builder: (context, state) => const Scaffold(body: SizedBox()),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider.value(value: bar),
        ],
        child: MaterialApp.router(
          theme: AppTheme.dark,
          routerConfig: router,
          localizationsDelegates: delegates,
          supportedLocales: const [Locale('en'), Locale('uk')],
          builder: (context, widget) => MediaQuery.withClampedTextScaling(
            minScaleFactor: textScale,
            maxScaleFactor: textScale,
            child: widget!,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('bar keys', () {
    test('the key "I have these" writes is always one the shelf already answers to', () {
      // Screen 09's "I actually have these" stocks a missing ingredient
      // under `BarCatalogueEntry.fromIngredient(ingredient).key`. If that
      // spelling ever drifted from `ingredientKeys`, the shelf would gain a
      // bottle makeability checks never recognise, and the drink would stay
      // blocked even after the host said they had everything.
      final withSlug = _ingredient('9a2b', slug: 'sweetVermouth');
      final withoutSlug = _ingredient('vermouth-dry');

      for (final ingredient in [withSlug, withoutSlug]) {
        final key = BarCatalogueEntry.fromIngredient(ingredient).key;
        expect(ingredientKeys(ingredient), contains(key));
      }
    });
  });

  group('screen 08 · what ran out', () {
    Future<BarProvider> barWithEntries(List<BarCatalogueEntry> entries) async {
      final bar = BarProvider();
      await bar.initialize();
      for (final entry in entries) {
        await bar.addEntry(entry);
      }
      return bar;
    }

    testWidgets('orders the busiest bottles first, then the rest fresh-first', (
      tester,
    ) async {
      final vodka = _entry('Vodka', BarSection.spirits);
      final cointreau = _entry('Cointreau', BarSection.spirits);
      final lime = _entry('Lime', BarSection.fresh);
      final gin = _entry('Gin', BarSection.spirits);

      final bar = await barWithEntries([vodka, cointreau, lime, gin]);

      await pumpRanOut(
        tester,
        bar: bar,
        args: RanOutArgs(pourCounts: {vodka.key: 5, cointreau.key: 2}),
      );

      double topOf(String text) => tester.getTopLeft(find.text(text)).dy;

      expect(topOf('Vodka'), lessThan(topOf('Cointreau')));
      expect(topOf('Cointreau'), lessThan(topOf('Lime')));
      expect(topOf('Lime'), lessThan(topOf('Gin')));
    });

    testWidgets('tapping a row updates the button count', (tester) async {
      final vodka = _entry('Vodka', BarSection.spirits);
      final bar = await barWithEntries([vodka]);

      await pumpRanOut(tester, bar: bar, args: const RanOutArgs());

      expect(find.text(en.ranOutUpdate(0)), findsOneWidget);

      await tester.tap(find.text('Vodka'));
      await tester.pump();

      expect(find.text(en.ranOutUpdate(1)), findsOneWidget);
    });

    testWidgets('Update my bar marks it gone and lists it under the party name', (
      tester,
    ) async {
      final vodka = _entry('Vodka', BarSection.spirits);
      final bar = await barWithEntries([vodka]);

      await pumpRanOut(
        tester,
        bar: bar,
        args: const RanOutArgs(partyName: "Kate's Birthday"),
      );

      await tester.tap(find.text('Vodka'));
      await tester.pump();
      await tester.tap(find.text(en.ranOutUpdate(1)));
      await tester.pumpAndSettle();

      expect(bar.ranOut.map((item) => item.key), contains(vodka.key));
      final listed = bar.shoppingList.where((entry) => entry.key == vodka.key).single;
      expect(listed.reason, ShoppingReason.ranOut);
      expect(listed.context, "Kate's Birthday");
    });

    testWidgets('an empty shelf only offers the way out', (tester) async {
      final bar = BarProvider();
      await bar.initialize();

      await pumpRanOut(tester, bar: bar, args: const RanOutArgs());

      expect(find.text(en.ranOutEmpty), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
      expect(find.text(en.ranOutNothing), findsOneWidget);
    });

    for (final MapEntry(key: device, value: size) in _sizes.entries) {
      for (final scale in _textScales) {
        testWidgets('lays out on a $device at ${scale}x text', (tester) async {
          final bar = await barWithEntries([
            _entry('Vodka', BarSection.spirits),
            _entry('Cointreau', BarSection.spirits),
            _entry('Lime', BarSection.fresh),
            _entry('Mint', BarSection.fresh),
            _entry('Soda water', BarSection.mixers),
          ]);

          await pumpRanOut(
            tester,
            bar: bar,
            args: RanOutArgs(
              partyName: "Kate's Birthday",
              drinksPoured: 31,
              pourCounts: {barKey('Vodka'): 11, barKey('Cointreau'): 8},
            ),
            size: size,
            textScale: scale,
          );

          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('screen 09 · two away', () {
    final gin = _ingredient('gin');
    final tonic = _ingredient('tonic');
    final lime = _ingredient('lime');
    final mint = _ingredient('mint', category: IngredientCategory.herb);

    Cocktail missingTwoOfFour() =>
        _cocktail('midnight-orchard', ingredients: [gin, tonic, lime, mint]);

    Future<BarProvider> barHoldingGinAndTonic() async {
      final bar = BarProvider();
      await bar.initialize();
      await bar.addIngredient(gin);
      await bar.addIngredient(tonic);
      return bar;
    }

    Future<void> openSheet(
      WidgetTester tester, {
      required BarProvider bar,
      required Cocktail cocktail,
    }) async {
      await pumpPlain(
        tester,
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showTwoAwaySheet(context, cocktail),
                child: const Text('open'),
              ),
            ),
          ),
        ),
        bar: bar,
        explore: ExploreProvider(repository: _FakeCocktailRepository([cocktail])),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('names the missing bottles and how close the shelf is', (
      tester,
    ) async {
      final bar = await barHoldingGinAndTonic();
      final cocktail = missingTwoOfFour();

      await openSheet(tester, bar: bar, cocktail: cocktail);

      expect(find.text(en.twoAwayTitle(2, 4)), findsOneWidget);
      expect(find.text('Lime'), findsOneWidget);
      expect(find.text('Mint'), findsOneWidget);
    });

    testWidgets('"Add both to my list" lists both missing bottles for this drink', (
      tester,
    ) async {
      final bar = await barHoldingGinAndTonic();
      final cocktail = missingTwoOfFour();

      await openSheet(tester, bar: bar, cocktail: cocktail);

      await tester.tap(find.text(en.twoAwayAddToList(2)));
      await tester.pumpAndSettle();

      for (final ingredient in [lime, mint]) {
        final key = BarCatalogueEntry.fromIngredient(ingredient).key;
        final listed = bar.shoppingList.where((entry) => entry.key == key).single;
        expect(listed.reason, ShoppingReason.recipe);
        expect(listed.context, 'midnight-orchard');
      }
    });

    testWidgets('"I actually have these" stocks both and the drink becomes makeable', (
      tester,
    ) async {
      final bar = await barHoldingGinAndTonic();
      final cocktail = missingTwoOfFour();

      await openSheet(tester, bar: bar, cocktail: cocktail);

      await tester.tap(find.text(en.twoAwayHaveThese));
      await tester.pumpAndSettle();

      expect(makeabilityOf(cocktail, bar.shelf).isMakeable, isTrue);
    });

    for (final MapEntry(key: device, value: size) in _sizes.entries) {
      for (final scale in _textScales) {
        testWidgets('the sheet holds on a $device at ${scale}x text', (tester) async {
          final bar = await barHoldingGinAndTonic();
          final cocktail = missingTwoOfFour();

          await pumpPlain(
            tester,
            Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => showTwoAwaySheet(context, cocktail),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
            bar: bar,
            explore: ExploreProvider(repository: _FakeCocktailRepository([cocktail])),
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

  group('the two-away entry on the cocktail sheet', () {
    final gin = _ingredient('gin');
    final tonic = _ingredient('tonic');
    final lime = _ingredient('lime');
    final mint = _ingredient('mint', category: IngredientCategory.herb);

    Widget sheetFor(Cocktail cocktail) => Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
        child: SingleChildScrollView(child: CocktailSheetContent(cocktail: cocktail)),
      ),
    );

    testWidgets('shows for a cocktail two bottles short', (tester) async {
      final bar = BarProvider();
      await bar.initialize();
      await bar.addIngredient(gin);
      await bar.addIngredient(tonic);

      final cocktail = _cocktail('midnight-orchard', ingredients: [gin, tonic, lime, mint]);

      await pumpPlain(tester, sheetFor(cocktail), bar: bar);

      expect(find.text(en.twoAwayPrompt(2)), findsOneWidget);
    });

    testWidgets('stays out of the way for a cocktail one bottle short', (
      tester,
    ) async {
      final bar = BarProvider();
      await bar.initialize();
      await bar.addIngredient(gin);

      final cocktail = _cocktail('gin-tonic', ingredients: [gin, tonic]);

      await pumpPlain(tester, sheetFor(cocktail), bar: bar);

      // The one-away nudge fires instead — never both at once.
      expect(find.textContaining('things short'), findsNothing);
      expect(find.text(en.cocktailAddToBarPlain('Tonic')), findsOneWidget);
    });
  });
}
