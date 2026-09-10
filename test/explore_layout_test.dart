import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:party_bar/generated/l10n/app_localizations.dart';
import 'package:party_bar/models/models.dart';
import 'package:party_bar/providers/bar_provider.dart';
import 'package:party_bar/providers/locale_provider.dart';
import 'package:party_bar/theme/theme.dart';
import 'package:party_bar/widgets/explore/cocktail_cards.dart';
import 'package:party_bar/widgets/explore/explore_chrome.dart';
import 'package:party_bar/widgets/explore/zero_results.dart';

/// Explore's shared vocabulary carries every screen in the flow, so it has to
/// survive the two things that actually break layouts in the field: a narrow
/// phone, and someone who has turned their text up.

const _sizes = <String, Size>{
  'iPhone 14 Pro': Size(390, 844),
  'small phone': Size(320, 568),
};

/// Large enough to catch a fixed-height card that cannot hold its own words.
const _textScales = <double>[1.0, 1.5];

Ingredient _ingredient(String id, {int? unlocks}) => Ingredient(
  id: id,
  title: {'en': id},
  category: IngredientCategory.spirit,
  unlocks: unlocks,
);

/// A drink with everything filled in — the longest the meta line ever gets.
final _loaded = Cocktail(
  id: 'midnight-orchard',
  title: const {'en': 'Midnight Orchard'},
  description: const {'en': 'Dark, stirred, and gone in four sips.'},
  image: '',
  categories: const [CocktailCategory.signature],
  ingredients: [_ingredient('gin'), _ingredient('vermouth')],
  equipments: const [],
  abv: 18,
  prepTimeMinutes: 5,
  method: CocktailMethod.stirred,
  baseSpirit: BaseSpirit.gin,
  flavor: FlavorProfile.bitter,
  popularity: 9,
);

