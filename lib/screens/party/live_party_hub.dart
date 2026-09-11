import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/cocktail_repository.dart';
import '../../models/models.dart';
import '../../providers/bar_provider.dart';
import '../../providers/party_cocktails.dart';
import '../../services/order_service.dart';
import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/auth/auth_controls.dart';
import '../../widgets/common/app_bottom_nav.dart';
import '../../widgets/common/glass.dart';
import '../../widgets/party/host_state_pill.dart';
import '../../widgets/party/menu_cocktail_tile.dart';
import '../../widgets/party/queue/order_landed_banner.dart';
import 'party_host_actions.dart';
import 'pouring_screen.dart';

const _fallbackHero = 'assets/images/onboarding/midnight_orchard.jpg';

/// Half the photo's colour, luminance kept — the paused bar looks paused.
const _halfSaturation = ColorFilter.matrix(<double>[
  0.6063, 0.3576, 0.0361, 0, 0, //
  0.1063, 0.8576, 0.0361, 0, 0, //
  0.1063, 0.3576, 0.5361, 0, 0, //
  0, 0, 0, 1, 0,
]);

/// The photo scrim, a shade heavier while paused.
const _pausedScrim = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0x9E0B0B0C),
    Color(0x1F0B0B0C),
    Color(0x380B0B0C),
    Color(0xFF0B0B0C),
  ],
  stops: [0.0, 0.32, 0.52, 1.0],
);

/// Screen 12's reassurance: what guests see, and what is still in hand.
class _GuestsSeeingCard extends StatelessWidget {
  const _GuestsSeeingCard({required this.guests, required this.waiting});

  final int guests;
  final int waiting;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    Widget stat(String label, String value) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.row,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: AppTypography.label.copyWith(
                fontSize: 10,
                color: AppColors.ink.withValues(alpha: .4),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTypography.section.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.34,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sheet,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.visibility,
                size: 18,
                color: AppColors.signalLight,
              ),
              const SizedBox(width: 10),
              Text(
                l10n.hostGuestsSeeing,
                style: AppTypography.cardTitle.copyWith(
                  fontSize: 12.5,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.row,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.lowWash,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.pause,
                    size: 18,
                    color: AppColors.low,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.hostBackInAMinute,
                        style: AppTypography.cardTitle.copyWith(
                          fontSize: 13,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        l10n.hostMenuVisibleOrderingOff,
                        style: AppTypography.meta.copyWith(
                          fontSize: 11.5,
                          height: 1.2,
                          color: AppColors.ink.withValues(alpha: .5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              stat(l10n.hostInQueue, l10n.hostOrdersCount(waiting)),
              const SizedBox(width: 10),
              stat(l10n.hostStillHere, l10n.hostGuestsCount(guests)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Flow 05 · screen 10 — the host's home for the rest of the night.
///
/// The Party tab while a party is live. One way into the queue ("Open the
/// bar", with what is waiting), one into the QR, and tonight's menu as a
/// rail that says which drinks are running low on the shelf and how many
/// of each have been ordered.
class LivePartyHub extends StatefulWidget {
  const LivePartyHub({super.key, required this.party});

  final Party party;

  @override
  State<LivePartyHub> createState() => _LivePartyHubState();
}

class _LivePartyHubState extends State<LivePartyHub> {
  late Stream<List<CocktailOrder>> _orders;
  List<Cocktail>? _cocktails;

  /// The last orders the stream delivered, for the end sheet.
  List<CocktailOrder> _latestOrders = const [];

  /// Screen 08 — orders that landed after this are worth a banner. Bumped to
  /// "now" once a banner is dismissed, so the same round never announces
  /// itself twice.
  DateTime _since = DateTime.now();
  List<CocktailOrder>? _bannerRound;
  String? _bannerRoundKey;
  Timer? _bannerTimer;

  /// What the banner's "Pour" hands the pouring screen — owned here so it is
  /// disposed with the hub rather than leaked per tap.
  final _pourCocktails = PartyCocktails();

  Party get _party => widget.party;

  @override
  void initState() {
    super.initState();
    _orders = OrderService().streamPartyOrders(_party.id);
    _loadMenu();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pourCocktails.dispose();
    super.dispose();
  }

  /// Screen 08(a) — the newest round nobody has been told landed yet. Runs
  /// after each frame rather than inline in build, since it may call
  /// [setState].
  void _checkForLanded(List<CocktailOrder> orders, {required bool visible}) {
    if (!mounted) return;
    // Paused, covered by the queue, or on another tab: nobody would see the
    // banner, and the queue already marks new orders. Count them as seen.
    if (!visible) {
      _since = DateTime.now();
      return;
    }
    final rounds = landedSince(orders, _since);
    if (rounds.isEmpty) return;

    final round = rounds.first;
    final key = round.first.roundId ?? round.first.id;
    if (key == _bannerRoundKey) return;

    _bannerRoundKey = key;
    _bannerTimer?.cancel();
    _bannerTimer = Timer(const Duration(seconds: 8), _dismissBanner);
    HapticFeedback.lightImpact();
    setState(() => _bannerRound = round);
  }

  void _dismissBanner() {
    _bannerTimer?.cancel();
    _bannerTimer = null;
    _since = DateTime.now();
    if (mounted) setState(() => _bannerRound = null);
  }

  Future<void> _pourFromBanner(CocktailOrder order) async {
    _dismissBanner();
    try {
      await OrderService().startPouring(order);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.hostSaveFailed)));
      }
      return;
    }
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PouringScreen(
          party: _party,
          order: order.copyWith(status: OrderStatus.preparing),
          cocktails: _pourCocktails,
        ),
      ),
    );
  }

  String? _cocktailTitle(BuildContext context, String id) =>
      _cocktails?.where((c) => c.id == id).firstOrNull?.title.translate(context);

  @override
  void didUpdateWidget(covariant LivePartyHub oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.party.id != _party.id) {
      _orders = OrderService().streamPartyOrders(_party.id);
    }
    final before = oldWidget.party.availableCocktailIds;
    final after = _party.availableCocktailIds;
    if (oldWidget.party.id != _party.id ||
        before.length != after.length ||
        !before.toSet().containsAll(after)) {
      _loadMenu();
    }
  }

