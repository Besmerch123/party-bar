import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:party_bar/providers/bar_provider.dart';
import 'package:party_bar/providers/explore_provider.dart';
import 'package:party_bar/providers/locale_provider.dart';
import 'package:party_bar/screens/bar/bar_search_screen.dart';
import 'package:party_bar/screens/bar/shopping_list_screen.dart';
import 'package:party_bar/services/elastic_service.dart';
import 'package:party_bar/theme/theme.dart';
import 'package:party_bar/widgets/bar/share_list_sheet.dart';

/// Flow 04 screens 02 (search & add), 06 (shopping list) and 07 (share as
/// text). No Firebase reaches these tests: [BarProvider] gets a fake
/// catalogue source, and the couple of cases that need [ExploreProvider] hand
/// it a fake cocktail repository instead of the real, Firestore-backed one.

const _sizes = <String, Size>{
  'iPhone 14 Pro': Size(390, 844),
  'small phone': Size(320, 568),
};
const _textScales = <double>[1.0, 1.5];

/// The routes [ShoppingListScreen] and the "add something else" row fall
/// back to — literals rather than importing the real `AppRoutes`, which
/// drags in every screen in the app just for two strings.
const _myBarPath = '/bar';
const _barSearchPath = '/bar/search';

/// [CocktailRepository] reaches into Firestore from its own field
/// initialisers, so a fake has to `implements` it rather than `extends` it —
/// `implements` never runs the real constructor, it only has to answer to the
/// same public shape. Only [searchCocktails] is ever actually called by
/// [ExploreProvider] here; the rest exist purely so the class type-checks.
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

class _FakeCatalogueSource implements BarCatalogueSource {
  _FakeCatalogueSource(this.entries);

  final List<BarCatalogueEntry> entries;

  @override
  Future<List<BarCatalogueEntry>> load() async => entries;
}

BarCatalogueEntry _entry(String name, BarSection section, {int? cocktailCount}) =>
    BarCatalogueEntry(
      key: barKey(name),
      kind: BarItemKind.ingredient,
      section: section,
      title: {'en': name},
      cocktailCount: cocktailCount,
    );

Ingredient _ingredient(
  String id, {
  IngredientCategory category = IngredientCategory.spirit,
}) => Ingredient(id: id, title: {'en': id}, category: category);

Cocktail _cocktail(String id, {required List<Ingredient> ingredients}) => Cocktail(
  id: id,
  title: {'en': id},
  description: const {'en': ''},
  image: '',
  categories: const [],
  ingredients: ingredients,
  equipments: const [],
);

/// The three bottles most of these tests search over: two that share a
/// prefix, one that does not — enough to prove ranking and highlighting
/// without a real catalogue.
List<BarCatalogueEntry> _catalogue() => [
  _entry('Cointreau', BarSection.spirits, cocktailCount: 22),
  _entry('Cointreau Blood Orange', BarSection.spirits),
  _entry('Triple sec', BarSection.spirits),
];

