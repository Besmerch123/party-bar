import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/measure_unit_provider.dart';
import '../../providers/party_cocktails.dart';
import '../../services/order_service.dart';
import '../../theme/theme.dart';
import '../../utils/cocktail_labels.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/auth/auth_controls.dart';
import '../../widgets/party/order_bits.dart';
import '../../widgets/party/queue/method_sheet.dart';
import '../../widgets/party/queue/out_of_stock_sheet.dart';
import '../../widgets/party/queue/queue_sheets.dart';

/// Flow 06 · screen 10 — pouring: measures big, the guest's note on top,
/// the method one tap away.
///
/// Pushed from the queue once "Start pouring" (or "Pour now") fires. Owns
/// its own stream of the party's orders so it can follow this one order live
/// and pop the moment it stops being `preparing` anywhere else — another
/// device putting it up, or the host cancelling it from the queue.
class PouringScreen extends StatefulWidget {
  const PouringScreen({
    super.key,
    required this.party,
    required this.order,
    required this.cocktails,
  });

  final Party party;
  final CocktailOrder order;
  final PartyCocktails cocktails;

  @override
  State<PouringScreen> createState() => _PouringScreenState();
}

class _PouringScreenState extends State<PouringScreen> {
  late final Stream<List<CocktailOrder>> _orders;
  late CocktailOrder _order;
  List<CocktailOrder> _all = const [];
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _orders = OrderService().streamPartyOrders(widget.party.id);
    widget.cocktails.ensure({widget.order.cocktailId});
  }

  void _maybeLeave(CocktailOrder? live) {
    if (_leaving) return;
    if (live == null || !live.isPreparing) {
      _leaving = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
          Navigator.of(context).maybePop();
        }
      });
    }
  }

  Future<void> _markReady() async {
    try {
      await OrderService().markReady(_order);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.hostSaveFailed)));
      return;
    }
    if (mounted) Navigator.of(context).maybePop();
  }

  Future<void> _cancelOrder(Cocktail? cocktail) async {
    final name = cocktail?.title.translate(context) ?? _order.cocktailId;
    final go = await showCancelOrderConfirmSheet(
      context,
      cocktailName: name,
      guestName: _order.guestName,
    );
    if (!go || !mounted) return;
    try {
      await OrderService().skip(_order);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.hostSaveFailed)));
      return;
    }
    if (mounted) Navigator.of(context).maybePop();
  }

  Future<void> _outOfSomething(Cocktail? cocktail) async {
    if (cocktail == null) return;
    final pulled = await showOutOfStockFlow(
      context,
      party: widget.party,
      order: _order,
      cocktail: cocktail,
      menu: widget.cocktails.resolve(widget.party.availableCocktailIds),
      allOrders: _all,
    );
    if (pulled && mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.cocktails,
      builder: (context, _) {
        final cocktail = widget.cocktails.byId(_order.cocktailId);
        return StreamBuilder<List<CocktailOrder>>(
          stream: _orders,
          builder: (context, snap) {
            final all = snap.data;
            if (all != null) {
              _all = all;
              final live = all.where((o) => o.id == widget.order.id).firstOrNull;
              if (live != null) _order = live;
              _maybeLeave(live);
            }

            return PouringBody(
              party: widget.party,
              order: _order,
              cocktail: cocktail,
              position: positionOf(_order, _all.isEmpty ? [_order] : _all),
              onBack: () => Navigator.of(context).maybePop(),
              onMarkReady: _markReady,
              onOpenMethod: cocktail == null || stepCountOf(cocktail, context) == 0
                  ? null
                  : () => showMethodSheet(
                        context,
                        host: widget.party.hostName,
                        cocktail: cocktail,
                        guestName: _order.guestName,
                        onReady: _markReady,
                      ),
              onOutOfSomething: () => _outOfSomething(cocktail),
              onCancelOrder: () => _cancelOrder(cocktail),
            );
          },
        );
      },
    );
  }
}

/// The visual half of screen 10 — plain data in, so it can be pumped in a
/// test without Firebase. Owns its own ticker for the "POURING · m:ss" pill.
class PouringBody extends StatefulWidget {
  const PouringBody({
    super.key,
    required this.party,
    required this.order,
    required this.cocktail,
    required this.position,
    required this.onBack,
    required this.onMarkReady,
    required this.onOpenMethod,
    required this.onOutOfSomething,
    required this.onCancelOrder,
  });

  final Party party;
  final CocktailOrder order;
  final Cocktail? cocktail;

  /// The order's remembered place in line — null once it has none.
  final int? position;

  final VoidCallback onBack;
  final VoidCallback onMarkReady;
  final VoidCallback? onOpenMethod;
  final VoidCallback onOutOfSomething;
  final VoidCallback onCancelOrder;

  @override
  State<PouringBody> createState() => _PouringBodyState();
}

