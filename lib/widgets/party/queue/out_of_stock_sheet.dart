import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/order_repository.dart';
import '../../../models/models.dart';
import '../../../providers/bar_provider.dart';
import '../../../theme/theme.dart';
import '../../../utils/localization_helper.dart';
import '../../auth/auth_controls.dart';
import '../host_sheets.dart';
import '../menu_cocktail_tile.dart';
import '../order_bits.dart';

/// Flow 06 · screen 12 — running out is one tap: name the ingredient, see
/// every drink it blocks, and pull them from the menu in one write.
///
/// Returns true once the order being poured has been pulled one way or the
/// other, so the pouring screen knows to close behind it.
Future<bool> showOutOfStockFlow(
  BuildContext context, {
  required Party party,
  required CocktailOrder order,
  required Cocktail cocktail,
  required List<Cocktail> menu,
  required List<CocktailOrder> allOrders,
}) async {
  Ingredient? ingredient;
  if (cocktail.ingredients.length > 1) {
    ingredient = await _showWhatRanOutSheet(context, cocktail: cocktail);
  } else if (cocktail.ingredients.isNotEmpty) {
    ingredient = cocktail.ingredients.first;
  }
  if (ingredient == null || !context.mounted) return false;

  return _showOutOfIngredientSheet(
    context,
    party: party,
    order: order,
    ingredient: ingredient,
    menu: menu,
    allOrders: allOrders,
  );
}

