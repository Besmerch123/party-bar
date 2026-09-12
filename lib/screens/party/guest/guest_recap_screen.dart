import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../generated/l10n/app_localizations.dart';
import '../../../models/auth.dart';
import '../../../models/models.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/party_cocktails.dart';
import '../../../services/guest_identity.dart';
import '../../../services/order_service.dart';
import '../../../services/party_service.dart';
import '../../../theme/theme.dart';
import '../../../utils/app_router.dart';
import '../../../utils/localization_helper.dart';
import '../../../widgets/auth/auth_barrier_sheet.dart';
import '../../../widgets/auth/auth_controls.dart';
import '../../../widgets/common/glass.dart';
import '../../../widgets/party/menu_cocktail_tile.dart';
import '../../../widgets/party/order_bits.dart' show hostFirstName;
import '../../../widgets/party/recap_bits.dart';

/// Flow 08 · screen 07 — the guest's own night, and the only place the app
/// asks anyone to host.
///
/// The numbers here are theirs, never the party's: three drinks, two of them
/// for Marta, four hours in the room. It lives on the phone for a week (see
/// [GuestSession.rememberRecap]) and needs no account to read, because a
/// guest never had one.
class GuestRecapScreen extends StatefulWidget {
  const GuestRecapScreen({super.key, required this.partyId, this.party});

  final String partyId;
  final Party? party;

  @override
  State<GuestRecapScreen> createState() => _GuestRecapScreenState();
}

class _GuestRecapScreenState extends State<GuestRecapScreen> {
  final PartyCocktails _cocktails = PartyCocktails();

  Party? _party;
  bool _missing = false;
  String? _guestId;

  List<CocktailOrder> _orders = const [];
  StreamSubscription<List<CocktailOrder>>? _ordersSub;