Future<BarProvider> _barWithCatalogue({List<BarCatalogueEntry>? catalogue}) async {
  final bar = BarProvider(catalogue: _FakeCatalogueSource(catalogue ?? _catalogue()));
  await bar.initialize();
  await bar.loadCatalogue();
  return bar;
}

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

    // The test binding has no engine behind it, so a platform channel call
    // that nobody answers — `Clipboard.setData`, from the share sheet's copy
    // action — would hang forever rather than complete or throw.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
  });

  /// A plain host — no router — for [BarSearchScreen] (it only ever calls
  /// `Navigator.maybePop`) and for the share sheet (a modal route of its
  /// own). Always carries an [ExploreProvider] because the search screen
  /// reads one in its post-frame callback even though it never renders
  /// anything from it.
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
          ChangeNotifierProvider.value(
            value: explore ?? ExploreProvider(repository: _FakeCocktailRepository()),
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
          home: child,
        ),
      ),
    );
    await tester.pump();
  }

  /// [ShoppingListScreen] calls real go_router extensions (`context.pop`,
  /// `context.go`, `context.push`), so it needs an actual [GoRouter] under
  /// it rather than a bare [Navigator].
  Future<void> pumpShoppingList(
    WidgetTester tester, {
    required BarProvider bar,
    required ExploreProvider explore,
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
        GoRoute(path: '/', builder: (context, state) => const ShoppingListScreen()),
        GoRoute(
          path: _myBarPath,
          builder: (context, state) => const Scaffold(body: SizedBox()),
        ),
        GoRoute(
          path: _barSearchPath,
          builder: (context, state) => const Scaffold(body: SizedBox()),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider.value(value: bar),
          ChangeNotifierProvider.value(value: explore),
        ],
        child: MaterialApp.router(
          theme: AppTheme.dark,
          routerConfig: router,
          localizationsDelegates: _delegates,
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

  /// The [Text] behind a [BarRow] title is always built with `Text.rich`, so
  /// this finds the one whose resolved name contains [containing] — used to
  /// dig into the [TextSpan] tree and check what got highlighted.
  Text richTitleContaining(WidgetTester tester, String containing) {
    final matches = tester
        .widgetList<Text>(find.byWidgetPredicate((widget) => widget is Text && widget.textSpan != null))
        .where((text) => text.textSpan!.toPlainText().contains(containing));
    return matches.first;
  }

  bool hasHighlightedRun(Text text, String run) {
    var found = false;
    text.textSpan!.visitChildren((span) {
      if (span is TextSpan &&
          span.text == run &&
          span.style?.color == AppColors.signalLight) {
        found = true;
      }
      return true;
    });
    return found;
  }

  group('02 · search & add', () {
    testWidgets('a fragment ranks the matching bottles, highlights the hit and offers the custom card', (
      tester,
    ) async {
      final bar = await _barWithCatalogue();
      await pumpPlain(tester, const BarSearchScreen(), bar: bar);

      await tester.enterText(find.byType(TextField), 'cointr');
      await tester.pump();

      // "Triple sec" does not contain "cointr" — only the two Cointreaus do.
      expect(find.text(l10n.barSearchMatches(2).toUpperCase()), findsOneWidget);

      final title = richTitleContaining(tester, 'Cointreau');
      expect(hasHighlightedRun(title, 'Cointr'), isTrue);

      expect(find.text(l10n.barAddCustom('cointr')), findsOneWidget);
    });

    testWidgets('tapping add stocks the bottle in place and the row flips to stocked', (
      tester,
    ) async {
      final bar = await _barWithCatalogue();
      await pumpPlain(tester, const BarSearchScreen(), bar: bar);

      await tester.enterText(find.byType(TextField), 'cointreau blood');
      await tester.pump();

      expect(bar.holdsKey('Cointreau Blood Orange'), isFalse);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(bar.holdsKey('Cointreau Blood Orange'), isTrue);
      // Still on the search screen, and the row now reads as already stocked.
      expect(find.byType(BarSearchScreen), findsOneWidget);
      expect(find.text(l10n.barAlreadyOnShelf), findsOneWidget);
    });

    testWidgets('a bottle already on the shelf reads as already on the shelf', (
      tester,
    ) async {
      final bar = await _barWithCatalogue();
      await bar.add('Triple sec');
      await pumpPlain(tester, const BarSearchScreen(), bar: bar);

      await tester.enterText(find.byType(TextField), 'triple');
      await tester.pump();

      expect(find.text(l10n.barAlreadyOnShelf), findsOneWidget);
    });

    testWidgets('the custom card adds a bottle by that name and clears the field', (
      tester,
    ) async {
      final bar = await _barWithCatalogue();
      await pumpPlain(tester, const BarSearchScreen(), bar: bar);

      await tester.enterText(find.byType(TextField), 'Zzz Fancy Gin');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pumpAndSettle();

      expect(bar.holdsKey('Zzz Fancy Gin'), isTrue);
      // Clearing the field drops straight back to the starter suggestions.
      expect(find.text(l10n.barStartersSection.toUpperCase()), findsOneWidget);
    });

    testWidgets('list mode adds a match straight to the shopping list, reason manual', (
      tester,
    ) async {
      final bar = await _barWithCatalogue();
      await pumpPlain(tester, const BarSearchScreen(mode: BarSearchMode.list), bar: bar);

      await tester.enterText(find.byType(TextField), 'triple');
      await tester.pump();

      expect(bar.isOnList(barKey('Triple sec')), isFalse);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      final listed = bar.shoppingList.singleWhere((e) => e.key == barKey('Triple sec'));
      expect(listed.reason, ShoppingReason.manual);
    });

    for (final MapEntry(key: device, value: size) in _sizes.entries) {
      for (final scale in _textScales) {
        testWidgets('lays out results on a $device at ${scale}x text', (tester) async {
          final bar = await _barWithCatalogue();
          await pumpPlain(tester, const BarSearchScreen(), bar: bar, size: size, textScale: scale);

          await tester.enterText(find.byType(TextField), 'cointr');
          await tester.pump();

          expect(tester.takeException(), isNull);
        });

        testWidgets('lays out the starter suggestions on a $device at ${scale}x text', (
          tester,
        ) async {
          final bar = await _barWithCatalogue();
          await pumpPlain(tester, const BarSearchScreen(), bar: bar, size: size, textScale: scale);
          await tester.pump();

          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('06 · shopping list', () {
    testWidgets('ticking a row stocks it and shows it is now on the shelf', (tester) async {
      final bar = await _barWithCatalogue(catalogue: []);
      await bar.addToList(_entry('Lime', BarSection.fresh), reason: ShoppingReason.manual);
      final explore = ExploreProvider(repository: _FakeCocktailRepository());
      await explore.load();

      await pumpShoppingList(tester, bar: bar, explore: explore);

      expect(bar.holdsKey('Lime'), isFalse);

      await tester.tap(find.text('Lime'));
      await tester.pump();

      expect(bar.holdsKey('Lime'), isTrue);
      expect(find.text(l10n.shoppingListNowOnShelf), findsOneWidget);
    });

    testWidgets('clearing the ticked ones leaves the rest of the list alone', (tester) async {
      final bar = await _barWithCatalogue(catalogue: []);
      await bar.addToList(_entry('Lime', BarSection.fresh), reason: ShoppingReason.manual);
      await bar.addToList(_entry('Mint', BarSection.fresh), reason: ShoppingReason.manual);
      await bar.toggleTick(barKey('Lime'));

      final explore = ExploreProvider(repository: _FakeCocktailRepository());
      await explore.load();

      await pumpShoppingList(tester, bar: bar, explore: explore);

      await tester.tap(find.text(l10n.shoppingListClearTicked));
      await tester.pump();

      expect(bar.shoppingList.map((e) => e.key).toList(), [barKey('Mint')]);
    });

    testWidgets('an entry that is the only thing blocking a fetched cocktail gets its own section', (
      tester,
    ) async {
      final gin = _ingredient('gin');
      final tonic = _ingredient('tonic', category: IngredientCategory.mixer);
      final cocktail = _cocktail('gin-tonic', ingredients: [gin, tonic]);

      final bar = await _barWithCatalogue(catalogue: []);
      await bar.addIngredient(gin);
      await bar.addToList(BarCatalogueEntry.fromIngredient(tonic), reason: ShoppingReason.manual);

      final explore = ExploreProvider(repository: _FakeCocktailRepository([cocktail]));
      await explore.load();

      await pumpShoppingList(tester, bar: bar, explore: explore);

      expect(
        find.text('${l10n.shoppingListBlockingHeader} · 1'.toUpperCase()),
        findsOneWidget,
      );
      expect(find.text(l10n.shoppingListBlockingLine(1)), findsOneWidget);
    });

    testWidgets('an empty list still offers a way to add something', (tester) async {
      final bar = await _barWithCatalogue(catalogue: []);
      final explore = ExploreProvider(repository: _FakeCocktailRepository());
      await explore.load();

      await pumpShoppingList(tester, bar: bar, explore: explore);

      // shoppingListEmptyTitle and the zero-count subtitle happen to share
      // the same English copy ("Nothing to buy"), so the body line is the
      // one that actually pins down the empty state.
      expect(find.text(l10n.shoppingListEmptyBody), findsOneWidget);
      expect(find.text(l10n.shoppingListAddSomething), findsOneWidget);
    });

    for (final MapEntry(key: device, value: size) in _sizes.entries) {
      for (final scale in _textScales) {
        testWidgets('lays out an empty list on a $device at ${scale}x text', (tester) async {
          final bar = await _barWithCatalogue(catalogue: []);
          final explore = ExploreProvider(repository: _FakeCocktailRepository());
          await explore.load();

          await pumpShoppingList(tester, bar: bar, explore: explore, size: size, textScale: scale);

          expect(tester.takeException(), isNull);
        });

        testWidgets('lays out a populated list on a $device at ${scale}x text', (
          tester,
        ) async {
          final gin = _ingredient('gin');
          final tonic = _ingredient('tonic', category: IngredientCategory.mixer);
          final cocktail = _cocktail('gin-tonic', ingredients: [gin, tonic]);

          final bar = await _barWithCatalogue(catalogue: []);
          await bar.addIngredient(gin);
          await bar.addToList(
            BarCatalogueEntry.fromIngredient(tonic),
            reason: ShoppingReason.manual,
          );
          await bar.addToList(
            _entry('Crushed ice', BarSection.ice),
            reason: ShoppingReason.ranOut,
            context: "Kate's Birthday",
          );
          await bar.toggleTick(barKey('Crushed ice'));

          final explore = ExploreProvider(repository: _FakeCocktailRepository([cocktail]));
          await explore.load();

          await pumpShoppingList(tester, bar: bar, explore: explore, size: size, textScale: scale);

          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('07 · share as text', () {
    Future<void> openSheet(WidgetTester tester, {required BarProvider bar}) async {
      await pumpPlain(
        tester,
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showShareListSheet(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
        bar: bar,
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('the preview only grows a reason once "include why" is switched on', (
      tester,
    ) async {
      final bar = await _barWithCatalogue(catalogue: []);
      await bar.addToList(_entry('Lime', BarSection.fresh), reason: ShoppingReason.manual);
      await bar.addToList(
        _entry('Soda water', BarSection.mixers),
        reason: ShoppingReason.ranOut,
        context: "Kate's Birthday",
      );

      await openSheet(tester, bar: bar);

      expect(find.text('Lime'), findsOneWidget);
      expect(find.textContaining(l10n.shoppingListAddedByYou), findsNothing);
      expect(find.textContaining(l10n.shoppingListRanOutAt("Kate's Birthday")), findsNothing);

      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(find.textContaining(l10n.shoppingListAddedByYou), findsOneWidget);
      expect(find.textContaining(l10n.shoppingListRanOutAt("Kate's Birthday")), findsOneWidget);
    });

    testWidgets('ticked entries never show up in the preview', (tester) async {
      final bar = await _barWithCatalogue(catalogue: []);
      await bar.addToList(_entry('Lime', BarSection.fresh), reason: ShoppingReason.manual);
      await bar.addToList(_entry('Mint', BarSection.fresh), reason: ShoppingReason.manual);
      await bar.toggleTick(barKey('Mint'));

      await openSheet(tester, bar: bar);

      expect(find.text('Lime'), findsOneWidget);
      expect(find.text('Mint'), findsNothing);
    });

    testWidgets('copy puts the exact preview text on the clipboard', (tester) async {
      final bar = await _barWithCatalogue(catalogue: []);
      await bar.addToList(_entry('Lime', BarSection.fresh), reason: ShoppingReason.manual);

      await openSheet(tester, bar: bar);
      await tester.tap(find.text(l10n.shareListCopy));
      // The copy handler awaits Clipboard.setData before showing the
      // SnackBar, so the confirmation needs a frame beyond the tap itself.
      await tester.pump();
      await tester.pump();

      expect(find.text(l10n.shareListCopied), findsOneWidget);
    });

    for (final MapEntry(key: device, value: size) in _sizes.entries) {
      for (final scale in _textScales) {
        testWidgets('lays out on a $device at ${scale}x text', (tester) async {
          final bar = await _barWithCatalogue(catalogue: []);
          await bar.addToList(_entry('Lime', BarSection.fresh), reason: ShoppingReason.manual);
          await bar.addToList(
            _entry('Soda water', BarSection.mixers),
            reason: ShoppingReason.ranOut,
            context: "Kate's Birthday",
          );

          await pumpPlain(
            tester,
            Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => showShareListSheet(context),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
            bar: bar,
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
