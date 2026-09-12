import 'package:flutter/material.dart';

import '../../generated/l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../theme/theme.dart';
import '../../utils/localization_helper.dart';
import '../auth/auth_controls.dart';
import 'host_sheets.dart';
import 'recap_bits.dart';

enum EndPartyChoice { end, keepPouring, pauseInstead }

/// Flow 08 · screen 01 — the ending is a question about the queue.
///
/// At 01:22 two drinks are still waiting, so the sheet names whose they are
/// and offers to pour them first; closing anyway is the second choice, not
/// the default. With an empty queue there is nothing to weigh and closing
/// becomes the primary again.
///
/// Nothing here is a summary of the night: the numbers are only enough to
/// answer "is it over?". The recap is a place, and it is read in the
/// morning.
Future<EndPartyChoice?> showEndPartySheet(
  BuildContext context, {
  required Party party,
  required List<CocktailOrder> orders,
}) {
  return showHostSheet<EndPartyChoice>(context, (context) {
    final l10n = context.l10n;
    void choose(EndPartyChoice choice) => Navigator.of(context).pop(choice);

    final waiting = orders.where((o) => o.isOpen).toList(growable: false);
    final poured = orders.where((o) => o.isDelivered).length;
    final guests = guestCountOf(orders);

    final now = DateTime.now();
    var open = now.difference(party.wentLiveAt ?? now);
    if (open.isNegative) open = Duration.zero;
    final openFor =
        '${open.inHours}h${open.inMinutes.remainder(60).toString().padLeft(2, '0')}';

    final queued = waiting.isNotEmpty;

    return HostSheet(
      children: [
        const HostSheetBadge(icon: Icons.flag, low: true),
        const SizedBox(height: 20),
        HostSheetTitle(queued ? l10n.hostCloseTitle : l10n.hostEndTitle, size: 26),
        const SizedBox(height: 12),
        HostSheetBody(
          queued
              ? l10n.hostCloseWaitingBody(
                  waiting.length,
                  waitingNames(l10n, waiting),
                )
              : l10n.hostEndBody,
        ),
        const SizedBox(height: 20),
        RecapStatRow(
          gap: 10,
          stats: [
            RecapStat(
              value: '$poured',
              label: l10n.hostEndPoured.toLowerCase(),
              background: AppColors.row,
              valueSize: 24,
              mono: true,
              accent: true,
            ),
            RecapStat(
              value: '$guests',
              label: l10n.hostEndGuests.toLowerCase(),
              background: AppColors.row,
              valueSize: 24,
              mono: true,
            ),
            RecapStat(
              value: openFor,
              label: l10n.hostEndOpenFor.toLowerCase(),
              background: AppColors.row,
              valueSize: 24,
              mono: true,
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (queued) ...[
          AuthPillButton(
            label: l10n.hostClosePourFirst(waiting.length),
            icon: Icons.local_bar,
            primary: true,
            height: AppSizes.buttonPrimary,
            onPressed: () => choose(EndPartyChoice.keepPouring),
          ),
          const SizedBox(height: 11),
          AuthPillButton(
            label: l10n.hostCloseAnyway(waiting.length),
            height: AppSizes.buttonGhost,
            onPressed: () => choose(EndPartyChoice.end),
          ),
        ] else ...[
          AuthPillButton(
            label: l10n.hostEndConfirm,
            icon: Icons.flag,
            height: AppSizes.buttonPrimary,
            background: AppColors.lowWash,
            foreground: kHostLowLight,
            onPressed: () => choose(EndPartyChoice.end),
          ),
          const SizedBox(height: 11),
          AuthPillButton(
            label: l10n.hostKeepPouring,
            icon: Icons.local_bar,
            height: AppSizes.buttonGhost,
            onPressed: () => choose(EndPartyChoice.keepPouring),
          ),
        ],
        const SizedBox(height: 6),
        // A Wrap, not a Row: "Just need a break? Pause the bar instead" is
        // two sentences' worth of words on one line, and it has to survive a
        // long translation and a large text scale without clipping.
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
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
        const SizedBox(height: 10),
        Text(
          l10n.hostCloseFootnote,
          textAlign: TextAlign.center,
          style: AppTypography.meta.copyWith(
            fontSize: 11.5,
            height: 1.5,
            color: AppColors.ink.withValues(alpha: .35),
          ),
        ),
      ],
    );
  });
}

/// "Sam and Olha" — whose drinks closing would cancel, oldest first and each
/// person named once. A long queue stops listing and counts the rest, since
/// a sentence with nine names in it is not a sentence anyone reads.
String waitingNames(AppLocalizations l10n, List<CocktailOrder> waiting) {
  final names = <String>[];
  for (final order in oldestFirst(waiting)) {
    final name = order.guestName.trim();
    if (name.isEmpty || names.contains(name)) continue;
    names.add(name);
  }

  if (names.isEmpty) return '';
  if (names.length == 1) return names.first;
  if (names.length == 2) return l10n.hostNamesPair(names.first, names[1]);
  return l10n.hostNamesMore(names.take(2).join(', '), names.length - 2);
}
