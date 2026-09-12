import 'package:flutter/material.dart';

import '../../../models/models.dart';
import '../../../theme/theme.dart';
import '../../../utils/localization_helper.dart';
import '../../common/glass.dart';
import '../order_bits.dart';

/// Flow 06 · screen 08 — the top banner announcing a round that just landed.
/// Floats over whatever the hub is showing; the caller times its own
/// dismissal (auto-dismiss ~8s per the design).
class OrderLandedBanner extends StatelessWidget {
  const OrderLandedBanner({
    super.key,
    required this.round,
    required this.cocktailTitleOf,
    required this.onPour,
  });

  /// The newest round, oldest order first — [landedSince]'s result.
  final List<CocktailOrder> round;

  /// Resolves a cocktail id to its translated title, or null while it is
  /// still loading.
  final String? Function(String cocktailId) cocktailTitleOf;

  final VoidCallback onPour;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sender = round.first.guestName;
    final names = round
        .map((o) {
          final title = cocktailTitleOf(o.cocktailId) ?? '—';
          return o.isForFriend ? '$title ${l10n.queueForFriend(o.forName!)}' : title;
        })
        .join(' · ');

    return GlassSurface(
      color: const Color(0xD11C1C20),
      borderRadius: BorderRadius.circular(22),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.signal,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              sender.trim().isEmpty ? '?' : sender.trim().characters.first.toUpperCase(),
              style: AppTypography.cardTitle.copyWith(fontSize: 15, color: AppColors.ink),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.queueOrderLandedTitle(sender, round.length),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.cardTitle.copyWith(fontSize: 14, letterSpacing: -0.1),
                ),
                const SizedBox(height: 5),
                Text(
                  names,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.meta.copyWith(
                    fontSize: 12,
                    color: AppColors.inkBody,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: AppColors.ink,
            borderRadius: AppRadius.pillAll,
            child: InkWell(
              onTap: onPour,
              borderRadius: AppRadius.pillAll,
              child: Container(
                constraints: const BoxConstraints(minHeight: AppSizes.minTap),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                child: Text(
                  l10n.queuePourPill,
                  style: AppTypography.cardTitle.copyWith(fontSize: 12, color: AppColors.ground),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Flow 06 · screen 08 — replaces the menu rail once the queue has something
/// in it: up to three oldest orders, and a tap opens the queue itself.
class WaitingOnYouCard extends StatelessWidget {
  const WaitingOnYouCard({
    super.key,
    required this.line,
    required this.cocktailTitleOf,
    required this.onTap,
  });

  /// [inLine] order, oldest first.
  final List<CocktailOrder> line;
  final String? Function(String cocktailId) cocktailTitleOf;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rows = line.take(3).toList();

    return Material(
      color: AppColors.sheet,
      borderRadius: AppRadius.tileAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.tileAll,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.queueWaitingOnYouTitle, style: AppTypography.cardTitle.copyWith(fontSize: 12.5)),
                  Text(
                    l10n.queueInLineBadge(line.length).toUpperCase(),
                    style: AppTypography.mono.copyWith(color: AppColors.signalLight),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              for (final (i, order) in rows.indexed) ...[
                if (i > 0) const SizedBox(height: 8),
                _WaitingRow(order: order, cocktailTitle: cocktailTitleOf(order.cocktailId)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WaitingRow extends StatelessWidget {
  const _WaitingRow({required this.order, required this.cocktailTitle});

  final CocktailOrder order;
  final String? cocktailTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final age = DateTime.now().difference(order.createdAt);
    final isNew = age < const Duration(seconds: 60);

    return Row(
      children: [
        GuestInitial(name: order.guestName, size: 22),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            l10n.queueDrinkForGuest(cocktailTitle ?? '—', order.guestName),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body.copyWith(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        if (isNew)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.signalWash,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              l10n.queueNewTag.toUpperCase(),
              style: AppTypography.label.copyWith(fontSize: 9, color: AppColors.signalLight),
            ),
          )
        else
          Text(formatWait(age), style: AppTypography.mono),
      ],
    );
  }
}
