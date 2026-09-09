/// Turns recipe vocabulary into the words on screen.
///
/// Kept out of the widgets because the same three facts — how long, how it is
/// built, how strong — are printed on a feed card, a search row and a detail
/// eyebrow, and they have to read identically in all three.
library;

import 'package:flutter/material.dart';

import '../generated/l10n/app_localizations.dart';
import '../models/models.dart';

/// The separator between facts on a meta line. A middle dot, never a comma:
/// these are peers, not a sentence.
const _joint = ' · ';

String methodLabel(AppLocalizations l10n, CocktailMethod method) =>
    switch (method) {
      CocktailMethod.built => l10n.methodBuilt,
      CocktailMethod.stirred => l10n.methodStirred,
      CocktailMethod.shaken => l10n.methodShaken,
      CocktailMethod.blended => l10n.methodBlended,
      CocktailMethod.layered => l10n.methodLayered,
    };

String spiritLabel(AppLocalizations l10n, BaseSpirit spirit) =>
    switch (spirit) {
      BaseSpirit.gin => l10n.spiritGin,
      BaseSpirit.vodka => l10n.spiritVodka,
      BaseSpirit.rum => l10n.spiritRum,
      BaseSpirit.whisky => l10n.spiritWhisky,
      BaseSpirit.tequila => l10n.spiritTequila,
      BaseSpirit.brandy => l10n.spiritBrandy,
      BaseSpirit.zeroProof => l10n.spiritZeroProof,
      BaseSpirit.other => l10n.spiritOther,
    };

String flavorLabel(AppLocalizations l10n, FlavorProfile flavor) =>
    switch (flavor) {
      FlavorProfile.citrus => l10n.flavorCitrus,
      FlavorProfile.bitter => l10n.flavorBitter,
      FlavorProfile.sweet => l10n.flavorSweet,
      FlavorProfile.herbal => l10n.flavorHerbal,
      FlavorProfile.spicy => l10n.flavorSpicy,
      FlavorProfile.fruity => l10n.flavorFruity,
      FlavorProfile.dry => l10n.flavorDry,
      FlavorProfile.creamy => l10n.flavorCreamy,
    };

String unitLabel(AppLocalizations l10n, MeasureUnit unit) => switch (unit) {
  MeasureUnit.ml => l10n.unitMl,
  MeasureUnit.cl => l10n.unitCl,
  MeasureUnit.oz => l10n.unitOz,
  MeasureUnit.dash => l10n.unitDash,
  MeasureUnit.barspoon => l10n.unitBarspoon,
  MeasureUnit.piece => l10n.unitPiece,
  MeasureUnit.splash => l10n.unitSplash,
  MeasureUnit.topUp => l10n.unitTopUp,
};

/// "45 ml", or just "top up" for units that carry no useful number.
String measureLabel(AppLocalizations l10n, IngredientMeasure measure) {
  final unit = unitLabel(l10n, measure.unit);
  if (!measure.unit.showsAmount) return unit;
  return l10n.measureAmount(measure.formattedAmount, unit);
}

/// The line under a cocktail's name — "5 min · stirred · 18% ABV".
///
/// Every part is optional, and the joints only appear between parts that
/// exist: a drink the catalogue knows nothing about prints nothing rather than
/// a row of empty separators.
String cocktailMeta(
  AppLocalizations l10n,
  Cocktail cocktail, {
  bool includeAbv = true,
}) {
  final parts = <String>[
    if (cocktail.prepTimeMinutes != null)
      l10n.cocktailMinutes(cocktail.prepTimeMinutes!),
    if (cocktail.method != null) methodLabel(l10n, cocktail.method!),
    if (includeAbv && cocktail.abv != null && cocktail.abv! > 0)
      l10n.cocktailAbv(_formatAbv(cocktail.abv!)),
  ];

  return parts.join(_joint);
}

/// The detail eyebrow — "CITRUS · SHAKEN". Rendered uppercase by the caller's
/// style, so the words themselves stay translatable.
String cocktailEyebrow(AppLocalizations l10n, Cocktail cocktail) {
  final parts = <String>[
    if (cocktail.flavor != null) flavorLabel(l10n, cocktail.flavor!),
    if (cocktail.method != null) methodLabel(l10n, cocktail.method!),
  ];

  return parts.join(_joint);
}

/// The label a removable filter chip carries.
String filterTagLabel(AppLocalizations l10n, ExploreFilterTag tag) =>
    switch (tag.kind) {
      ExploreFilterKind.makeable => l10n.filterChipMakeable,
      ExploreFilterKind.spirit => spiritLabel(l10n, tag.spirit!),
      ExploreFilterKind.underThreeMinutes => l10n.filterChipUnderThree,
      ExploreFilterKind.noShaker => l10n.filterChipNoShaker,
      ExploreFilterKind.threeIngredientsMax => l10n.filterChipThreeIngredients,
    };

String sortLabel(AppLocalizations l10n, ExploreSort sort) => switch (sort) {
  ExploreSort.makeable => l10n.sortMakeable,
  ExploreSort.popular => l10n.sortPopular,
  ExploreSort.seasonal => l10n.sortSeasonal,
};

/// The note beside the result count — "makeable first".
String sortNote(AppLocalizations l10n, ExploreSort sort) => switch (sort) {
  ExploreSort.makeable => l10n.resultsMakeableFirst,
  ExploreSort.popular => l10n.resultsPopularFirst,
  ExploreSort.seasonal => l10n.resultsSeasonalFirst,
};

/// The icon standing in for a base spirit where no photograph exists.
IconData spiritIcon(BaseSpirit spirit) => switch (spirit) {
  BaseSpirit.zeroProof => Icons.no_drinks_outlined,
  BaseSpirit.other => Icons.local_bar_outlined,
  _ => Icons.liquor_outlined,
};

/// 18, not 18.0 — but 18.5 survives.
String _formatAbv(double abv) =>
    abv == abv.roundToDouble() ? abv.toInt().toString() : abv.toString();
