import 'package:flutter/material.dart';

import '../../../models/models.dart';
import '../../../theme/theme.dart';
import '../../../utils/localization_helper.dart';
import '../../../widgets/auth/auth_controls.dart';
import '../../../widgets/party/order_bits.dart' show hostFirstName;

/// Flow 07 · screen 06 — the party ends while the guest is still holding the
/// phone.
///
/// Not an error and not a dead end: a closing sentence, the three numbers
/// that are actually theirs, and one way out. The code has stopped working
/// by the time this is on screen, so there is nothing here to retry.
class PartyEndedScreen extends StatelessWidget {
  const PartyEndedScreen({
    super.key,
    required this.party,
    required this.myOrders,
    required this.onDone,
    this.onSeeTheNight,
  });

  final Party party;

  /// Only this phone's orders — the numbers are the guest's night, not the
  /// party's. The party's own totals belong to the host's recap.
  final List<CocktailOrder> myOrders;

  final VoidCallback onDone;

  /// Flow 08 · screen 07. Null only where the recap is not reachable — the
  /// screen then ships the numbers and a single way out rather than a dead
  /// button.
  final VoidCallback? onSeeTheNight;

  /// A cancelled drink was never drunk, so it is not part of the night.
  List<CocktailOrder> get _poured =>
      myOrders.where((o) => !o.isCancelled).toList();

  /// Rounded down, floored at one: someone who arrived at half past midnight
  /// was still here for the night, and "0H here" says otherwise.
  int get _hoursHere {
    final arrived = myOrders.isEmpty
        ? party.wentLiveAt
        : myOrders.map((o) => o.createdAt).reduce((a, b) => a.isBefore(b) ? a : b);
    if (arrived == null) return 1;

    final until = party.endedAt ?? DateTime.now();
    final hours = until.difference(arrived).inHours;
    return hours < 1 ? 1 : hours;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final poured = _poured;
    final forFriends = poured.where((o) => o.forName != null).length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  AppSpacing.lg,
                  AppSpacing.screenEdge,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.fillMuted,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.bedtime,
                        size: 26,
                        color: AppColors.ink.withValues(alpha: .55),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.joinEndedTitle(hostFirstName(party.hostName)),
                      style: AppTypography.title.copyWith(
                        fontSize: 34,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.joinEndedBody(party.name),
                      style: AppTypography.body.copyWith(
                        color: AppColors.inkBody,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _YourNight(
                      drinks: poured.length,
                      forFriends: forFriends,
                      hours: _hoursHere,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                0,
                AppSpacing.screenEdge,
                22,
              ),
              child: Column(
                children: [
                  if (onSeeTheNight case final see?) ...[
                    AuthPillButton(
                      label: l10n.guestRecapSee,
                      icon: Icons.auto_stories,
                      primary: true,
                      height: AppSizes.buttonPrimary,
                      onPressed: see,
                    ),
                    const SizedBox(height: 10),
                    AuthPillButton(
                      label: l10n.joinEndedDone,
                      height: AppSizes.buttonGhost,
                      onPressed: onDone,
                    ),
                  ] else
                    AuthPillButton(
                      label: l10n.joinEndedDone,
                      primary: true,
                      height: AppSizes.buttonPrimary,
                      onPressed: onDone,
                    ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.joinEndedFootnote,
                    textAlign: TextAlign.center,
                    style: AppTypography.caption,
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

class _YourNight extends StatelessWidget {
  const _YourNight({
    required this.drinks,
    required this.forFriends,
    required this.hours,
  });

  final int drinks;
  final int forFriends;
  final int hours;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.sheet,
        borderRadius: AppRadius.cardAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthEyebrow(label: l10n.joinEndedYourNight),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  value: '$drinks',
                  label: l10n.joinEndedDrinksLabel(drinks),
                ),
              ),
              Expanded(
                child: _Stat(
                  value: '$forFriends',
                  label: l10n.joinEndedFriendsLabel(forFriends),
                ),
              ),
              Expanded(
                child: _Stat(
                  value: l10n.joinEndedHours(hours),
                  label: l10n.joinEndedHereLabel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTypography.heading.copyWith(fontSize: 28, height: 1),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTypography.caption,
        ),
      ],
    );
  }
}
