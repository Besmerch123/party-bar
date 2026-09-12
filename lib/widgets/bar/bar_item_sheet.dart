import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/bar_provider.dart';
import '../../providers/explore_provider.dart';
import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/bar_labels.dart';
import '../../utils/localization_helper.dart';
import '../common/app_sheet.dart';
import 'bar_row.dart';

/// Flow 04 · screen 05 — the item sheet.
///
/// One switch (stocked or not), one shortcut for the moment it runs dry, one
/// note, one way out. Whatever unlocks because of this bottle gets a couple
/// of photos, never a counter that reads like a campaign.
Future<void> showBarItemSheet(BuildContext context, String key) {
  return showAppSheet<void>(context, (_) => _BarItemSheet(itemKey: key));
}

class _BarItemSheet extends StatefulWidget {
  const _BarItemSheet({required this.itemKey});

  final String itemKey;

  @override
  State<_BarItemSheet> createState() => _BarItemSheetState();
}

class _BarItemSheetState extends State<_BarItemSheet> {
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    // The "unlocks for you" tiles need BarStats, which needs Explore's own
    // fetch — reached from search before the feed has ever loaded, this
    // would otherwise sit with nothing to show rather than asking for it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final explore = context.read<ExploreProvider>();
      if (!explore.hasLoaded && !explore.isLoading) explore.load();
    });
  }

  /// Shared by the auto-close effect and the Done button, so however the
  /// sheet ends up closing, it only ever pops once.
  void _close() {
    if (_closed) return;
    _closed = true;
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    if (_closed) return const SizedBox.shrink();

    final bar = context.watch<BarProvider>();
    final item = bar.itemFor(widget.itemKey);

    // Undone from the row's own circle, restocked from the shopping list,
    // removed from another sheet entirely — however it happened, there is
    // nothing left here to show.
    if (item == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _close());
      return const SizedBox.shrink();
    }

    final explore = context.watch<ExploreProvider>();
    final stats = BarStats.compute(explore.fetched, bar.shelf);
    final name = barItemName(context, item);

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
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.ink.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _Header(item: item, name: name, stats: stats),
            const SizedBox(height: 22),
            _ActionGroup(bar: bar, item: item, name: name, onClose: _close),
            if (stats.makeableUsing(item.key).isNotEmpty) ...[
              const SizedBox(height: 20),
              _UnlocksSection(cocktails: stats.makeableUsing(item.key)),
            ],
            const SizedBox(height: 22),
            _DoneButton(onTap: _close),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.item, required this.name, required this.stats});

  final BarItem item;
  final String name;
  final BarStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final parts = <String>[barSectionLabel(l10n, item.section)];
    if (stats.hasCatalogue) {
      final used = stats.usedInMakeable(item.key);
      if (used > 0) {
        parts.add(
          item.kind == BarItemKind.equipment
              ? l10n.barNeededForYourDrinks(used)
              : l10n.barInYourDrinks(used),
        );
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BarThumb(image: item.image, icon: barSectionIcon(item.section), size: 64),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: AppTypography.title.copyWith(
                  fontSize: 22,
                  height: 1.1,
                  letterSpacing: -0.66,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 7),
              Text(
                parts.join(' · '),
                style: AppTypography.meta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The four grouped rows: stocked switch, the ran-out shortcut (stocked
/// items only), the note, and remove. One hairline-thin gap between each,
/// clipped to one outer radius — [BarRow]'s own shape belongs to a plain
/// list, not this huddle.
class _ActionGroup extends StatelessWidget {
  const _ActionGroup({
    required this.bar,
    required this.item,
    required this.name,
    required this.onClose,
  });

  final BarProvider bar;
  final BarItem item;
  final String name;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final note = item.note?.trim();
    final hasNote = note != null && note.isNotEmpty;

    return ClipRRect(
      borderRadius: AppRadius.tileAll,
      child: Container(
        color: AppColors.fillSubtle,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetRow(
              icon: Icons.check_circle,
              iconColor: AppColors.ready,
              label: l10n.barSheetOnShelf,
              trailing: Switch(
                value: item.isStocked,
                activeTrackColor: AppColors.ready,
                onChanged: (_) => bar.toggleStocked(item.key),
              ),
            ),
            if (item.isStocked) ...[
              const SizedBox(height: 1),
              _SheetRow(
                icon: Icons.remove_shopping_cart,
                iconColor: AppColors.low,
                label: l10n.barSheetRanOut,
                trailing: const Icon(
                  Icons.chevron_right,
                  size: 19,
                  color: AppColors.inkMeta,
                ),
                onTap: () async {
                  await bar.markRanOut(item.key, addToList: true);
                  onClose();
                },
              ),
            ],
            const SizedBox(height: 1),
            _SheetRow(
              icon: Icons.edit_note,
              iconColor: AppColors.signalLight,
              label: l10n.barSheetNote,
              trailing: Text(
                hasNote ? note : l10n.barSheetNoteAdd,
                style: AppTypography.meta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _editNote(context, bar, item),
            ),
            const SizedBox(height: 1),
            _SheetRow(
              icon: Icons.delete,
              iconColor: AppColors.inkMeta,
              label: l10n.barSheetRemove,
              labelColor: AppColors.inkBody,
              onTap: () => _remove(context, bar, item, name, onClose),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _editNote(BuildContext context, BarProvider bar, BarItem item) async {
  final result = await showDialog<String>(
    context: context,
    builder: (_) => _NoteDialog(initialNote: item.note ?? ''),
  );

  if (result == null || !context.mounted) return;
  await bar.setNote(item.key, result);
}

/// Its own widget, not a controller built inline, so the [TextEditingController]
/// is disposed when this dialog's element actually leaves the tree — after
/// its closing transition finishes — rather than the instant [showDialog]'s
/// future completes, which is a frame or two too early.
class _NoteDialog extends StatefulWidget {
  const _NoteDialog({required this.initialNote});

  final String initialNote;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialNote,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      backgroundColor: AppColors.row,
      title: Text(
        l10n.barSheetNote,
        style: AppTypography.cardTitle.copyWith(fontSize: 16),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 2,
        style: AppTypography.body.copyWith(color: AppColors.ink),
        decoration: InputDecoration(hintText: l10n.barSheetNoteHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(l10n.barSheetNoteSave),
        ),
      ],
    );
  }
}

/// Removes the item, then offers one tap to undo — restoring not just the
/// bottle but the note and ran-out status it had a moment ago, so undo
/// really does mean "as it was" rather than "back, blank".
Future<void> _remove(
  BuildContext context,
  BarProvider bar,
  BarItem item,
  String name,
  VoidCallback onClose,
) async {
  final entry = item.toEntry();
  final note = item.note;
  final wasRanOut = !item.isStocked;
  final l10n = context.l10n;

  await bar.removeItem(item.key);
  if (!context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  onClose();

  messenger.showSnackBar(
    SnackBar(
      content: Text(l10n.barRemoved(name)),
      action: SnackBarAction(
        label: l10n.barUndo,
        onPressed: () => _undoRemoval(bar, entry, note: note, wasRanOut: wasRanOut),
      ),
    ),
  );
}

Future<void> _undoRemoval(
  BarProvider bar,
  BarCatalogueEntry entry, {
  required String? note,
  required bool wasRanOut,
}) async {
  await bar.addEntry(entry);
  if (wasRanOut) await bar.markRanOut(entry.key);
  if (note != null && note.isNotEmpty) await bar.setNote(entry.key, note);
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.labelColor,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: label,
      child: Material(
        color: AppColors.row,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.cardTitle.copyWith(
                      fontSize: 14,
                      color: labelColor ?? AppColors.ink,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 12),
                  // Loose, not tight — a long note preview still has to
                  // give way rather than overflow the row, the same
                  // trade-off BarRow's own trailing slot makes.
                  Flexible(child: trailing!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "UNLOCKS FOR YOU" — up to two photos of what this bottle would make
/// possible, most popular first, and a "+N more" tile rather than a longer
/// and longer row once there is more to say than two photos can.
class _UnlocksSection extends StatelessWidget {
  const _UnlocksSection({required this.cocktails});

  final List<Cocktail> cocktails;

  @override
  Widget build(BuildContext context) {
    final shown = cocktails.take(2).toList(growable: false);
    final more = cocktails.length - shown.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.l10n.barSheetUnlocks.toUpperCase(),
          style: AppTypography.label,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, cocktail) in shown.indexed) ...[
              if (i > 0) const SizedBox(width: 10),
              _UnlockTile(cocktail: cocktail),
            ],
            if (more > 0) ...[
              const SizedBox(width: 10),
              Expanded(child: _MoreTile(count: more)),
            ],
          ],
        ),
      ],
    );
  }
}

class _UnlockTile extends StatelessWidget {
  const _UnlockTile({required this.cocktail});

  final Cocktail cocktail;

  @override
  Widget build(BuildContext context) {
    final title = cocktail.title.translate(context);

    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: AppColors.row,
        borderRadius: AppRadius.tileAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () =>
              context.push('${AppRoutes.cocktailDetails}/${cocktail.id}'),
          child: SizedBox(
            width: 100,
            height: 126,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (cocktail.image.isNotEmpty)
                  Image.network(
                    cocktail.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const ColoredBox(color: AppColors.row),
                  )
                else
                  const ColoredBox(color: AppColors.row),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 56,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.ground.withValues(alpha: 0.85),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.cardTitle.copyWith(fontSize: 13),
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

class _MoreTile extends StatelessWidget {
  const _MoreTile({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 126,
      decoration: BoxDecoration(
        color: AppColors.row,
        borderRadius: AppRadius.tileAll,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '+$count',
            style: AppTypography.title.copyWith(
              fontSize: 20,
              height: 1.0,
              letterSpacing: -0.2,
              color: AppColors.signalLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.barSheetMore,
            style: AppTypography.meta.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _DoneButton extends StatelessWidget {
  const _DoneButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.barSheetDone,
      child: Material(
        color: AppColors.fillStrong,
        borderRadius: AppRadius.pillAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.pillAll,
          child: Container(
            height: 54,
            alignment: Alignment.center,
            child: Text(
              context.l10n.barSheetDone,
              style: AppTypography.cardTitle.copyWith(
                fontSize: 14,
                color: AppColors.inkBody,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
