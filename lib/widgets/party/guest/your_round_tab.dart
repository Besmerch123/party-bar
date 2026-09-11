import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/models.dart';
import '../../../providers/party_cocktails.dart';
import '../../../theme/theme.dart';
import '../../../utils/localization_helper.dart';
import '../../common/app_bottom_nav.dart';
import '../../common/app_chip.dart';
import '../order_bits.dart';
import 'round_bits.dart';

/// Flow 06 · Your round tab (a light version of Flow 07 · 05) — every order
/// this phone has sent tonight, newest first, each carrying where it stands.
/// No Change/Leave actions live here; that is Flow 07's tab, not this one's.
class YourRoundTab extends StatelessWidget {
  const YourRoundTab({
    super.key,
    required this.party,
    required this.allOrders,
    required this.myOrders,
    required this.guestName,
    required this.cocktails,
  });

  final Party party;
  final List<CocktailOrder> allOrders;
  final List<CocktailOrder> myOrders;
  final String guestName;
  final PartyCocktails cocktails;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ordered = oldestFirst(myOrders).reversed.toList();
    final stillComing = myOrders.where((o) => o.isOpen).length;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        16,
        AppSpacing.screenEdge,
        AppBottomNav.insetOf(context) + 70,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.roundYourRoundTitle, style: AppTypography.title.copyWith(fontSize: 30)),
          const SizedBox(height: 10),
          Row(
            children: [
              TagChip(label: party.name, icon: Icons.local_bar),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            l10n.roundTonightSummary(myOrders.length, stillComing),
            style: AppTypography.meta.copyWith(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.sheet, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                GuestInitial(name: guestName, size: 34, highlighted: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.roundYoureTonight(guestName),
                    style: AppTypography.cardTitle.copyWith(fontSize: 13.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          if (ordered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(l10n.roundMenuEmptyTitle, style: AppTypography.meta),
              ),
            )
          else
            for (final order in ordered) ...[
              _OrderCard(order: order, cocktail: cocktails.byId(order.cocktailId), allOrders: allOrders),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.cocktail, required this.allOrders});

  final CocktailOrder order;
  final Cocktail? cocktail;
  final List<CocktailOrder> allOrders;

  @override
  Widget build(BuildContext context) {
    final title = cocktail?.title.translate(context) ?? order.cocktailId;
    final time = DateFormat.Hm(Localizations.localeOf(context).toLanguageTag()).format(order.createdAt);
    final highlight = order.isPending || order.isPreparing;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: highlight ? AppColors.signalWash : AppColors.sheet,
        borderRadius: BorderRadius.circular(18),
        border: highlight ? Border.all(color: AppColors.signal.withValues(alpha: .4)) : null,
      ),
      child: Row(
        children: [
          OrderThumb(image: cocktail?.image, size: 58, greyed: order.isCancelled),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTypography.cardTitle.copyWith(fontSize: 15)),
                const SizedBox(height: 6),
                Text(
                  '${forLabel(context, forName: order.forName)} · $time',
                  style: AppTypography.meta.copyWith(fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _trailing(context),
        ],
      ),
    );
  }

  Widget _trailing(BuildContext context) {
    final l10n = context.l10n;
    switch (order.status) {
      case OrderStatus.pending:
        return StatusChip(
          label: l10n.roundOrderPositionInLine(positionOf(order, allOrders) ?? 1),
          tone: ChipTone.signal,
        );
      case OrderStatus.preparing:
        return StatusChip(label: l10n.roundStatusMixing, tone: ChipTone.signal);
      case OrderStatus.ready:
        return StatusChip(label: l10n.roundStatusReady, tone: ChipTone.ready);
      case OrderStatus.delivered:
        return StatusChip(label: l10n.roundStatusServed, tone: ChipTone.neutral);
      case OrderStatus.cancelled:
        return StatusChip(
          label: order.wasPulledForStock ? l10n.roundStatusPulled : l10n.roundStatusCancelled,
          tone: ChipTone.low,
        );
    }
  }
}
