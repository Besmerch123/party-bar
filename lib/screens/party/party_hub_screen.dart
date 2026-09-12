import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/auth.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../services/guest_session.dart';
import '../../services/party_service.dart';
import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/auth/auth_barrier_sheet.dart';
import '../../widgets/auth/auth_controls.dart';
import '../../widgets/common/app_bottom_nav.dart';
import '../../widgets/common/glass.dart';
import '../../widgets/party/host_party_card.dart';
import '../../widgets/party/host_state_pill.dart';
import 'live_party_hub.dart';

const _heroImage = 'assets/images/onboarding/midnight_orchard.jpg';
const _recapImage = 'assets/images/onboarding/cosmopolitan.jpg';

/// Flow 05 — the Party tab, which is the host's home.
///
/// Screen 01 (bar closed) until one of the host's parties is live. Signed
/// out there is nothing of theirs to list, so the hub never touches
/// Firestore until someone is.
class PartyHubScreen extends StatefulWidget {
  const PartyHubScreen({super.key});

  @override
  State<PartyHubScreen> createState() => _PartyHubScreenState();
}

class _PartyHubScreenState extends State<PartyHubScreen> {
  PartyService? _service;
  Stream<List<Party>>? _hosted;
  String? _hostedFor;

  /// Flow 07 — the party this phone is a guest at, if any. The design's
  /// fourth door: the phone remembers, so coming back is a tap rather than
  /// six characters. Dropped the moment the host closes the bar.
  Stream<Party?>? _guestParty;

  @override
  void initState() {
    super.initState();
    GuestSession.partyId().then((id) {
      if (!mounted || id == null) return;
      setState(() {
        _guestParty = (_service ??= PartyService()).streamParty(id);
      });
    });
  }

  void _openGuestParty(Party party) {
    context.push('${AppRoutes.activePartyGuest}/${party.id}', extra: party);
  }

  /// One subscription per signed-in account, rebuilt only when the account
  /// changes — not on every rebuild of the tab.
  Stream<List<Party>>? _hostedStreamFor(String? uid) {
    if (uid != _hostedFor) {
      _hostedFor = uid;
      _hosted = uid == null
          ? null
          : (_service ??= PartyService()).getHostedParties();
    }
    return _hosted;
  }

