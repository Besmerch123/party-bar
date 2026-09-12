import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/order_repository.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/party_cocktails.dart';
import '../../providers/round_draft.dart';
import '../../services/guest_identity.dart';
import '../../services/guest_session.dart';
import '../../services/order_service.dart';
import '../../services/party_service.dart';
import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/common/app_bottom_nav.dart';
import '../../widgets/party/guest/buzz_banner.dart';
import '../../widgets/party/guest/guest_name_gate.dart';
import '../../widgets/party/guest/leave_party_sheet.dart';
import '../../widgets/party/guest/menu_tab.dart';
import '../../widgets/party/guest/paused_bar.dart';
import '../../widgets/party/guest/tonight_tab.dart';
import '../../widgets/party/guest/your_round_sheet.dart';
import '../../widgets/party/guest/your_round_tab.dart';
import '../../widgets/party/order_bits.dart' show hostFirstName;
import 'guest/add_to_round_screen.dart';
import 'guest/party_ended_screen.dart';
import 'guest/round_sent_screen.dart';

/// Flow 06 — the guest's side of the loop: build a round, send it, watch it
/// move, grab it. Flow 07 owns how someone arrives here and how they leave:
/// the party is remembered on this phone ([GuestSession]) until it ends, the
/// name is asked at the first send rather than at the door, and the paused
/// and ended states are this screen's, not a placeholder's.
///
/// This widget owns the live data — the party, every order at it, and which
/// of them are this phone's — and hands it to the tabs below as plain data,
/// so each of them renders without touching Firebase. It also owns the three
/// pieces of purely local state the guest needs: the round being built before
/// it is sent ([RoundDraft]), the name this phone orders under, and the buzz
/// — there is no push notification in this app, so a ready order (or a
/// re-buzz) is caught by diffing successive order snapshots and answered with
/// a haptic and an in-app banner instead.
class GuestPartyScreen extends StatefulWidget {
  const GuestPartyScreen({
    super.key,
    required this.party,
    this.guestName,
    this.welcome = false,
  });

  final Party party;

  /// Only ever a seed. A guest who has never ordered has no name yet, and is
  /// asked for one on the tap that sends their first round.
  final String? guestName;

  /// True when a link or a QR opened this directly, which is the one arrival
  /// that needs a word of confirmation — nothing else on screen says a door
  /// was just passed through.
  final bool welcome;

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
  String? _name;

  Set<String> _dismissedPulls = const {};
  bool _firstOrdersSnapshot = true;
  List<CocktailOrder> _previousMine = const [];

  int _tab = 0;
  bool _welcome = false;
  Timer? _welcomeTimer;

  CocktailOrder? _buzzOrder;
  Cocktail? _buzzNext;

  Party get _current => _party ?? widget.party;
  bool get _paused => _current.status == PartyStatus.paused;
  String get _host => hostFirstName(_current.hostName);
  String get _dismissedPullsKey => 'round_dismissed_pulls_${widget.party.id}';

  @override
  void initState() {
    super.initState();
    _cocktails.ensure(widget.party.availableCocktailIds);

    // The name outlives a single party — a guest is asked once, not once per
    // party — so the phone's remembered one is the seed for this one.
    _name = widget.guestName ?? context.read<AuthenticationProvider>().guestName;

    // Until the host closes the bar, reopening the app lands back here.
    GuestSession.remember(widget.party.id);

    if (widget.welcome) {
      _welcome = true;
      _welcomeTimer = Timer(
        const Duration(seconds: 4),
        () => mounted ? setState(() => _welcome = false) : null,
      );
    }

    GuestIdentity.deviceId().then((id) {
      if (!mounted) return;
      setState(() => _guestId = id);
    });

    _loadDismissedPulls();

    _partySub = PartyService().streamParty(widget.party.id).listen((party) {
      // A party that ended is no longer somewhere to come back to — but its
      // recap is, for a week (Flow 08 · screen 07).
      if (party?.isEnded ?? false) {
        GuestSession.forget();
        GuestSession.rememberRecap(widget.party.id);
      }
      if (mounted) setState(() => _party = party ?? widget.party);
    });
    _ordersSub = OrderRepository().streamPartyOrders(widget.party.id).listen(_onOrders);
  }

  @override
  void dispose() {
    _welcomeTimer?.cancel();
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
      final mine = ordersOf(all, guestId: id, guestName: _name);

      // This phone has ordered before but does not remember what it called
      // itself — cleared storage, a reinstall, an order sent before the name
      // was kept. The orders themselves know, and they are the only place
      // the host reads it from anyway.
      if (_name == null && mine.isNotEmpty) {
        _name = mine.last.guestName;
      }

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
    return ordersOf(_orders, guestId: id, guestName: _name);
  }