  @override
  void initState() {
    super.initState();
    _party = widget.party;
    if (_party == null) {
      _loadParty();
    } else {
      _cocktails.ensure(_party!.availableCocktailIds);
    }

    GuestIdentity.deviceId().then((id) {
      if (mounted) setState(() => _guestId = id);
    });

    _ordersSub = OrderService().streamPartyOrders(widget.partyId).listen((
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
      _cocktails.ensure(party.availableCocktailIds);
    } catch (_) {
      if (mounted) setState(() => _missing = true);
    }
  }

  void _exit() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.partyHub);
    }
  }

  /// Hosting is one of the three things that needs an account, so the
  /// barrier appears here as a sheet over the recap rather than walking
  /// someone out of the night they are still reading.
  Future<void> _startABar() async {
    final auth = context.read<AuthenticationProvider>();
    if (auth.isAuthenticated) {
      context.push(AppRoutes.createParty);
      return;
    }

    final signedIn = await showAuthBarrierSheet(
      context,
      reason: AuthReason.hostParty,
      redirectPath: AppRoutes.createParty,
    );
    if (signedIn && mounted) context.push(AppRoutes.createParty);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final party = _party;
    final guestId = _guestId;

    if (_missing) {
      return _Gone(message: l10n.guestRecapGone, onClose: _exit);
    }
    if (party == null || guestId == null) {
      return const Scaffold(
        backgroundColor: AppColors.ground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final mine = ordersOf(
      _orders,
      guestId: guestId,
      guestName: context.watch<AuthenticationProvider>().guestName,
    );

    return ListenableBuilder(
      listenable: _cocktails,
      builder: (context, _) => _build(context, GuestRecap.of(party, mine)),
    );
  }

  Widget _build(BuildContext context, GuestRecap recap) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final party = recap.party;
    final host = hostFirstName(party.hostName);

    final last = recap.lastDrink;
    final lastCocktail = last == null ? null : _cocktails.byId(last.cocktailId);

    final headline = recap.forFriends > 0
        ? l10n.guestRecapTitleMade(recap.forFriends, recap.drinks)
        : l10n.guestRecapTitle(recap.drinks);
    final story = _story(l10n, recap, host, lastCocktail);

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: Stack(
        children: [
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                MenuCocktailImage(image: lastCocktail?.image),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x8C0B0B0C),
                        Color(0x590B0B0C),
                        Color(0xEB0B0B0C),
                        Color(0xFF0B0B0C),
                      ],
                      stops: [0.0, 0.26, 0.62, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenEdge,
                    8,
                    AppSpacing.screenEdge,
                    0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GlassIconButton(
                        icon: Icons.close,
                        size: 34,
                        tooltip: l10n.close,
                        onTap: _exit,
                      ),
                      GlassIconButton(
                        icon: Icons.ios_share,
                        size: 34,
                        tooltip: l10n.recapShare,
                        onTap: () => Share.share(
                          '${headline.replaceAll('\n', ' ')} — $story',
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenEdge,
                      110,
                      AppSpacing.screenEdge,
                      AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n
                              .guestRecapEyebrow(
                                party.name,
                                DateFormat.MMMd(locale).format(
                                  party.endedAt ?? recap.party.createdAt,
                                ),
                              )
                              .toUpperCase(),
                          style: AppTypography.label.copyWith(
                            fontSize: 10.5,
                            letterSpacing: 1.47,
                            color: AppColors.ink.withValues(alpha: .55),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          headline,
                          style: AppTypography.title.copyWith(
                            fontSize: 34,
                            height: 1.02,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: Text(
                            story,
                            style: AppTypography.body.copyWith(
                              fontSize: 13.5,
                              height: 1.6,
                              color: AppColors.ink.withValues(alpha: .62),
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        RecapStatRow(
                          gap: 10,
                          stats: [
                            RecapStat(
                              value: '${recap.drinks}',
                              label: l10n.joinEndedDrinksLabel(recap.drinks),
                              valueSize: 26,
                              mono: true,
                              accent: true,
                            ),
                            RecapStat(
                              value: '${recap.forFriends}',
                              label: l10n.joinEndedFriendsLabel(
                                recap.forFriends,
                              ),
                              valueSize: 26,
                              mono: true,
                            ),
                            RecapStat(
                              value: l10n.joinEndedHours(recap.hoursThere),
                              label: l10n.joinEndedHereLabel,
                              valueSize: 26,
                              mono: true,
                            ),
                          ],
                        ),
                        if (lastCocktail != null) ...[
                          const SizedBox(height: 10),
                          NightRow(
                            title: lastCocktail.title.translate(context),
                            subtitle: lastCocktail.description.translate(
                              context,
                            ),
                            image: lastCocktail.image,
                            onTap: () => context.push(
                              '${AppRoutes.cocktailDetails}/${lastCocktail.id}',
                            ),
                            trailing: _RecipeChip(label: l10n.guestRecapRecipe),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenEdge,
                    16,
                    AppSpacing.screenEdge,
                    26,
                  ),
                  child: Column(
                    children: [
                      AuthPillButton(
                        label: l10n.guestRecapStartBar,
                        icon: Icons.local_bar,
                        primary: true,
                        height: AppSizes.buttonPrimary,
                        onPressed: _startABar,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.guestRecapFootnote,
                        textAlign: TextAlign.center,
                        style: AppTypography.meta.copyWith(
                          fontSize: 11.5,
                          height: 1.5,
                          color: AppColors.ink.withValues(alpha: .35),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Two sentences at most: who the drinks were for, and the one the night
  /// ended on. A guest who ordered nothing gets a third thing to read that
  /// is neither an apology nor a nudge.
  String _story(
    AppLocalizations l10n,
    GuestRecap recap,
    String host,
    Cocktail? lastCocktail,
  ) {
    if (recap.drinks == 0) return l10n.guestRecapNothing(host);

    final sentences = <String>[
      if (recap.forFriends > 0 && recap.friends.isNotEmpty)
        l10n.guestRecapForFriends(recap.forFriends, recap.friends.join(', ')),
      if (lastCocktail != null)
        l10n.guestRecapLastDrink(lastCocktail.title.translate(context), host),
    ];
    return sentences.join(' ');
  }
}

class _RecipeChip extends StatelessWidget {
  const _RecipeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.signalWash,
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.label.copyWith(
          fontSize: 10.5,
          color: AppColors.signalLight,
        ),
      ),
    );
  }
}

class _Gone extends StatelessWidget {
  const _Gone({required this.message, required this.onClose});

  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenEdge),
          child: Column(
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
        ),
      ),
    );
  }
}
