/// The list a host actually buys from.
///
/// A ran-out bottle, a recipe short one ingredient, a thing typed in by
/// hand while walking the aisles — three different reasons to want
/// something, one flat list. [ShoppingEntry] keeps the reason and, where it
/// matters, the story ("ran out at Kate's Birthday", "for the Old
/// Fashioned") so the list can explain itself later without anyone
/// remembering why they added it.
library;

import 'bar_item.dart';
import 'recipe.dart' show enumByName;
import 'shared_types.dart';

/// Why something ended up on the list.
enum ShoppingReason { ranOut, recipe, manual }

class ShoppingEntry {
  const ShoppingEntry({
    required this.key,
    required this.kind,
    required this.section,
    this.sourceId,
    this.starterId,
    this.title = const {},
    this.image,
    required this.reason,
    this.context,
    this.ticked = false,
    required this.addedAt,
  });

  final String key;
  final BarItemKind kind;
  final BarSection section;
  final String? sourceId;
  final String? starterId;
  final Map<String, String> title;
  final String? image;
  final ShoppingReason reason;

  /// The party name for [ShoppingReason.ranOut], the cocktail name for
  /// [ShoppingReason.recipe]. Unused for a manual add.
  final String? context;

  /// Ticking moves the item onto the shelf; the entry stays until cleared.
  final bool ticked;
  final DateTime addedAt;

  factory ShoppingEntry.fromEntry(
    BarCatalogueEntry entry, {
    required ShoppingReason reason,
    String? context,
    required DateTime now,
  }) => ShoppingEntry(
    key: entry.key,
    kind: entry.kind,
    section: entry.section,
    sourceId: entry.sourceId,
    starterId: entry.starterId,
    title: entry.title,
    image: entry.image,
    reason: reason,
    context: context,
    addedAt: now,
  );

  BarCatalogueEntry toEntry() => BarCatalogueEntry(
    key: key,
    kind: kind,
    section: section,
    sourceId: sourceId,
    starterId: starterId,
    title: title,
    image: image,
  );

  ShoppingEntry copyWith({
    ShoppingReason? reason,
    String? context,
    bool clearContext = false,
    bool? ticked,
  }) => ShoppingEntry(
    key: key,
    kind: kind,
    section: section,
    sourceId: sourceId,
    starterId: starterId,
    title: title,
    image: image,
    reason: reason ?? this.reason,
    context: clearContext ? null : (context ?? this.context),
    ticked: ticked ?? this.ticked,
    addedAt: addedAt,
  );

  Map<String, dynamic> toJson() => {
    'key': key,
    'kind': kind.name,
    'section': section.name,
    if (sourceId != null) 'sourceId': sourceId,
    if (starterId != null) 'starterId': starterId,
    if (title.isNotEmpty) 'title': title,
    if (image != null) 'image': image,
    'reason': reason.name,
    if (context != null) 'context': context,
    'ticked': ticked,
    'addedAt': addedAt.toIso8601String(),
  };

  factory ShoppingEntry.fromJson(Map<String, dynamic> json) => ShoppingEntry(
    key: json['key'] as String,
    kind: enumByName(BarItemKind.values, json['kind']) ?? BarItemKind.ingredient,
    section: enumByName(BarSection.values, json['section']) ?? BarSection.other,
    sourceId: json['sourceId'] as String?,
    starterId: json['starterId'] as String?,
    title: json['title'] == null
        ? const {}
        : Map<String, String>.from(json['title'] as Map),
    image: json['image'] as String?,
    reason: enumByName(ShoppingReason.values, json['reason']) ?? ShoppingReason.manual,
    context: json['context'] as String?,
    ticked: json['ticked'] as bool? ?? false,
    // Stored locally as ISO-8601 (see [toJson]); read through the same
    // tolerant codec as Firestore dates.
    addedAt: firestoreDateOr(
      json['addedAt'],
      DateTime.fromMillisecondsSinceEpoch(0),
    ),
  );
}

/// Plain-text rendering for screen 07 — "share the list" needs no app on the
/// other end, so this is deliberately not markdown or HTML.
///
/// Only unticked entries print: a ticked one is already on the shelf, and a
/// list that still asked someone to buy it would be lying. [nameOf] resolves
/// display names because l10n lives in the UI, not here; [whyOf], when
/// given, appends " — " and the reason to a line.
String shoppingListText(
  List<ShoppingEntry> entries, {
  required String heading,
  required String Function(ShoppingEntry entry) nameOf,
  String? Function(ShoppingEntry entry)? whyOf,
  String? footer,
}) {
  final lines = <String>[heading, ''];

  for (final entry in entries.where((entry) => !entry.ticked)) {
    final why = whyOf?.call(entry);
    lines.add(
      why == null || why.isEmpty ? nameOf(entry) : '${nameOf(entry)} — $why',
    );
  }

  if (footer != null && footer.isNotEmpty) {
    lines.add('');
    lines.add(footer);
  }

  return lines.join('\n');
}