  /// Flow 07 · screen 03. The name is not a door — it is asked on the tap
  /// that sends the round, and that same tap is what sends it. Returns null
  /// if the guest backed out, which cancels the send with the round intact.
  Future<String?> _resolveName({int? drinks}) async {
    final auth = context.read<AuthenticationProvider>();

    final name = await showGuestNameGate(
      context,
      hostName: _host,
      drinks: drinks,
      initialName: _name,
    );
    if (name == null) return null;

    // Kept beyond this party: a guest is asked their name once, not once per
    // party, and the next door prefills it.
    await auth.setGuestName(name);
    if (mounted) setState(() => _name = name);
    return name;
  }

  Future<void> _changeName() async {
    await _resolveName();
  }

  Future<void> _leaveParty() async {
    final router = GoRouter.of(context);
    final left = await showLeavePartySheet(context, party: _current);
    if (left != true) return;

    await GuestSession.forget();
    if (!mounted) return;

    if (router.canPop()) {
      router.pop();
    } else {
      router.go(AppRoutes.partyHub);
    }
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
          guestName: _name,
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
      guestName: _name,
      resolveName: _resolveName,
      paused: _paused,
    );

    if (sentIds != null && sentIds.isNotEmpty && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RoundSentScreen(
            party: _current,
            orders: OrderRepository().streamPartyOrders(widget.party.id),
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

  /// Flow 07 · screen 06 → Flow 08 · screen 07. The recap replaces the
  /// closing screen rather than stacking over it: going "back" from the
  /// night belongs at the party tab, not at a bar that has shut.
  void _seeTheNight() => GoRouter.of(context).pushReplacement(
    '${AppRoutes.guestRecap}/${_current.id}',
    extra: _current,
  );

  void _done() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(AppRoutes.partyHub);
    }
  }

  /// "Midnight Orchard · still #2 in line" — what the pause did not touch.
  String? _stillInLine() {
    final waiting = _myOrders.where((o) => o.isPending).toList();
    if (waiting.isEmpty) return null;
    final order = waiting.first;
    final title =
        _cocktails.byId(order.cocktailId)?.title.translate(context) ??
        order.cocktailId;
    return context.l10n.joinPausedStillInLine(
      title,
      positionOf(order, _orders) ?? 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final party = _current;
    final id = _guestId;

    if (id == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final myOrders = _myOrders;

    if (party.status == PartyStatus.ended) {
      return PartyEndedScreen(
        party: party,
        myOrders: myOrders,
        onDone: _done,
        onSeeTheNight: _seeTheNight,
      );
    }

    final name = _name ?? '';

    final tabs = <Widget>[
      TonightTab(
        party: party,
        allOrders: _orders,
        myOrders: myOrders,
        guestId: id,
        guestName: name,
        cocktails: _cocktails,
        dismissedPulls: _dismissedPulls,
        onDismissPull: _dismissPull,
        onOpenMenu: () => setState(() => _tab = 1),
      ),
      MenuTab(party: party, allOrders: _orders, cocktails: _cocktails, onTapCocktail: _openAddToRound),
      YourRoundTab(
        party: party,
        allOrders: _orders,
        myOrders: myOrders,
        guestName: _name,
        cocktails: _cocktails,
        onChangeName: _changeName,
        onLeave: _leaveParty,
      ),
    ];

    return Scaffold(
      body: ListenableBuilder(
        listenable: Listenable.merge([_draft, _cocktails]),
        builder: (context, _) {
          return Stack(
            children: [
              IndexedStack(index: _tab, children: tabs),
              if (_paused)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: PausedNotice(
                    hostName: _host,
                    stillInLine: _stillInLine(),
                  ),
                ),
              // A paused bar is the more urgent of the two, and they would
              // otherwise draw on top of each other.
              if (_welcome && !_paused)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: _ArrivalBanner(
                    onDismissed: () => setState(() => _welcome = false),
                  ),
                ),
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
                    if (_paused)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: PausedFooter(hostName: _host),
                      )
                    else if (!_draft.isEmpty)
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

/// Flow 07 · screen 02 — the only thing a link arrival is told. It says a
/// door was passed, then gets out of the way of the drinks.
class _ArrivalBanner extends StatelessWidget {
  const _ArrivalBanner({required this.onDismissed});

  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenEdge,
          8,
          AppSpacing.screenEdge,
          0,
        ),
        child: Dismissible(
          key: const ValueKey('guest-arrival'),
          direction: DismissDirection.up,
          onDismissed: (_) => onDismissed(),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 9, 15, 9),
              decoration: BoxDecoration(
                // Opaque for the same reason as the paused notice: this
                // lands over whatever photograph the tab is holding.
                color: Color.alphaBlend(AppColors.readyWash, AppColors.sheet),
                borderRadius: AppRadius.pillAll,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 17,
                    color: AppColors.ready,
                  ),
                  const SizedBox(width: 9),
                  Text(
                    context.l10n.joinYoureIn,
                    style: AppTypography.cardTitle.copyWith(
                      fontSize: 12.5,
                      color: AppColors.ready,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
