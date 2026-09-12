import 'package:flutter/material.dart';

import '../../../models/models.dart';
import '../../../theme/theme.dart';
import '../../../utils/localization_helper.dart';
import '../host_sheets.dart' show kHostLowLight;
import '../order_bits.dart';

/// Flow 06 — small pieces shared across the guest's screens: the host's
/// first name, the four-segment progress bar, a short "how long ago", and
/// the round-mate row every open state (04/05/07) reuses for "the rest of
/// the round".

/// "for you" / "for Marta" — who a round item is for, in the sender's own
/// voice.
String forLabel(BuildContext context, {required String? forName}) {
  final l10n = context.l10n;
  return forName == null || forName.isEmpty
      ? l10n.roundForYou
      : l10n.roundForFriend(forName);
}

/// "Your Gin & Tonic" / "Marta's Cosmopolitan" — the same pairing, third
/// person, for screen 13's "what else is still coming".
String possessiveLabel(
  BuildContext context, {
  required String? forName,
  required String drinkName,
}) {
  final l10n = context.l10n;
  return forName == null || forName.isEmpty
      ? l10n.roundOthersLabelMine(drinkName)
      : l10n.roundOthersLabelFriend(forName, drinkName);
}

/// "20s" under a minute, "4m" after — the ticking unit [roundReadySince]
/// wraps. Never seconds once a whole minute has passed: a phone glanced at
/// five minutes on should read "5m ago", not a stale "312s ago".
String shortElapsed(Duration elapsed) {
  if (elapsed.isNegative) elapsed = Duration.zero;
  if (elapsed.inMinutes < 1) return '${elapsed.inSeconds}s';
  return '${elapsed.inMinutes}m';
}

/// The SENT · IN LINE · MIXING · READY ladder. [litCount] is
/// [progressSegmentsOf] — 1 for a cancelled order, up to 4 once ready.
class RoundProgressBar extends StatelessWidget {
  const RoundProgressBar({super.key, required this.litCount, this.litColor = AppColors.ink});

  final int litCount;
  final Color litColor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = [
      l10n.roundStageSent,
      l10n.roundStageInLine,
      l10n.roundStageMixing,
      l10n.roundStageReady,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 0; i < 4; i++) ...[
              if (i > 0) const SizedBox(width: 5),
              Expanded(
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: i < litCount ? litColor : AppColors.ink.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < 4; i++)
              Expanded(
                child: Text(
                  labels[i].toUpperCase(),
                  textAlign: i == 0 ? TextAlign.start : (i == 3 ? TextAlign.end : TextAlign.center),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label.copyWith(
                    fontSize: 9,
                    color: i < litCount ? litColor : AppColors.inkFaint,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// One of "the round's other drinks" — every state (04/05/07) shows the
/// rest of the round the same way, only the trailing content differs by
/// what that order is doing right now.
class RoundMateRow extends StatelessWidget {
  const RoundMateRow({
    super.key,
    required this.order,
    required this.cocktail,
    required this.allOrders,
    this.onCancel,
    this.dense = false,
  });

  final CocktailOrder order;
  final Cocktail? cocktail;
  final Iterable<CocktailOrder> allOrders;
  final VoidCallback? onCancel;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = cocktail?.title.translate(context) ?? order.cocktailId;
    final size = dense ? 44.0 : 48.0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: dense ? 8 : 0),
      child: Row(
        children: [
          OrderThumb(image: cocktail?.image, size: size, greyed: order.isCancelled),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: title, style: AppTypography.cardTitle.copyWith(fontSize: 12.5)),
                      if (order.isForFriend)
                        TextSpan(
                          text: ' · ${l10n.roundForFriend(order.forName!)}',
                          style: AppTypography.meta.copyWith(fontWeight: FontWeight.w500),
                        ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                _trailingLabel(context),
              ],
            ),
          ),
          if (onCancel != null && order.canGuestCancel) ...[
            const SizedBox(width: 8),
            _CancelLink(onTap: onCancel!),
          ],
        ],
      ),
    );
  }

  Widget _trailingLabel(BuildContext context) {
    final l10n = context.l10n;

    switch (order.status) {
      case OrderStatus.pending:
        final position = positionOf(order, allOrders);
        return Text(
          position == null ? l10n.roundStatusReady : l10n.roundOrderPositionInLine(position),
          style: AppTypography.meta.copyWith(fontSize: 11, color: AppColors.ink.withValues(alpha: .42)),
        );
      case OrderStatus.preparing:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(color: AppColors.signalLight, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              l10n.roundMixingNow,
              style: AppTypography.caption.copyWith(color: AppColors.signalLight),
            ),
          ],
        );
      case OrderStatus.ready:
        return Text(
          l10n.roundStatusReady,
          style: AppTypography.caption.copyWith(color: AppColors.ready, fontWeight: FontWeight.w600),
        );
      case OrderStatus.delivered:
        return Text(
          l10n.roundStatusServed,
          style: AppTypography.meta.copyWith(fontSize: 11, color: AppColors.inkFaint),
        );
      case OrderStatus.cancelled:
        return Text(
          order.wasPulledForStock ? l10n.roundStatusPulled : l10n.roundStatusCancelled,
          style: AppTypography.meta.copyWith(fontSize: 11, color: kHostLowLight.withValues(alpha: .8)),
        );
    }
  }
}

class _CancelLink extends StatelessWidget {
  const _CancelLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.pillAll,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.minTap, minWidth: AppSizes.minTap),
        child: Center(
          child: Text(
            context.l10n.cancel,
            style: AppTypography.meta.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.inkMeta,
            ),
          ),
        ),
      ),
    );
  }
}
