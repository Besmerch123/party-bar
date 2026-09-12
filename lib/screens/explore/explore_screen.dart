import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/bar_provider.dart';
import '../../providers/explore_provider.dart';
import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/common/app_bottom_nav.dart';
import '../../widgets/explore/cocktail_cards.dart';
import '../../widgets/explore/explore_chrome.dart';
import '../../widgets/explore/explore_filters_sheet.dart';

/// The app's front door, signed out: a photographic feed that answers "what
/// can I pour right now" from the on-device shelf alone.
///
/// Lives inside an [IndexedStack] with the other tabs, so it is built far more
/// often than it is actually shown — [initState] must not touch the provider,
/// and a load only fires once per real visit.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<ExploreProvider>();
      if (!provider.hasLoaded) provider.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final explore = context.watch<ExploreProvider>();
    final bar = context.watch<BarProvider>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              title: l10n.exploreFeedTitle,
              subtitle: bar.isEmpty
                  ? l10n.exploreNoShelfYet(explore.catalogueTotal)
                  : l10n.exploreShelfMatch(
                      explore.makeableCount,
                      explore.catalogueTotal,
                    ),
              onSearch: () => context.push(AppRoutes.exploreSearch),
            ),
            const SizedBox(height: 16),
            ExploreFilterBar(
              filters: explore.filters,
              onRemove: context.read<ExploreProvider>().removeFilter,
              onOpenSheet: () => showExploreFiltersSheet(context),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: _Body(explore: explore, shelf: bar.shelf),
            ),
          ],
        ),
      ),
    );
  }
}

/// Headline plus shelf-match subtitle, and the way into search. Fixed above
/// the scroll so the promise of the screen never scrolls out of view.
class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.onSearch,
  });

  final String title;
  final String subtitle;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        12,
        AppSpacing.screenEdge,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.title.copyWith(
                    fontSize: 30,
                    height: 1.02,
                    letterSpacing: -1.05,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 9),
                Text(
                  subtitle,
                  style: AppTypography.meta,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _SearchButton(onTap: onSearch),
        ],
      ),
    );
  }
}

/// A long headline must never squeeze this out of tap range, so it sits
/// outside the [Expanded] column rather than sharing its width.
class _SearchButton extends StatelessWidget {
  const _SearchButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.searchHint,
      child: Material(
        color: AppColors.fillMuted,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 34,
            height: 34,
            child: Icon(Icons.search, size: 18, color: AppColors.inkBody),
          ),
        ),
      ),
    );
  }
}

/// Everything below the filter bar: whichever of loading, error, empty or the
/// feed itself currently applies.
class _Body extends StatelessWidget {
  const _Body({required this.explore, required this.shelf});

  final ExploreProvider explore;
  final Set<String> shelf;

  @override
  Widget build(BuildContext context) {
    if (!explore.hasLoaded && explore.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Once a feed has loaded, a later failed refresh must not tear it down —
    // the old results are still true, so they stay on screen and the error is
    // simply dropped rather than shown over them.
    if (explore.error != null && !explore.hasLoaded) {
      return _ErrorState(message: explore.error!, onRetry: explore.refresh);
    }

    return RefreshIndicator(
      onRefresh: explore.refresh,
      // Guarded on the list itself rather than on `isEmpty`, which goes false
      // again the moment a refresh starts — and the feed below needs a hero.
      child: explore.results.isEmpty
          ? const _EmptyFeed()
          : _Feed(results: explore.results, shelf: shelf),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.low),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.errorLoadingCocktails, style: AppTypography.section),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: AppTypography.meta,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}

/// Loaded, but nothing survived the query. Kept inside a scroll view — even
/// though it has nothing to scroll — so the [RefreshIndicator] above it can
/// still be pulled to try again.
class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenEdge,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.exploreEmptyTitle,
                    style: AppTypography.section,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.exploreEmptyBody,
                    style: AppTypography.meta,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The scrolling feed itself: a hero, up to three curated sections, then
/// whatever is left — so the feed is always the whole result set, never a
/// truncated sample that quietly drops drinks nobody sees.
class _Feed extends StatelessWidget {
  const _Feed({required this.results, required this.shelf});

  final List<Cocktail> results;
  final Set<String> shelf;

  static const _sectionGrid = 200.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hero = results.first;
    final remainder = results.skip(1).toList(growable: false);
    final shown = <String>{hero.id};

    final readyNow = shelf.isNotEmpty
        ? remainder
              .where((c) => makeabilityOf(c, shelf).isMakeable)
              .toList(growable: false)
        : const <Cocktail>[];
    // "Ready now" only earns its place once it has something a single hero
    // could not already say — one match is a coincidence, not a section.
    final showReadyNow = readyNow.length >= 2;
    final readyNowShown = showReadyNow
        ? readyNow.take(4).toList(growable: false)
        : const <Cocktail>[];
    shown.addAll(readyNowShown.map((c) => c.id));

