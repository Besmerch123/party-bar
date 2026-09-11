/// "38 drinks you can make" and the numbers around it.
///
/// The design is explicit that this is only ever a subtitle — no unlock
/// engine, no progress bar — but a subtitle still has to be computed
/// somewhere, and doing it once per build rather than once per row is the
/// difference between a shelf screen and a screen that recomputes a
/// makeability pass for every one of forty rows on every frame.
library;

import 'bar.dart';
import 'cocktail.dart';

/// The shelf's relationship to the catalogue, computed once per (cocktails,
/// shelf) pair and read many times.
class BarStats {
  const BarStats._({
    required this.hasCatalogue,
    required this.makeableCount,
    required Map<String, int> usedInMakeable,
    required Map<String, int> blockedBy,
    required Map<String, int> missingIn,
    required Map<String, List<Cocktail>> makeableUsing,
  }) : _usedInMakeable = usedInMakeable,
       _blockedBy = blockedBy,
       _missingIn = missingIn,
       _makeableUsing = makeableUsing;

  /// Nothing known yet — before Explore has fetched anything, print no drink
  /// figures rather than a row of zeroes pretending to be facts.
  static const empty = BarStats._(
    hasCatalogue: false,
    makeableCount: 0,
    usedInMakeable: {},
    blockedBy: {},
    missingIn: {},
    makeableUsing: {},
  );

  /// False when [compute] was given no cocktails to work from.
  final bool hasCatalogue;

  final int makeableCount;

  final Map<String, int> _usedInMakeable;
  final Map<String, int> _blockedBy;
  final Map<String, int> _missingIn;
  final Map<String, List<Cocktail>> _makeableUsing;

  factory BarStats.compute(Iterable<Cocktail> cocktails, Set<String> shelf) {
    final list = cocktails.toList(growable: false);
    if (list.isEmpty) return empty;

    final usedInMakeable = <String, int>{};
    final blockedBy = <String, int>{};
    final missingIn = <String, int>{};
    final makeableUsing = <String, List<Cocktail>>{};
    var makeableCount = 0;

    for (final cocktail in list) {
      final makeability = makeabilityOf(cocktail, shelf);

      final missingKeys = <String>{};
      for (final ingredient in makeability.missing) {
        missingKeys.addAll(ingredientKeys(ingredient));
      }
      for (final key in missingKeys) {
        missingIn[key] = (missingIn[key] ?? 0) + 1;
      }

      if (makeability.isOneAway) {
        for (final key in ingredientKeys(makeability.missing.single)) {
          blockedBy[key] = (blockedBy[key] ?? 0) + 1;
        }
      }

      if (!makeability.isMakeable) continue;
      makeableCount++;

      final usedKeys = <String>{};
      for (final ingredient in cocktail.ingredients) {
        usedKeys.addAll(ingredientKeys(ingredient));
      }
      for (final equipment in cocktail.equipments) {
        usedKeys.addAll(equipmentKeys(equipment));
      }
      for (final key in usedKeys) {
        usedInMakeable[key] = (usedInMakeable[key] ?? 0) + 1;
        makeableUsing.putIfAbsent(key, () => []).add(cocktail);
      }
    }

    // Popularity order for the item sheet's "unlocks for you" tiles; a
    // cocktail with no popularity score yet sorts last rather than first.
    for (final matches in makeableUsing.values) {
      matches.sort((a, b) {
        final scoreA = a.popularity;
        final scoreB = b.popularity;
        if (scoreA == null && scoreB == null) return 0;
        if (scoreA == null) return 1;
        if (scoreB == null) return -1;
        return scoreB.compareTo(scoreA);
      });
    }

    return BarStats._(
      hasCatalogue: true,
      makeableCount: makeableCount,
      usedInMakeable: usedInMakeable,
      blockedBy: blockedBy,
      missingIn: missingIn,
      makeableUsing: makeableUsing,
    );
  }

  /// How many makeable cocktails use [key] — ingredient or equipment.
  int usedInMakeable(String key) => _usedInMakeable[key] ?? 0;

  /// How many cocktails [key] is the *only* thing missing from — the "blocks
  /// 2 drinks" pill on a ran-out row.
  int blockedBy(String key) => _blockedBy[key] ?? 0;

  /// How many cocktails are missing [key], whether or not it is the only
  /// thing they are missing — the shopping list's "blocking" header.
  int missingIn(String key) => _missingIn[key] ?? 0;

  /// Makeable cocktails that use [key], most popular first.
  List<Cocktail> makeableUsing(String key) => _makeableUsing[key] ?? const [];
}