  Future<void> _loadMenu() async {
    final ids = _party.availableCocktailIds;
    final repository = CocktailRepository();
    final loaded = await Future.wait(
      ids.map((id) async {
        try {
          return await repository.getCocktail(id);
        } catch (_) {
          return null;
        }
      }),
    );
    // A newer menu arrived while this one loaded.
    if (!mounted || ids != _party.availableCocktailIds) return;
    setState(() => _cocktails = loaded.whereType<Cocktail>().toList());
  }

  Future<void> _editMenu() => editPartyMenu(
    context,
    _party,
    _cocktails ?? const [],
    onPicked: (picked) => setState(() => _cocktails = picked),
  );

  /// Screen 11, and through it screen 13.
  Future<void> _manage() => manageParty(
    context,
    party: _party,
    orders: _latestOrders,
    onEditMenu: _editMenu,
  );

  Future<void> _setStatus(PartyStatus status) =>
      setPartyStatus(context, _party, status);

  void _openQueue() => context.push(
    '${AppRoutes.activePartyHost}/${_party.id}',
    extra: _party,
  );

  void _openInvite() => openPartyInvite(context, _party);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CocktailOrder>>(
      stream: _orders,
      builder: (context, snapshot) {
        final orders = snapshot.data ?? const <CocktailOrder>[];
        _latestOrders = orders;
        final visible =
            _party.status != PartyStatus.paused &&
            (ModalRoute.of(context)?.isCurrent ?? true) &&
            TickerMode.of(context);
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _checkForLanded(orders, visible: visible),
        );
        return _party.status == PartyStatus.paused
            ? _buildPaused(orders)
            : _buildHub(orders);
      },
    );
  }

  Widget _buildHub(List<CocktailOrder> orders) {
    final l10n = context.l10n;
    final guests = orders.map((o) => o.guestName).toSet().length;
    final poured = orders
        .where((o) => o.status == OrderStatus.delivered)
        .length;
    final waiting = orders.where((o) => o.isOpen).length;

    final heroImage = _cocktails
        ?.map((c) => c.image)
        .where((image) => image.isNotEmpty)
        .firstOrNull;

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 500,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (heroImage != null)
                MenuCocktailImage(image: heroImage)
              else
                Image.asset(_fallbackHero, fit: BoxFit.cover),
              const PhotoScrim(),
            ],
          ),
        ),
        SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final inset = AppBottomNav.insetOf(context);
              return SingleChildScrollView(
                padding: EdgeInsets.only(bottom: inset),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - inset,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _topBar(guests, waiting),
                        const SizedBox(height: 120),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screenEdge,
                            0,
                            AppSpacing.screenEdge,
                            24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.hostHereAndPoured(guests, poured),
                                style: AppTypography.meta.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink.withValues(alpha: .72),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _party.name,
                                style: AppTypography.display.copyWith(
                                  height: .98,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: _QueueButton(
                                      label: l10n.hostOpenTheBar,
                                      waiting: waiting,
                                      onTap: _openQueue,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GlassIconButton(
                                    icon: Icons.qr_code_2,
                                    size: 56,
                                    tooltip: l10n.hostShowQr,
                                    onTap: _openInvite,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _waitingOrMenuRail(orders),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_bannerRound case final round?)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                child: OrderLandedBanner(
                  round: round,
                  cocktailTitleOf: (id) => _cocktailTitle(context, id),
                  onPour: () => _pourFromBanner(round.first),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Screen 08(b) — once something is waiting, it takes the menu rail's
  /// place; the menu is one tap away in "Manage" regardless.
  Widget _waitingOrMenuRail(List<CocktailOrder> orders) {
    final line = inLine(orders);
    if (line.isEmpty) return _menuRail(orders);

    return Padding(
      padding: AppSpacing.screen,
      child: WaitingOnYouCard(
        line: line,
        cocktailTitleOf: (id) => _cocktailTitle(context, id),
        onTap: _openQueue,
      ),
    );
  }

  // --------------------------------------------------------- 12 · paused

  /// Screen 12 — the state is unmissable: the photo loses half its colour,
  /// the pill turns amber, and the one big button reopens the bar.
  Widget _buildPaused(List<CocktailOrder> orders) {
    final l10n = context.l10n;
    final guests = orders.map((o) => o.guestName).toSet().length;
    final waiting = orders.where((o) => o.isOpen).length;

    final now = DateTime.now();
    final pausedFor = now.difference(_party.pausedAt ?? now);
    final pausedLabel = pausedFor.isNegative || pausedFor.inHours == 0
        ? '${pausedFor.isNegative ? 0 : pausedFor.inMinutes}m'
        : LiveElapsedPill.format(pausedFor);

    final heroImage = _cocktails
        ?.map((c) => c.image)
        .where((image) => image.isNotEmpty)
        .firstOrNull;

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 500,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColorFiltered(
                colorFilter: _halfSaturation,
                child: heroImage != null
                    ? MenuCocktailImage(image: heroImage)
                    : Image.asset(_fallbackHero, fit: BoxFit.cover),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(gradient: _pausedScrim),
              ),
            ],
          ),
        ),
        SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final inset = AppBottomNav.insetOf(context);
              return SingleChildScrollView(
                padding: EdgeInsets.only(bottom: inset),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - inset,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screenEdge,
                            8,
                            AppSpacing.screenEdge,
                            0,
                          ),
                          child: Row(
                            children: [
                              HostStatePill(
                                label: l10n.hostPausedPill(pausedLabel),
                                tone: HostPillTone.paused,
                              ),
                              const Spacer(),
                              GlassIconButton(
                                icon: Icons.tune,
                                size: 34,
                                tooltip: l10n.hostManage,
                                onTap: () => _manage(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 120),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screenEdge,
                            0,
                            AppSpacing.screenEdge,
                            24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.hostPausedTitle,
                                style: AppTypography.display.copyWith(
                                  fontSize: 38,
                                  height: .98,
                                ),
                              ),
                              const SizedBox(height: 14),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 300,
                                ),
                                child: Text(
                                  l10n.hostPausedBody(waiting),
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.ink.withValues(alpha: .62),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              AuthPillButton(
                                label: l10n.hostReopenBar,
                                icon: Icons.play_arrow,
                                primary: true,
                                height: AppSizes.buttonPrimary,
                                onPressed: () =>
                                    _setStatus(PartyStatus.active),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: AppSpacing.screen,
                          child: _GuestsSeeingCard(
                            guests: guests,
                            waiting: waiting,
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _topBar(int guests, int waiting) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        8,
        AppSpacing.screenEdge,
        0,
      ),
      child: Row(
        children: [
          LiveElapsedPill(since: _party.wentLiveAt),
          const Spacer(),
          GlassIconButton(
            icon: Icons.ios_share,
            size: 34,
            tooltip: context.l10n.hostShare,
            onTap: () => Share.share(
              context.l10n.hostShareText(_party.name, _party.joinCode),
            ),
          ),
          const SizedBox(width: 8),
          GlassIconButton(
            icon: Icons.tune,
            size: 34,
            tooltip: context.l10n.hostManage,
            onTap: () => _manage(),
          ),
        ],
      ),
    );
  }

  Widget _menuRail(List<CocktailOrder> orders) {
    final shelf = context.watch<BarProvider>().shelf;
    final cocktails = _cocktails;
    final ordered = <String, int>{};
    for (final order in orders) {
      if (order.status == OrderStatus.cancelled) continue;
      ordered[order.cocktailId] = (ordered[order.cocktailId] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.screen,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  context.l10n.hostOnTheMenuTonight,
                  style: AppTypography.section,
                ),
              ),
              _TextLink(
                label: context.l10n.hostEdit,
                onTap: cocktails == null ? null : _editMenu,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (cocktails != null && cocktails.isEmpty)
          Padding(
            padding: AppSpacing.screen,
            child: Text(
              context.l10n.hostMenuEmptyRequests,
              style: AppTypography.meta,
            ),
          )
        else
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: AppSpacing.screen,
              itemCount: cocktails?.length ?? 0,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final cocktail = cocktails![index];
                final low = !makeabilityOf(cocktail, shelf).isMakeable;
                final count = ordered[cocktail.id] ?? 0;
                return _RailTile(
                  name: cocktail.title.translate(context),
                  image: cocktail.image,
                  badge: low
                      ? context.l10n.hostLowBadge.toUpperCase()
                      : count > 0
                      ? '×$count'
                      : null,
                  low: low,
                );
              },
            ),
          ),
      ],
    );
  }
}

