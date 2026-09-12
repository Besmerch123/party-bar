import 'package:flutter/material.dart';

import '../../../theme/theme.dart';
import '../../../utils/localization_helper.dart';

/// Flow 07 · screen 07 — the host's panic button, seen from the floor.
///
/// A pause is not an outage, and the guest's side has to say so twice: the
/// notice explains that nothing was lost, and the footer replaces the round
/// pill so the reason ordering does nothing is where the ordering used to be.
class PausedNotice extends StatelessWidget {
  const PausedNotice({
    super.key,
    required this.hostName,
    this.stillInLine,
  });

  final String hostName;

  /// "Midnight Orchard · still #2 in line" — the whole point of the notice
  /// is that the queue survived the pause, so it shows the queue.
  final String? stillInLine;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenEdge,
          8,
          AppSpacing.screenEdge,
          0,
        ),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            // This lands on whichever tab the guest is on, and half of them
            // hold a full-bleed photo. A tinted wash would let the picture
            // through the sentence, so the tint is blended onto a solid
            // surface instead of laid over one.
            color: Color.alphaBlend(AppColors.lowWash, AppColors.sheet),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.pause_circle,
                    size: 19,
                    color: AppColors.low,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.joinPausedTitle(hostName),
                          style: AppTypography.cardTitle.copyWith(
                            fontSize: 12.5,
                            height: 1.45,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          l10n.joinPausedBody,
                          style: AppTypography.body.copyWith(
                            fontSize: 12,
                            height: 1.45,
                            color: AppColors.inkBody,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (stillInLine case final line?) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.ground.withValues(alpha: .4),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_bar,
                        size: 16,
                        color: AppColors.inkMeta,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          line,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.meta.copyWith(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink.withValues(alpha: .8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Sits where the "Your round · N" pill sits when the bar is open, so the
/// answer to "why did nothing happen" is under the thumb that just tried.
class PausedFooter extends StatelessWidget {
  const PausedFooter({super.key, required this.hostName});

  final String hostName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.sheet,
          borderRadius: AppRadius.cardAll,
          border: Border.all(color: AppColors.hairline),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock,
                  size: 15,
                  color: AppColors.ink.withValues(alpha: .5),
                ),
                const SizedBox(width: 8),
                // A long translation at a bumped text scale must wrap, not
                // push the lock off the edge of a small phone.
                Flexible(
                  child: Text(
                    l10n.joinPausedLocked,
                    style: AppTypography.cardTitle.copyWith(
                      fontSize: 12.5,
                      color: AppColors.ink.withValues(alpha: .75),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              l10n.joinPausedNudge(hostName),
              textAlign: TextAlign.center,
              style: AppTypography.meta.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
