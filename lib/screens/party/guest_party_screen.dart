import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/models.dart';
import '../../providers/party_cocktails.dart';
import '../../providers/round_draft.dart';
import '../../services/guest_identity.dart';
import '../../services/order_service.dart';
import '../../services/party_service.dart';
import '../../theme/theme.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/auth/auth_controls.dart';
import '../../widgets/common/app_bottom_nav.dart';
import '../../widgets/party/guest/buzz_banner.dart';
import '../../widgets/party/guest/menu_tab.dart';
import '../../widgets/party/guest/tonight_tab.dart';
import '../../widgets/party/guest/your_round_sheet.dart';
import '../../widgets/party/guest/your_round_tab.dart';
import '../../widgets/party/order_bits.dart' show hostFirstName;
import 'guest/add_to_round_screen.dart';
import 'guest/round_sent_screen.dart';

/// Flow 06 — the guest's side of the loop: build a round, send it, watch it
/// move, grab it. Reached from the join form with the [Party] and the name.
///
/// This widget owns the live data — the party, every order at it, and which
/// of them are this phone's — and hands it to the tabs below as plain data,
/// so each of them renders without touching Firebase. It also owns the two
/// pieces of purely local state Flow 06 needs: the round being built before
/// it is sent ([RoundDraft]), and the buzz — there is no push notification
/// in this app, so a ready order (or a re-buzz) is caught by diffing
/// successive order snapshots and answered with a haptic and an in-app
/// banner instead.
class GuestPartyScreen extends StatefulWidget {
  const GuestPartyScreen({
    super.key,
    required this.party,
    required this.guestName,
  });

  final Party party;
  final String guestName;

  @override
  State<GuestPartyScreen> createState() => _GuestPartyScreenState();
}

class _GuestPartyScreenState extends State<GuestPartyScreen> {
  final _draft = RoundDraft();
  final _cocktails = PartyCocktails();

  StreamSubscription<Party?>? _partySub;
  StreamSubscription<List<CocktailOrder>>? _ordersSub;

  Party? _party;
  List<CocktailOrder> _orders = const [];
  String? _guestId;

  Set<String> _dismissedPulls = const {};
  bool _firstOrdersSnapshot = true;
  List<CocktailOrder> _previousMine = const [];

  int _tab = 0;

  CocktailOrder? _buzzOrder;
  Cocktail? _buzzNext;

  Party get _current => _party ?? widget.party;
  String get _dismissedPullsKey => 'round_dismissed_pulls_${widget.party.id}';

  @override
  void initState() {
    super.initState();
    _cocktails.ensure(widget.party.availableCocktailIds);

    GuestIdentity.deviceId().then((id) {
      if (!mounted) return;
      setState(() => _guestId = id);
    });

    _loadDismissedPulls();

    _partySub = PartyService().streamParty(widget.party.id).listen((party) {
      if (mounted) setState(() => _party = party ?? widget.party);
    });
    _ordersSub = OrderService().streamPartyOrders(widget.party.id).listen(_onOrders);
  }

  @override
  void dispose() {
    _partySub?.cancel();
    _ordersSub?.cancel();
    _draft.dispose();
    _cocktails.dispose();
    super.dispose();
  }

