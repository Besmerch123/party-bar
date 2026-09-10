import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/bar_provider.dart';
import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/cocktail_labels.dart';
import '../../utils/localization_helper.dart';
import 'cocktail_cards.dart';
import 'explore_chrome.dart';

/// Screen 04b — the answer to zero results.
///
/// The flow's rule is that a dead end is a design failure: this always says
/// why the list emptied, and always hands back a next drink, even when
/// nothing more specific than the typed words can be blamed for it.
class ZeroResults extends StatelessWidget {
  const ZeroResults({
    super.key,
    required this.query,
    required this.filters,
    required this.previewCount,
    required this.nearMisses,
    required this.pourableFallback,
    required this.onRemoveFilter,
    required this.onClearFilters,
  });

  final String query;
  final ExploreFilters filters;

  /// How many results a hypothetical filter set would return. Used to test
  /// each active tag in isolation, on the real fetched set, without touching
  /// the provider's actual state.
  final int Function(ExploreFilters) previewCount;

  final List<NearMiss> nearMisses;
  final List<Cocktail> pourableFallback;
  final ValueChanged<ExploreFilterTag> onRemoveFilter;
  final VoidCallback onClearFilters;

  /// The one filter that, alone, is standing between the query and results —
  /// or null when no single tag explains it, because either several are
  /// compounding or none are on at all. Naming a filter that would not
  /// actually fix things is worse than naming none.
  ExploreFilterTag? get _blocker {
    final candidates = filters.tags
        .where((tag) => previewCount(filters.without(tag)) > 0)
        .toList(growable: false);
    return candidates.length == 1 ? candidates.single : null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final blocker = _blocker;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        0,
        AppSpacing.screenEdge,
        32,
      ),
      children: [
        _Explanation(
          query: query,
          filters: filters,
          blocker: blocker,
          onRemoveFilter: onRemoveFilter,
          onClearFilters: onClearFilters,
        ),
        if (nearMisses.isNotEmpty) ...[
          const SizedBox(height: 26),
          EyebrowLabel(l10n.zeroResultsOneBottleAway),
          const SizedBox(height: 12),
          Column(
            children: [
              for (final (index, miss) in nearMisses.indexed) ...[
                if (index > 0) const SizedBox(height: 8),
                _NearMissRow(miss: miss),
              ],
            ],
          ),
        ],
        if (pourableFallback.isNotEmpty) ...[
          const SizedBox(height: 26),
          EyebrowLabel(l10n.zeroResultsPourable),
          const SizedBox(height: 12),
          CocktailGrid(
            children: [
              for (final cocktail in pourableFallback.take(4))
                CocktailTile(
                  cocktail: cocktail,
                  onTap: () => _openDetails(context, cocktail),
                  height: 150,
                  showMeta: false,
                ),
            ],
          ),
        ],
      ],
    );
  }

  static void _openDetails(BuildContext context, Cocktail cocktail) =>
      context.push('${AppRoutes.cocktailDetails}/${cocktail.id}');
}

/// The card that names the problem. Which words it uses depends entirely on
/// whether one filter can be singled out as the cause — see [ZeroResults._blocker].
class _Explanation extends StatelessWidget {
  const _Explanation({
    required this.query,
    required this.filters,
    required this.blocker,
    required this.onRemoveFilter,
    required this.onClearFilters,
  });

  final String query;
  final ExploreFilters filters;
  final ExploreFilterTag? blocker;
  final ValueChanged<ExploreFilterTag> onRemoveFilter;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final blocker = this.blocker;

    final String headline;
    final String body;
    if (blocker != null) {
      final label = filterTagLabel(l10n, blocker);
      headline = l10n.zeroResultsBlockedTitle(label);
      body = query.isEmpty
          ? l10n.zeroResultsBodyNoQuery(label)
          : l10n.zeroResultsBody(query, label);
    } else {
      headline = l10n.zeroResultsTitle;
      body = l10n.zeroResultsBodyPlain(query);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.sheet,
        borderRadius: AppRadius.cardAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.fillSubtle,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.search_off,
              size: 21,
              color: AppColors.inkMeta,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            headline,
            style: AppTypography.section.copyWith(fontSize: 17, height: 1.25),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 9),
          Text(
            body,
            style: AppTypography.meta,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          // "Clear all" only earns a place once something is actually on —
          // an empty filter set has nothing this card could offer to drop.
          if (!filters.isEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (blocker != null)
                  _Pill.white(
                    label: l10n.zeroResultsDropFilter(
                      filterTagLabel(l10n, blocker),
                    ),
                    onTap: () => onRemoveFilter(blocker),
                  ),
                _Pill.muted(
                  label: l10n.zeroResultsClearAll,
                  onTap: onClearFilters,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// The two pill styles this card ever shows: white for the one specific fix,
/// muted for the blunter "start over".
class _Pill extends StatelessWidget {
  const _Pill.white({required this.label, required this.onTap})
    : background = AppColors.ink,
      foreground = AppColors.ground;

  const _Pill.muted({required this.label, required this.onTap})
    : background = AppColors.fillStrong,
      foreground = AppColors.ink;

  final String label;
  final VoidCallback onTap;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: AppRadius.pillAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.pillAll,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.body.copyWith(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              height: 1.0,
              color: foreground,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

/// One drink exactly a bottle short, with the bottle itself as the action.
class _NearMissRow extends StatelessWidget {
  const _NearMissRow({required this.miss});

  final NearMiss miss;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ingredientName = miss.ingredient.title.translate(context);
    // A fabricated "unlocks 0" would read as a real count instead of the
    // catalogue simply not knowing yet, so the unknown case gets its own
    // sentence rather than a fake number.
    final subtitle = miss.unlocks > 0
        ? l10n.zeroResultsUnlocks(ingredientName, miss.unlocks)
        : l10n.zeroResultsUnlocksUnknown(ingredientName);

    return CocktailListRow(
      cocktail: miss.cocktail,
      subtitle: subtitle,
      onTap: () => context.push(
        '${AppRoutes.cocktailDetails}/${miss.cocktail.id}',
      ),
      trailing: _AddButton(ingredient: miss.ingredient, name: ingredientName),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.ingredient, required this.name});

  final Ingredient ingredient;
  final String name;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Semantics(
      label: l10n.addToBar,
      button: true,
      child: Material(
        color: AppColors.lowWash,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () async {
            await context.read<BarProvider>().addIngredient(ingredient);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.addedToBar(name))),
            );
          },
          child: const SizedBox(
            width: 32,
            height: 32,
            child: Icon(Icons.add, size: 17, color: AppColors.low),
          ),
        ),
      ),
    );
  }
}
