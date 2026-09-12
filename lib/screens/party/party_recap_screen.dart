import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/order_repository.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/party_cocktails.dart';
import '../../services/party_service.dart';
import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/auth/auth_controls.dart';
import '../../widgets/common/glass.dart';
import '../../widgets/party/menu_cocktail_tile.dart';
import '../../widgets/party/order_bits.dart' show formatStopwatch;
import '../../widgets/party/recap_bits.dart';
import '../../widgets/party/save_menu_sheet.dart';
import '../bar/ran_out_screen.dart';
import 'party_ending.dart';
import 'share_card_screen.dart';

/// The photo behind a recap with nothing to show a drink of.
const _fallbackHero = 'assets/images/onboarding/cosmopolitan.jpg';

/// How recently a party has to have ended to still be "last night".
const _lastNight = Duration(hours: 24);

/// Flow 08 · screen 02 — the night, as a place rather than a moment.
///
/// Nobody reads numbers at 01:24, so this is not shown at the end of the
/// party: it has a route, it sits in history, and closing it loses nothing.
/// Everything the night leaves behind — the share card, the restock, the
/// saved menu — hangs off this one screen instead of being a step the host
/// has to walk through.
class PartyRecapScreen extends StatefulWidget {
  const PartyRecapScreen({super.key, required this.partyId, this.party});

  final String partyId;

  /// Handed over by whatever opened the recap, so the screen draws before
  /// Firestore answers. A cold link carries none and loads it by id.
  final Party? party;

  @override
  State<PartyRecapScreen> createState() => _PartyRecapScreenState();
}

class _PartyRecapScreenState extends State<PartyRecapScreen> {
  final PartyCocktails _cocktails = PartyCocktails();

  Party? _party;
  bool _missing = false;

  List<CocktailOrder> _orders = const [];
  StreamSubscription<List<CocktailOrder>>? _ordersSub;

  /// What the ran-out checklist will open with. Best-effort and slow, so the
  /// card is tappable long before it arrives.
  RanOutArgs? _ranOut;

  /// Set once the menu has been kept, so the card stops offering it.
  String? _savedMenu;

  @override
  void initState() {
    super.initState();
    _party = widget.party;
    if (_party == null) {
      _loadParty();
    } else {
      _onParty(_party!);
    }

    _ordersSub = OrderRepository().streamPartyOrders(widget.partyId).listen((
      orders,
    ) {
      _cocktails.ensure(orders.map((o) => o.cocktailId));
      if (mounted) setState(() => _orders = orders);
    });
  }

  @override
  void dispose() {
    _ordersSub?.cancel();
    _cocktails.dispose();
    super.dispose();
  }

  Future<void> _loadParty() async {
    try {
      final party = await PartyService().getPartyById(widget.partyId);
      if (!mounted) return;
      if (party == null) {
        setState(() => _missing = true);
        return;
      }
      setState(() => _party = party);
      _onParty(party);
    } catch (_) {
      if (mounted) setState(() => _missing = true);
    }
  }

  void _onParty(Party party) {
    _cocktails.ensure(party.availableCocktailIds);
    unawaited(_loadRanOut(party));
  }

  Future<void> _loadRanOut(Party party) async {
    final args = await ranOutArgsFor(party);
    if (mounted) setState(() => _ranOut = args);
  }

  String? _title(String cocktailId) =>
      _cocktails.byId(cocktailId)?.title.translate(context);

  String? _image(String cocktailId) => _cocktails.byId(cocktailId)?.image;

