import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/bar_provider.dart';
import '../../providers/explore_provider.dart';
import '../../providers/measure_unit_provider.dart';
import '../../providers/party_menu_draft.dart';
import '../../theme/theme.dart';
import '../../utils/cocktail_labels.dart';
import '../../utils/localization_helper.dart';
import '../auth/auth_controls.dart';
import '../common/app_sheet.dart';
import 'menu_cocktail_tile.dart';

/// The name every menu-picker screen (search, all cocktails) is pushed
/// under, so "show me what I can make" can pop straight back to the grid.
const kMenuPickerRouteName = 'party-menu-picker';

/// The pale amber a missing ingredient's name is set in.
const _lowLight = Color(0xFFF5C97A);

enum _MissingChoice { addAndBuy, showMakeable }

/// Flow 05 · screen 06 — warn, never block.
///
/// Toggles [cocktail] on the [PartyMenuDraft] in scope. Taking a drink off,
/// or adding one the shelf can pour, just happens; adding one that is short
/// asks first — add it anyway and buy what is missing, or go back to the
/// drinks that need nothing.
Future<void> toggleOnMenu(BuildContext context, Cocktail cocktail) async {
  final menu = context.read<PartyMenuDraft>();
  if (menu.contains(cocktail.id)) {
    menu.remove(cocktail.id);
    return;
  }

  final bar = context.read<BarProvider>();
  final makeability = makeabilityOf(cocktail, bar.shelf);
  if (makeability.missing.isEmpty) {
    menu.add(cocktail);
    return;
  }

  final makeableCount = context
      .read<ExploreProvider>()
      .fetched
      .where((c) => makeabilityOf(c, bar.shelf).isMakeable)
      .length;

  final choice = await showAppSheet<_MissingChoice>(
    context,
    (_) => _MissingIngredientSheet(
      cocktail: cocktail,
      makeability: makeability,
      makeableCount: makeableCount,
    ),
  );
  if (!context.mounted) return;

  switch (choice) {
    case _MissingChoice.addAndBuy:
      menu.add(cocktail);
      final title = cocktail.title.translate(context);
      for (final ingredient in makeability.missing) {
        final fallback = BarCatalogueEntry.fromIngredient(ingredient);
        await bar.addToList(
          bar.entryFor(fallback.key) ?? fallback,
          reason: ShoppingReason.recipe,
          context: title,
        );
      }
    case _MissingChoice.showMakeable:
      if (!context.mounted) return;
      Navigator.of(
        context,
      ).popUntil((route) => route.settings.name != kMenuPickerRouteName);
    case null:
      break;
  }
}

class _MissingIngredientSheet extends StatelessWidget {
  const _MissingIngredientSheet({
    required this.cocktail,
    required this.makeability,
    required this.makeableCount,
  });

  final Cocktail cocktail;
  final Makeability makeability;
  final int makeableCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final missing = makeability.missing;
    final missingIds = missing.map((i) => i.id).toSet();
    final required = cocktail.requiredIngredients;
    final oneName = missing.length == 1
        ? missing.single.title.translate(context).toLowerCase()
        : null;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.sheet,
        borderRadius: AppRadius.sheetTop,
        boxShadow: [kSheetShadow],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenEdge,
          12,
          AppSpacing.screenEdge,
          30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.ink.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 62,
                    height: 62,
                    child: MenuCocktailImage(image: cocktail.image),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cocktail.title.translate(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.heading.copyWith(
                          fontSize: 22,
                          height: 1.0,
                          letterSpacing: -0.66,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        required
                            .map((i) => i.title.translate(context))
                            .join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.meta.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: AppColors.ink.withValues(alpha: .5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              oneName != null
                  ? l10n.hostMissingOneTitle(oneName)
                  : l10n.hostMissingManyTitle(missing.length),
              style: AppTypography.heading.copyWith(
                fontSize: 24,
                height: 1.08,
                letterSpacing: -0.84,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.hostMissingBody,
              style: AppTypography.body.copyWith(height: 1.6),
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  for (final (i, ingredient) in required.indexed) ...[
                    if (i > 0)
                      Container(height: 1, color: AppColors.fillSubtle),
                    _IngredientRow(
                      name: ingredient.title.translate(context),
                      measure: cocktail.measureFor(ingredient.id),
                      missing: missingIds.contains(ingredient.id),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            AuthPillButton(
              label: oneName != null
                  ? l10n.hostMissingAddAndBuyOne(oneName)
                  : l10n.hostMissingAddAndBuyMany(missing.length),
              icon: Icons.add_shopping_cart,
              primary: true,
              height: AppSizes.buttonPrimary,
              onPressed: () =>
                  Navigator.of(context).pop(_MissingChoice.addAndBuy),
            ),
            const SizedBox(height: 10),
            AuthPillButton(
              label: l10n.hostMissingShowMakeable(makeableCount),
              icon: Icons.swap_horiz,
              height: AppSizes.buttonGhost,
              onPressed: () =>
                  Navigator.of(context).pop(_MissingChoice.showMakeable),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.hostMissingFootnote,
              textAlign: TextAlign.center,
              style: AppTypography.meta.copyWith(
                fontSize: 12,
                color: AppColors.ink.withValues(alpha: .4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({
    required this.name,
    required this.measure,
    required this.missing,
  });

  final String name;
  final IngredientMeasure? measure;
  final bool missing;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final unit = context.watch<MeasureUnitProvider>().unit;

    return ColoredBox(
      color: AppColors.row,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: missing ? AppColors.lowWash : AppColors.fillMuted,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                missing ? Icons.error : Icons.liquor,
                size: 17,
                color: missing ? AppColors.low : AppColors.signalLight,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.cardTitle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: missing ? _lowLight : AppColors.ink,
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (missing)
              Text(
                l10n.hostMissingOutOfStock,
                style: AppTypography.meta.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.low,
                ),
              )
            else if (measure != null)
              Text(
                measureLabel(l10n, measure!, displayUnit: unit),
                style: AppTypography.measure.copyWith(
                  color: AppColors.inkBody,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
