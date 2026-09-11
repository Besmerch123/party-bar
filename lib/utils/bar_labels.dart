import 'package:flutter/material.dart';

import '../generated/l10n/app_localizations.dart';
import '../models/bar_item.dart';
import '../models/shared_types.dart';
import '../models/shopping_list.dart';
import 'localization_helper.dart';

/// Names and glyphs shared by every Flow 04 · My bar surface.
///
/// A bar item's name can come from three places, in order: the catalogue's
/// own [I18nField] title, a starter's l10n label (starters carry no title of
/// their own — the twelve rows and the shaker are described entirely in
/// l10n), or, for the rare legacy key neither of those knows about, the key
/// itself made presentable.

/// A starter row's label, including the equipment row onboarding never
/// offered. Moved out of `widgets/onboarding/bottles_step.dart` so the shelf
/// and onboarding read the same switch.
String starterLabel(AppLocalizations l10n, String starterId) =>
    switch (starterId) {
      'gin' => l10n.bottleGin,
      'vodka' => l10n.bottleVodka,
      'tonic' => l10n.bottleTonic,
      'lime' => l10n.bottleLime,
      'whiteRum' => l10n.bottleWhiteRum,
      'sweetVermouth' => l10n.bottleSweetVermouth,
      'whiskey' => l10n.bottleWhiskey,
      'tequila' => l10n.bottleTequila,
      'tripleSec' => l10n.bottleTripleSec,
      'lemon' => l10n.bottleLemon,
      'simpleSyrup' => l10n.bottleSimpleSyrup,
      'sodaWater' => l10n.bottleSodaWater,
      'angostura' => l10n.bottleAngostura,
      'mint' => l10n.bottleMint,
      'shaker' => l10n.bottleShaker,
      _ => _prettify(starterId),
    };

/// Filter chip label for a section — short, one word where it can be.
String barSectionLabel(AppLocalizations l10n, BarSection section) =>
    switch (section) {
      BarSection.spirits => l10n.barSectionSpirits,
      BarSection.mixers => l10n.barSectionMixers,
      BarSection.fresh => l10n.barSectionFresh,
      BarSection.syrups => l10n.barSectionSyrups,
      BarSection.tools => l10n.barSectionTools,
      BarSection.ice => l10n.barSectionIce,
      BarSection.other => l10n.barSectionOther,
    };

/// Group header label for a section — the fuller name over a run of rows.
String barGroupLabel(AppLocalizations l10n, BarSection section) =>
    switch (section) {
      BarSection.spirits => l10n.barGroupSpirits,
      BarSection.mixers => l10n.barGroupMixers,
      BarSection.fresh => l10n.barGroupFresh,
      BarSection.syrups => l10n.barGroupSyrups,
      BarSection.tools => l10n.barGroupTools,
      BarSection.ice => l10n.barGroupIce,
      BarSection.other => l10n.barGroupOther,
    };

/// The glyph a section's rows fall back to when they carry no photo.
IconData barSectionIcon(BarSection section) => switch (section) {
  BarSection.spirits => Icons.liquor,
  BarSection.mixers => Icons.local_drink,
  BarSection.fresh => Icons.eco,
  BarSection.syrups => Icons.science,
  BarSection.tools => Icons.blender,
  BarSection.ice => Icons.ac_unit,
  BarSection.other => Icons.category,
};

String barEntryName(BuildContext context, BarCatalogueEntry entry) =>
    _resolveName(
      context,
      title: entry.title,
      starterId: entry.starterId,
      key: entry.key,
    );

String barItemName(BuildContext context, BarItem item) => _resolveName(
  context,
  title: item.title,
  starterId: item.starterId,
  key: item.key,
);

String shoppingEntryName(BuildContext context, ShoppingEntry entry) =>
    _resolveName(
      context,
      title: entry.title,
      starterId: entry.starterId,
      key: entry.key,
    );

/// title.translate -> starterLabel -> prettified key, in that order — the
/// first one with something to say wins.
String _resolveName(
  BuildContext context, {
  required Map<String, String> title,
  required String? starterId,
  required String key,
}) {
  final translated = title.translate(context);
  if (translated.isNotEmpty) return translated;

  final starterId0 = starterId;
  if (starterId0 != null && starterId0.isNotEmpty) {
    return starterLabel(context.l10n, starterId0);
  }

  return _prettify(key);
}

/// A [barKey] has no spaces or punctuation left to work with, so the best a
/// fallback can do is stop it reading as all-lowercase code.
String _prettify(String id) {
  if (id.isEmpty) return id;
  return id[0].toUpperCase() + id.substring(1);
}