  void _exit() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.partyHub);
    }
  }

  Future<void> _share(PartyRecap recap) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ShareCardScreen(
        recap: recap,
        orders: _orders,
        cocktails: _cocktails,
      ),
    ),
  );

  void _restock() {
    final party = _party;
    if (party == null) return;
    context.push(
      AppRoutes.barRanOut,
      extra: _ranOut ?? RanOutArgs(partyName: party.name),
    );
  }

  Future<void> _saveMenu() async {
    final party = _party;
    if (party == null) return;

    final saved = await showSaveMenuSheet(
      context,
      suggestedName: party.name,
      cocktailIds: party.availableCocktailIds,
    );
    if (saved == null || !mounted) return;
    setState(() => _savedMenu = saved.name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final party = _party;

    if (party == null) {
      return Scaffold(
        body: SafeArea(
          child: _missing
              ? _Missing(message: l10n.recapMissing, onClose: _exit)
              : const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return ListenableBuilder(
      listenable: _cocktails,
      builder: (context, _) => _build(context, PartyRecap.of(party, _orders)),
    );
  }

  Widget _build(BuildContext context, PartyRecap recap) {
    final l10n = context.l10n;
    final party = recap.party;
    final locale = Localizations.localeOf(context).toLanguageTag();

    final heroId = recap.tallies.isEmpty
        ? party.availableCocktailIds.firstOrNull
        : recap.tallies.first.cocktailId;

    return Scaffold(
      body: Stack(
        children: [
          _Hero(image: heroId == null ? null : _image(heroId)),
          SafeArea(
            child: Column(
              children: [
                _TopBar(
                  badge: _badge(l10n, party),
                  onBack: _exit,
                  onShare: () => _share(recap),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenEdge,
                      150,
                      AppSpacing.screenEdge,
                      AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          party.name,
                          style: AppTypography.display.copyWith(
                            fontSize: 38,
                            height: .98,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _when(l10n, recap, locale),
                          style: AppTypography.meta.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkBody,
                          ),
                        ),
                        const SizedBox(height: 24),
                        RecapStatRow(
                          stats: [
                            RecapStat(
                              value: '${recap.poured}',
                              label: l10n.recapPouredLabel,
                              accent: true,
                            ),
                            RecapStat(
                              value: recap.averageWait == null
                                  ? l10n.recapNoWait
                                  : formatStopwatch(recap.averageWait!),
                              label: l10n.recapWaitLabel,
                            ),
                            RecapStat(
                              value: '${recap.recipesUsed}',
                              label: l10n.recapRecipesLabel,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (recap.isEmpty)
                          Text(
                            l10n.recapNothingPoured,
                            style: AppTypography.body,
                          )
                        else ...[
                          Text(
                            l10n.recapWhatPeopleDrank,
                            style: AppTypography.section,
                          ),
                          const SizedBox(height: 14),
                          for (final (index, tally) in recap.tallies.indexed) ...[
                            if (index > 0) const SizedBox(height: 10),
                            DrinkTallyRow(
                              name: _title(tally.cocktailId) ?? tally.cocktailId,
                              image: _image(tally.cocktailId),
                              count: tally.poured,
                              share: recap.showsBars
                                  ? recap.shareOf(tally)
                                  : null,
                              leader: index == 0,
                            ),
                          ],
                        ],
                        const SizedBox(height: 16),
                        _Leftovers(
                          restockCount: _ranOut?.pourCounts.length ?? 0,
                          menuCount: party.availableCocktailIds.length,
                          savedMenu: _savedMenu,
                          onRestock: _restock,
                          onSaveMenu: _saveMenu,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenEdge,
                    18,
                    AppSpacing.screenEdge,
                    24,
                  ),
                  child: AuthPillButton(
                    label: l10n.recapShare,
                    icon: Icons.ios_share,
                    primary: true,
                    height: AppSizes.buttonPrimary,
                    onPressed: () => _share(recap),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _badge(AppLocalizations l10n, Party party) {
    if (!party.isEnded) return l10n.recapTonight;
    final endedAt = party.endedAt;
    if (endedAt == null) return l10n.recapEarlier;
    return DateTime.now().difference(endedAt) < _lastNight
        ? l10n.recapLastNight
        : l10n.recapEarlier;
  }

  /// "Fri 4 Sep · 21:00 – 01:24 · 9 guests", or the open-ended version for a
  /// party still pouring.
  String _when(AppLocalizations l10n, PartyRecap recap, String locale) {
    final date = DateFormat('EEE d MMM', locale).format(recap.startedAt);
    final from = DateFormat.Hm(locale).format(recap.startedAt);
    final guests = l10n.recapGuests(recap.guests);
    final until = recap.endedAt;

    return until == null
        ? l10n.recapWhenOpen(date, from, guests)
        : l10n.recapWhen(date, from, DateFormat.Hm(locale).format(until), guests);
  }
}

/// The two cards the night's leftovers hang off. Saving the menu is replaced
/// by what it saved rather than disappearing — a card that vanishes on tap
/// reads as a mistake.
class _Leftovers extends StatelessWidget {
  const _Leftovers({
    required this.restockCount,
    required this.menuCount,
    required this.savedMenu,
    required this.onRestock,
    required this.onSaveMenu,
  });

  final int restockCount;
  final int menuCount;
  final String? savedMenu;
  final VoidCallback onRestock;
  final VoidCallback onSaveMenu;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final saved = savedMenu;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: RecapActionCard(
              icon: Icons.shopping_basket,
              tone: AppColors.low,
              wash: AppColors.lowWash,
              title: l10n.recapRestockTitle,
              subtitle: l10n.recapRestockBody(restockCount),
              onTap: onRestock,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RecapActionCard(
              icon: saved == null ? Icons.bookmark_add : Icons.bookmark,
              title: saved == null
                  ? l10n.recapSaveMenuTitle
                  : l10n.recapSaveMenuDone(saved),
              subtitle: l10n.recapSaveMenuBody(menuCount),
              onTap: onSaveMenu,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.badge,
    required this.onBack,
    required this.onShare,
  });

  final String badge;
  final VoidCallback onBack;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, 8, AppSpacing.screenEdge, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GlassIconButton(
            icon: Icons.arrow_back,
            size: 34,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onTap: onBack,
          ),
          GlassSurface(
            color: AppColors.glass,
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
            child: Text(
              badge.toUpperCase(),
              style: AppTypography.label.copyWith(fontSize: 10.5),
            ),
          ),
          GlassIconButton(
            icon: Icons.ios_share,
            size: 34,
            tooltip: context.l10n.recapShare,
            onTap: onShare,
          ),
        ],
      ),
    );
  }
}

/// The busiest drink of the night carries the top of the screen, fading into
/// the ground so the numbers below never fight it.
class _Hero extends StatelessWidget {
  const _Hero({required this.image});

  final String? image;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 400,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (image == null || image!.isEmpty)
            Image.asset(
              _fallbackHero,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) =>
                  const ColoredBox(color: AppColors.row),
            )
          else
            MenuCocktailImage(image: image),
          const PhotoScrim(),
        ],
      ),
    );
  }
}

class _Missing extends StatelessWidget {
  const _Missing({required this.message, required this.onClose});

  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenEdge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.heading.copyWith(fontSize: 24),
          ),
          const Spacer(),
          AuthPillButton(
            label: context.l10n.joinEndedDone,
            primary: true,
            height: AppSizes.buttonPrimary,
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}