/// The first sheet, for a drink with more than one ingredient: which bottle
/// actually ran out.
Future<Ingredient?> _showWhatRanOutSheet(
  BuildContext context, {
  required Cocktail cocktail,
}) {
  return showHostSheet<Ingredient>(context, (context) {
    final l10n = context.l10n;
    return HostSheet(
      children: [
        HostSheetTitle(l10n.queueWhatRanOutTitle, size: 22),
        const SizedBox(height: 16),
        HostRowGroup(
          children: [
            for (final ingredient in cocktail.ingredients)
              Material(
                color: AppColors.row,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(ingredient),
                  child: Padding(
                    padding: const EdgeInsets.all(13),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: MenuCocktailImage(image: ingredient.image),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            ingredient.title.translate(context),
                            style: AppTypography.body.copyWith(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  });
}

Future<bool> _showOutOfIngredientSheet(
  BuildContext context, {
  required Party party,
  required CocktailOrder order,
  required Ingredient ingredient,
  required List<Cocktail> menu,
  required List<CocktailOrder> allOrders,
}) async {
  final pulled = await showHostSheet<bool>(
    context,
    (context) => _OutOfIngredientSheetContent(
      party: party,
      order: order,
      ingredient: ingredient,
      menu: menu,
      allOrders: allOrders,
    ),
  );
  return pulled ?? false;
}

class _OutOfIngredientSheetContent extends StatefulWidget {
  const _OutOfIngredientSheetContent({
    required this.party,
    required this.order,
    required this.ingredient,
    required this.menu,
    required this.allOrders,
  });

  final Party party;
  final CocktailOrder order;
  final Ingredient ingredient;
  final List<Cocktail> menu;
  final List<CocktailOrder> allOrders;

  @override
  State<_OutOfIngredientSheetContent> createState() => _OutOfIngredientSheetContentState();
}

class _OutOfIngredientSheetContentState extends State<_OutOfIngredientSheetContent> {
  late List<Cocktail> _affected;
  late Set<String> _toggled;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _affected = cocktailsNeeding(widget.ingredient.id, widget.menu);
    if (_affected.every((c) => c.id != widget.order.cocktailId)) {
      final current = widget.menu.where((c) => c.id == widget.order.cocktailId).firstOrNull;
      if (current != null) _affected = [current, ..._affected];
    }
    _toggled = _affected.map((c) => c.id).toSet();
  }

  /// Orders a pull would actually take back — in line or being poured. One
  /// already on the counter is poured, and stays.
  int _waitingFor(String cocktailId) => widget.allOrders
      .where(
        (o) => (o.isPending || o.isPreparing) && o.cocktailId == cocktailId,
      )
      .length;

  String? _firstAffectedGuest() {
    final open = widget.allOrders
        .where((o) => o.isOpen && _toggled.contains(o.cocktailId))
        .toList();
    return oldestFirst(open).firstOrNull?.guestName;
  }

  Future<void> _pull(bool onlyThisOrder) async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      if (onlyThisOrder) {
        await OrderRepository().cancelByHost(
          widget.order,
          reason: CancelReason.outOfStock,
          outOf: widget.ingredient,
        );
      } else {
        final cocktailIds = _toggled.toList();
        // The drink being poured is why this sheet is open, so it is pulled
        // even if its own switch was turned off — otherwise the pouring
        // screen closes on an order still marked as pouring.
        final orders = [
          widget.order,
          ...widget.allOrders.where(
            (o) =>
                o.id != widget.order.id &&
                o.isOpen &&
                cocktailIds.contains(o.cocktailId),
          ),
        ];
        await OrderRepository().pullForStock(
          partyId: widget.party.id,
          ingredient: widget.ingredient,
          orders: orders,
          cocktailIds: cocktailIds,
        );
      }

      if (!mounted) return;
      final bar = context.read<BarProvider>();
      final trackedKey = ingredientKeys(widget.ingredient)
          .where((key) => bar.itemFor(key) != null)
          .firstOrNull;
      if (trackedKey != null) await bar.markRanOut(trackedKey);

      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.hostSaveFailed)));
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ingredientName = widget.ingredient.title.translate(context);
    final firstGuest = _firstAffectedGuest();

    return HostSheet(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 52,
              height: 52,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: MenuCocktailImage(image: widget.ingredient.image),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.queueOutOfTitle(ingredientName),
                    style: AppTypography.heading.copyWith(fontSize: 22, height: 1),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.queueOutOfSubtitle(_affected.length),
                    style: AppTypography.meta,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        HostRowGroup(
          children: [
            for (final drink in _affected)
              _AffectedDrinkRow(
                cocktail: drink,
                waiting: _waitingFor(drink.id),
                on: _toggled.contains(drink.id),
                onChanged: (on) => setState(() {
                  if (on) {
                    _toggled.add(drink.id);
                  } else {
                    _toggled.remove(drink.id);
                  }
                }),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: AppColors.lowWash, borderRadius: AppRadius.tileAll),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.forward_to_inbox, size: 18, color: AppColors.low),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      firstGuest == null
                          ? l10n.queueGuestsToldGeneric
                          : l10n.queueGuestsToldTitle(firstGuest),
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 12.5,
                        color: kHostLowLight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                l10n.queueGuestsToldBody(hostFirstName(widget.party.hostName), ingredientName),
                style: AppTypography.meta.copyWith(
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.inkBody,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        AuthPillButton(
          label: l10n.queuePullDrinks(_toggled.length),
          height: AppSizes.buttonPrimary,
          background: AppColors.low,
          foreground: AppColors.ground,
          onPressed: _toggled.isEmpty || _busy ? null : () => _pull(false),
        ),
        const SizedBox(height: 10),
        AuthPillButton(
          label: l10n.queueKeepOnMenu,
          height: AppSizes.buttonGhost,
          onPressed: _busy ? null : () => _pull(true),
        ),
      ],
    );
  }
}

class _AffectedDrinkRow extends StatelessWidget {
  const _AffectedDrinkRow({
    required this.cocktail,
    required this.waiting,
    required this.on,
    required this.onChanged,
  });

  final Cocktail cocktail;
  final int waiting;
  final bool on;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      color: AppColors.row,
      padding: const EdgeInsets.all(13),
      child: Row(
        children: [
          OrderThumb(image: cocktail.image, size: 40, radius: 11, greyed: waiting == 0),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cocktail.title.translate(context),
                  style: AppTypography.body.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(l10n.queueWaitingInQueue(waiting), style: AppTypography.meta.copyWith(fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: on,
            onChanged: onChanged,
            activeThumbColor: AppColors.ground,
            activeTrackColor: AppColors.low,
          ),
        ],
      ),
    );
  }
}
