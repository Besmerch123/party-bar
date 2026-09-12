import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/bar_provider.dart';
import '../../providers/explore_provider.dart';
import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/bar_labels.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/bar/bar_row.dart';
import '../../widgets/bar/share_list_sheet.dart';

/// Flow 04 · screen 06 — the list a host actually buys from.
///
/// Ticking an entry does two things at once: it stocks the item and it
/// crosses the line out, because on this list "bought" and "on the shelf"
/// are the same fact. Nothing here ever shows a quantity — the shelf stayed
/// binary, so the list that feeds it does too.
class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  @override
  void initState() {
    super.initState();
    // The "blocking your drinks" section needs to know what the shelf is
    // actually missing — if Explore has not fetched anything yet, ask it to,
    // the same way the search screen and the shelf itself do.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final explore = context.read<ExploreProvider>();
      if (!explore.hasLoaded) explore.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bar = context.watch<BarProvider>();
    final explore = context.watch<ExploreProvider>();
    final stats = BarStats.compute(explore.fetched, bar.shelf);

    final shoppingList = bar.shoppingList;
    final unticked = shoppingList.where((e) => !e.ticked).toList(growable: false);
    final ticked = shoppingList.where((e) => e.ticked).toList(growable: false);

    final blocking = stats.hasCatalogue
        ? unticked.where((e) => stats.blockedBy(e.key) > 0).toList(growable: false)
        : const <ShoppingEntry>[];
    final blockingKeys = blocking.map((e) => e.key).toSet();
    final also = shoppingList
        .where((e) => !blockingKeys.contains(e.key))
        .toList(growable: false);

    final canShare = unticked.isNotEmpty;
    final canClearTicked = ticked.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopRow(canShare: canShare, canClearTicked: canClearTicked, bar: bar),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                14,
                AppSpacing.screenEdge,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.shoppingListTitle,
                    style: AppTypography.titleCompact,
                  ),
                  const SizedBox(height: 9),
                  Text(
                    l10n.shoppingListSubtitle(unticked.length),
                    style: AppTypography.meta,
                  ),
                ],
              ),
            ),
            Expanded(
              child: shoppingList.isEmpty
                  ? const _EmptyList()
                  : _ListBody(blocking: blocking, also: also, bar: bar, stats: stats),
            ),
            _BottomBar(canShare: canShare, canClearTicked: canClearTicked, bar: bar),
          ],
        ),
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({required this.canShare, required this.canClearTicked, required this.bar});

  final bool canShare;
  final bool canClearTicked;
  final BarProvider bar;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        8,
        AppSpacing.screenEdge,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _RoundIconButton(
            icon: Icons.arrow_back,
            semanticsLabel: MaterialLocalizations.of(context).backButtonTooltip,
            onTap: () {
              if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.myBar);
              }
            },
          ),
          Row(
            children: [
              _RoundIconButton(
                icon: Icons.ios_share,
                semanticsLabel: l10n.shoppingListShare,
                enabled: canShare,
                onTap: canShare ? () => showShareListSheet(context) : null,
              ),
              const SizedBox(width: 8),
              _RoundIconButton(
                icon: Icons.more_horiz,
                semanticsLabel: l10n.barSheetMore,
                onTap: () => _openMenu(context, canClearTicked: canClearTicked),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openMenu(BuildContext context, {required bool canClearTicked}) async {
    final l10n = context.l10n;

    final action = await showModalBottomSheet<_ListMenuAction>(
      context: context,
      backgroundColor: AppColors.sheet,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
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
            const SizedBox(height: 8),
            if (canClearTicked)
              ListTile(
                leading: const Icon(Icons.check_circle_outline, color: AppColors.inkBody),
                title: Text(
                  l10n.shoppingListClearTicked,
                  style: AppTypography.body.copyWith(color: AppColors.ink),
                ),
                onTap: () => Navigator.of(sheetContext).pop(_ListMenuAction.clearTicked),
              ),
            ListTile(
              leading: const Icon(Icons.delete_sweep_outlined, color: AppColors.inkBody),
              title: Text(
                l10n.shoppingListClearAll,
                style: AppTypography.body.copyWith(color: AppColors.ink),
              ),
              onTap: () => Navigator.of(sheetContext).pop(_ListMenuAction.clearAll),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    switch (action) {
      case _ListMenuAction.clearTicked:
        await bar.clearTicked();
      case _ListMenuAction.clearAll:
        await bar.clearList();
      case null:
        break;
    }
  }
}

enum _ListMenuAction { clearTicked, clearAll }

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.semanticsLabel,
    this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String semanticsLabel;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: semanticsLabel,
      child: Material(
        color: AppColors.fillStrong,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(icon, size: 18, color: enabled ? AppColors.ink : AppColors.inkMeta),
          ),
        ),
      ),
    );
  }
}

/// Blocking entries first, then everything else — ticked ones included, so
/// the list still shows what was just bought rather than making it vanish.
class _ListBody extends StatelessWidget {
  const _ListBody({
    required this.blocking,
    required this.also,
    required this.bar,
    required this.stats,
  });

