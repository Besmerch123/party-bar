import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bar_provider.dart';
import '../../providers/explore_provider.dart';
import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/bar_labels.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/bar/bar_item_sheet.dart';
import '../../widgets/bar/bar_row.dart';
import '../../widgets/bar/bar_sign_in_nudge.dart';
import '../../widgets/common/app_bottom_nav.dart';

/// Flow 04 · screens 01, 03, 04 — the shelf itself.
///
/// Three looks, one screen: the twelve starters before anything is owned, the
/// grouped shelf once something is, and that same shelf cut down to whatever
/// section chips are on. Which one shows is read straight off [BarProvider];
/// only the starter view's own "stay put while I tap a few more" latch and
/// which chips are on live in this widget's state.
class MyBarScreen extends StatefulWidget {
  const MyBarScreen({super.key});

  @override
  State<MyBarScreen> createState() => _MyBarScreenState();
}

class _MyBarScreenState extends State<MyBarScreen> {
  bool _starterLatchDecided = false;

  /// Once the shelf was empty and the starter list showed, it keeps showing
  /// — the design's "one ticked row still in this view" — until search or
  /// the add button is opened, or every starter has been added.
  bool _showStarters = false;

  Set<BarSection> _selectedSections = const {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BarProvider>().loadCatalogue();
      final explore = context.read<ExploreProvider>();
      if (!explore.hasLoaded && !explore.isLoading) explore.load();
    });
  }

  void _decideStarterLatch(BarProvider bar) {
    if (_starterLatchDecided || !bar.isInitialized) return;
    _starterLatchDecided = true;
    _showStarters = !bar.hasItems;
  }

  void _leaveStarters() {
    if (_showStarters) setState(() => _showStarters = false);
  }

  Future<void> _openSearch() async {
    _leaveStarters();
    await context.push(AppRoutes.barSearch);
    if (!mounted) return;
    await maybeNudgeSignIn(context);
  }

  Future<void> _openShoppingList() => context.push(AppRoutes.shoppingList);

  void _toggleSection(BarSection section) {
    setState(() {
      final next = Set<BarSection>.of(_selectedSections);
      if (!next.remove(section)) next.add(section);
      _selectedSections = next;
    });
  }

  void _clearSections() {
    if (_selectedSections.isEmpty) return;
    setState(() => _selectedSections = const {});
  }

  Future<void> _addStarter(BarCatalogueEntry entry) async {
    await context.read<BarProvider>().addEntry(entry);
    if (!mounted) return;
    await maybeNudgeSignIn(context);
  }

  Future<void> _addAllStarters(BarProvider bar) async {
    final missing = kShelfStarters.where((s) => !bar.shelf.contains(s.key));
    await bar.addEntries(missing);
    if (!mounted) return;
    await maybeNudgeSignIn(context);
  }

  @override
  Widget build(BuildContext context) {
    final bar = context.watch<BarProvider>();
    _decideStarterLatch(bar);

    // No spinner flash while the device copy is still being read — just the
    // ground colour until there is a real answer.
    if (!bar.isInitialized) {
      return const Scaffold(
        backgroundColor: AppColors.ground,
        body: SizedBox.shrink(),
      );
    }

    final auth = context.watch<AuthenticationProvider>();
    final explore = context.watch<ExploreProvider>();
    final stats = BarStats.compute(explore.fetched, bar.shelf);

    final allStartersOnShelf = kShelfStarters.every(
      (s) => bar.shelf.contains(s.key),
    );
    final showStarters = _showStarters && !allStartersOnShelf;

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        bottom: false,
        child: showStarters
            ? _buildEmptyShelf(bar, auth.isAuthenticated)
            : _buildShelf(bar, stats),
      ),
    );
  }

  // ------------------------------------------------------------- 01 · empty

  Widget _buildEmptyShelf(BarProvider bar, bool signedIn) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenEdge,
            12,
            AppSpacing.screenEdge,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.barTitle,
                style: AppTypography.title.copyWith(
                  fontSize: 30,
                  height: 1.02,
                  letterSpacing: -1.05,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                signedIn ? l10n.barEmptyBodySignedIn : l10n.barEmptyBody,
                style: AppTypography.meta,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenEdge,
            18,
            AppSpacing.screenEdge,
            0,
          ),
          child: _SearchPill(onTap: _openSearch),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenEdge,
              24,
              AppSpacing.screenEdge,
              AppBottomNav.insetOf(context),
            ),
            children: [
              BarGroupHeader(
                label: l10n.barStartersSection,
                actionLabel: l10n.barAddAll,
                onAction: () => _addAllStarters(bar),
              ),
              const SizedBox(height: 14),
              for (final (i, starter) in kShelfStarters.indexed) ...[
                if (i > 0) const SizedBox(height: 8),
                _starterRow(context, bar, starter, _addStarter, (key) {
                  context.read<BarProvider>().removeItem(key);
                }),
              ],
              const SizedBox(height: 16),
              Center(
                child: Text(
                  l10n.barStartersFooter,
                  style: AppTypography.meta,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------- 03 / 04 · shelf

  Widget _buildShelf(BarProvider bar, BarStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(bar, stats),
        const SizedBox(height: 16),
        _buildChips(bar),
        const SizedBox(height: 4),
        Expanded(
          child: _selectedSections.isEmpty
              ? _buildUnfiltered(bar, stats)
              : _buildFiltered(bar, stats),
        ),
      ],
    );
  }

  Widget _buildHeader(BarProvider bar, BarStats stats) {
    final l10n = context.l10n;
    final stockedCount = bar.stocked.length;
    final unticked = bar.shoppingList.where((e) => !e.ticked).length;

    final String subtitle;
    if (_selectedSections.isEmpty) {
      subtitle =
          l10n.barShelfCount(stockedCount) +
          (stats.hasCatalogue
              ? ' · ${l10n.barMakeableCount(stats.makeableCount)}'
              : '');
    } else {
      final ordered = BarSection.values.where(_selectedSections.contains);
      final labels = ordered
          .map((s) => barSectionLabel(l10n, s))
          .join(', ');
      final itemsInSelected = bar.items
          .where((i) => _selectedSections.contains(i.section))
          .length;
      subtitle = '$labels · ${l10n.barThingsCount(itemsInSelected)}';
    }

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
                  l10n.barTitle,
                  style: AppTypography.title.copyWith(
                    fontSize: 30,
                    height: 1.02,
                    letterSpacing: -1.05,
                  ),
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
          _HeaderIconButton(
            icon: Icons.receipt_long,
            background: AppColors.fillStrong,
            iconColor: AppColors.ink,
            semanticsLabel: l10n.barOpenList,
            badgeCount: unticked,
            onTap: _openShoppingList,
          ),
          const SizedBox(width: 10),
          _HeaderIconButton(
            icon: Icons.add,
            background: AppColors.signal,
            iconColor: Colors.white,
            semanticsLabel: l10n.barAddItem,
            badgeCount: 0,
            onTap: _openSearch,
          ),
        ],
      ),
    );
  }

  Widget _buildChips(BarProvider bar) {
    final l10n = context.l10n;
    // A section earns a chip the moment anything of its lives on the bar —
    // stocked or ran out — so a section that has gone entirely dry is still
    // reachable in the filtered view (04) that shows its ran-out rows inline.
    final sections = BarSection.values
        .where((s) => bar.items.any((i) => i.section == s))
        .toList(growable: false);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
      child: Row(
        children: [
          _ChipShell(
            text: '${l10n.barFilterAll} ${bar.stocked.length}',
            selected: _selectedSections.isEmpty,
            showClose: false,
            onTap: _clearSections,
          ),
          for (final section in sections) ...[
            const SizedBox(width: 8),
            _ChipShell(
              text: _chipLabel(l10n, bar, section),
              selected: _selectedSections.contains(section),
              showClose: _selectedSections.contains(section),
              onTap: () => _toggleSection(section),
            ),
          ],
        ],
      ),
    );
  }

  /// The label alone once a chip is selected (design 04); otherwise the
  /// label plus how many of the section are actually stocked — omitted
  /// when that count is zero rather than printing a bare "0".
  String _chipLabel(AppLocalizations l10n, BarProvider bar, BarSection section) {
    final label = barSectionLabel(l10n, section);
    if (_selectedSections.contains(section)) return label;

    final count = bar.stocked.where((i) => i.section == section).length;
    return count > 0 ? '$label $count' : label;
  }

  Widget _buildUnfiltered(BarProvider bar, BarStats stats) {
    final l10n = context.l10n;
    final stocked = bar.stocked;
    final ranOut = bar.ranOut;
    final sections = BarSection.values
        .where((s) => stocked.any((i) => i.section == s))
        .toList(growable: false);
    final ranOutAllOnList =
        ranOut.isNotEmpty && ranOut.every((i) => bar.isOnList(i.key));

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        16,
        AppSpacing.screenEdge,
        AppBottomNav.insetOf(context),
      ),
      children: [
        for (final section in sections) ...[
          BarGroupHeader(
            label:
                '${barGroupLabel(l10n, section)} · '
                '${stocked.where((i) => i.section == section).length}',
          ),
          const SizedBox(height: 12),
          for (final (i, item)
              in stocked.where((i) => i.section == section).indexed) ...[
            if (i > 0) const SizedBox(height: 8),
            _stockedRow(context, item, stats),
          ],
          const SizedBox(height: 22),
        ],
        if (ranOut.isNotEmpty) ...[
          BarGroupHeader(
            label: '${l10n.barRanOutGroup} · ${ranOut.length}',
            color: AppColors.low,
            actionLabel: ranOutAllOnList ? null : l10n.barAddAllToList,
            onAction: ranOutAllOnList ? null : bar.addRanOutToList,
          ),
          const SizedBox(height: 12),
          for (final (i, item) in ranOut.indexed) ...[
            if (i > 0) const SizedBox(height: 8),
            _ranOutRow(context, bar, item, stats),
          ],
        ],
      ],
    );
  }

  Widget _buildFiltered(BarProvider bar, BarStats stats) {
    final l10n = context.l10n;
    final ordered = BarSection.values.where(_selectedSections.contains);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        16,
        AppSpacing.screenEdge,
        AppBottomNav.insetOf(context),
      ),
      children: [
        for (final section in ordered) ...[
          BarGroupHeader(
            label:
                '${barGroupLabel(l10n, section)} · '
                '${bar.items.where((i) => i.section == section).length}',
          ),
          const SizedBox(height: 12),
          for (final (i, item)
              in bar.items.where((i) => i.section == section).indexed) ...[
            if (i > 0) const SizedBox(height: 8),
            item.isStocked
                ? _stockedRow(context, item, stats)
                : _filteredRanOutRow(context, bar, item),
          ],
          const SizedBox(height: 22),
        ],
        if (_selectedSections.contains(BarSection.fresh))
          _freshInfoCard(context),
      ],
    );
  }
}

