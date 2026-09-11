import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/bar_provider.dart';
import '../../providers/explore_provider.dart';
import '../../theme/theme.dart';
import '../../utils/bar_labels.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/bar/bar_row.dart';

/// Which list [BarSearchScreen] is adding to — the shelf itself, or the
/// shopping list (reached with `?mode=list`).
enum BarSearchMode { shelf, list }

/// Flow 04 · screen 02 — search is the only way onto the shelf, and it adds
/// in place: there is no separate "confirm" step, a tap on a result flips
/// straight to stocked and the row updates under your thumb.
///
/// The same screen doubles as the shopping list's own search
/// ([BarSearchMode.list]) — the field, the highlighting and the "add your
/// own" card all behave the same way, only what a tap commits to differs.
class BarSearchScreen extends StatefulWidget {
  const BarSearchScreen({super.key, this.mode = BarSearchMode.shelf});

  final BarSearchMode mode;

  @override
  State<BarSearchScreen> createState() => _BarSearchScreenState();
}

class _BarSearchScreenState extends State<BarSearchScreen> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode.addListener(_handleFocusChange);

    // Neither load is required for the search screen itself to work — the
    // starter list and the catalogue already in memory are enough — but
    // kicking both off here means the results that need them (drink counts,
    // the full catalogue past the starters) are ready by the time typing
    // catches up.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BarProvider>().loadCatalogue();
      final explore = context.read<ExploreProvider>();
      if (!explore.hasLoaded) explore.load();
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

  void _onChanged(String value) => setState(() => _query = value);

  /// Shared by the custom-add card: adding clears the field and drops back
  /// to the starter suggestions rather than leaving a stale query on screen.
  void _clearField() {
    _controller.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bar = context.watch<BarProvider>();

    return Scaffold(
      backgroundColor: AppColors.ground,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                10,
                AppSpacing.screenEdge,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _SearchField(
                      controller: _controller,
                      focusNode: _focusNode,
                      focused: _focused,
                      hint: widget.mode == BarSearchMode.list
                          ? l10n.barSearchListHint
                          : l10n.barSearchHint,
                      onChanged: _onChanged,
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      l10n.barSearchCancel,
                      style: AppTypography.body.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkBody,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (bar.catalogueLoading)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: SizedBox(
                  height: 2,
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor: AppColors.fillSubtle,
                    valueColor: AlwaysStoppedAnimation(AppColors.signal),
                  ),
                ),
              )
            else if (bar.catalogueFailed)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  8,
                  AppSpacing.screenEdge,
                  0,
                ),
                child: Text(
                  l10n.barCatalogueOffline,
                  style: AppTypography.meta,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Expanded(
              child: _Body(
                mode: widget.mode,
                query: _query,
                bar: bar,
                onCustomAdded: _clearField,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.focused,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool focused;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.sheet,
        borderRadius: AppRadius.pillAll,
        border: focused ? Border.all(color: AppColors.signal, width: 1.5) : null,
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: AppColors.inkMeta),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => focusNode.unfocus(),
              style: AppTypography.body.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1,
                color: AppColors.ink,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: AppTypography.body.copyWith(color: AppColors.inkMeta),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Everything below the field: the starter suggestions or the ran-out list
/// when nothing has been typed, the ranked matches once it has.
class _Body extends StatelessWidget {
  const _Body({
    required this.mode,
    required this.query,
    required this.bar,
    required this.onCustomAdded,
  });

  final BarSearchMode mode;
  final String query;
  final BarProvider bar;
  final VoidCallback onCustomAdded;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      return mode == BarSearchMode.shelf
          ? _StartersList(bar: bar)
          : _RanOutForList(bar: bar);
    }

    final candidates = _candidates(bar);
    final matches = searchBarCatalogue(
      candidates,
      trimmed,
      nameOf: (entry) => barEntryName(context, entry),
    );

    final foldedQuery = trimmed.toLowerCase();
    final showCustomCard = !matches.any(
      (match) => barEntryName(context, match.entry).toLowerCase() == foldedQuery,
    );

    // Only the shelf mode singles out one row for the brighter "primary" add
    // circle — the first result nothing is tracking yet, i.e. the one tap
    // most likely to be why someone searched at all.
    var firstOtherIndex = -1;
    if (mode == BarSearchMode.shelf) {
      for (var i = 0; i < matches.length; i++) {
        if (bar.itemFor(matches[i].entry.key) == null) {
          firstOtherIndex = i;
          break;
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        20,
        AppSpacing.screenEdge,
        32,
      ),
      children: [
        BarGroupHeader(label: l10n.barSearchMatches(matches.length)),
        const SizedBox(height: 14),
        for (final (index, match) in matches.indexed) ...[
          if (index > 0) const SizedBox(height: 8),
          mode == BarSearchMode.shelf
              ? _shelfRow(
                  context,
                  bar,
                  match.entry,
                  titleSpan: _highlightSpan(
                    barEntryName(context, match.entry),
                    match.start,
                    match.end,
                  ),
                  primary: index == firstOtherIndex,
                )
              : _listRow(
                  context,
                  bar,
                  match.entry,
                  titleSpan: _highlightSpan(
                    barEntryName(context, match.entry),
                    match.start,
                    match.end,
                  ),
                ),
        ],
        if (showCustomCard) ...[
          const SizedBox(height: 16),
          _CustomAddCard(
            mode: mode,
            query: trimmed,
            bar: bar,
            onAdded: onCustomAdded,
          ),
        ],
      ],
    );
  }

  /// The catalogue, plus a shape for any of the host's own items the
  /// catalogue itself has never heard of — a custom bottle typed in once
  /// still has to be findable the next time someone searches for it.
  List<BarCatalogueEntry> _candidates(BarProvider bar) {
    final map = <String, BarCatalogueEntry>{
      for (final entry in bar.catalogue) entry.key: entry,
    };
    for (final item in bar.items) {
      map.putIfAbsent(item.key, () => item.toEntry());
    }
    return map.values.toList(growable: false);
  }
}

/// Screen 01's twelve suggestions, offered again here — search is the only
/// way in, but it does not have to start from a blank field.
class _StartersList extends StatelessWidget {
  const _StartersList({required this.bar});

  final BarProvider bar;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        20,
        AppSpacing.screenEdge,
        32,
      ),
      children: [
        BarGroupHeader(label: l10n.barStartersSection),
        const SizedBox(height: 14),
        for (final (index, starter) in kShelfStarters.indexed) ...[
          if (index > 0) const SizedBox(height: 8),
          _shelfRow(context, bar, bar.entryFor(starter.key) ?? starter),
        ],
      ],
    );
  }
}