  /// Hosting is one of the three things that needs an owner, so this is a
  /// place the barrier can appear. It appears as a sheet over the hub rather
  /// than by walking someone into a screen that tells them no — the route
  /// guard behind it is the backstop for a cold deep link, not the way anyone
  /// should meet this.
  Future<void> _createParty() async {
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

  void _openParty(Party party) {
    if (party.isLive) {
      context.push('${AppRoutes.activePartyHost}/${party.id}', extra: party);
    } else {
      context.push('${AppRoutes.partyDetails}/${party.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthenticationProvider>().user?.uid;
    final stream = _hostedStreamFor(uid);

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: StreamBuilder<Party?>(
        stream: _guestParty,
        builder: (context, guestSnapshot) {
          // Only a party still live is somewhere to go back to; one that
          // ended belongs to whoever is clearing up, not to this tab.
          final guestParty = guestSnapshot.data?.isLive ?? false
              ? guestSnapshot.data
              : null;

          if (stream == null) {
            return _BarClosed(
              parties: const [],
              guestParty: guestParty,
              onHost: _createParty,
              onOpen: _openParty,
              onRejoin: _openGuestParty,
            );
          }

          return StreamBuilder<List<Party>>(
            stream: stream,
            builder: (context, snapshot) {
              final parties = snapshot.data ?? const <Party>[];
              final live = parties.where((p) => p.isLive).firstOrNull;
              if (live != null) return LivePartyHub(party: live);

              return _BarClosed(
                parties: parties,
                guestParty: guestParty,
                onHost: _createParty,
                onOpen: _openParty,
                onRejoin: _openGuestParty,
              );
            },
          );
        },
      ),
    );
  }
}

// ------------------------------------------------------------ 01 · closed

class _BarClosed extends StatelessWidget {
  const _BarClosed({
    required this.parties,
    required this.guestParty,
    required this.onHost,
    required this.onOpen,
    required this.onRejoin,
  });

  final List<Party> parties;

  /// A live party this phone is a guest at — someone else's bar, so it never
  /// joins [_cards] below, which are the host's own.
  final Party? guestParty;

  final VoidCallback onHost;
  final ValueChanged<Party> onOpen;
  final ValueChanged<Party> onRejoin;

  /// Anything live first, then every draft, then only the last party that
  /// ended — the recap worth a glance, not an archive.
  List<Party> get _cards => [
    ...parties.where((p) => p.isLive),
    ...parties.where((p) => p.isDraft),
    ...parties.where((p) => p.isEnded).take(1),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cards = _cards;

    return Stack(
      children: [
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 500,
          child: _Hero(image: _heroImage),
        ),
        SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: EdgeInsets.only(bottom: AppBottomNav.insetOf(context)),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      constraints.maxHeight - AppBottomNav.insetOf(context),
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
                        child: HostStatePill(label: l10n.hostBarClosed),
                      ),
                      const SizedBox(height: 120),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenEdge,
                          0,
                          AppSpacing.screenEdge,
                          22,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.hostNothingPouring,
                              style: AppTypography.display.copyWith(
                                height: .98,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 290),
                              child: Text(
                                l10n.hostNothingPouringBody,
                                style: AppTypography.body.copyWith(
                                  color: AppColors.ink.withValues(alpha: .62),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            AuthPillButton(
                              label: l10n.hostPartyCta,
                              icon: Icons.add,
                              primary: true,
                              height: AppSizes.buttonPrimary,
                              onPressed: onHost,
                            ),
                            const SizedBox(height: 10),
                            if (guestParty case final party?)
                              AuthPillButton(
                                label: l10n.joinBackTo(party.name),
                                icon: Icons.nightlife,
                                height: AppSizes.buttonSecondary,
                                background: AppColors.signalWash,
                                foreground: AppColors.ink,
                                onPressed: () => onRejoin(party),
                              )
                            else
                              AuthPillButton(
                                label: l10n.hostJoinWithCode,
                                icon: Icons.qr_code_scanner,
                                height: AppSizes.buttonSecondary,
                                background: AppColors.glass,
                                foreground: AppColors.ink,
                                onPressed: () =>
                                    context.push(AppRoutes.joinParty),
                              ),
                          ],
                        ),
                      ),
                      for (final (i, party) in cards.indexed) ...[
                        if (i > 0) const SizedBox(height: 10),
                        Padding(
                          padding: AppSpacing.screen,
                          child: _card(context, party),
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _card(BuildContext context, Party party) {
    final l10n = context.l10n;

    if (party.isLive) {
      return HostPartyCard(
        title: party.name,
        meta: l10n.hostLiveMeta(party.availableCocktailIds.length),
        actionLabel: l10n.hostOpen,
        icon: Icons.nightlife,
        actionColor: AppColors.signalLight,
        onTap: () => onOpen(party),
      );
    }

    if (party.isEnded) {
      return HostPartyCard(
        title: party.name,
        meta: l10n.hostEndedMeta(party.totalOrders),
        actionLabel: l10n.hostRecap,
        image: _recapImage,
        actionColor: AppColors.signalLight,
        onTap: () => onOpen(party),
      );
    }

    final saved = DateFormat.Hm(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(party.createdAt);
    return HostPartyCard(
      title: party.name,
      meta: l10n.hostDraftMeta(party.availableCocktailIds.length, saved),
      actionLabel: l10n.hostResume,
      onTap: () => onOpen(party),
    );
  }
}

// ---------------------------------------------------------------- chrome

/// A full-bleed photo carrying the one approved scrim.
class _Hero extends StatelessWidget {
  const _Hero({required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(image, fit: BoxFit.cover),
        const PhotoScrim(),
      ],
    );
  }
}
