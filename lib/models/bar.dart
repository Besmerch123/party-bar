/// The shelf, and what it can pour.
///
/// "Makeable with my bar" is the strongest filter in the app and it works
/// signed out — so it has to be answerable on the device, from a shelf the
/// first run collected before any account existed. That shelf is a set of
/// bottle keys, not ingredient document ids: onboarding wrote `sweetVermouth`
/// long before it knew a document called `sweet-vermouth` exists.
library;

import 'cocktail.dart';
import 'equipment.dart';
import 'ingredient.dart';

/// Folds an ingredient id, a slug or a starter-bottle key onto the one
/// spelling the shelf compares on.
///
/// `sweetVermouth`, `sweet-vermouth` and `Sweet Vermouth` are the same bottle;
/// insisting they are spelled the same everywhere would mean the shelf breaks
/// the first time the catalogue is re-seeded.
String barKey(String raw) =>
    raw.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');

/// Every key an ingredient answers to. An explicit [Ingredient.slug] wins, but
/// the document id is always accepted so an un-backfilled catalogue still
/// matches.
Set<String> ingredientKeys(Ingredient ingredient) => {
  barKey(ingredient.id),
  if (ingredient.slug != null && ingredient.slug!.isNotEmpty)
    barKey(ingredient.slug!),
};

/// Every key a piece of equipment answers to, mirroring [ingredientKeys].
Set<String> equipmentKeys(Equipment equipment) => {
  barKey(equipment.id),
  if (equipment.slug != null && equipment.slug!.isNotEmpty)
    barKey(equipment.slug!),
};

/// What stands between a shelf and a finished drink.
class Makeability {
  const Makeability({required this.missing, required this.requiredCount});

  /// Required ingredients the shelf does not hold, in recipe order.
  final List<Ingredient> missing;

  /// How many ingredients the recipe actually gates on — optional garnishes
  /// excluded. Zero when the recipe lists nothing, which is why [isMakeable]
  /// checks it: an empty recipe is unknown, not pourable.
  final int requiredCount;

  bool get isMakeable => requiredCount > 0 && missing.isEmpty;

  int get missingCount => missing.length;

  /// Exactly one bottle short — the case the zero-results screen answers with.
  bool get isOneAway => missing.length == 1;

  /// How many of the required ingredients are already on the shelf.
  int get onShelfCount => requiredCount - missing.length;
}

/// Works out what [cocktail] is missing from a [shelf] of [barKey]s.
///
/// A cocktail whose ingredient list has not loaded reports `requiredCount: 0`
/// rather than "makeable" — the UI shows nothing instead of a false promise.
Makeability makeabilityOf(Cocktail cocktail, Set<String> shelf) {
  final required = cocktail.requiredIngredients;

  final missing = required
      .where((ingredient) => !ingredientKeys(ingredient).any(shelf.contains))
      .toList(growable: false);

  return Makeability(missing: missing, requiredCount: required.length);
}

/// A drink one bottle away, and the bottle in question.
class NearMiss {
  const NearMiss({required this.cocktail, required this.ingredient});

  final Cocktail cocktail;

  /// The single thing the shelf is short of.
  final Ingredient ingredient;

  /// How many other drinks that bottle would open up. Falls back to zero until
  /// the catalogue carries the figure, which sorts these last rather than
  /// inventing a number.
  int get unlocks => ingredient.unlocks ?? 0;
}

/// The drinks a shelf is exactly one bottle short of, best bottle first.
///
/// Ranked by how much the missing bottle unlocks — the open question in the
/// design was whether to rank by unlocks, by price, or by closeness to the
/// query, and unlocks is the only one the catalogue can answer today.
List<NearMiss> nearMisses(
  Iterable<Cocktail> cocktails,
  Set<String> shelf, {
  int limit = 4,
}) {
  final misses = <NearMiss>[];

  for (final cocktail in cocktails) {
    final makeability = makeabilityOf(cocktail, shelf);
    if (!makeability.isOneAway) continue;
    misses.add(
      NearMiss(cocktail: cocktail, ingredient: makeability.missing.single),
    );
  }

  misses.sort((a, b) => b.unlocks.compareTo(a.unlocks));
  return misses.take(limit).toList(growable: false);
}
