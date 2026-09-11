import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/models.dart';
import '../../../providers/party_cocktails.dart';
import '../../../services/order_service.dart';
import '../../../theme/theme.dart';
import '../../../utils/cocktail_labels.dart';
import '../../../utils/localization_helper.dart';
import '../../common/app_bottom_nav.dart';
import '../../common/glass.dart';
import '../menu_cocktail_tile.dart';
import '../order_bits.dart';
import 'round_bits.dart';

const _fallbackHero = 'assets/images/onboarding/midnight_orchard.jpg';

/// Flow 06 · Tonight tab. Nothing yet sent shows the arrival view (shaped
/// like Flow 07 · 02); once a round exists it drives the tab instead —
/// whichever of its drinks is furthest along (ready beats mixing beats in
/// line beats a pull the guest has not dismissed).
///
/// Takes plain data throughout — party, every order, this phone's orders,
/// the resolved cocktails — so it renders without Firebase behind it.
class TonightTab extends StatefulWidget {
  const TonightTab({
    super.key,
    required this.party,
    required this.allOrders,
    required this.myOrders,
    required this.guestId,
    required this.guestName,
    required this.cocktails,
    required this.dismissedPulls,
    required this.onDismissPull,
    required this.onOpenMenu,
  });

  final Party party;
  final List<CocktailOrder> allOrders;
  final List<CocktailOrder> myOrders;
  final String guestId;
  final String guestName;
  final PartyCocktails cocktails;
  final Set<String> dismissedPulls;
  final ValueChanged<String> onDismissPull;
  final VoidCallback onOpenMenu;

  @override
  State<TonightTab> createState() => _TonightTabState();
}

class _TonightTabState extends State<TonightTab> {
  /// Ready orders the guest tapped "On my way" on — acknowledged locally
  /// only, never written back. Once acknowledged an order falls back to the
  /// plain round card instead of holding the full-bleed hero.
  final _acknowledged = <String>{};
  Timer? _ticker;
  bool _swapBusy = false;

  @override
  void initState() {
    super.initState();
    // Drives the mixing stopwatch and the ready "Ns ago" pill.
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
    final round = currentRoundOf(widget.myOrders, dismissedPulls: widget.dismissedPulls);
    if (round == null) return _buildArrival();

    final lead = _leadOf(round);
    if (lead == null) return _buildArrival();

    final others = round.where((o) => o.id != lead.id).toList();

    if (lead.isReady && !_acknowledged.contains(lead.id)) {
      return _ReadyView(
        order: lead,
        others: others,
        allOrders: widget.allOrders,
        party: widget.party,
        cocktails: widget.cocktails,
        onAcknowledge: () => setState(() => _acknowledged.add(lead.id)),
        onCancel: _cancelOne,
      );
    }

    if (lead.wasPulledForStock) {
      return _PulledView(
        pulled: lead,
        round: round,
        allOrders: widget.allOrders,
        party: widget.party,
        cocktails: widget.cocktails,
        busy: _swapBusy,
        onSwapIn: (cocktail) => _swapIn(lead, cocktail),
        onDismiss: () => widget.onDismissPull(lead.id),
      );
    }

    return _RoundCardView(
      party: widget.party,
      allOrders: widget.allOrders,
      guestName: widget.guestName,
      lead: lead,
      others: others,
      acknowledgedReady: lead.isReady,
      cocktails: widget.cocktails,
      onCancel: _cancelOne,
      onOpenMenu: widget.onOpenMenu,
    );
  }

  Widget _buildArrival() => _ArrivalView(
    party: widget.party,
    allOrders: widget.allOrders,
    cocktails: widget.cocktails,
    onOpenMenu: widget.onOpenMenu,
  );

  /// Ready beats mixing beats in line beats an undismissed pull, oldest
  /// first within a tier. A ready order the guest already acknowledged is
  /// still offered last, so the round card has something to show.
  CocktailOrder? _leadOf(List<CocktailOrder> round) {
    CocktailOrder? pick(bool Function(CocktailOrder) test) {
      final matches = round.where(test).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return matches.firstOrNull;
    }

    return pick((o) => o.isReady && !_acknowledged.contains(o.id)) ??
        pick((o) => o.isPreparing) ??
        pick((o) => o.isPending) ??
        pick((o) => o.wasPulledForStock && !widget.dismissedPulls.contains(o.id)) ??
        pick((o) => o.isReady);
  }