    final twoBottles = remainder
        .where(
          (c) =>
              !shown.contains(c.id) &&
              (c.requiredIngredients.length == 1 ||
                  c.requiredIngredients.length == 2),
        )
        .toList(growable: false);
    final twoBottlesShown = twoBottles.take(4).toList(growable: false);
    shown.addAll(twoBottlesShown.map((c) => c.id));

    final zeroProof = remainder
        .where(
          (c) =>
              !shown.contains(c.id) &&
              (c.baseSpirit == BaseSpirit.zeroProof ||
                  c.categories.contains(CocktailCategory.mocktail)),
        )
        .toList(growable: false);
    final zeroProofShown = zeroProof.take(4).toList(growable: false);
    shown.addAll(zeroProofShown.map((c) => c.id));

    final rest = remainder
        .where((c) => !shown.contains(c.id))
        .toList(growable: false);

    void openSearchWith(ExploreFilters filters) {
      context.read<ExploreProvider>().setFilters(filters);
      context.push(AppRoutes.exploreSearch);
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenEdge,
            0,
            AppSpacing.screenEdge,
            AppBottomNav.insetOf(context),
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              CocktailPosterCard(
                cocktail: hero,
                status: _statusFor(context, hero, shelf),
                onTap: () => _openDetails(context, hero),
              ),
              if (readyNowShown.isNotEmpty) ...[
                const SizedBox(height: 24),
                SectionHeader(title: l10n.exploreSectionMakeableNow),
                const SizedBox(height: 14),
                CocktailGrid(
                  children: [
                    for (final cocktail in readyNowShown)
                      CocktailTile(
                        cocktail: cocktail,
                        status: _statusFor(context, cocktail, shelf),
                        onTap: () => _openDetails(context, cocktail),
                        height: _sectionGrid,
                      ),
                  ],
                ),
              ],
              if (twoBottlesShown.isNotEmpty) ...[
                const SizedBox(height: 22),
                SectionHeader(
                  title: l10n.exploreSectionTwoBottles,
                  actionLabel: l10n.exploreSeeAll,
                  onAction: () => openSearchWith(
                    context
                        .read<ExploreProvider>()
                        .filters
                        .copyWith(threeIngredientsMax: true),
                  ),
                ),
                const SizedBox(height: 14),
                CocktailGrid(
                  children: [
                    for (final cocktail in twoBottlesShown)
                      CocktailTile(
                        cocktail: cocktail,
                        status: _statusFor(context, cocktail, shelf),
                        onTap: () => _openDetails(context, cocktail),
                        height: _sectionGrid,
                      ),
                  ],
                ),
              ],
              if (zeroProofShown.isNotEmpty) ...[
                const SizedBox(height: 22),
                SectionHeader(
                  title: l10n.exploreSectionZeroProof,
                  actionLabel: l10n.exploreSeeAll,
                  onAction: () => openSearchWith(
                    context
                        .read<ExploreProvider>()
                        .filters
                        .copyWith(spirits: {BaseSpirit.zeroProof}),
                  ),
                ),
                const SizedBox(height: 14),
                CocktailGrid(
                  children: [
                    for (final cocktail in zeroProofShown)
                      CocktailTile(
                        cocktail: cocktail,
                        status: _statusFor(context, cocktail, shelf),
                        onTap: () => _openDetails(context, cocktail),
                        height: _sectionGrid,
                      ),
                  ],
                ),
              ],
              if (rest.isNotEmpty) ...[
                const SizedBox(height: 22),
                CocktailGrid(
                  children: [
                    for (final cocktail in rest)
                      CocktailTile(
                        cocktail: cocktail,
                        status: _statusFor(context, cocktail, shelf),
                        onTap: () => _openDetails(context, cocktail),
                        height: _sectionGrid,
                      ),
                  ],
                ),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  static void _openDetails(BuildContext context, Cocktail cocktail) =>
      context.push('${AppRoutes.cocktailDetails}/${cocktail.id}');

  /// An empty shelf makes every verdict the same non-answer — "missing 4",
  /// "missing 5" on every card is noise, not information — so an unstocked
  /// bar gets no badge at all rather than a wall of identical warnings.
  static ShelfStatus? _statusFor(
    BuildContext context,
    Cocktail cocktail,
    Set<String> shelf,
  ) {
    if (shelf.isEmpty) return null;

    final makeability = makeabilityOf(cocktail, shelf);
    final missingName = makeability.isOneAway
        ? makeability.missing.single.title.translate(context)
        : null;

    return ShelfStatus(makeability: makeability, missingName: missingName);
  }
}
