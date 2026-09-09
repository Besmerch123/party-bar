/// The state of an Explore query — what was typed, what was filtered, how it
/// is ordered.
///
/// Two rules from the flow are encoded here rather than in a widget. Every
/// active filter is representable as a removable [ExploreFilterTag], so there
/// is no filter the chip row cannot show and no state a person cannot see.
/// And the ordering falls back to [ExploreSort.popular] on an empty shelf,
/// because "makeable first" means nothing when nothing is makeable.
library;

import 'bar.dart';
import 'cocktail.dart';
import 'recipe.dart';

/// How a result set is ordered. Shown as a segmented control, never hidden in
/// a preference.
enum ExploreSort { makeable, popular, seasonal }

/// The kinds of filter the sheet offers. Each one is a chip you can pull off.
enum ExploreFilterKind {
  makeable,
  spirit,
  underThreeMinutes,
  noShaker,
  threeIngredientsMax,
}

/// One active filter, in a form the chip row can render and remove.
class ExploreFilterTag {
  const ExploreFilterTag(this.kind, {this.spirit});

  final ExploreFilterKind kind;

  /// Set only when [kind] is [ExploreFilterKind.spirit].
  final BaseSpirit? spirit;

  @override
  bool operator ==(Object other) =>
      other is ExploreFilterTag && other.kind == kind && other.spirit == spirit;

  @override
  int get hashCode => Object.hash(kind, spirit);
}

/// How long "quick" is. Three minutes is the number the filter label promises.
const kQuickPrepMinutes = 3;

/// How short "short" is, for the three-ingredients filter.
const kShortIngredientCount = 3;

/// Everything the filter sheet can set.
class ExploreFilters {
  const ExploreFilters({
    this.makeableOnly = false,
    this.spirits = const {},
    this.underThreeMinutes = false,
    this.noShaker = false,
    this.threeIngredientsMax = false,
  });

  /// Keep only drinks the shelf can already pour.
  final bool makeableOnly;

  /// Base spirits to keep. Empty means every spirit.
  final Set<BaseSpirit> spirits;

  final bool underThreeMinutes;
  final bool noShaker;
  final bool threeIngredientsMax;

  static const empty = ExploreFilters();

  bool get isEmpty => activeCount == 0;

  /// What the count on the filter button reads.
  int get activeCount =>
      (makeableOnly ? 1 : 0) +
      spirits.length +
      (underThreeMinutes ? 1 : 0) +
      (noShaker ? 1 : 0) +
      (threeIngredientsMax ? 1 : 0);

  /// Every active filter, in the order the chip row shows them.
  List<ExploreFilterTag> get tags => [
    if (makeableOnly) const ExploreFilterTag(ExploreFilterKind.makeable),
    for (final spirit in spirits)
      ExploreFilterTag(ExploreFilterKind.spirit, spirit: spirit),
    if (underThreeMinutes)
      const ExploreFilterTag(ExploreFilterKind.underThreeMinutes),
    if (noShaker) const ExploreFilterTag(ExploreFilterKind.noShaker),
    if (threeIngredientsMax)
      const ExploreFilterTag(ExploreFilterKind.threeIngredientsMax),
  ];

  ExploreFilters copyWith({
    bool? makeableOnly,
    Set<BaseSpirit>? spirits,
    bool? underThreeMinutes,
    bool? noShaker,
    bool? threeIngredientsMax,
  }) {
    return ExploreFilters(
      makeableOnly: makeableOnly ?? this.makeableOnly,
      spirits: spirits ?? this.spirits,
      underThreeMinutes: underThreeMinutes ?? this.underThreeMinutes,
      noShaker: noShaker ?? this.noShaker,
      threeIngredientsMax: threeIngredientsMax ?? this.threeIngredientsMax,
    );
  }

  ExploreFilters toggleSpirit(BaseSpirit spirit) {
    final next = Set<BaseSpirit>.from(spirits);
    if (!next.remove(spirit)) next.add(spirit);
    return copyWith(spirits: next);
  }

  /// Drops one chip. This is the only way a filter leaves, so the chip row and
  /// the sheet can never disagree about what is on.
  ExploreFilters without(ExploreFilterTag tag) => switch (tag.kind) {
    ExploreFilterKind.makeable => copyWith(makeableOnly: false),
    ExploreFilterKind.spirit => copyWith(
      spirits: Set<BaseSpirit>.from(spirits)..remove(tag.spirit),
    ),
    ExploreFilterKind.underThreeMinutes => copyWith(underThreeMinutes: false),
    ExploreFilterKind.noShaker => copyWith(noShaker: false),
    ExploreFilterKind.threeIngredientsMax =>
      copyWith(threeIngredientsMax: false),
  };

  /// Whether one cocktail survives these filters against [shelf].
  bool allows(Cocktail cocktail, Set<String> shelf) {
    if (makeableOnly && !makeabilityOf(cocktail, shelf).isMakeable) return false;

    if (spirits.isNotEmpty &&
        (cocktail.baseSpirit == null ||
            !spirits.contains(cocktail.baseSpirit))) {
      return false;
    }

    // An unknown prep time is not "quick". Better to drop a drink from a
    // narrow filter than to promise three minutes the catalogue never said.
    if (underThreeMinutes &&
        (cocktail.prepTimeMinutes == null ||
            cocktail.prepTimeMinutes! > kQuickPrepMinutes)) {
      return false;
    }

    if (noShaker && cocktail.method == CocktailMethod.shaken) return false;

    if (threeIngredientsMax &&
        cocktail.requiredIngredients.length > kShortIngredientCount) {
      return false;
    }

    return true;
  }
}

/// The sort a fresh Explore opens on.
///
/// Makeable-first whenever there is a shelf to measure against; popular when
/// there is not, so the first screen is never a wall of drinks you cannot make.
ExploreSort defaultSortFor({required bool hasShelf}) =>
    hasShelf ? ExploreSort.makeable : ExploreSort.popular;

/// Orders a result set for display.
///
/// The backend can order by popularity and season on its own, but only the
/// device knows the shelf — so makeable-first is finished here, grouping by
/// how many bottles are missing and breaking ties on popularity.
List<Cocktail> sortCocktails(
  List<Cocktail> cocktails,
  ExploreSort sort,
  Set<String> shelf,
) {
  final ordered = List<Cocktail>.from(cocktails);

  int byPopularity(Cocktail a, Cocktail b) =>
      (b.popularity ?? -1).compareTo(a.popularity ?? -1);

  switch (sort) {
    case ExploreSort.makeable:
      ordered.sort((a, b) {
        final missingA = makeabilityOf(a, shelf).missingCount;
        final missingB = makeabilityOf(b, shelf).missingCount;
        if (missingA != missingB) return missingA.compareTo(missingB);
        return byPopularity(a, b);
      });

    case ExploreSort.popular:
      ordered.sort(byPopularity);

    case ExploreSort.seasonal:
      ordered.sort((a, b) {
        final seasonA = a.seasonalScore ?? -1;
        final seasonB = b.seasonalScore ?? -1;
        if (seasonA != seasonB) return seasonB.compareTo(seasonA);
        return byPopularity(a, b);
      });
  }

  return ordered;
}