class _PouringBodyState extends State<PouringBody> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final order = widget.order;
    final cocktail = widget.cocktail;
    final elapsed = DateTime.now().difference(order.preparedAt ?? order.createdAt);
    final position = widget.position;

    final glassware = cocktail?.equipments
        .where((e) => e.kind == EquipmentKind.glassware)
        .map((e) => e.title.translate(context))
        .firstOrNull;
    final hint = [
      if (glassware != null && glassware.isNotEmpty) glassware,
      if (cocktail?.method != null) methodLabel(l10n, cocktail!.method!),
    ].join(' · ');

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, 8, AppSpacing.screenEdge, 0),
              child: Row(
                children: [
                  AuthIconAction(icon: Icons.arrow_back, onTap: widget.onBack, semanticLabel: l10n.queueBack),
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.signalWash,
                          borderRadius: AppRadius.pillAll,
                        ),
                        child: Text(
                          l10n.queuePouringPill(formatStopwatch(elapsed)).toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label.copyWith(color: AppColors.signalLight),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.minTap),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  18,
                  AppSpacing.screenEdge,
                  20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GuestInitial(name: order.guestName, size: 24, highlighted: true),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            order.isForFriend
                                ? l10n.queueForGuestFromSender(order.forName!, order.guestName)
                                : l10n.queueForGuestPosition(order.guestName, position ?? 1),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.meta.copyWith(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink.withValues(alpha: .6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      cocktail?.title.translate(context) ?? '—',
                      style: AppTypography.display.copyWith(fontSize: 38, height: .98),
                    ),
                    if (order.note case final note?) ...[
                      const SizedBox(height: 16),
                      _NoteCallout(guest: order.guestName, note: note),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.queuePourPill.toUpperCase(),
                          style: AppTypography.label.copyWith(
                            color: AppColors.ink.withValues(alpha: .45),
                          ),
                        ),
                        if (hint.isNotEmpty)
                          Flexible(
                            child: Text(
                              hint,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: AppTypography.meta.copyWith(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink.withValues(alpha: .5),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (cocktail != null) _MeasuresGroup(cocktail: cocktail),
                    if (cocktail != null && widget.onOpenMethod != null) ...[
                      const SizedBox(height: 12),
                      _MethodRow(
                        label: l10n.queueHowHostMakesItRow(
                          hostFirstName(widget.party.hostName),
                          stepCountOf(cocktail, context),
                        ),
                        onTap: widget.onOpenMethod!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                0,
                AppSpacing.screenEdge,
                18,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 62,
                    child: Material(
                      color: AppColors.ink,
                      borderRadius: AppRadius.pillAll,
                      child: InkWell(
                        onTap: widget.onMarkReady,
                        borderRadius: AppRadius.pillAll,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check, size: 24, color: AppColors.ground),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                l10n.queueReadyBuzz(order.guestName),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.buttonPrimary.copyWith(
                                  fontSize: 17,
                                  color: AppColors.ground,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _FooterAction(
                          icon: Icons.production_quantity_limits,
                          label: l10n.queueOutOfSomething,
                          onTap: widget.onOutOfSomething,
                          amber: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _FooterAction(
                          icon: Icons.close,
                          label: l10n.queueCancelOrder,
                          onTap: widget.onCancelOrder,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteCallout extends StatelessWidget {
  const _NoteCallout({required this.guest, required this.note});

  final String guest;
  final String note;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: AppColors.lowWash, borderRadius: AppRadius.tileAll),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.edit_note, size: 19, color: AppColors.low),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.queueNoteLabel(guest).toUpperCase(),
                  style: AppTypography.label.copyWith(fontSize: 10, color: AppColors.low),
                ),
                const SizedBox(height: 6),
                Text(
                  note,
                  style: AppTypography.body.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                    // The design's note text is a paler amber than
                    // kHostLowLight (host_sheets.dart) — #FFE0B0 has no
                    // named token of its own.
                    color: const Color(0xFFFFE0B0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasuresGroup extends StatelessWidget {
  const _MeasuresGroup({required this.cocktail});

  final Cocktail cocktail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final unit = context.watch<MeasureUnitProvider>().unit;
    // Most of the catalogue has no quantities yet. Every ingredient is still
    // listed, so the host always sees what goes in; the amount column only
    // appears when the recipe states at least one.
    final rows = [
      for (final ingredient in cocktail.ingredients)
        (ingredient, cocktail.measureFor(ingredient.id)),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    final anyMeasured = rows.any((row) => row.$2 != null);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          for (final (i, entry) in rows.indexed) ...[
            if (i > 0) const SizedBox(height: 1),
            Container(
              color: AppColors.sheet,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  if (anyMeasured) ...[
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 78),
                      child: Text(
                        entry.$2 == null
                            ? '—'
                            : measureLabel(l10n, entry.$2!, displayUnit: unit),
                        style: AppTypography.mono.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                  Expanded(
                    child: Text(
                      entry.$1.title.translate(context),
                      style: AppTypography.body.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MethodRow extends StatelessWidget {
  const _MethodRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.fillMuted,
      borderRadius: AppRadius.tileAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.tileAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.menu_book, size: 19, color: AppColors.signalLight),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
              ),
              Icon(Icons.expand_less, size: 20, color: AppColors.ink.withValues(alpha: .35)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterAction extends StatelessWidget {
  const _FooterAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.amber = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool amber;

  @override
  Widget build(BuildContext context) {
    final tint = amber ? AppColors.low : AppColors.ink.withValues(alpha: .5);
    return Material(
      color: amber ? AppColors.lowWash : AppColors.fillMuted,
      borderRadius: AppRadius.pillAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.pillAll,
        child: SizedBox(
          height: 46,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: tint),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.buttonSecondary.copyWith(fontSize: 12.5, color: tint),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