  Future<void> _loadDismissedPulls() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_dismissedPullsKey) ?? const [];
    if (mounted) setState(() => _dismissedPulls = saved.toSet());
  }

  Future<void> _dismissPull(String orderId) async {
    setState(() => _dismissedPulls = {..._dismissedPulls, orderId});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_dismissedPullsKey, _dismissedPulls.toList(growable: false));
  }

  void _onOrders(List<CocktailOrder> all) {
    _cocktails.ensure({..._current.availableCocktailIds, ...all.map((o) => o.cocktailId)});

    final id = _guestId;
    if (id != null) {
      final mine = ordersOf(all, guestId: id, guestName: widget.guestName);
      if (!_firstOrdersSnapshot) {
        _detectBuzz(previous: _previousMine, current: mine, all: all);
      }
      _previousMine = mine;
      _firstOrdersSnapshot = false;
    }

    if (mounted) setState(() => _orders = all);
  }

  /// The buzz: a ready order, or a re-buzz (`buzzedAt` moved later). Skips
  /// the very first snapshot — that is just this phone catching up, not
  /// something changing.
  void _detectBuzz({
    required List<CocktailOrder> previous,
    required List<CocktailOrder> current,
    required List<CocktailOrder> all,
  }) {
    final byId = {for (final o in previous) o.id: o};
    for (final order in current) {
      final prev = byId[order.id];
      if (prev == null) continue;
      final readyTurnedOn = order.isReady && !prev.isReady;
      final buzzedBumped =
          order.buzzedAt != null &&
          order.buzzedAt != prev.buzzedAt &&
          (prev.buzzedAt == null || order.buzzedAt!.isAfter(prev.buzzedAt!));
      if (readyTurnedOn || buzzedBumped) {
        _fireBuzz(order, all);
        return;
      }
    }
  }

  void _fireBuzz(CocktailOrder order, List<CocktailOrder> all) {
    HapticFeedback.heavyImpact();

    CocktailOrder? next;
    final roundId = order.roundId;
    if (roundId != null) {
      final mates = all.where((o) => o.roundId == roundId && o.id != order.id && o.isOpen).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      next = mates.firstOrNull;
    }
    if (next != null) _cocktails.ensure({next.cocktailId});

    setState(() {
      _buzzOrder = order;
      _buzzNext = next != null ? _cocktails.byId(next.cocktailId) : null;
    });
  }

  List<CocktailOrder> get _myOrders {
    final id = _guestId;
    if (id == null) return const [];
    return ordersOf(_orders, guestId: id, guestName: widget.guestName);
  }

  Future<void> _openAddToRound(Cocktail cocktail) async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddToRoundScreen(
          party: _current,
          cocktail: cocktail,
          draft: _draft,
          aheadOfNewOrder: aheadOfNewOrder(_orders),
          orderedTonight: orderedTonight(_orders)[cocktail.id] ?? 0,
          guestName: widget.guestName,
        ),
      ),
    );
    if (added == true && mounted) _openYourRound();
  }

  Future<void> _openYourRound() async {
    final id = _guestId;
    if (id == null || _draft.isEmpty) return;

    final sentIds = await showYourRoundSheet(
      context,
      party: _current,
      draft: _draft,
      cocktails: _cocktails,
      aheadOfNewOrder: aheadOfNewOrder(_orders),
      guestId: id,
      guestName: widget.guestName,
      paused: _current.status == PartyStatus.paused,
    );

    if (sentIds != null && sentIds.isNotEmpty && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RoundSentScreen(
            party: _current,
            orders: OrderService().streamPartyOrders(widget.party.id),
            roundIds: sentIds,
            cocktails: _cocktails,
            onBackToMenu: () {
              Navigator.of(context).pop();
              setState(() => _tab = 1);
            },
            onCancelRound: (round) => OrderService().cancelRound(round),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final party = _current;
    final id = _guestId;

    if (id == null) {
      return const Scaffold(backgroundColor: AppColors.ground, body: SizedBox.shrink());
    }

    if (party.status == PartyStatus.ended) return _EndedScaffold(party: party);

    final myOrders = _myOrders;

    final tabs = <Widget>[
      TonightTab(
        party: party,
        allOrders: _orders,
        myOrders: myOrders,
        guestId: id,
        guestName: widget.guestName,
        cocktails: _cocktails,
        dismissedPulls: _dismissedPulls,
        onDismissPull: _dismissPull,
        onOpenMenu: () => setState(() => _tab = 1),
      ),
      MenuTab(party: party, allOrders: _orders, cocktails: _cocktails, onTapCocktail: _openAddToRound),
      YourRoundTab(party: party, allOrders: _orders, myOrders: myOrders, guestName: widget.guestName, cocktails: _cocktails),
    ];

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: ListenableBuilder(
        listenable: Listenable.merge([_draft, _cocktails]),
        builder: (context, _) {
          return Stack(
            children: [
              IndexedStack(index: _tab, children: tabs),
              if (party.status == PartyStatus.paused) _PausedNotice(hostName: party.hostName),
              if (_buzzOrder != null)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: BuzzBanner(
                    order: _buzzOrder!,
                    cocktail: _cocktails.byId(_buzzOrder!.cocktailId),
                    party: party,
                    nextUp: _buzzNext,
                    onTap: () {
                      setState(() {
                        _tab = 0;
                        _buzzOrder = null;
                      });
                    },
                    onDismissed: () => setState(() => _buzzOrder = null),
                  ),
                ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_draft.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _RoundPill(count: _draft.length, onTap: _openYourRound),
                      ),
                    AppBottomNav(
                      destinations: [
                        AppNavDestination(icon: Icons.nightlife_outlined, activeIcon: Icons.nightlife, label: context.l10n.roundNavTonight),
                        AppNavDestination(icon: Icons.local_bar_outlined, activeIcon: Icons.local_bar, label: context.l10n.menu),
                        AppNavDestination(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: context.l10n.roundNavYourRound),
                      ],
                      currentIndex: _tab,
                      onDestinationSelected: (i) => setState(() => _tab = i),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RoundPill extends StatelessWidget {
  const _RoundPill({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
      child: Material(
        color: AppColors.ink,
        borderRadius: AppRadius.pillAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.pillAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.receipt_long, size: 17, color: AppColors.ground),
                const SizedBox(width: 8),
                Text(
                  context.l10n.roundPill(count),
                  style: AppTypography.cardTitle.copyWith(fontSize: 13, color: AppColors.ground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A clear, minimal notice — Flow 07 owns the full paused design.
class _PausedNotice extends StatelessWidget {
  const _PausedNotice({required this.hostName});

  final String hostName;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, 8, AppSpacing.screenEdge, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(color: AppColors.lowWash, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                const Icon(Icons.pause_circle, size: 18, color: AppColors.low),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.l10n.roundPausedBody(hostFirstName(hostName)),
                    style: AppTypography.meta.copyWith(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.ink),
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

/// A calm dead end once the host ends the party — Flow 07 owns the full
/// after-party design; this is just the way out.
class _EndedScaffold extends StatelessWidget {
  const _EndedScaffold({required this.party});

  final Party party;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge * 1.5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_bar_outlined, size: 40, color: AppColors.ink.withValues(alpha: .3)),
              const SizedBox(height: 20),
              Text(l10n.roundEndedTitle, style: AppTypography.title.copyWith(fontSize: 28), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(
                l10n.roundEndedBody(party.name),
                textAlign: TextAlign.center,
                style: AppTypography.body,
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: AuthPillButton(
                  label: l10n.roundEndedLeave,
                  primary: true,
                  height: AppSizes.buttonGhost,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
