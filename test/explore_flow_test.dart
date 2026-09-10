import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:party_bar/models/models.dart';
import 'package:party_bar/providers/bar_provider.dart';

/// The rules flow 02 rests on: what the shelf can pour, what one filter drops,
/// and what order the result comes back in. All three are answered on the
/// device, so all three are worth pinning down here.

Ingredient _ingredient(String id, {String? slug, int? unlocks}) => Ingredient(
  id: id,
  title: {'en': id},
  category: IngredientCategory.spirit,
  slug: slug,
  unlocks: unlocks,
);

Cocktail _cocktail(
  String id, {
  List<Ingredient> ingredients = const [],
  Map<String, IngredientMeasure> measures = const {},
  CocktailMethod? method,
  BaseSpirit? baseSpirit,
  int? prepTimeMinutes,
  int? popularity,
  int? seasonalScore,
}) => Cocktail(
  id: id,
  title: {'en': id},
  description: const {'en': ''},
  image: '',
  categories: const [],
  ingredients: ingredients,
  equipments: const [],
  measures: measures,
  method: method,
  baseSpirit: baseSpirit,
  prepTimeMinutes: prepTimeMinutes,
  popularity: popularity,
  seasonalScore: seasonalScore,
);

void main() {
  group('bar keys', () {
    test('fold the spellings the shelf and the catalogue disagree on', () {
      expect(barKey('sweetVermouth'), barKey('sweet-vermouth'));
      expect(barKey('Sweet Vermouth'), barKey('sweet_vermouth'));
    });

    test('let an explicit slug stand in for the document id', () {
      final ingredient = _ingredient('c7f21a', slug: 'gin');
      expect(ingredientKeys(ingredient), contains('gin'));
      expect(ingredientKeys(ingredient), contains('c7f21a'));
    });
  });

  group('makeability', () {
    final gin = _ingredient('gin');
    final tonic = _ingredient('tonic');
    final lime = _ingredient('lime', unlocks: 11);

    test('is unknown, not true, when the recipe lists nothing', () {
      final verdict = makeabilityOf(_cocktail('mystery'), {'gin'});

      expect(verdict.requiredCount, 0);
      expect(verdict.isMakeable, isFalse);
    });

    test('holds when every required ingredient is on the shelf', () {
      final verdict = makeabilityOf(
        _cocktail('gin-tonic', ingredients: [gin, tonic]),
        {'gin', 'tonic'},
      );

      expect(verdict.isMakeable, isTrue);
      expect(verdict.missing, isEmpty);
    });

    test('names what is missing, in recipe order', () {
      final verdict = makeabilityOf(
        _cocktail('gin-tonic', ingredients: [gin, tonic, lime]),
        {'gin'},
      );

      expect(verdict.missingCount, 2);
      expect(verdict.missing.first.id, 'tonic');
      expect(verdict.isOneAway, isFalse);
    });

    test('does not let an optional garnish block the drink', () {
      final verdict = makeabilityOf(
        _cocktail(
          'gin-tonic',
          ingredients: [gin, tonic, lime],
          measures: {
            'lime': const IngredientMeasure(
              amount: 1,
              unit: MeasureUnit.piece,
              optional: true,
            ),
          },
        ),
        {'gin', 'tonic'},
      );

      expect(verdict.isMakeable, isTrue);
    });
  });

  group('near misses', () {
    test('rank by what the missing bottle unlocks, best first', () {
      final gin = _ingredient('gin');
      final lime = _ingredient('lime', unlocks: 11);
      final campari = _ingredient('campari', unlocks: 3);

      final misses = nearMisses(
        [
          _cocktail('bitter-highball', ingredients: [gin, campari]),
          _cocktail('gimlet', ingredients: [gin, lime]),
          // Two bottles short — not a near miss at all.
          _cocktail('negroni', ingredients: [lime, campari]),
        ],
        {'gin'},
      );

      expect(misses.map((miss) => miss.cocktail.id), ['gimlet', 'bitter-highball']);
      expect(misses.first.unlocks, 11);
    });
  });

  group('filters', () {
    final gin = _ingredient('gin');
    final tonic = _ingredient('tonic');
    final lime = _ingredient('lime');

    final shaken = _cocktail(
      'daiquiri',
      ingredients: [gin, lime],
      method: CocktailMethod.shaken,
      baseSpirit: BaseSpirit.rum,
      prepTimeMinutes: 4,
    );
    final built = _cocktail(
      'gin-tonic',
      ingredients: [gin, tonic],
      method: CocktailMethod.built,
      baseSpirit: BaseSpirit.gin,
      prepTimeMinutes: 2,
    );

    test('no shaker drops shaken drinks and nothing else', () {
      const filters = ExploreFilters(noShaker: true);

      expect(filters.allows(shaken, const {}), isFalse);
      expect(filters.allows(built, const {}), isTrue);
    });

    test('an unstated prep time is not counted as quick', () {
      const filters = ExploreFilters(underThreeMinutes: true);
      final unknown = _cocktail('unknown', ingredients: [gin]);

      expect(filters.allows(built, const {}), isTrue);
      expect(filters.allows(shaken, const {}), isFalse);
      expect(filters.allows(unknown, const {}), isFalse);
    });

    test('makeable-only measures against the shelf it was given', () {
      const filters = ExploreFilters(makeableOnly: true);

      expect(filters.allows(built, {'gin', 'tonic'}), isTrue);
      expect(filters.allows(built, {'gin'}), isFalse);
    });

    test('every active filter is representable as a removable chip', () {
      const filters = ExploreFilters(
        makeableOnly: true,
        spirits: {BaseSpirit.gin, BaseSpirit.rum},
        noShaker: true,
      );

      expect(filters.activeCount, 4);
      expect(filters.tags.length, filters.activeCount);

      final withoutGin = filters.without(
        const ExploreFilterTag(ExploreFilterKind.spirit, spirit: BaseSpirit.gin),
      );
      expect(withoutGin.spirits, {BaseSpirit.rum});
      expect(withoutGin.activeCount, 3);
    });

    test('clearing every chip lands back on the empty filter', () {
      var filters = const ExploreFilters(
        makeableOnly: true,
        underThreeMinutes: true,
        threeIngredientsMax: true,
        spirits: {BaseSpirit.vodka},
      );

      for (final tag in filters.tags) {
        filters = filters.without(tag);
      }

      expect(filters.isEmpty, isTrue);
    });
  });

  group('sorting', () {
    final gin = _ingredient('gin');
    final lime = _ingredient('lime');

    final pourable = _cocktail(
      'pourable',
      ingredients: [gin],
      popularity: 1,
      seasonalScore: 1,
    );
    final oneAway = _cocktail(
      'one-away',
      ingredients: [gin, lime],
      popularity: 9,
      seasonalScore: 9,
    );

    test('makeable-first outranks popularity', () {
      final ordered = sortCocktails(
        [oneAway, pourable],
        ExploreSort.makeable,
        {'gin'},
      );

      expect(ordered.map((c) => c.id), ['pourable', 'one-away']);
    });

    test('popular ignores the shelf entirely', () {
      final ordered = sortCocktails(
        [pourable, oneAway],
        ExploreSort.popular,
        {'gin'},
      );

      expect(ordered.map((c) => c.id), ['one-away', 'pourable']);
    });

    test('an unranked drink sorts last rather than first', () {
      final unranked = _cocktail('unranked', ingredients: [gin]);

      final ordered = sortCocktails(
        [unranked, pourable],
        ExploreSort.popular,
        const {},
      );

      expect(ordered.last.id, 'unranked');
    });
  });

  group('default sort', () {
    test('is makeable-first only once there is a shelf to measure against', () {
      expect(defaultSortFor(hasShelf: true), ExploreSort.makeable);
      expect(defaultSortFor(hasShelf: false), ExploreSort.popular);
    });
  });

  group('the shelf', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('adopts what the first run collected, once', () async {
      SharedPreferences.setMockInitialValues({
        'onboarding_bottles': ['gin', 'sweetVermouth'],
      });

      final bar = BarProvider();
      await bar.initialize();

      expect(bar.bottleCount, 2);
      expect(bar.holdsKey('sweet-vermouth'), isTrue);
    });

    test('ignores onboarding once it has a shelf of its own', () async {
      SharedPreferences.setMockInitialValues({
        'bar_shelf': ['gin'],
        'onboarding_bottles': ['gin', 'vodka', 'lime'],
      });

      final bar = BarProvider();
      await bar.initialize();

      expect(bar.bottleCount, 1);
      expect(bar.holdsKey('vodka'), isFalse);
    });

    test('holds an ingredient by either of its names', () async {
      final bar = BarProvider();
      await bar.initialize();
      await bar.add('sweetVermouth');

      expect(bar.holds(_ingredient('sweet-vermouth')), isTrue);
      expect(bar.holds(_ingredient('9a2b', slug: 'sweetVermouth')), isTrue);
      expect(bar.holds(_ingredient('gin')), isFalse);
    });
  });
}
