import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/cocktail_repository.dart';
import '../../models/models.dart';
import '../../providers/bar_provider.dart';
import '../../providers/explore_provider.dart';
import '../../providers/party_menu_draft.dart';
import '../../services/elastic_service.dart';
import '../../theme/theme.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/party/menu_cocktail_row.dart';
import '../../widgets/party/missing_ingredient_sheet.dart';
import 'create_party_screen.dart' show HostInfoNote;

/// Flow 05 · screen 04 — search while building the menu.
///
/// What is short is said inline, on the row, instead of hiding the drink:
/// the host decides. Reads and writes the [PartyMenuDraft] provided by the
/// step that pushed it.
class MenuSearchScreen extends StatefulWidget {
  const MenuSearchScreen({super.key});

  @override
  State<MenuSearchScreen> createState() => _MenuSearchScreenState();
}

class _MenuSearchScreenState extends State<MenuSearchScreen> {
  final _controller = TextEditingController();
  final _repository = CocktailRepository();

  Timer? _debounce;
  int _requestId = 0;

  /// Null until a query has been searched — until then the rows are what
  /// Explore already fetched.
  List<Cocktail>? _results;
  bool _loading = false;
  bool _failed = false;
  bool _onlyMakeable = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(ExploreProvider.debounce, () => _search(value));
  }

  Future<void> _search(String raw) async {
    _debounce?.cancel();
    final query = raw.trim();
    final requestId = ++_requestId;

    if (query.isEmpty) {
      setState(() {
        _results = null;
        _loading = false;
        _failed = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _failed = false;
    });

    try {
      final result = await _repository.searchCocktails(
        query: query,
        pagination: const PaginationParams(pageSize: 30),
      );
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _results = result.cocktails;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  void _toggle(PartyMenuDraft menu, Cocktail cocktail) =>
      toggleOnMenu(context, cocktail);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final menu = context.watch<PartyMenuDraft>();
    final shelf = context.watch<BarProvider>().shelf;
    final explore = context.watch<ExploreProvider>();

    final rows = [
      for (final cocktail in _results ?? explore.fetched)
        (cocktail, makeabilityOf(cocktail, shelf)),
    ].where((row) => !_onlyMakeable || row.$2.isMakeable).toList();

    final short = rows.where((row) => row.$2.missing.isNotEmpty).firstOrNull;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                10,
                AppSpacing.screenEdge - 8,
                0,
              ),
              child: Row(
                children: [
                  Expanded(child: _field(l10n.hostMenuSearchHint)),
                  const SizedBox(width: 2),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      l10n.hostSearchDone,
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 13,
                        color: AppColors.signalLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                14,
                AppSpacing.screenEdge - 6,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.hostSearchMatches(rows.length).toUpperCase(),
                      style: AppTypography.label.copyWith(
                        color: AppColors.inkMeta,
                      ),
                    ),
                  ),
                  Text(
                    l10n.hostSearchOnlyMakeable,
                    style: AppTypography.meta.copyWith(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink.withValues(alpha: .5),
                    ),
                  ),
                  Transform.scale(
                    scale: .75,
                    child: Switch(
                      value: _onlyMakeable,
                      activeTrackColor: AppColors.signal,
                      onChanged: (value) =>
                          setState(() => _onlyMakeable = value),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _list(menu, rows, short)),
          ],
        ),
      ),
    );
  }

  Widget _field(String hint) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.row,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.signal, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 19, color: AppColors.signalLight),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onChanged,
              onSubmitted: _search,
              textInputAction: TextInputAction.search,
              cursorColor: AppColors.signal,
              style: AppTypography.cardTitle.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: hint,
                hintStyle: AppTypography.body.copyWith(
                  fontSize: 13.5,
                  color: AppColors.ink.withValues(alpha: .38),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(
    PartyMenuDraft menu,
    List<(Cocktail, Makeability)> rows,
    (Cocktail, Makeability)? short,
  ) {
    final l10n = context.l10n;

    if (rows.isEmpty) {
      final Widget message;
      if (_loading) {
        message = const CircularProgressIndicator(color: AppColors.signal);
      } else if (_failed) {
        message = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.hostMenuLoadFailed, style: AppTypography.body),
            TextButton(
              onPressed: () => _search(_controller.text),
              child: Text(l10n.hostRetry),
            ),
          ],
        );
      } else if (_controller.text.trim().isNotEmpty) {
        message = Text(
          l10n.hostSearchNoResults(_controller.text.trim()),
          style: AppTypography.body,
          textAlign: TextAlign.center,
        );
      } else {
        message = const SizedBox.shrink();
      }
      return Padding(
        padding: AppSpacing.screen,
        child: Center(child: message),
      );
    }

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        8,
        AppSpacing.screenEdge,
        AppSpacing.md,
      ),
      children: [
        for (final (i, (cocktail, makeability)) in rows.indexed) ...[
          if (i > 0) const SizedBox(height: 1),
          _row(menu, cocktail, makeability, menuGroupRadius(i, rows.length)),
        ],
        if (short != null) ...[
          const SizedBox(height: 14),
          HostInfoNote(
            icon: Icons.shopping_basket_outlined,
            text: l10n.hostSearchShoppingTip(
              short.$2.missing.first.title.translate(context),
            ),
          ),
        ],
      ],
    );
  }

  Widget _row(
    PartyMenuDraft menu,
    Cocktail cocktail,
    Makeability makeability,
    BorderRadius radius,
  ) {
    final l10n = context.l10n;
    final name = cocktail.title.translate(context);
    final picked = menu.contains(cocktail.id);

    Widget? badge;
    if (makeability.isMakeable) {
      badge = MenuStockBadge(label: l10n.hostBadgeAllInStock, ready: true);
    } else if (makeability.isOneAway) {
      badge = MenuStockBadge(
        label: l10n.hostBadgeNo(
          makeability.missing.single.title.translate(context),
        ),
        ready: false,
      );
    } else if (makeability.missing.isNotEmpty) {
      badge = MenuStockBadge(
        label: l10n.hostBadgeMissing(makeability.missingCount),
        ready: false,
      );
    }

    final ingredients = cocktail.requiredIngredients
        .map((ingredient) => ingredient.title.translate(context))
        .join(' · ');

    return MenuCocktailRow(
      name: name,
      image: cocktail.image,
      subtitle: ingredients.isEmpty ? null : ingredients,
      badge: badge,
      picked: picked,
      emphasiseAdd: makeability.isMakeable,
      borderRadius: radius,
      semanticLabel: picked ? l10n.hostMenuRemove(name) : l10n.hostMenuAdd(name),
      onToggle: () => _toggle(menu, cocktail),
    );
  }
}
