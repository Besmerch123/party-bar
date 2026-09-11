/// What actually sits on a shelf.
///
/// Flow 04 is deliberately binary — a bottle is in the bar or it is not, no
/// levels, no millilitres — but "in the bar" still has to remember three
/// things a bare [Set<String>] cannot: when it arrived (for "added just
/// now"), whether it ran out (so it drops to its own group instead of
/// vanishing), and the odd note a host leaves themselves ("Bombay
/// Sapphire"). [BarItem] is that record; [BarCatalogueEntry] is the lighter
/// shape search results and starters come in, before they are anyone's yet.
library;

import 'bar.dart';
import 'equipment.dart';
import 'ingredient.dart';
import 'onboarding.dart';
import 'recipe.dart' show enumByName;

/// Where an item sits on the shelf and which filter chip finds it.
enum BarSection { spirits, mixers, fresh, syrups, tools, ice, other }

enum BarItemStatus { stocked, ranOut }

/// What kind of thing a bar item is made from — a catalogued ingredient, a
/// piece of equipment, or a name the host typed that the catalogue has never
/// heard of.
enum BarItemKind { ingredient, equipment, custom }

/// Stocked count at which the one-time sign-in nudge becomes due.
const kBarSignInNudgeThreshold = 8;

/// "Added just now" window.
const kBarRecentlyAddedWindow = Duration(minutes: 10);

/// Folds an [IngredientCategory] onto the coarser grouping the shelf shows.
BarSection sectionForIngredient(IngredientCategory category) =>
    switch (category) {
      IngredientCategory.spirit || IngredientCategory.liqueur => BarSection.spirits,
      IngredientCategory.mixer => BarSection.mixers,
      IngredientCategory.fruit ||
      IngredientCategory.herb ||
      IngredientCategory.garnish => BarSection.fresh,
      IngredientCategory.syrup ||
      IngredientCategory.bitters ||
      IngredientCategory.spice => BarSection.syrups,
      IngredientCategory.ice => BarSection.ice,
      IngredientCategory.other => BarSection.other,
    };

/// Folds an [EquipmentKind] onto the coarser grouping the shelf shows.
BarSection sectionForEquipment(EquipmentKind kind) => switch (kind) {
  EquipmentKind.tool || EquipmentKind.glassware => BarSection.tools,
  EquipmentKind.ice => BarSection.ice,
};

/// Something that can be put on the shelf: a catalogued ingredient or piece
/// of equipment, one of the twelve starter rows, or a name the host typed.
///
/// This is the shape search results and [kShelfStarters] come in — nothing
/// here says whether it is actually on anyone's bar. [BarItem] is what an
/// entry becomes once it is.
class BarCatalogueEntry {
  const BarCatalogueEntry({
    required this.key,
    required this.kind,
    required this.section,
    this.sourceId,
    this.starterId,
    this.title = const {},
    this.image,
    this.cocktailCount,
  });

  /// The [barKey] form — the one spelling the shelf and shopping list agree
  /// on, however the catalogue re-seeds itself underneath.
  final String key;
  final BarItemKind kind;
  final BarSection section;

  /// The ingredient or equipment document id, when this came from Firestore.
  final String? sourceId;

  /// The id in [kStarterBottles] / [kShelfStarters], when this is one of the
  /// twelve suggestions. The label lives in l10n, not here.
  final String? starterId;

  /// Empty for starters (labelled from l10n) and for a custom entry before
  /// it is saved.
  final Map<String, String> title;

  /// `assets/...` renders with [Image.asset]; anything else is a network URL.
  final String? image;

  /// Catalogue-wide "in N drinks" figure. Null means unknown — print
  /// nothing rather than a number that might be wrong.
  final int? cocktailCount;

  factory BarCatalogueEntry.fromIngredient(Ingredient ingredient) =>
      BarCatalogueEntry(
        key: barKey(ingredient.slug ?? ingredient.id),
        kind: BarItemKind.ingredient,
        section: sectionForIngredient(ingredient.category),
        sourceId: ingredient.id,
        title: ingredient.title,
        image: ingredient.image,
        cocktailCount: ingredient.cocktailCount,
      );

  factory BarCatalogueEntry.fromEquipment(Equipment equipment) =>
      BarCatalogueEntry(
        key: barKey(equipment.slug ?? equipment.id),
        kind: BarItemKind.equipment,
        section: sectionForEquipment(equipment.kind),
        sourceId: equipment.id,
        title: equipment.title,
        image: equipment.image,
        cocktailCount: equipment.cocktailCount,
      );

  /// A bottle the catalogue has never heard of. Filed under "everything
  /// else" — the host is the only authority on what it is.
  factory BarCatalogueEntry.custom(String name) => BarCatalogueEntry(
    key: barKey(name),
    kind: BarItemKind.custom,
    section: BarSection.other,
    title: {'en': name, 'uk': name},
  );
}

/// The twelve rows the empty shelf offers, in design order. Figures reuse
/// [kStarterBottles]; the shaker is equipment, so it has no cocktail count of
/// its own.
///
/// `final`, not `const`: building each row means looking its figures up in
/// [kStarterBottles], and a list lookup cannot run at compile time.
final List<BarCatalogueEntry> kShelfStarters = [
  for (final id in const [
    'gin',
    'vodka',
    'whiteRum',
    'tequila',
    'whiskey',
    'tripleSec',
    'lime',
    'lemon',
    'simpleSyrup',
    'tonic',
    'sodaWater',
  ])
    _shelfStarterEntry(id),
  BarCatalogueEntry(
    key: barKey('shaker'),
    kind: BarItemKind.equipment,
    section: BarSection.tools,
    starterId: 'shaker',
  ),
];