  final List<ShoppingEntry> blocking;
  final List<ShoppingEntry> also;
  final BarProvider bar;
  final BarStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        22,
        AppSpacing.screenEdge,
        32,
      ),
      children: [
        if (blocking.isNotEmpty) ...[
          BarGroupHeader(
            label: '${l10n.shoppingListBlockingHeader} · ${blocking.length}',
            color: AppColors.low,
          ),
          const SizedBox(height: 12),
          for (final (index, entry) in blocking.indexed) ...[
            if (index > 0) const SizedBox(height: 8),
            _ShoppingRow(
              entry: entry,
              blocking: true,
              blockCount: stats.blockedBy(entry.key),
              bar: bar,
            ),
          ],
          const SizedBox(height: 22),
          BarGroupHeader(label: '${l10n.shoppingListAlsoHeader} · ${also.length}'),
          const SizedBox(height: 12),
        ],
        for (final (index, entry) in also.indexed) ...[
          if (index > 0) const SizedBox(height: 8),
          _ShoppingRow(entry: entry, blocking: false, blockCount: 0, bar: bar),
        ],
        const SizedBox(height: 16),
        const _AddSomethingRow(),
      ],
    );
  }
}

class _ShoppingRow extends StatelessWidget {
  const _ShoppingRow({
    required this.entry,
    required this.blocking,
    required this.blockCount,
    required this.bar,
  });

  final ShoppingEntry entry;
  final bool blocking;
  final int blockCount;
  final BarProvider bar;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ticked = entry.ticked;

    return Dismissible(
      key: ValueKey(entry.key),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => bar.removeFromList(entry.key),
      background: Container(
        margin: const EdgeInsets.only(bottom: 0),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: AppColors.lowWash, borderRadius: AppRadius.tileAll),
        child: Semantics(
          label: l10n.shoppingListRemove,
          child: const Icon(Icons.delete_outline, color: AppColors.low),
        ),
      ),
      child: BarRow(
        leading: _ShoppingCheckbox(ticked: ticked),
        title: shoppingEntryName(context, entry),
        titleColor: ticked ? AppColors.inkMeta : null,
        titleDecoration: ticked ? TextDecoration.lineThrough : null,
        subtitle: _subtitleFor(l10n, entry, blocking: blocking, blockCount: blockCount),
        subtitleColor: ticked
            ? AppColors.ready
            : (blocking ? AppColors.low : null),
        onTap: () => bar.toggleTick(entry.key),
      ),
    );
  }
}

class _ShoppingCheckbox extends StatelessWidget {
  const _ShoppingCheckbox({required this.ticked});

  final bool ticked;

  @override
  Widget build(BuildContext context) {
    if (ticked) {
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppColors.ready,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.check, size: 18, color: AppColors.ground),
      );
    }
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.ink.withValues(alpha: .25), width: 2),
      ),
    );
  }
}

/// Ticked always wins ("now on your shelf" — the whole point of ticking);
/// short of that, blocking beats the plain reason, since it is the more
/// useful thing to tell someone about to go shopping.
String _subtitleFor(
  AppLocalizations l10n,
  ShoppingEntry entry, {
  required bool blocking,
  required int blockCount,
}) {
  if (entry.ticked) return l10n.shoppingListNowOnShelf;
  if (blocking) return l10n.shoppingListBlockingLine(blockCount);
  return shoppingReasonText(l10n, entry);
}

class _AddSomethingRow extends StatelessWidget {
  const _AddSomethingRow();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Semantics(
      button: true,
      label: l10n.shoppingListAddSomething,
      child: Material(
        color: AppColors.sheet,
        borderRadius: AppRadius.tileAll,
        child: InkWell(
          borderRadius: AppRadius.tileAll,
          onTap: () => context.push('${AppRoutes.barSearch}?mode=list'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Icon(Icons.add, size: 20, color: AppColors.inkMeta),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.shoppingListAddSomething,
                    style: AppTypography.body.copyWith(color: AppColors.inkMeta),
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

class _EmptyList extends StatelessWidget {
  const _EmptyList();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        40,
        AppSpacing.screenEdge,
        32,
      ),
      children: [
        Text(l10n.shoppingListEmptyTitle, style: AppTypography.heading),
        const SizedBox(height: 10),
        Text(l10n.shoppingListEmptyBody, style: AppTypography.body),
        const SizedBox(height: 22),
        const _AddSomethingRow(),
      ],
    );
  }
}

/// Both actions are omitted, not disabled, when there is nothing for them to
/// do — an always-visible "Share the list" button over an empty list would
/// be sharing nothing.
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.canShare, required this.canClearTicked, required this.bar});

  final bool canShare;
  final bool canClearTicked;
  final BarProvider bar;

  @override
  Widget build(BuildContext context) {
    if (!canShare && !canClearTicked) return const SizedBox.shrink();

    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        16,
        AppSpacing.screenEdge,
        22,
      ),
      child: Column(
        children: [
          if (canShare)
            SizedBox(
              height: 56,
              width: double.infinity,
              child: Material(
                color: Colors.white,
                borderRadius: AppRadius.pillAll,
                child: InkWell(
                  borderRadius: AppRadius.pillAll,
                  onTap: () => showShareListSheet(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.ios_share, size: 20, color: AppColors.ground),
                      const SizedBox(width: 9),
                      Flexible(
                        child: Text(
                          l10n.shoppingListShare,
                          style: AppTypography.buttonPrimary.copyWith(
                            fontSize: 14.5,
                            color: AppColors.ground,
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
          if (canShare && canClearTicked) const SizedBox(height: 10),
          if (canClearTicked)
            SizedBox(
              height: 44,
              width: double.infinity,
              child: TextButton(
                onPressed: () => bar.clearTicked(),
                child: Text(
                  l10n.shoppingListClearTicked,
                  style: AppTypography.body.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkBody,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