  Future<void> _cancelOne(CocktailOrder order) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await OrderService().cancelByGuest(order);
    } on OrderAlreadyPouring {
      messenger.showSnackBar(SnackBar(content: Text(l10n.roundCancelTooLate)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorWithMessage(e.toString()))));
    }
  }

  Future<void> _swapIn(CocktailOrder pulled, Cocktail swapTo) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _swapBusy = true);
    try {
      await OrderService().sendRound(
        partyId: widget.party.id,
        guestName: widget.guestName,
        guestId: widget.guestId,
        items: [RoundItem(cocktailId: swapTo.id, forName: pulled.forName)],
      );
      widget.onDismissPull(pulled.id);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.roundSwapFailed)));
    } finally {
      if (mounted) setState(() => _swapBusy = false);
    }
  }
}

// ------------------------------------------------------------- arrival

class _ArrivalView extends StatelessWidget {
  const _ArrivalView({
    required this.party,
    required this.allOrders,
    required this.cocktails,
    required this.onOpenMenu,
  });

  final Party party;
  final List<CocktailOrder> allOrders;
  final PartyCocktails cocktails;
  final VoidCallback onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final menu = cocktails.resolve(party.availableCocktailIds);
    final heroImage = menu.map((c) => c.image).where((i) => i.isNotEmpty).firstOrNull;
    final guests = allOrders.map((o) => o.guestName).toSet().length;
    final ordered = orderedTonight(allOrders);

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: AppBottomNav.insetOf(context) + 70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 340,
                width: double.infinity,
                child: heroImage != null
                    ? MenuCocktailImage(image: heroImage)
                    : Image.asset(_fallbackHero, fit: BoxFit.cover),
              ),
              const SizedBox(height: 340, child: PhotoScrim()),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, 12, AppSpacing.screenEdge, 0),
                  child: GlassSurface(
                    padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.signal,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: AppColors.signal, blurRadius: 8)],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(l10n.roundBarOpenPill.toUpperCase(), style: AppTypography.label),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, 18, AppSpacing.screenEdge, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(party.name, style: AppTypography.title.copyWith(fontSize: 30)),
                const SizedBox(height: 10),
                Text(
                  l10n.roundHostPouring(hostFirstName(party.hostName), guests),
                  style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Text(l10n.roundOnMenuTonight, style: AppTypography.section)),
                InkWell(
                  onTap: onOpenMenu,
                  borderRadius: AppRadius.pillAll,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    child: Text(
                      l10n.roundSeeAll(party.availableCocktailIds.length),
                      style: AppTypography.meta.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.signalLight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Still loading reads as loading, not as a host who added nothing —
          // the same distinction the Menu tab draws.
          if (menu.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
              child: Text(
                party.availableCocktailIds.isNotEmpty &&
                        !cocktails.isSettled(party.availableCocktailIds)
                    ? l10n.roundMenuLoading
                    : l10n.roundMenuEmptyBody(hostFirstName(party.hostName)),
                style: AppTypography.meta,
              ),
            )
          else
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
                itemCount: menu.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final cocktail = menu[index];
                  return _MenuRailTile(
                    name: cocktail.title.translate(context),
                    image: cocktail.image,
                    ordered: ordered[cocktail.id] ?? 0,
                    onTap: onOpenMenu,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuRailTile extends StatelessWidget {
  const _MenuRailTile({required this.name, required this.image, required this.ordered, required this.onTap});

  final String name;
  final String image;
  final int ordered;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
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
              if (ordered > 0)
                Positioned(
                  top: 9,
                  right: 9,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.readyWash,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '×$ordered',
                      style: AppTypography.label.copyWith(fontSize: 9.5, letterSpacing: 0, color: AppColors.ready),
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
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------- party header

class _PartyHeader extends StatelessWidget {
  const _PartyHeader({required this.party, required this.allOrders, required this.guestName});

  final Party party;
  final List<CocktailOrder> allOrders;
  final String guestName;

  @override
  Widget build(BuildContext context) {
    final guests = allOrders.map((o) => o.guestName).toSet().length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, 4, AppSpacing.screenEdge, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  party.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.heading.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.signal,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppColors.signal, blurRadius: 8)],
                      ),
                    ),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        context.l10n.roundPartyOpenGuests(guests),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.meta.copyWith(fontSize: 11.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GuestInitial(name: guestName, size: 34, highlighted: true),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------- in line / mixing / acked-ready

/// Screens 04 and 05, plus the fallback once a ready drink is acknowledged.
class _RoundCardView extends StatelessWidget {
  const _RoundCardView({
    required this.party,
    required this.allOrders,
    required this.guestName,
    required this.lead,
    required this.others,
    required this.acknowledgedReady,
    required this.cocktails,
    required this.onCancel,
    required this.onOpenMenu,
  });

  final Party party;
  final List<CocktailOrder> allOrders;
  final String guestName;
  final CocktailOrder lead;
  final List<CocktailOrder> others;
  final bool acknowledgedReady;
  final PartyCocktails cocktails;
  final ValueChanged<CocktailOrder> onCancel;
  final VoidCallback onOpenMenu;

  bool get _mixing => lead.isPreparing;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cocktail = cocktails.byId(lead.cocktailId);
    final drinkName = cocktail?.title.translate(context) ?? lead.cocktailId;
    final sentTime = DateFormat.Hm(Localizations.localeOf(context).toLanguageTag()).format(lead.createdAt);
    final menu = cocktails.resolve(party.availableCocktailIds);
    final ordered = orderedTonight(allOrders);

    return SingleChildScrollView(
      // No hero photo above these views, so they clear the status bar
      // themselves.
      padding: EdgeInsets.only(
        bottom: AppBottomNav.insetOf(context) + 70,
        top: MediaQuery.paddingOf(context).top + 4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PartyHeader(party: party, allOrders: allOrders, guestName: guestName),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: _mixing
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.signal.withValues(alpha: .28), AppColors.sheet],
                      ),
                      border: Border.all(color: AppColors.signal.withValues(alpha: .5), width: 1.5),
                    )
                  : BoxDecoration(color: AppColors.sheet, borderRadius: BorderRadius.circular(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _mixing
                            ? Container(
                                padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
                                decoration: BoxDecoration(
                                  color: AppColors.signal.withValues(alpha: .28),
                                  borderRadius: AppRadius.pillAll,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const _Dot(color: AppColors.signalLight),
                                    const SizedBox(width: 7),
                                    Flexible(
                                      child: Text(
                                        l10n.roundMixingNow.toUpperCase(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.label.copyWith(color: const Color(0xFFC9D7FF)),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Text(
                                l10n.roundYourRoundEyebrow.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.label,
                              ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _mixing
                            ? formatStopwatch(DateTime.now().difference(lead.preparedAt ?? DateTime.now()))
                            : l10n.roundSentAt(sentTime),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.measure.copyWith(fontSize: 11, color: AppColors.ink.withValues(alpha: .45)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _heroContent(context, drinkName),
                  const SizedBox(height: 14),
                  RoundProgressBar(
                    litCount: progressSegmentsOf(lead),
                    litColor: _mixing ? AppColors.signalLight : AppColors.ink,
                  ),
                  if (_mixing) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.ground.withValues(alpha: .4),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lock, size: 17, color: AppColors.ink.withValues(alpha: .45)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.roundCancelLocked,
                              style: AppTypography.meta.copyWith(fontSize: 11.5, height: 1.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (others.isNotEmpty && !_mixing) ...[
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 14),
                    for (final order in others)
                      RoundMateRow(
                        order: order,
                        cocktail: cocktails.byId(order.cocktailId),
                        allOrders: allOrders,
                        onCancel: () => onCancel(order),
                      ),
                  ],
                ],
              ),
            ),
          ),
          if (_mixing && others.isNotEmpty) ...[
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: AppColors.sheet, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    for (final order in others)
                      RoundMateRow(
                        order: order,
                        cocktail: cocktails.byId(order.cocktailId),
                        allOrders: allOrders,
                        onCancel: () => onCancel(order),
                      ),
                  ],
                ),
              ),
            ),
          ],
          if (_mixing) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
              child: OrderAside(icon: Icons.notifications_active, iconColor: AppColors.signalLight, child: Text(l10n.roundPocketIt)),
            ),
          ],
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Text(l10n.roundWhileYouWait, style: AppTypography.section)),
                InkWell(
                  onTap: onOpenMenu,
                  borderRadius: AppRadius.pillAll,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    child: Text(
                      l10n.roundFullMenu,
                      style: AppTypography.meta.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.signalLight),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
              itemCount: menu.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final cocktail = menu[index];
                return _MenuRailTile(
                  name: cocktail.title.translate(context),
                  image: cocktail.image,
                  ordered: ordered[cocktail.id] ?? 0,
                  onTap: onOpenMenu,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroContent(BuildContext context, String drinkName) {
    final l10n = context.l10n;
    if (_mixing) {
      return Text(
        lead.isForFriend
            ? l10n.roundMixingHeadlineFriend(hostFirstName(party.hostName), lead.forName!, drinkName)
            : l10n.roundMixingHeadlineMine(hostFirstName(party.hostName), drinkName),
        style: AppTypography.heading.copyWith(fontSize: 26),
      );
    }
    if (acknowledgedReady) {
      return Row(
        children: [
          const Icon(Icons.check_circle, size: 22, color: AppColors.ready),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${l10n.roundStatusReady} · $drinkName',
              style: AppTypography.cardTitle.copyWith(fontSize: 16),
            ),
          ),
        ],
      );
    }

    final position = positionOf(lead, allOrders) ?? 1;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('#$position', style: AppTypography.measure.copyWith(fontSize: 40, fontWeight: FontWeight.w800, color: AppColors.ink)),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              position == 1 ? l10n.roundYoureNext(drinkName) : l10n.roundInLine(drinkName),
              style: AppTypography.cardTitle.copyWith(fontSize: 13, fontWeight: FontWeight.w600, height: 1.3),
            ),
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color, blurRadius: 8)]),
    );
  }
}

