import 'package:flutter/material.dart';

import '../../../data/order_repository.dart';
import '../../../models/models.dart';
import '../../../providers/party_cocktails.dart';
import '../../../providers/round_draft.dart';
import '../../../theme/theme.dart';
import '../../../utils/localization_helper.dart';
import '../../auth/auth_controls.dart';
import '../host_sheets.dart';
import '../order_bits.dart';
import 'round_bits.dart';

/// Flow 06 · screen 02 — the round in hand, one row per drink, sent in one
/// tap. Reopened from the shell's floating "Your round · N" pill.
///
/// Returns the sent orders' ids once the round was sent, so the caller can
/// push screen 03 pinned to exactly them; null otherwise. Reads [draft] by
/// direct reference rather than through a `Provider` — `showModalBottomSheet`
/// mounts its content on the app's root navigator, which sits outside the
/// guest shell's own provider scope.
///
/// Flow 07 · screen 03 — [guestName] is null for a guest who has not ordered
/// yet. The send then goes through [resolveName] first, so the name is asked
/// on the tap that sends rather than on the way in, and that one tap still
/// finishes the job.
Future<List<String>?> showYourRoundSheet(
  BuildContext context, {
  required Party party,
  required RoundDraft draft,
  required PartyCocktails cocktails,
  required int aheadOfNewOrder,
  required String guestId,
  required String? guestName,
  required Future<String?> Function({int? drinks}) resolveName,
  required bool paused,
}) {
  return showHostSheet<List<String>>(
    context,
    (context) => _YourRoundSheet(
      party: party,
      draft: draft,
      cocktails: cocktails,
      aheadOfNewOrder: aheadOfNewOrder,
      guestId: guestId,
      guestName: guestName,
      resolveName: resolveName,
      paused: paused,
    ),
  );
}

class _YourRoundSheet extends StatefulWidget {
  const _YourRoundSheet({
    required this.party,
    required this.draft,
    required this.cocktails,
    required this.aheadOfNewOrder,
    required this.guestId,
    required this.guestName,
    required this.resolveName,
    required this.paused,
  });

  final Party party;
  final RoundDraft draft;
  final PartyCocktails cocktails;
  final int aheadOfNewOrder;
  final String guestId;
  final String? guestName;
  final Future<String?> Function({int? drinks}) resolveName;
  final bool paused;

  @override
  State<_YourRoundSheet> createState() => _YourRoundSheetState();
}

class _YourRoundSheetState extends State<_YourRoundSheet> {
  bool _sending = false;

  Future<void> _send() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Screen 03. A guest with no name yet is asked for one here, and backing
    // out of that leaves the round exactly as it was.
    final name =
        widget.guestName ??
        await widget.resolveName(drinks: widget.draft.length);
    if (name == null || !mounted) return;

    setState(() => _sending = true);
    try {
      final ids = await OrderRepository().sendRound(
        partyId: widget.party.id,
        guestName: name,
        guestId: widget.guestId,
        items: widget.draft.items,
      );
      widget.draft.clear();
      navigator.pop(ids);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.roundSendFailed)));
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListenableBuilder(
      listenable: widget.draft,
      builder: (context, _) {
        final items = widget.draft.items;
        final host = hostFirstName(widget.party.hostName);
        final a = widget.aheadOfNewOrder + 1;
        final b = widget.aheadOfNewOrder + items.length;

        return HostSheet(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HostSheetTitle(l10n.roundYourRoundTitle),
                      const SizedBox(height: 8),
                      Text(l10n.roundPoursOneAtATime(host), style: AppTypography.body.copyWith(fontSize: 12.5)),
                    ],
                  ),
                ),
                Text(
                  l10n.roundDrinksCount(items.length).toUpperCase(),
                  style: AppTypography.measure.copyWith(fontSize: 12, color: AppColors.inkMeta),
                ),
              ],
            ),
            const SizedBox(height: 18),
            for (final (i, item) in items.indexed) ...[
              if (i > 0) const SizedBox(height: 10),
              _DraftRow(
                item: item,
                cocktail: widget.cocktails.byId(item.cocktailId),
                onRemove: () => widget.draft.removeAt(i),
              ),
            ],
            if (items.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.fillSubtle, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.group, size: 18, color: AppColors.ink.withValues(alpha: .4)),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        items.length == 1
                            ? l10n.roundAheadSendingSingle(widget.aheadOfNewOrder, a)
                            : l10n.roundAheadSendingRange(widget.aheadOfNewOrder, a, b),
                        style: AppTypography.meta.copyWith(fontSize: 12, height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (widget.paused) ...[
                Text(
                  l10n.roundSendingPaused,
                  textAlign: TextAlign.center,
                  style: AppTypography.meta.copyWith(fontSize: 12, color: AppColors.low),
                ),
                const SizedBox(height: 10),
              ],
              AuthPillButton(
                label: l10n.roundSendTo(host),
                icon: Icons.send,
                primary: true,
                height: AppSizes.buttonPrimary,
                onPressed: widget.paused || _sending ? null : _send,
              ),
              const SizedBox(height: 12),
              AuthGhostAction(
                label: l10n.roundAddOneMore,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ] else
              AuthGhostAction(
                label: l10n.roundAddOneMore,
                onPressed: () => Navigator.of(context).pop(),
              ),
          ],
        );
      },
    );
  }
}

class _DraftRow extends StatelessWidget {
  const _DraftRow({required this.item, required this.cocktail, required this.onRemove});

  final RoundItem item;
  final Cocktail? cocktail;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: AppColors.row, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          OrderThumb(image: cocktail?.image, size: 54, radius: 14),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  cocktail?.title.translate(context) ?? item.cocktailId,
                  style: AppTypography.cardTitle.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 7),
                Text(forLabel(context, forName: item.forName), style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                if (item.note case final note?) ...[
                  const SizedBox(height: 8),
                  OrderNoteChip(note: note, small: true),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.close, size: 19, color: AppColors.inkGhost),
          ),
        ],
      ),
    );
  }
}
