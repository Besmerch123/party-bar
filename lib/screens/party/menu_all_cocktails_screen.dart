import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/bar_provider.dart';
import '../../providers/explore_provider.dart';
import '../../providers/party_menu_draft.dart';
import '../../theme/theme.dart';
import '../../utils/cocktail_labels.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/auth/auth_controls.dart';
import '../../widgets/party/host_filter_pill.dart';
import '../../widgets/party/menu_cocktail_row.dart';
import '../../widgets/party/missing_ingredient_sheet.dart';
import 'menu_search_screen.dart';

/// Opens the full list seeded with [current] — the draft's menu, or a live
/// party's — and returns what the host left with, or null if nothing changed.
Future<List<Cocktail>?> pickPartyMenu(
  BuildContext context,
  List<Cocktail> current,
) async {
  final menu = PartyMenuDraft(initial: current);
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: const RouteSettings(name: kMenuPickerRouteName),
      builder: (_) => ChangeNotifierProvider<PartyMenuDraft>.value(
        value: menu,
        child: const MenuAllCocktailsScreen(),
      ),
    ),
  );

  final picked = menu.cocktails;
  menu.dispose();

  final before = current.map((c) => c.id).toSet();
  final after = picked.map((c) => c.id).toSet();
  if (before.length == after.length && before.containsAll(after)) return null;
  return picked;
}

/// Flow 05 · screen 05 — every cocktail, nothing hidden, everything labelled.
///
/// Two sections: what the shelf can pour now, and what needs shopping,
/// closest first. Shares the [PartyMenuDraft] of the step that pushed it.
class MenuAllCocktailsScreen extends StatefulWidget {
  const MenuAllCocktailsScreen({super.key});

  @override
  State<MenuAllCocktailsScreen> createState() => _MenuAllCocktailsScreenState();
}

class _MenuAllCocktailsScreenState extends State<MenuAllCocktailsScreen> {
  BaseSpirit? _spirit;

  void _openSearch() {
    final menu = context.read<PartyMenuDraft>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: kMenuPickerRouteName),
        builder: (_) => ChangeNotifierProvider<PartyMenuDraft>.value(
          value: menu,
          child: const MenuSearchScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final menu = context.watch<PartyMenuDraft>();
    final shelf = context.watch<BarProvider>().shelf;
    final fetched = context.watch<ExploreProvider>().fetched;

    final spirits = BaseSpirit.values
        .where((s) => s != BaseSpirit.other)
        .where((s) => fetched.any((c) => c.baseSpirit == s))
        .toList(growable: false);

    final rows = [
      for (final cocktail in fetched)
        if (_spirit == null || cocktail.baseSpirit == _spirit)
          (cocktail, makeabilityOf(cocktail, shelf)),
    ];
    final ready = rows.where((r) => r.$2.isMakeable).toList(growable: false);

    // Closest first; a recipe that has not loaded its ingredients has no
    // distance to measure, so it goes last rather than looking pourable.
    int distance(Makeability m) =>
        m.requiredCount == 0 ? 1 << 20 : m.missingCount;
    final shopping = rows.where((r) => !r.$2.isMakeable).toList()
      ..sort((a, b) => distance(a.$2).compareTo(distance(b.$2)));

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(17, 3, 17, 0),
              child: Row(
                children: [
                  AuthIconAction(
                    icon: Icons.arrow_back,
                    semanticLabel: MaterialLocalizations.of(
                      context,
                    ).backButtonTooltip,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      l10n.hostAllTitle,
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 14,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  AuthIconAction(
                    icon: Icons.search,
                    semanticLabel: l10n.hostMenuSearchHint,
                    onTap: _openSearch,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: AppSpacing.screen,
              child: Row(
                children: [
                  HostFilterPill(
                    label: l10n.hostAllFilterAll,
                    selected: _spirit == null,
                    onTap: () => setState(() => _spirit = null),
                  ),
                  for (final spirit in spirits) ...[
                    const SizedBox(width: 8),
                    HostFilterPill(
                      label: spiritLabel(l10n, spirit),
                      selected: _spirit == spirit,
                      onTap: () => setState(
                        () => _spirit = _spirit == spirit ? null : spirit,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  18,
                  AppSpacing.screenEdge,
                  AppSpacing.md,
                ),
                children: [
                  if (ready.isNotEmpty) ...[
                    _Eyebrow(
                      label: l10n.hostAllReady(ready.length),
                      color: AppColors.ready,
                    ),
                    const SizedBox(height: 12),
                    for (final (i, (cocktail, _)) in ready.indexed) ...[
                      if (i > 0) const SizedBox(height: 1),
                      _readyRow(menu, cocktail, menuGroupRadius(i, ready.length)),
                    ],
                    const SizedBox(height: 22),
                  ],
                  if (shopping.isNotEmpty) ...[
                    _Eyebrow(
                      label: l10n.hostAllNeedsShopping(shopping.length),
                      color: AppColors.low,
                      note: l10n.hostAllClosestFirst,
                    ),
                    const SizedBox(height: 12),
                    for (final (i, (cocktail, makeability))
                        in shopping.indexed) ...[
                      if (i > 0) const SizedBox(height: 1),
                      _shoppingRow(
                        menu,
                        cocktail,
                        makeability,
                        menuGroupRadius(i, shopping.length),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                6,
                AppSpacing.screenEdge,
                20,
              ),
              child: AuthPillButton(
                label: l10n.hostAllDone(menu.count),
                primary: true,
                height: AppSizes.buttonSecondary,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _readyRow(PartyMenuDraft menu, Cocktail cocktail, BorderRadius radius) {
    final l10n = context.l10n;
    final name = cocktail.title.translate(context);
    final picked = menu.contains(cocktail.id);
    final parts = [
      l10n.hostAllIngredientCount(cocktail.requiredIngredients.length),
      if (cocktail.method != null)
        methodLabel(l10n, cocktail.method!).toLowerCase(),
    ];

    return MenuCocktailRow(
      name: name,
      image: cocktail.image,
      subtitle: parts.join(' · '),
      picked: picked,
      thumbSize: 46,
      borderRadius: radius,
      semanticLabel: picked ? l10n.hostMenuRemove(name) : l10n.hostMenuAdd(name),
      onToggle: () => menu.toggle(cocktail),
    );
  }

  Widget _shoppingRow(
    PartyMenuDraft menu,
    Cocktail cocktail,
    Makeability makeability,
    BorderRadius radius,
  ) {
    final l10n = context.l10n;
    final name = cocktail.title.translate(context);
    final picked = menu.contains(cocktail.id);
    final missing = makeability.missing
        .map((ingredient) => ingredient.title.translate(context))
        .join(', ');

    return MenuCocktailRow(
      name: name,
      image: cocktail.image,
      subtitle: missing.isEmpty
          ? null
          : l10n.hostAllShort(makeability.missingCount, missing),
      subtitleColor: AppColors.low,
      dimmed: true,
      picked: picked,
      thumbSize: 46,
      borderRadius: radius,
      semanticLabel: picked ? l10n.hostMenuRemove(name) : l10n.hostMenuAdd(name),
      onToggle: () => toggleOnMenu(context, cocktail),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.label, required this.color, this.note});

  final String label;
  final Color color;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label.toUpperCase(),
            style: AppTypography.label.copyWith(color: color),
          ),
        ),
        if (note != null)
          Text(
            note!,
            style: AppTypography.meta.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.ink.withValues(alpha: .45),
            ),
          ),
      ],
    );
  }
}
