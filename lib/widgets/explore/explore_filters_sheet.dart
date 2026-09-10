import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/bar_provider.dart';
import '../../providers/explore_provider.dart';
import '../../theme/theme.dart';
import '../../utils/cocktail_labels.dart';
import '../../utils/localization_helper.dart';
import '../common/app_chip.dart';
import 'explore_chrome.dart';

/// Opens Explore's one filter surface.
///
/// Sort and every facet live in a single sheet so there is never a second,
/// hidden place a person would have to remember to check.
Future<void> showExploreFiltersSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (_) => const ExploreFiltersSheet(),
  );
}

/// The body of the filter sheet.
///
/// Everything here edits a local draft, seeded from [ExploreProvider] on
/// open. Nothing reaches the provider — and nothing reaches the feed — until
/// the primary button is pressed; dismissing the sheet any other way just
/// throws the draft away, which is the entire point of drafting.
class ExploreFiltersSheet extends StatefulWidget {
  const ExploreFiltersSheet({super.key});

  @override
  State<ExploreFiltersSheet> createState() => _ExploreFiltersSheetState();
}

class _ExploreFiltersSheetState extends State<ExploreFiltersSheet> {
  late ExploreFilters _draft;
  late ExploreSort _draftSort;

  @override
  void initState() {
    super.initState();
    final explore = context.read<ExploreProvider>();
    _draft = explore.filters;
    _draftSort = explore.sort;
  }

  void _reset() {
    // Clearing the filters is a different decision from clearing the sort:
    // someone who picked "Seasonal" on purpose did not ask for "Popular"
    // back just because they also want to drop the spirit chips.
    setState(() => _draft = ExploreFilters.empty);
  }

  void _apply() {
    final explore = context.read<ExploreProvider>();
    explore.setFilters(_draft);
    explore.setSort(_draftSort);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final explore = context.watch<ExploreProvider>();
    final bar = context.watch<BarProvider>();

    final previewCount = explore.previewCount(_draft);
    final drinksCount = explore.fetched
        .where((cocktail) => makeabilityOf(cocktail, bar.shelf).isMakeable)
        .length;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
      decoration: const BoxDecoration(
        color: AppColors.sheet,
        borderRadius: AppRadius.sheetTop,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const _DragHandle(),
          const SizedBox(height: 10),
          _Header(
            showReset: !_draft.isEmpty,
            onReset: _reset,
          ),
          const SizedBox(height: 18),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MakeableRow(
                    bar: bar,
                    drinksCount: drinksCount,
                    value: _draft.makeableOnly,
                    // An empty shelf can pour nothing, so a filter that keeps
                    // only what it pours would always empty the feed — the
                    // switch is disabled rather than let someone set a trap
                    // for themselves.
                    onChanged: bar.isEmpty
                        ? null
                        : (value) => setState(
                            () => _draft = _draft.copyWith(makeableOnly: value),
                          ),
                  ),
                  const SizedBox(height: 22),
                  EyebrowLabel(l10n.filterSectionSort),
                  const SizedBox(height: 11),
                  _SortSegmented(
                    value: _draftSort,
                    onChanged: (sort) => setState(() => _draftSort = sort),
                  ),
                  const SizedBox(height: 22),
                  EyebrowLabel(l10n.filterSectionBaseSpirit),
                  const SizedBox(height: 11),
                  _SpiritWrap(
                    selected: _draft.spirits,
                    onToggle: (spirit) => setState(
                      () => _draft = _draft.toggleSpirit(spirit),
                    ),
                  ),
                  const SizedBox(height: 22),
                  EyebrowLabel(l10n.filterSectionEffort),
                  const SizedBox(height: 11),
                  _EffortList(
                    draft: _draft,
                    onChanged: (next) => setState(() => _draft = next),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SubmitButton(
            label: l10n.filterShowDrinks(previewCount),
            // A zero-result count means committing this draft would land on
            // a dead feed with no way, from inside this sheet, to see why.
            onPressed: previewCount > 0 ? _apply : null,
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom + 26),
        ],
      ),
    );
  }
}

/// The grab affordance at the top of the sheet.
///
/// [AppColors.hairline] reads as barely-there over the sheet's own fill, so
/// this borrows the slightly brighter [AppColors.glassStroke] instead.
class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 38,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.glassStroke,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.showReset, required this.onReset});

  final bool showReset;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            l10n.filterSheetTitle,
            style: AppTypography.title.copyWith(
              fontSize: 22,
              letterSpacing: -0.55,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (showReset)
          TextButton(
            onPressed: onReset,
            child: Text(l10n.filterReset),
          ),
      ],
    );
  }
}