// ------------------------------------------------------------- ready (07)

class _ReadyView extends StatelessWidget {
  const _ReadyView({
    required this.order,
    required this.others,
    required this.allOrders,
    required this.party,
    required this.cocktails,
    required this.onAcknowledge,
    required this.onCancel,
  });

  final CocktailOrder order;
  final List<CocktailOrder> others;
  final List<CocktailOrder> allOrders;
  final Party party;
  final PartyCocktails cocktails;
  final VoidCallback onAcknowledge;
  final ValueChanged<CocktailOrder> onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cocktail = cocktails.byId(order.cocktailId);
    final drinkName = cocktail?.title.translate(context) ?? order.cocktailId;
    final elapsed = shortElapsed(DateTime.now().difference(order.readyAt ?? DateTime.now()));

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: AppBottomNav.insetOf(context) + 70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(height: 420, width: double.infinity, child: MenuCocktailImage(image: cocktail?.image ?? '')),
              const SizedBox(height: 420, child: PhotoScrim()),
              Positioned(
                left: AppSpacing.screenEdge,
                right: AppSpacing.screenEdge,
                bottom: 20,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(9, 7, 14, 7),
                        decoration: BoxDecoration(
                          color: AppColors.ready.withValues(alpha: .92),
                          borderRadius: AppRadius.pillAll,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle, size: 15, color: Color(0xFF08240F)),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                l10n.roundReadySince(elapsed).toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.label.copyWith(color: const Color(0xFF08240F)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(l10n.roundGrabIt, style: AppTypography.display.copyWith(fontSize: 44, height: .96)),
                      const SizedBox(height: 14),
                      Text(
                        order.note != null
                            ? l10n.roundReadyLineWithNote(drinkName, order.note!)
                            : l10n.roundReadyLineNoNote(drinkName),
                        style: AppTypography.body.copyWith(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.inkBody),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (others.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: AppColors.sheet, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    for (final other in others)
                      RoundMateRow(
                        order: other,
                        cocktail: cocktails.byId(other.cocktailId),
                        allOrders: allOrders,
                        onCancel: () => onCancel(other),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
            child: Column(
              children: [
                SizedBox(
                  height: AppSizes.buttonPrimary + 4,
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onAcknowledge,
                    style: FilledButton.styleFrom(backgroundColor: AppColors.ink, foregroundColor: AppColors.ground),
                    icon: const Icon(Icons.directions_walk),
                    label: Text(l10n.roundOnMyWay),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.roundServedFootnote(hostFirstName(party.hostName)),
                  textAlign: TextAlign.center,
                  style: AppTypography.meta.copyWith(fontSize: 11.5, color: AppColors.ink.withValues(alpha: .35)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------- pulled (13)

class _PulledView extends StatelessWidget {
  const _PulledView({
    required this.pulled,
    required this.round,
    required this.allOrders,
    required this.party,
    required this.cocktails,
    required this.busy,
    required this.onSwapIn,
    required this.onDismiss,
  });

  final CocktailOrder pulled;
  final List<CocktailOrder> round;
  final List<CocktailOrder> allOrders;
  final Party party;
  final PartyCocktails cocktails;
  final bool busy;
  final ValueChanged<Cocktail> onSwapIn;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final host = hostFirstName(party.hostName);
    final pulledCocktail = cocktails.byId(pulled.cocktailId);
    final pulledName = pulledCocktail?.title.translate(context) ?? pulled.cocktailId;
    final ingredientName = pulled.outOfIngredientTitle?.translate(context) ?? '';

    // Still on its way means in line or being poured — a drink already on
    // the counter is not "coming", and has no place in line to name.
    final stillComing = round
        .where((o) => o.id != pulled.id && (o.isPending || o.isPreparing))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final menu = cocktails.resolve(party.availableCocktailIds);
    final suggestions = swapSuggestionsFor(pulled, menu: menu, round: round, allOrders: allOrders);
    final roundmateIds = {for (final o in round) if (o.id != pulled.id && !o.isCancelled) o.cocktailId};

    return SingleChildScrollView(
      // No hero photo above these views, so they clear the status bar
      // themselves.
      padding: EdgeInsets.only(
        bottom: AppBottomNav.insetOf(context) + 70,
        top: MediaQuery.paddingOf(context).top + 4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PartyHeader(party: party, allOrders: allOrders, guestName: pulled.guestName),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.low.withValues(alpha: .22), AppColors.sheet],
                ),
                border: Border.all(color: AppColors.low.withValues(alpha: .4), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(color: AppColors.lowWash, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.production_quantity_limits, size: 18, color: AppColors.low),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          l10n.roundPulledPill.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label.copyWith(color: AppColors.low),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.roundPulledTitle(host, ingredientName),
                    style: AppTypography.heading.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 12),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '${l10n.roundPulledIntro(pulledName)} '),
                        if (stillComing.isNotEmpty)
                          TextSpan(
                            text: l10n.roundStillComingAt(
                              possessiveLabel(
                                context,
                                forName: stillComing.first.forName,
                                drinkName: cocktails.byId(stillComing.first.cocktailId)?.title.translate(context) ?? stillComing.first.cocktailId,
                              ),
                              positionOf(stillComing.first, allOrders) ?? 1,
                            ),
                          ),
                      ],
                    ),
                    style: AppTypography.body.copyWith(fontSize: 13.5, height: 1.55, color: AppColors.ink.withValues(alpha: .65)),
                  ),
                ],
              ),
            ),
          ),
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.roundSwapTitle, style: AppTypography.section.copyWith(fontSize: 15)),
                  const SizedBox(height: 6),
                  Text(l10n.roundSwapSubtitle, style: AppTypography.meta.copyWith(fontSize: 12)),
                  const SizedBox(height: 14),
                  for (final suggestion in suggestions) ...[
                    _SwapRow(
                      cocktail: suggestion,
                      matesLabel: roundmateIds.contains(suggestion.id)
                          ? l10n.roundSwapMateLabel(
                              round.firstWhere((o) => o.cocktailId == suggestion.id && o.id != pulled.id).forName ?? pulled.guestName,
                            )
                          : null,
                      busy: busy,
                      onTap: busy ? null : () => onSwapIn(suggestion),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: onDismiss,
              child: Text(l10n.roundNothingForNow, style: AppTypography.meta.copyWith(fontSize: 12.5, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwapRow extends StatelessWidget {
  const _SwapRow({required this.cocktail, required this.matesLabel, required this.busy, required this.onTap});

  final Cocktail cocktail;
  final String? matesLabel;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: AppColors.sheet, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          OrderThumb(image: cocktail.image, size: 56, radius: 14),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(cocktail.title.translate(context), style: AppTypography.cardTitle.copyWith(fontSize: 15)),
                const SizedBox(height: 6),
                Text(
                  matesLabel ?? cocktailMeta(context.l10n, cocktail),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.meta.copyWith(fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: AppSizes.minTap,
            child: FilledButton(
              onPressed: onTap,
              // The theme's filled button is full-width (Size.fromHeight);
              // inside a Row that is an infinite width, and the whole
              // "sorry, it's out" view fails to lay out.
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.ink,
                foregroundColor: AppColors.ground,
                minimumSize: const Size(0, AppSizes.minTap),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                // The design's pill is 12.5; the theme's primary label is too
                // wide to share a 320pt row at a large text scale.
                textStyle: AppTypography.buttonSecondary.copyWith(fontSize: 12.5),
              ),
              child: busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ground),
                    )
                  : Text(context.l10n.roundSwapIn),
            ),
          ),
        ],
      ),
    );
  }
}
