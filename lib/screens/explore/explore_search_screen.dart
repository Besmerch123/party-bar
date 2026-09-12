import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/bar_provider.dart';
import '../../providers/explore_provider.dart';
import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/cocktail_labels.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/common/app_bottom_nav.dart';
import '../../widgets/common/app_chip.dart';
import '../../widgets/explore/cocktail_cards.dart';
import '../../widgets/explore/explore_chrome.dart';
import '../../widgets/explore/explore_filters_sheet.dart';
import '../../widgets/explore/zero_results.dart';

/// Screens 02, 04 and 04b as one surface: search suggestions, the filtered
/// feed, and the zero-result answer are three bodies under a search field
/// that never moves — because a query set here is the same query the feed
/// reads, not a hand-off to a separate screen.
class ExploreSearchScreen extends StatefulWidget {
  const ExploreSearchScreen({super.key});

  @override
  State<ExploreSearchScreen> createState() => _ExploreSearchScreenState();
}

class _ExploreSearchScreenState extends State<ExploreSearchScreen> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  // Whether the field reads as "searching" — decided explicitly rather than
  // derived purely from the text, because picking a spirit tile has to land
  // on the results state even though it clears the query on the way in.
  bool _resultsMode = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    final explore = context.read<ExploreProvider>();
    _controller = TextEditingController(text: explore.query);
    _resultsMode = explore.query.isNotEmpty;
    _focusNode.addListener(_handleFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ExploreProvider>().loadPopular();
    });
  }

  void _handleFocusChange() {
    if (!mounted) return;
    setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    context.read<ExploreProvider>().setQuery(value);
    final searching = value.isNotEmpty;
    if (searching != _resultsMode) setState(() => _resultsMode = searching);
  }

  void _onSubmitted(String value) {
    final explore = context.read<ExploreProvider>();
    explore.setQuery(value, immediate: true);
    // Remembering happens on submit alone — typing is still deciding what to
    // ask for, not asking it, and the recent list should only hold searches
    // someone actually committed to.
    explore.rememberSearch(value);
    if (value.isNotEmpty && !_resultsMode) {
      setState(() => _resultsMode = true);
    }
  }

  /// Shared by the leading back button and the field's own clear glyph: both
  /// undo the query and drop back to suggestions, they just sit in different
  /// places relative to the pill.
  void _clearToSuggestions() {
    _controller.clear();
    context.read<ExploreProvider>().setQuery('', immediate: true);
    setState(() => _resultsMode = false);
  }

  void _restoreRecent(String term) {
    _controller.value = TextEditingValue(
      text: term,
      selection: TextSelection.collapsed(offset: term.length),
    );
    context.read<ExploreProvider>().setQuery(term, immediate: true);
    setState(() => _resultsMode = true);
  }

  /// A spirit tile is a shortcut straight into the filtered feed, not a
  /// search term — the query is cleared so the filter chip underneath is the
  /// only thing claiming credit for what narrowed the list.
  void _pickSpirit(BaseSpirit spirit) {
    final explore = context.read<ExploreProvider>();
    explore.setFilters(explore.filters.copyWith(spirits: {spirit}));
    _controller.clear();
    explore.setQuery('', immediate: true);
    setState(() => _resultsMode = true);
  }

  @override
  Widget build(BuildContext context) {
    final explore = context.watch<ExploreProvider>();
    final bar = context.watch<BarProvider>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _SearchHeader(
              controller: _controller,
              focusNode: _focusNode,
              focused: _focused,
              resultsMode: _resultsMode,
              onChanged: _onChanged,
              onSubmitted: _onSubmitted,
              onClear: _clearToSuggestions,
              onCancel: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: _resultsMode
                  ? _ResultsBody(explore: explore, shelf: bar.shelf)
                  : _SuggestionsBody(
                      onRestoreSearch: _restoreRecent,
                      onPickSpirit: _pickSpirit,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The field that never scrolls away, and whatever sits beside it. Its own
/// chrome — a leading back button plus an inline clear, or a trailing Cancel
/// — comes entirely from [resultsMode], since that is the same fact the body
/// underneath switches on.
class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.controller,
    required this.focusNode,
    required this.focused,
    required this.resultsMode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onCancel,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool focused;
  final bool resultsMode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        10,
        AppSpacing.screenEdge,
        0,
      ),
      child: Row(
        children: [
          if (resultsMode) ...[
            _RoundIconButton(icon: Icons.arrow_back, onTap: onClear),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: _SearchPill(
              controller: controller,
              focusNode: focusNode,
              focused: focused,
              autofocus: !resultsMode,
              showClear: resultsMode,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              onClear: onClear,
            ),
          ),
          if (!resultsMode) ...[
            const SizedBox(width: 6),
            TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.searchCancel,
                style: AppTypography.body.copyWith(color: AppColors.inkBody),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The pill itself. A focus ring is the only chrome that comes and goes with
/// the keyboard; autofocus and the inline clear glyph are decided by the
/// caller from whether a query is already in flight, not from focus.
class _SearchPill extends StatelessWidget {
  const _SearchPill({
    required this.controller,
    required this.focusNode,
    required this.focused,
    required this.autofocus,
    required this.showClear,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool focused;
  final bool autofocus;
  final bool showClear;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.row,
        borderRadius: AppRadius.pillAll,
        border: focused
            ? Border.all(color: AppColors.signal, width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 19, color: AppColors.inkMeta),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: autofocus,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              style: AppTypography.body.copyWith(color: AppColors.ink),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: l10n.searchHint,
                hintStyle: AppTypography.body.copyWith(
                  color: AppColors.inkMeta,
                ),
              ),
            ),
          ),
          if (showClear)
            Semantics(
              label: l10n.searchClearQuery,
              button: true,
              child: GestureDetector(
                onTap: onClear,
                child: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.cancel,
                    size: 17,
                    color: AppColors.inkMeta,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.fillMuted,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, size: 18, color: AppColors.inkBody),
        ),
      ),
    );
  }
}

/// Screen 02 — recent terms, trending drinks, and a shortcut by spirit, for
/// the moment before anything has been typed.
class _SuggestionsBody extends StatelessWidget {
  const _SuggestionsBody({
    required this.onRestoreSearch,
    required this.onPickSpirit,
  });

  final ValueChanged<String> onRestoreSearch;
  final ValueChanged<BaseSpirit> onPickSpirit;

  // Six spirits, not all eight — brandy and "other" have no icon worth
  // showing and no real audience browsing by them.
  static const _spirits = [
    BaseSpirit.gin,
    BaseSpirit.vodka,
    BaseSpirit.rum,
    BaseSpirit.whisky,
    BaseSpirit.tequila,
    BaseSpirit.zeroProof,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final explore = context.watch<ExploreProvider>();
    final recent = explore.recentSearches;
    final popular = explore.popular;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        22,
        AppSpacing.screenEdge,
        32,
      ),
      children: [
        if (recent.isNotEmpty) ...[
          EyebrowLabel(
            l10n.searchRecent,
            trailing: TextButton(
              onPressed: () =>
                  context.read<ExploreProvider>().clearRecentSearches(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.searchClearRecent,
                style: AppTypography.body.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.signalLight,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final term in recent)
                TagChip(
                  label: term,
                  onTap: () => onRestoreSearch(term),
                  onDeleted: () =>
                      context.read<ExploreProvider>().removeRecentSearch(term),
                ),
            ],
          ),
        ],
        if (popular.isNotEmpty) ...[
          const SizedBox(height: 26),
          EyebrowLabel(l10n.searchPopularThisWeek),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: AppRadius.tileAll,
            child: ColoredBox(
              color: AppColors.fillSubtle,
              child: Column(
                children: [
                  for (final (index, cocktail) in popular.indexed) ...[
                    if (index > 0) const SizedBox(height: 1),
                    _PopularRow(
                      cocktail: cocktail,
                      onTap: () => context.push(
                        '${AppRoutes.cocktailDetails}/${cocktail.id}',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 26),
        EyebrowLabel(l10n.searchBrowseBySpirit),
        const SizedBox(height: 12),
        CocktailGrid(
          children: [
            for (final spirit in _spirits)
              _SpiritTile(spirit: spirit, onTap: () => onPickSpirit(spirit)),
          ],
        ),
      ],
    );
  }
}

class _PopularRow extends StatelessWidget {
  const _PopularRow({required this.cocktail, required this.onTap});

  final Cocktail cocktail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: cocktail.title.translate(context),
      child: Material(
        color: AppColors.row,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.trending_up,
                  size: 18,
                  color: AppColors.inkMeta,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    cocktail.title.translate(context),
                    style: AppTypography.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.north_east,
                  size: 17,
                  color: AppColors.inkMeta,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpiritTile extends StatelessWidget {
  const _SpiritTile({required this.spirit, required this.onTap});

  final BaseSpirit spirit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = spiritLabel(l10n, spirit);

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppColors.row,
        borderRadius: AppRadius.tileAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.tileAll,
          child: SizedBox(
            height: 78,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    // A quiet watermark, not an illustration — the name
                    // carries the tile, the icon just backs it up.
                    child: Opacity(
                      opacity: 0.5,
                      child: Icon(
                        spiritIcon(spirit),
                        size: 20,
                        color: AppColors.inkMeta,
                      ),
                    ),
                  ),
                  Text(
                    label,
                    style: AppTypography.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Screen 04 — the filtered feed, or screen 04b in its place once nothing
/// survives the filters.
class _ResultsBody extends StatelessWidget {
  const _ResultsBody({required this.explore, required this.shelf});

  final ExploreProvider explore;
  final Set<String> shelf;

  @override
  Widget build(BuildContext context) {
    final results = explore.results;

    // A refetch in flight must never blank a list someone is mid-scroll on —
    // the previous results stay exactly where they were, with only a thin
    // bar under the filter row to say a new answer is on the way.
    final showLoadingBar = explore.isLoading && results.isNotEmpty;

    return Column(
      children: [
        const SizedBox(height: 14),
        ExploreFilterBar(
          filters: explore.filters,
          onRemove: explore.removeFilter,
          onOpenSheet: () => showExploreFiltersSheet(context),
        ),
        if (showLoadingBar)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: SizedBox(
              height: 2,
              child: LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: AppColors.fillSubtle,
                valueColor: AlwaysStoppedAnimation(AppColors.signal),
              ),
            ),
          )
        else
          const SizedBox(height: 18),
        Expanded(
          child: explore.isEmpty
              ? ZeroResults(
                  query: explore.query,
                  filters: explore.filters,
                  previewCount: explore.previewCount,
                  nearMisses: explore.nearMissSuggestions,
                  pourableFallback: explore.pourableFallback,
                  onRemoveFilter: explore.removeFilter,
                  onClearFilters: explore.clearFilters,
                )
              : _ResultsList(
                  results: results,
                  sort: explore.sort,
                  shelf: shelf,
                ),
        ),
      ],
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({
    required this.results,
    required this.sort,
    required this.shelf,
  });

  final List<Cocktail> results;
  final ExploreSort sort;
  final Set<String> shelf;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final grid = results.take(2).toList(growable: false);
    final rest = results.skip(2).toList(growable: false);

    return CustomScrollView(
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      l10n.resultsCount(results.length),
                      style: AppTypography.section.copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    sortNote(l10n, sort),
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CocktailGrid(
                children: [
                  for (final cocktail in grid)
                    CocktailTile(
                      cocktail: cocktail,
                      status: _statusFor(context, cocktail, shelf),
                      onTap: () => _openDetails(context, cocktail),
                      height: 194,
                    ),
                ],
              ),
              if (rest.isNotEmpty) ...[
                const SizedBox(height: 10),
                Column(
                  children: [
                    for (final (index, cocktail) in rest.indexed) ...[
                      if (index > 0) const SizedBox(height: 8),
                      CocktailListRow(
                        cocktail: cocktail,
                        status: _statusFor(context, cocktail, shelf),
                        onTap: () => _openDetails(context, cocktail),
                      ),
                    ],
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

  /// An empty shelf makes every verdict the same non-answer — "4 missing" on
  /// every card is noise, not information — so an unstocked bar gets no
  /// badge at all rather than a wall of identical warnings.
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