/// The headline filter — makeable-with-my-bar — set apart from the rest of
/// the sheet because it is the one control the whole flow is built around.
class _MakeableRow extends StatelessWidget {
  const _MakeableRow({
    required this.bar,
    required this.drinksCount,
    required this.value,
    required this.onChanged,
  });

  final BarProvider bar;
  final int drinksCount;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return MergeSemantics(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          color: AppColors.signalWash,
          borderRadius: AppRadius.tileAll,
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                // A stronger pour of the same wash the card sits on — this
                // is the one control that has to look heavier than the rest.
                color: AppColors.signal.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.local_bar,
                size: 19,
                color: AppColors.signalLight,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.filterMakeableTitle,
                    style: AppTypography.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bar.isEmpty
                        ? l10n.filterMakeableEmptyBar
                        : l10n.filterMakeableSubtitle(
                            bar.bottleCount,
                            drinksCount,
                          ),
                    style: AppTypography.meta,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

/// Sort as a visible segmented control — never a hidden preference.
class _SortSegmented extends StatelessWidget {
  const _SortSegmented({required this.value, required this.onChanged});

  final ExploreSort value;
  final ValueChanged<ExploreSort> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.fillSubtle,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final (index, sort) in ExploreSort.values.indexed) ...[
            if (index > 0) const SizedBox(width: 4),
            Expanded(
              child: _SortSegment(
                label: sortLabel(l10n, sort),
                selected: sort == value,
                onTap: () => onChanged(sort),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SortSegment extends StatelessWidget {
  const _SortSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(11),
          child: AnimatedContainer(
            duration: AppMotion.tap,
            curve: AppMotion.curve,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.fillStrong : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Text(
              label,
              style: AppTypography.body.copyWith(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                height: 1.0,
                color: selected ? AppColors.ink : AppColors.inkBody,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

class _SpiritWrap extends StatelessWidget {
  const _SpiritWrap({required this.selected, required this.onToggle});

  final Set<BaseSpirit> selected;
  final ValueChanged<BaseSpirit> onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final spirit in BaseSpirit.values)
          TagChip(
            label: spiritLabel(l10n, spirit),
            selected: selected.contains(spirit),
            onTap: () => onToggle(spirit),
          ),
      ],
    );
  }
}

/// The three effort toggles, in the house grouped-list pattern: one hairline
/// gap between opaque rows over a shared fill, rather than a border on each.
class _EffortList extends StatelessWidget {
  const _EffortList({required this.draft, required this.onChanged});

  final ExploreFilters draft;
  final ValueChanged<ExploreFilters> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ClipRRect(
      borderRadius: AppRadius.tileAll,
      child: ColoredBox(
        color: AppColors.fillSubtle,
        child: Column(
          children: [
            _EffortRow(
              icon: Icons.timer,
              label: l10n.filterUnderThreeMinutes,
              value: draft.underThreeMinutes,
              onChanged: (value) =>
                  onChanged(draft.copyWith(underThreeMinutes: value)),
            ),
            const SizedBox(height: 1),
            _EffortRow(
              icon: Icons.block,
              label: l10n.filterNoShaker,
              value: draft.noShaker,
              onChanged: (value) => onChanged(draft.copyWith(noShaker: value)),
            ),
            const SizedBox(height: 1),
            _EffortRow(
              icon: Icons.looks_3_outlined,
              label: l10n.filterThreeIngredients,
              value: draft.threeIngredientsMax,
              onChanged: (value) =>
                  onChanged(draft.copyWith(threeIngredientsMax: value)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EffortRow extends StatelessWidget {
  const _EffortRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Material(
        color: AppColors.row,
        child: InkWell(
          onTap: () => onChanged(!value),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.signalLight),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.body.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Switch(value: value, onChanged: onChanged),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The one white control in a sheet that is otherwise all dark fills — the
/// button carries the primary action, so it is the thing the eye lands on.
class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      // A hair taller than AppSizes.buttonPrimary: the sheet's own colours
      // (ink on ground) diverge from the themed primary button, so this
      // sets its own metrics rather than half-borrow the theme's.
      height: 58,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.ground,
          disabledBackgroundColor: AppColors.fillMuted,
          disabledForegroundColor: AppColors.inkMeta,
          textStyle: AppTypography.buttonPrimary,
          shape: const StadiumBorder(),
        ),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