/// A quiet accent text link sized to the tap minimum.
class _TextLink extends StatelessWidget {
  const _TextLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.pillAll,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.minTap),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Center(
            child: Text(
              label,
              style: AppTypography.meta.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.signalLight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QueueButton extends StatelessWidget {
  const _QueueButton({
    required this.label,
    required this.waiting,
    required this.onTap,
  });

  final String label;
  final int waiting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.ink,
      borderRadius: AppRadius.pillAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.pillAll,
        child: SizedBox(
          height: AppSizes.buttonPrimary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_bar, size: 20, color: AppColors.ground),
              const SizedBox(width: 9),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.buttonPrimary.copyWith(
                    fontSize: 14.5,
                    color: AppColors.ground,
                  ),
                ),
              ),
              if (waiting > 0) ...[
                const SizedBox(width: 9),
                Container(
                  constraints: const BoxConstraints(minWidth: 22),
                  height: 22,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.signal,
                    borderRadius: AppRadius.pillAll,
                  ),
                  child: Text(
                    '$waiting',
                    style: AppTypography.cardTitle.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RailTile extends StatelessWidget {
  const _RailTile({
    required this.name,
    required this.image,
    required this.badge,
    required this.low,
  });

  final String name;
  final String? image;
  final String? badge;
  final bool low;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 118,
      child: ClipRRect(
        borderRadius: AppRadius.tileAll,
        child: Stack(
          fit: StackFit.expand,
          children: [
            MenuCocktailImage(image: image),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x000B0B0C), Color(0xCC0B0B0C)],
                  stops: [0.45, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.cardTitle.copyWith(color: AppColors.ink),
              ),
            ),
            if (badge != null)
              Positioned(
                top: 9,
                right: 9,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: low
                        ? AppColors.low.withValues(alpha: .9)
                        : AppColors.ground.withValues(alpha: .6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge!,
                    style: AppTypography.label.copyWith(
                      fontSize: 9.5,
                      letterSpacing: 0,
                      color: low ? AppColors.ground : AppColors.ink,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
