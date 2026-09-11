import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/party_cocktails.dart';
import '../../services/order_service.dart';
import '../../services/party_service.dart';
import '../../theme/theme.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/party/queue/queue_body.dart';
import '../../widgets/party/queue/queue_sheets.dart';
import 'party_host_actions.dart';
import 'pouring_screen.dart';

/// Flow 06 · screens 09 and 11 — "The bar": the host's queue. Reached from
/// the live hub's "Open the bar".
///
/// This widget owns the live data — the party and every order at it — and
/// the cocktails those orders point at; [QueueBody] does the drawing from
/// plain data.
class BarQueueScreen extends StatefulWidget {
  const BarQueueScreen({super.key, required this.party});

  final Party party;

  @override
  State<BarQueueScreen> createState() => _BarQueueScreenState();
}

class _BarQueueScreenState extends State<BarQueueScreen> {
  late final Stream<Party?> _party;
  late final Stream<List<CocktailOrder>> _orders;

  final _cocktails = PartyCocktails();
  Timer? _ticker;

  /// Set once the "party is gone" pop has been requested, so a second
  /// snapshot saying the same thing does not queue a second pop.
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _party = PartyService().streamParty(widget.party.id);
    _orders = OrderService().streamPartyOrders(widget.party.id);
    _cocktails.ensure(widget.party.availableCocktailIds);
    // Names and photos arrive after the orders do; nothing else would
    // rebuild the queue when they land.
    _cocktails.addListener(_onCocktailsLoaded);
    // Waiting times ("waiting 4m") are computed at build time from
    // DateTime.now(); this is what makes them advance without a new order.
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _cocktails.removeListener(_onCocktailsLoaded);
    _cocktails.dispose();
    super.dispose();
  }

  void _onCocktailsLoaded() {
    if (mounted) setState(() {});
  }

  void _maybeLeave(Party? party) {
    if (_leaving || (party != null && !party.isEnded)) return;
    _leaving = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
        Navigator.of(context).maybePop();
      }
    });
  }

  Future<void> _startPouring(Party party, CocktailOrder order, List<CocktailOrder> all) async {
    try {
      await OrderService().startPouring(order);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.hostSaveFailed)));
      return;
    }
    _openPouring(party, order.copyWith(status: OrderStatus.preparing));
  }

  void _openPouring(Party party, CocktailOrder order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PouringScreen(party: party, order: order, cocktails: _cocktails),
      ),
    );
  }

  Future<void> _skipWithConfirm(CocktailOrder order) async {
    final cocktail = _cocktails.byId(order.cocktailId);
    final name = cocktail?.title.translate(context) ?? order.cocktailId;
    final go = await showSkipConfirmSheet(context, cocktailName: name);
    if (!go || !mounted) return;
    try {
      await OrderService().skip(order);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.hostSaveFailed)));
    }
  }

  Future<void> _tapInLineRow(Party party, CocktailOrder order, List<CocktailOrder> all) async {
    final choice = await showInLineRowSheet(context);
    if (!mounted || choice == null) return;
    switch (choice) {
      case InLineRowChoice.pourNow:
        await _startPouring(party, order, all);
      case InLineRowChoice.skip:
        await _skipWithConfirm(order);
    }
  }

  Future<void> _buzzAgain(CocktailOrder order) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await OrderService().buzz(order);
      messenger.showSnackBar(SnackBar(content: Text(l10n.queueBuzzedAgainSnack(order.guestName))));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.hostSaveFailed)));
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.hostSaveFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _cocktails,
      child: Scaffold(
        backgroundColor: AppColors.ground,
        body: StreamBuilder<Party?>(
          stream: _party,
          initialData: widget.party,
          builder: (context, partySnap) {
            final party = partySnap.data;
            _maybeLeave(party);
            final current = party ?? widget.party;

            return StreamBuilder<List<CocktailOrder>>(
              stream: _orders,
              builder: (context, ordersSnap) {
                final all = ordersSnap.data ?? const <CocktailOrder>[];
                _cocktails.ensure({
                  ...current.availableCocktailIds,
                  ...all.map((o) => o.cocktailId),
                });

                return QueueBody(
                  party: current,
                  orders: all,
                  cocktails: _cocktails,
                  onBack: () => Navigator.of(context).maybePop(),
                  onTogglePause: () => _run(
                    () => setPartyStatus(
                      context,
                      current,
                      current.status == PartyStatus.paused
                          ? PartyStatus.active
                          : PartyStatus.paused,
                    ),
                  ),
                  onManage: () => manageParty(
                    context,
                    party: current,
                    orders: all,
                    onEditMenu: () async {
                      await editPartyMenu(
                        context,
                        current,
                        _cocktails.resolve(current.availableCocktailIds),
                      );
                    },
                    replaceRouteOnEnd: true,
                  ),
                  onInvite: () => openPartyInvite(context, current),
                  onStartPouring: (order) => _startPouring(current, order, all),
                  onSkip: (order) => _skipWithConfirm(order),
                  onTapPouring: (order) => _openPouring(current, order),
                  onTapInLineRow: (order) => _tapInLineRow(current, order, all),
                  onMarkServed: (order) => _run(() => OrderService().markServed(order)),
                  onBuzzAgain: (order) => _buzzAgain(order),
                  onBackToMixing: (order) => _run(() => OrderService().backToMixing(order)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