BarCatalogueEntry _shelfStarterEntry(String id) {
  final bottle = kStarterBottles.where((b) => b.id == id).first;
  return BarCatalogueEntry(
    key: barKey(id),
    kind: BarItemKind.ingredient,
    section: starterSection(id),
    starterId: id,
    image: bottle.image,
    cocktailCount: bottle.cocktailCount,
  );
}

/// Section for any starter id, including the ones step 05 of onboarding
/// offers but the shelf's own suggestion list does not
/// (`sweetVermouth`, `angostura`, `mint`).
BarSection starterSection(String starterId) => switch (starterId) {
  'gin' ||
  'vodka' ||
  'whiteRum' ||
  'tequila' ||
  'whiskey' ||
  'tripleSec' ||
  'sweetVermouth' => BarSection.spirits,
  'tonic' || 'sodaWater' => BarSection.mixers,
  'lime' || 'lemon' || 'mint' => BarSection.fresh,
  'simpleSyrup' || 'angostura' => BarSection.syrups,
  'shaker' => BarSection.tools,
  _ => BarSection.other,
};

/// One thing on a shelf: stocked or ran out, with the note a host leaves
/// themselves and the moment it arrived.
class BarItem {
  const BarItem({
    required this.key,
    required this.kind,
    required this.section,
    this.sourceId,
    this.starterId,
    this.title = const {},
    this.image,
    this.status = BarItemStatus.stocked,
    this.note,
    required this.addedAt,
    this.statusChangedAt,
  });

  final String key;
  final BarItemKind kind;
  final BarSection section;
  final String? sourceId;
  final String? starterId;
  final Map<String, String> title;
  final String? image;
  final BarItemStatus status;
  final String? note;

  /// When this first joined the bar. Never moves — restocking a bottle that
  /// ran out does not make it a new bottle, it just flips [status] back.
  final DateTime addedAt;

  /// When [status] last flipped. Null for an item that has never run out.
  final DateTime? statusChangedAt;

  bool get isStocked => status == BarItemStatus.stocked;

  /// True for a stocked item that joined within [kBarRecentlyAddedWindow] of
  /// [now] — the design's "Added just now" badge.
  bool isRecentlyAdded(DateTime now) =>
      isStocked && now.difference(addedAt) < kBarRecentlyAddedWindow;

  factory BarItem.fromEntry(BarCatalogueEntry entry, {required DateTime now}) =>
      BarItem(
        key: entry.key,
        kind: entry.kind,
        section: entry.section,
        sourceId: entry.sourceId,
        starterId: entry.starterId,
        title: entry.title,
        image: entry.image,
        addedAt: now,
      );

  /// Back to the catalogue shape — for re-adding to a list, or for the item
  /// sheet's "unlocks for you" lookups that key off an entry, not an item.
  BarCatalogueEntry toEntry() => BarCatalogueEntry(
    key: key,
    kind: kind,
    section: section,
    sourceId: sourceId,
    starterId: starterId,
    title: title,
    image: image,
    cocktailCount: null,
  );

  /// [clearNote] is how a caller blanks the note — passing `note: null`
  /// alone would be indistinguishable from "leave it as it is".
  BarItem copyWith({
    BarItemStatus? status,
    String? note,
    bool clearNote = false,
    DateTime? statusChangedAt,
  }) => BarItem(
    key: key,
    kind: kind,
    section: section,
    sourceId: sourceId,
    starterId: starterId,
    title: title,
    image: image,
    status: status ?? this.status,
    note: clearNote ? null : (note ?? this.note),
    addedAt: addedAt,
    statusChangedAt: statusChangedAt ?? this.statusChangedAt,
  );

  Map<String, dynamic> toJson() => {
    'key': key,
    'kind': kind.name,
    'section': section.name,
    if (sourceId != null) 'sourceId': sourceId,
    if (starterId != null) 'starterId': starterId,
    if (title.isNotEmpty) 'title': title,
    if (image != null) 'image': image,
    'status': status.name,
    if (note != null) 'note': note,
    'addedAt': addedAt.toIso8601String(),
    if (statusChangedAt != null)
      'statusChangedAt': statusChangedAt!.toIso8601String(),
  };

  factory BarItem.fromJson(Map<String, dynamic> json) => BarItem(
    key: json['key'] as String,
    kind: enumByName(BarItemKind.values, json['kind']) ?? BarItemKind.ingredient,
    section: enumByName(BarSection.values, json['section']) ?? BarSection.other,
    sourceId: json['sourceId'] as String?,
    starterId: json['starterId'] as String?,
    title: json['title'] == null
        ? const {}
        : Map<String, String>.from(json['title'] as Map),
    image: json['image'] as String?,
    status: enumByName(BarItemStatus.values, json['status']) ?? BarItemStatus.stocked,
    note: json['note'] as String?,
    addedAt: DateTime.parse(json['addedAt'] as String),
    statusChangedAt: json['statusChangedAt'] == null
        ? null
        : DateTime.parse(json['statusChangedAt'] as String),
  );
}
