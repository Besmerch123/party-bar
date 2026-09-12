import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/bar.dart';
import '../../models/bar_item.dart';
import '../../models/bar_stats.dart';
import '../../models/cocktail.dart';
import '../../models/ingredient.dart';
import '../../models/shared_types.dart';
import '../../models/shopping_list.dart';
import '../../providers/bar_provider.dart';
import '../../providers/explore_provider.dart';
import '../../theme/theme.dart';
import '../../utils/bar_labels.dart';
import '../../utils/localization_helper.dart';
import '../common/app_sheet.dart';

/// Flow 04 · screen 09 — "Two away", the one place outside the ran-out
/// checklist a gap is named: reached from a recipe the shelf is two or three
/// bottles short of.
///
/// Not a gate and not a progress bar — the design is explicit that the
/// makeable count never earns more than a subtitle anywhere else. This sheet
/// is the single, deliberate exception, because it answers a question the
/// host was already asking ("what is actually stopping me from making
/// this?") rather than nagging about one they were not.
Future<void> showTwoAwaySheet(BuildContext context, Cocktail cocktail) {
  return showAppSheet<void>(context, (_) => _TwoAwaySheet(cocktail: cocktail));
}

class _TwoAwaySheet extends StatefulWidget {
  const _TwoAwaySheet({required this.cocktail});

  final Cocktail cocktail;

  @override
  State<_TwoAwaySheet> createState() => _TwoAwaySheetState();
}

class _TwoAwaySheetState extends State<_TwoAwaySheet> {
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    // The sheet needs BarStats to say anything about "also blocks N more",
    // and Explore may not have fetched anything yet if this is reached
    // before the feed ever loaded — same guarded, once-per-visit trigger
    // ExploreScreen itself uses.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final explore = context.read<ExploreProvider>();
      if (!explore.hasLoaded && !explore.isLoading) explore.load();
    });
  }

  /// Shared by the auto-close effect and both buttons, so however the sheet
  /// ends up closing, it only ever pops once.
  void _close() {
    if (_closed) return;
    _closed = true;
    Navigator.of(context).maybePop();
  }

  Future<void> _addToList(BarProvider bar, Makeability makeability) async {
    final title = widget.cocktail.title.translate(context);
    for (final ingredient in makeability.missing) {
      await bar.addToList(
        _entryFor(bar, ingredient),
        reason: ShoppingReason.recipe,
        context: title,
      );
    }
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final label = context.l10n.twoAwayAddedToList;
    _close();
    messenger.showSnackBar(SnackBar(content: Text(label)));
  }

  Future<void> _haveThese(BarProvider bar, Makeability makeability) async {
    final entries = [
      for (final ingredient in makeability.missing) _entryFor(bar, ingredient),
    ];
    await bar.addEntries(entries);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final label = context.l10n.twoAwayAddedToBar;
    _close();
    messenger.showSnackBar(SnackBar(content: Text(label)));
  }

  BarCatalogueEntry _entryFor(BarProvider bar, Ingredient ingredient) {
    final fallback = BarCatalogueEntry.fromIngredient(ingredient);
    return bar.entryFor(fallback.key) ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    if (_closed) return const SizedBox.shrink();

    final l10n = context.l10n;
    final bar = context.watch<BarProvider>();
    final explore = context.watch<ExploreProvider>();
    final makeability = makeabilityOf(widget.cocktail, bar.shelf);
    final stats = BarStats.compute(explore.fetched, bar.shelf);

    // The shelf moved out from under this sheet — "I have these" stocked
    // exactly what was missing, or someone edited the bar in another tab
    // while this was open. Either way the gap this sheet was named for is
    // gone, so it closes itself instead of arguing with a shelf that has
    // already moved on.
    if (makeability.isMakeable || makeability.missingCount < 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _close());
      return const SizedBox.shrink();
    }

    final held = widget.cocktail.requiredIngredients
        .where((ingredient) => !makeability.missing.contains(ingredient))
        .map((ingredient) => ingredient.title.translate(context))
        .join(', ');

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenEdge,
          12,
          AppSpacing.screenEdge,
          MediaQuery.paddingOf(context).bottom + 30,
        ),
        decoration: const BoxDecoration(
          color: AppColors.sheet,
          borderRadius: AppRadius.sheetTop,
          boxShadow: [kSheetShadow],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: _Handle()),
            const SizedBox(height: 22),
            Text(
              l10n.twoAwayEyebrow(makeability.missingCount).toUpperCase(),
              style: AppTypography.label.copyWith(color: AppColors.low),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.twoAwayTitle(makeability.onShelfCount, makeability.requiredCount),
              style: AppTypography.heading,
            ),
            const SizedBox(height: 12),
            Text(l10n.twoAwayBody, style: AppTypography.body),
            const SizedBox(height: 20),
            _RowsGroup(missing: makeability.missing, stats: stats, held: held),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _addToList(bar, makeability),
                icon: const Icon(Icons.add_shopping_cart),
                label: Text(l10n.twoAwayAddToList(makeability.missingCount)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonGhost,
              child: OutlinedButton.icon(
                onPressed: () => _haveThese(bar, makeability),
                icon: const Icon(Icons.check),
                label: Text(l10n.twoAwayHaveThese),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(
                l10n.twoAwayFootnote,
                textAlign: TextAlign.center,
                style: AppTypography.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.ink.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// One row per missing ingredient, plus a final row naming what the shelf
/// already has — the same "here is what is actually holding you back" shape
/// as the sheet's ingredient list, just narrowed to the gap.
class _RowsGroup extends StatelessWidget {
  const _RowsGroup({required this.missing, required this.stats, required this.held});

  final List<Ingredient> missing;
  final BarStats stats;
  final String held;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: ColoredBox(
        color: AppColors.fillSubtle,
        child: Column(
          children: [
            for (final (index, ingredient) in missing.indexed) ...[
              if (index > 0) const SizedBox(height: 1),
              _MissingRow(ingredient: ingredient, stats: stats),
            ],
            // A drink made only of what is missing has nothing to list here,
            // and an empty row with a tick would read as a claim.
            if (held.isNotEmpty) ...[
              const SizedBox(height: 1),
              _HeldRow(names: held),
            ],
          ],
        ),
      ),
    );
  }
}

class _MissingRow extends StatelessWidget {
  const _MissingRow({required this.ingredient, required this.stats});

  final Ingredient ingredient;
  final BarStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final key = BarCatalogueEntry.fromIngredient(ingredient).key;
    final alsoBlocks = math.max(0, stats.missingIn(key) - 1);

    return ColoredBox(
      color: AppColors.row,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.lowWash,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                barSectionIcon(sectionForIngredient(ingredient.category)),
                size: 17,
                color: AppColors.low,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ingredient.title.translate(context),
                style: AppTypography.body.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.low,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Only printed once the catalogue has actually been fetched — a
            // zero here would otherwise read as a fact rather than an
            // unknown.
            if (stats.hasCatalogue) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  l10n.twoAwayAlsoBlocks(alsoBlocks),
                  style: AppTypography.body.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: alsoBlocks > 0 ? AppColors.low : AppColors.inkMeta,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeldRow extends StatelessWidget {
  const _HeldRow({required this.names});

  final String names;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.row,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.fillMuted,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.liquor, size: 17, color: AppColors.signalLight),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                names,
                style: AppTypography.body.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkBody,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.check, size: 17, color: AppColors.ready),
          ],
        ),
      ),
    );
  }
}