// ----------------------------------------------------------------- widgets

class _SearchPill extends StatelessWidget {
  const _SearchPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.barSearchHint,
      child: Material(
        color: AppColors.sheet,
        borderRadius: AppRadius.pillAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.pillAll,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                const Icon(Icons.search, size: 20, color: AppColors.inkMeta),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    context.l10n.barSearchHint,
                    style: AppTypography.body.copyWith(
                      fontSize: 13.5,
                      color: AppColors.inkMeta,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The 40px circle a shelf header ends with — the shopping list and the way
/// into search, each with room for a small count badge.
class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.semanticsLabel,
    required this.badgeCount,
    required this.onTap,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final String semanticsLabel;
  final int badgeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: background,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(child: Icon(icon, size: 22, color: iconColor)),
                if (badgeCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: AppColors.signal,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A filter pill — plain when off, white with a close glyph when on. The
/// design's own vocabulary, distinct from [TagChip]'s blue-when-selected
/// look, which belongs to Explore.
class _ChipShell extends StatelessWidget {
  const _ChipShell({
    required this.text,
    required this.selected,
    required this.showClose,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final bool showClose;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: text,
      child: Material(
        color: selected ? Colors.white : AppColors.fillStrong,
        borderRadius: AppRadius.pillAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.pillAll,
          child: Padding(
            padding: EdgeInsets.fromLTRB(14, 9, showClose ? 12 : 14, 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: AppTypography.body.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                    color: selected ? AppColors.ground : AppColors.inkBody,
                  ),
                ),
                if (showClose) ...[
                  const SizedBox(width: 7),
                  const Icon(Icons.close, size: 15, color: AppColors.ground),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------- rows

Widget _starterRow(
  BuildContext context,
  BarProvider bar,
  BarCatalogueEntry starter,
  ValueChanged<BarCatalogueEntry> onAdd,
  ValueChanged<String> onUndo,
) {
  final l10n = context.l10n;
  final resolved = bar.entryFor(starter.key) ?? starter;
  final stocked = bar.shelf.contains(starter.key);
  final name = barEntryName(context, resolved);

  String? subtitle;
  Color? subtitleColor;
  if (stocked) {
    subtitle = l10n.barOnYourShelf;
    subtitleColor = AppColors.ready;
  } else if (resolved.cocktailCount != null) {
    subtitle = resolved.kind == BarItemKind.equipment
        ? l10n.barNeededForDrinks(resolved.cocktailCount!)
        : l10n.barInDrinks(resolved.cocktailCount!);
  }

  return BarRow(
    leading: BarThumb(
      image: resolved.image,
      icon: barSectionIcon(resolved.section),
      checked: stocked,
    ),
    title: name,
    subtitle: subtitle,
    subtitleColor: subtitleColor,
    trailing: stocked
        ? BarActionCircle(
            icon: Icons.check,
            tone: BarActionTone.ready,
            semanticsLabel: '${l10n.barSheetRemove} ($name)',
            onTap: () => onUndo(starter.key),
          )
        : BarActionCircle(
            icon: Icons.add,
            tone: BarActionTone.neutral,
            semanticsLabel: '${l10n.barAddItem} ($name)',
            onTap: () => onAdd(resolved),
          ),
  );
}

Widget _stockedRow(BuildContext context, BarItem item, BarStats stats) {
  final l10n = context.l10n;
  final name = barItemName(context, item);

  String? subtitle;
  if (item.isRecentlyAdded(DateTime.now())) {
    subtitle = l10n.barAddedJustNow;
  } else {
    final parts = <String>[];
    final note = item.note?.trim();
    if (note != null && note.isNotEmpty) parts.add(note);
    if (stats.hasCatalogue) {
      final n = stats.usedInMakeable(item.key);
      if (n > 0) {
        parts.add(
          item.kind == BarItemKind.equipment
              ? l10n.barNeededForYourDrinks(n)
              : l10n.barInYourDrinks(n),
        );
      }
    }
    if (parts.isNotEmpty) subtitle = parts.join(' · ');
  }

  return BarRow(
    leading: BarThumb(image: item.image, icon: barSectionIcon(item.section)),
    title: name,
    subtitle: subtitle,
    trailing: BarActionCircle(
      icon: Icons.check,
      tone: BarActionTone.ready,
      semanticsLabel: l10n.barMarkRanOut(name),
      onTap: () => context.read<BarProvider>().toggleStocked(item.key),
    ),
    onTap: () => showBarItemSheet(context, item.key),
  );
}

Widget _ranOutRow(
  BuildContext context,
  BarProvider bar,
  BarItem item,
  BarStats stats,
) {
  final l10n = context.l10n;
  final name = barItemName(context, item);
  final blocks = stats.blockedBy(item.key);
  final onList = bar.isOnList(item.key);

  final String subtitle;
  if (onList) {
    subtitle = blocks > 0
        ? '${l10n.barBlocksDrinks(blocks)} · ${l10n.barOnYourList}'
        : l10n.barOnYourList;
  } else {
    subtitle = blocks > 0 ? l10n.barBlocksDrinks(blocks) : l10n.barRanOutGroup;
  }

  return BarRow(
    leading: BarThumb(
      image: item.image,
      icon: barSectionIcon(item.section),
      tone: BarThumbTone.low,
    ),
    title: name,
    titleColor: AppColors.ink.withValues(alpha: 0.85),
    subtitle: subtitle,
    subtitleColor: AppColors.low,
    trailing: onList
        ? BarActionCircle(
            icon: Icons.check,
            tone: BarActionTone.dim,
            semanticsLabel: l10n.barPutBack(name),
            onTap: () => bar.restock(item.key),
          )
        : BarPillAction(
            label: l10n.barAddToList,
            onTap: () => bar.addToList(
              item.toEntry(),
              reason: ShoppingReason.ranOut,
            ),
          ),
    onTap: () => showBarItemSheet(context, item.key),
  );
}

Widget _filteredRanOutRow(BuildContext context, BarProvider bar, BarItem item) {
  final l10n = context.l10n;
  final name = barItemName(context, item);

  return BarRow(
    leading: BarThumb(image: item.image, icon: barSectionIcon(item.section)),
    title: name,
    titleColor: AppColors.inkBody,
    subtitle: l10n.barNotInYourBar,
    trailing: BarActionCircle(
      icon: Icons.check,
      tone: BarActionTone.dim,
      semanticsLabel: l10n.barPutBack(name),
      onTap: () => bar.restock(item.key),
    ),
    onTap: () => showBarItemSheet(context, item.key),
  );
}

Widget _freshInfoCard(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: AppColors.sheet,
      borderRadius: AppRadius.tileAll,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, size: 19, color: AppColors.signalLight),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            context.l10n.barFreshInfo,
            style: AppTypography.meta.copyWith(height: 1.5),
          ),
        ),
      ],
    ),
  );
}
