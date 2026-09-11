import 'package:flutter/material.dart';

import '../../../models/models.dart';
import '../../../providers/party_cocktails.dart';
import '../../../theme/theme.dart';
import '../../../utils/localization_helper.dart';
import '../../../widgets/auth/auth_controls.dart';
import '../../../widgets/common/glass.dart';
import '../../../widgets/party/order_bits.dart' show hostFirstName;

/// Flow 06 · screen 03 — the round just sent, kept live from the orders
/// stream so a position dropping (or an order the host starts pouring
/// already) shows without leaving the screen. [orders] is the full,
/// continuously-updated stream; [roundIds] pins which of them belong to
/// this send.
class RoundSentScreen extends StatelessWidget {
  const RoundSentScreen({
    super.key,
    required this.party,
    required this.orders,
    required this.roundIds,
    required this.cocktails,
    required this.onBackToMenu,
    required this.onCancelRound,
  });

  final Party party;
  final Stream<List<CocktailOrder>> orders;
  final List<String> roundIds;
  final PartyCocktails cocktails;
  final VoidCallback onBackToMenu;
  final Future<int> Function(List<CocktailOrder> round) onCancelRound;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final host = hostFirstName(party.hostName);

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: StreamBuilder<List<CocktailOrder>>(
        stream: orders,
        builder: (context, snapshot) {
          final all = snapshot.data ?? const <CocktailOrder>[];
          // Oldest first, the order the host pours in — a round sent in one
          // batch shares a timestamp, so send order is not line order.
          final round = oldestFirst(
            roundIds
                .map((id) => all.where((o) => o.id == id).firstOrNull)
                .whereType<CocktailOrder>(),
          );

          return Stack(
            children: [
              SizedBox(
                height: 520,
                width: double.infinity,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.matrix(<double>[
                    0.6063, 0.3576, 0.0361, 0, 0, //
                    0.1063, 0.8576, 0.0361, 0, 0, //
                    0.1063, 0.3576, 0.5361, 0, 0, //
                    0, 0, 0, 1, 0,
                  ]),
                  child: Image.asset('assets/images/onboarding/midnight_orchard.jpg', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 520, child: PhotoScrim()),
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(color: AppColors.readyWash, borderRadius: BorderRadius.circular(32)),
                                child: const Icon(Icons.check, size: 32, color: AppColors.ready),
                              ),
                              const SizedBox(height: 22),
                              Text(l10n.roundOrdersIn, style: AppTypography.title.copyWith(fontSize: 34)),
                              const SizedBox(height: 16),
                              Text(
                                l10n.roundOrdersInBody(round.length, host),
                                textAlign: TextAlign.center,
                                style: AppTypography.body.copyWith(fontSize: 13.5, color: AppColors.ink.withValues(alpha: .62)),
                              ),
                              const SizedBox(height: 28),
                              Row(
                                children: [
                                  for (final (i, order) in round.indexed) ...[
                                    if (i > 0) const SizedBox(width: 10),
                                    Expanded(child: _GlassTile(order: order, cocktail: cocktails.byId(order.cocktailId), allOrders: all)),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, 0, AppSpacing.screenEdge, 22),
                      child: Column(
                        children: [
                          AuthPillButton(
                            label: l10n.roundBackToMenu,
                            icon: Icons.local_bar,
                            primary: true,
                            height: AppSizes.buttonPrimary,
                            onPressed: onBackToMenu,
                          ),
                          const SizedBox(height: 14),
                          AuthGhostAction(
                            label: l10n.roundCancelRound,
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final kept = await onCancelRound(round);
                              if (kept > 0) {
                                messenger.showSnackBar(SnackBar(content: Text(l10n.roundCancelRoundKept(kept))));
                              }
                            },
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.roundCancelRoundFootnote(host),
                            textAlign: TextAlign.center,
                            style: AppTypography.meta.copyWith(fontSize: 11.5, color: AppColors.ink.withValues(alpha: .32)),
                          ),
                        ],
                      ),
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

class _GlassTile extends StatelessWidget {
  const _GlassTile({required this.order, required this.cocktail, required this.allOrders});

  final CocktailOrder order;
  final Cocktail? cocktail;
  final List<CocktailOrder> allOrders;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = cocktail?.title.translate(context) ?? order.cocktailId;
    final eyebrow = order.isForFriend ? '$title · ${order.forName}' : title;
    final position = positionOf(order, allOrders);

    return GlassSurface(
      borderRadius: AppRadius.tileAll,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label.copyWith(fontSize: 9.5),
          ),
          const SizedBox(height: 8),
          Text(
            position != null ? '#$position' : '—',
            style: AppTypography.measure.copyWith(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.ink),
          ),
          const SizedBox(height: 6),
          Text(
            position != null ? l10n.roundInLineTag : l10n.roundStatusMixing,
            style: AppTypography.meta.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