/// A drink the catalogue knows nothing about beyond its name — the cards must
/// print nothing rather than a placeholder.
final _bare = Cocktail(
  id: 'unknown',
  title: const {'en': 'A Considerably Longer Cocktail Name'},
  description: const {'en': ''},
  image: '',
  categories: const [],
  ingredients: const [],
  equipments: const [],
);

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pump(
    WidgetTester tester,
    Widget child,
    Size size,
    double textScale, {
    bool scroll = true,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => BarProvider()),
        ],
        child: MaterialApp(
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
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenEdge),
              // Cards are laid out inside a scroll view the way a feed holds
              // them; anything that scrolls on its own is given the body
              // directly, since nesting two viewports is a test bug rather
              // than a layout one.
              child: scroll
                  ? SingleChildScrollView(child: child)
                  : child,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  final shelf = {barKey('gin')};

  ShelfStatus statusFor(Cocktail cocktail) {
    final makeability = makeabilityOf(cocktail, shelf);
    return ShelfStatus(
      makeability: makeability,
      missingName: makeability.isOneAway
          ? makeability.missing.single.title['en']
          : null,
    );
  }

  final cards = <String, Widget>{
    'poster, one bottle short': CocktailPosterCard(
      cocktail: _loaded,
      status: statusFor(_loaded),
    ),
    'poster, nothing known': CocktailPosterCard(cocktail: _bare),
    'tile, one bottle short': CocktailTile(
      cocktail: _loaded,
      status: statusFor(_loaded),
    ),
    'tile, long name and no data': CocktailTile(cocktail: _bare),
    'row, one bottle short': CocktailListRow(
      cocktail: _loaded,
      status: statusFor(_loaded),
    ),
    'row, long name and no data': CocktailListRow(cocktail: _bare),
  };

  for (final MapEntry(key: name, value: card) in cards.entries) {
    for (final MapEntry(key: device, value: size) in _sizes.entries) {
      for (final scale in _textScales) {
        testWidgets('$name survives a $device at ${scale}x text', (
          tester,
        ) async {
          await pump(tester, card, size, scale);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('a card says nothing it was never told', (tester) async {
    await pump(tester, CocktailTile(cocktail: _bare), _sizes.values.first, 1.0);

    // No separator left stranded by a meta line with no parts to join.
    expect(find.textContaining('·'), findsNothing);
    expect(find.text('A Considerably Longer Cocktail Name'), findsOneWidget);
  });

  testWidgets('an empty shelf earns no verdict badge', (tester) async {
    await pump(
      tester,
      CocktailPosterCard(cocktail: _loaded),
      _sizes.values.first,
      1.0,
    );

    expect(find.textContaining('MISSING'), findsNothing);
    expect(find.textContaining('ON YOUR SHELF'), findsNothing);
  });

  group('the filter bar', () {
    const filters = ExploreFilters(
      makeableOnly: true,
      spirits: {BaseSpirit.gin, BaseSpirit.tequila},
      noShaker: true,
      underThreeMinutes: true,
    );

    for (final MapEntry(key: device, value: size) in _sizes.entries) {
      testWidgets('scrolls rather than overflowing on a $device', (
        tester,
      ) async {
        await pump(
          tester,
          const SizedBox(
            height: 40,
            child: ExploreFilterBar(
              filters: filters,
              onOpenSheet: _noop,
              onRemove: _ignoreTag,
            ),
          ),
          size,
          1.0,
        );

        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('shows one removable chip per active filter', (tester) async {
      await pump(
        tester,
        const SizedBox(
          height: 40,
          child: ExploreFilterBar(
            filters: filters,
            onOpenSheet: _noop,
            onRemove: _ignoreTag,
          ),
        ),
        const Size(900, 400),
        1.0,
      );

      expect(filters.tags.length, filters.activeCount);
      expect(find.byIcon(Icons.close), findsNWidgets(filters.activeCount));
    });
  });

  group('zero results', () {
    Widget build({required ExploreFilters filters, required String query}) {
      return ZeroResults(
        query: query,
        filters: filters,
        // Standing in for the real fetched set: nothing comes back while
        // either of these two is still on, so a single filter can only be
        // blamed when it is the only one that was on to begin with.
        previewCount: (candidate) =>
            candidate.noShaker || candidate.makeableOnly ? 0 : 3,
        nearMisses: [
          NearMiss(
            cocktail: _loaded,
            ingredient: _ingredient('coffee liqueur', unlocks: 6),
          ),
        ],
        pourableFallback: [_loaded, _bare],
        onRemoveFilter: _ignoreTag,
        onClearFilters: _noop,
      );
    }

    testWidgets('names the one filter standing in the way', (tester) async {
      await pump(
        tester,
        build(
          filters: const ExploreFilters(noShaker: true),
          query: 'espresso martini',
        ),
        _sizes.values.first,
        1.0,
        scroll: false,
      );

      expect(find.textContaining('No shaker'), findsWidgets);
      expect(find.textContaining('espresso martini'), findsOneWidget);
    });

    testWidgets('blames nothing when several filters compound', (tester) async {
      await pump(
        tester,
        build(
          // Both would still leave the list empty on their own, so neither
          // can honestly be singled out.
          filters: const ExploreFilters(noShaker: true, makeableOnly: true),
          query: 'espresso martini',
        ),
        _sizes.values.first,
        1.0,
        scroll: false,
      );

      expect(tester.takeException(), isNull);
      // The offer to drop one specific filter is withheld, not guessed at.
      expect(find.textContaining('Drop'), findsNothing);
    });

    for (final MapEntry(key: device, value: size) in _sizes.entries) {
      testWidgets('lays out on a $device', (tester) async {
        await pump(
          tester,
          build(
            filters: const ExploreFilters(noShaker: true),
            query: 'espresso martini',
          ),
          size,
          1.0,
          scroll: false,
        );

        expect(tester.takeException(), isNull);
      });
    }
  });
}

void _noop() {}

void _ignoreTag(ExploreFilterTag _) {}