/// The shopping list's own search, before anything has been typed: whatever
/// just ran out and is not on the list yet is the obvious thing to offer.
class _RanOutForList extends StatelessWidget {
  const _RanOutForList({required this.bar});

  final BarProvider bar;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = bar.ranOut
        .where((item) => !bar.isOnList(item.key))
        .toList(growable: false);
    if (items.isEmpty) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        20,
        AppSpacing.screenEdge,
        32,
      ),
      children: [
        BarGroupHeader(label: l10n.barRanOutGroup),
        const SizedBox(height: 14),
        for (final (index, item) in items.indexed) ...[
          if (index > 0) const SizedBox(height: 8),
          _listRow(context, bar, item.toEntry()),
        ],
      ],
    );
  }
}

/// "Not here? Add it as your own" — search never dead-ends, even for a
/// bottle the catalogue has no idea exists.
class _CustomAddCard extends StatelessWidget {
  const _CustomAddCard({
    required this.mode,
    required this.query,
    required this.bar,
    required this.onAdded,
  });

  final BarSearchMode mode;
  final String query;
  final BarProvider bar;
  final VoidCallback onAdded;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = mode == BarSearchMode.list
        ? l10n.barAddCustomToList(query)
        : l10n.barAddCustom(query);

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppColors.signalWash,
        borderRadius: AppRadius.tileAll,
        child: InkWell(
          borderRadius: AppRadius.tileAll,
          onTap: () async {
            if (mode == BarSearchMode.list) {
              await bar.addToList(
                BarCatalogueEntry.custom(query),
                reason: ShoppingReason.manual,
              );
            } else {
              await bar.addCustom(query);
            }
            onAdded();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.add_circle, size: 20, color: AppColors.signalLight),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.body.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                      color: AppColors.inkBody,
                    ),
                    maxLines: 2,
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

/// Shelf mode's three row states, shared by the starter list and the ranked
/// matches: already stocked, ran out and one tap from true again, or nothing
/// tracking it yet.
Widget _shelfRow(
  BuildContext context,
  BarProvider bar,
  BarCatalogueEntry entry, {
  InlineSpan? titleSpan,
  bool primary = false,
}) {
  final l10n = context.l10n;
  final name = barEntryName(context, entry);
  final item = bar.itemFor(entry.key);

  if (item != null && item.isStocked) {
    return BarRow(
      leading: BarThumb(
        image: entry.image,
        icon: barSectionIcon(entry.section),
        checked: true,
      ),
      title: name,
      titleSpan: titleSpan,
      subtitle: l10n.barAlreadyOnShelf,
      subtitleColor: AppColors.ready,
      trailing: BarActionCircle(
        icon: Icons.check,
        tone: BarActionTone.ready,
        semanticsLabel: l10n.barAlreadyOnShelf,
      ),
    );
  }

  if (item != null && !item.isStocked) {
    return BarRow(
      leading: BarThumb(
        image: entry.image,
        icon: barSectionIcon(entry.section),
        tone: BarThumbTone.low,
      ),
      title: name,
      titleSpan: titleSpan,
      subtitle: l10n.barRanOutTapRestock,
      subtitleColor: AppColors.low,
      trailing: BarActionCircle(
        icon: Icons.add,
        semanticsLabel: l10n.barPutBack(name),
        onTap: () => bar.restock(entry.key),
      ),
    );
  }

  return BarRow(
    leading: BarThumb(image: entry.image, icon: barSectionIcon(entry.section)),
    title: name,
    titleSpan: titleSpan,
    subtitle: _defaultSubtitle(l10n, entry),
    trailing: BarActionCircle(
      icon: Icons.add,
      tone: primary ? BarActionTone.primary : BarActionTone.neutral,
      semanticsLabel: l10n.barAddItem,
      onTap: () => bar.addEntry(entry),
    ),
  );
}

/// The shopping list's own two row states: already on it, or one tap away.
Widget _listRow(
  BuildContext context,
  BarProvider bar,
  BarCatalogueEntry entry, {
  InlineSpan? titleSpan,
}) {
  final l10n = context.l10n;
  final name = barEntryName(context, entry);

  if (bar.isOnList(entry.key)) {
    return BarRow(
      leading: BarThumb(
        image: entry.image,
        icon: barSectionIcon(entry.section),
        checked: true,
      ),
      title: name,
      titleSpan: titleSpan,
      subtitle: l10n.barAlreadyOnList,
      subtitleColor: AppColors.ready,
      trailing: BarActionCircle(
        icon: Icons.check,
        tone: BarActionTone.ready,
        semanticsLabel: l10n.barAlreadyOnList,
      ),
    );
  }

  return BarRow(
    leading: BarThumb(image: entry.image, icon: barSectionIcon(entry.section)),
    title: name,
    titleSpan: titleSpan,
    subtitle: _defaultSubtitle(l10n, entry),
    trailing: BarActionCircle(
      icon: Icons.add,
      semanticsLabel: l10n.barAddToList,
      onTap: () => bar.addToList(entry, reason: ShoppingReason.manual),
    ),
  );
}

/// A row with nothing more specific to say still says something: the
/// section it belongs to, and — when the catalogue knows — how many drinks
/// it would open up.
String _defaultSubtitle(AppLocalizations l10n, BarCatalogueEntry entry) {
  final section = barSectionLabel(l10n, entry.section);
  final count = entry.cocktailCount;
  if (count == null) return section;
  return '$section · ${l10n.barInDrinksInline(count)}';
}

/// Colours the matched range of [name] in [AppColors.signalLight], leaving
/// the rest to inherit the row's own title style.
InlineSpan _highlightSpan(String name, int start, int end) {
  if (start < 0 || end > name.length || start >= end) {
    return TextSpan(text: name);
  }
  return TextSpan(
    children: [
      if (start > 0) TextSpan(text: name.substring(0, start)),
      TextSpan(
        text: name.substring(start, end),
        style: const TextStyle(color: AppColors.signalLight),
      ),
      if (end < name.length) TextSpan(text: name.substring(end)),
    ],
  );
}
