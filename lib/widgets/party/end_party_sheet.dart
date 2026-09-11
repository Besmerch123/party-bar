import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme/theme.dart';
import '../../utils/localization_helper.dart';
import '../auth/auth_controls.dart';
import 'host_sheets.dart';

enum EndPartyChoice { end, keepPouring, pauseInstead }

/// Flow 05 · screen 13 — the only one-way door.
///
/// Says what ending destroys (the code, the queue, anything still waiting),
/// shows the night in three numbers, and offers the reversible way out —
/// pause — right under the irreversible one.
Future<EndPartyChoice?> showEndPartySheet(
  BuildContext context, {
  required Party party,
  required List<CocktailOrder> orders,
}) {
  return showHostSheet<EndPartyChoice>(context, (context) {
    final l10n = context.l10n;
    void choose(EndPartyChoice choice) => Navigator.of(context).pop(choice);

    final waiting = orders
        .where(
          (o) =>
              o.status == OrderStatus.pending ||
              o.status == OrderStatus.preparing ||
              o.status == OrderStatus.ready,
        )
        .length;
    final poured = orders
        .where((o) => o.status == OrderStatus.delivered)
        .length;
    final guests = orders.map((o) => o.guestName).toSet().length;

    final now = DateTime.now();
    var open = now.difference(party.wentLiveAt ?? now);
    if (open.isNegative) open = Duration.zero;
    final openFor =
        '${open.inHours}h${open.inMinutes.remainder(60).toString().padLeft(2, '0')}';

    return HostSheet(
      children: [
        const HostSheetBadge(icon: Icons.flag, low: true),
        const SizedBox(height: 20),
        HostSheetTitle(l10n.hostEndTitle),
        const SizedBox(height: 12),
        HostSheetBody(l10n.hostEndBody),
        const SizedBox(height: 18),
        if (waiting > 0) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.low.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.hourglass_top, size: 19, color: AppColors.low),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.hostEndWaiting(waiting),
                        style: AppTypography.cardTitle.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: kHostLowLight,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        l10n.hostEndWaitingDetail(waiting),
                        style: AppTypography.meta.copyWith(
                          fontSize: 11.5,
                          height: 1.3,
                          color: AppColors.ink.withValues(alpha: .55),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        Row(
          children: [
            _Stat(label: l10n.hostEndPoured, value: '$poured'),
            const SizedBox(width: 8),
            _Stat(label: l10n.hostEndGuests, value: '$guests'),
            const SizedBox(width: 8),
            _Stat(label: l10n.hostEndOpenFor, value: openFor, mono: true),
          ],
        ),
        const SizedBox(height: 18),
        AuthPillButton(
          label: l10n.hostEndConfirm,
          icon: Icons.flag,
          height: AppSizes.buttonPrimary,
          background: AppColors.lowWash,
          foreground: kHostLowLight,
          onPressed: () => choose(EndPartyChoice.end),
        ),
        const SizedBox(height: 10),
        AuthPillButton(
          label: l10n.hostKeepPouring,
          icon: Icons.local_bar,
          height: AppSizes.buttonGhost,
          onPressed: () => choose(EndPartyChoice.keepPouring),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.hostJustNeedBreak,
              style: AppTypography.meta.copyWith(
                fontSize: 12,
                color: AppColors.ink.withValues(alpha: .4),
              ),
            ),
            TextButton(
              onPressed: () => choose(EndPartyChoice.pauseInstead),
              style: TextButton.styleFrom(
                minimumSize: const Size(0, AppSizes.minTap),
                padding: const EdgeInsets.symmetric(horizontal: 6),
              ),
              child: Text(
                l10n.hostPauseInstead,
                style: AppTypography.meta.copyWith(
                  fontSize: 12,
                  color: AppColors.signalLight,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  });
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.mono = false});

  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final valueStyle = mono
        ? AppTypography.measure.copyWith(fontSize: 19, color: AppColors.ink)
        : AppTypography.section.copyWith(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.38,
            color: AppColors.ink,
          );

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.row,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label.copyWith(
                fontSize: 9.5,
                color: AppColors.ink.withValues(alpha: .4),
              ),
            ),
            const SizedBox(height: 7),
            Text(value, style: valueStyle),
          ],
        ),
      ),
    );
  }
}
