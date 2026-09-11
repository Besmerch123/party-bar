import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme/theme.dart';
import '../../utils/localization_helper.dart';
import '../auth/auth_controls.dart';
import 'host_sheets.dart';
import 'host_state_pill.dart';

enum ManagePartyAction { pause, reopen, editMenu, invite, end }

/// Flow 05 · screen 11 — one sheet, everything reversible.
///
/// Pause leads, because it is the panic button. The co-host row is a seam:
/// shown, marked SOON, never tappable.
Future<ManagePartyAction?> showManagePartySheet(
  BuildContext context, {
  required Party party,
  required int guests,
  required int waiting,

  /// While the bar is paused, the lead button reopens it instead.
  bool paused = false,
}) {
  return showHostSheet<ManagePartyAction>(context, (context) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final elapsed = now.difference(party.wentLiveAt ?? now);
    void choose(ManagePartyAction action) => Navigator.of(context).pop(action);

    return HostSheet(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HostSheetTitle(l10n.hostManage, size: 22),
                  const SizedBox(height: 8),
                  Text(
                    l10n.hostManageSub(
                      LiveElapsedPill.format(
                        elapsed.isNegative ? Duration.zero : elapsed,
                      ),
                      guests,
                      waiting,
                    ),
                    style: AppTypography.meta.copyWith(
                      color: AppColors.ink.withValues(alpha: .5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _LiveChip(label: l10n.hostLiveChip),
          ],
        ),
        const SizedBox(height: 20),
        if (paused)
          AuthPillButton(
            label: l10n.hostReopenBar,
            icon: Icons.play_arrow,
            primary: true,
            height: AppSizes.buttonPrimary,
            onPressed: () => choose(ManagePartyAction.reopen),
          )
        else ...[
          AuthPillButton(
            label: l10n.hostPauseBar,
            icon: Icons.pause,
            height: AppSizes.buttonPrimary,
            background: AppColors.lowWash,
            foreground: kHostLowLight,
            onPressed: () => choose(ManagePartyAction.pause),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.hostPauseCaption,
            textAlign: TextAlign.center,
            style: AppTypography.meta.copyWith(
              fontSize: 11.5,
              color: AppColors.ink.withValues(alpha: .42),
            ),
          ),
        ],
        const SizedBox(height: 18),
        HostRowGroup(
          children: [
            _ManageRow(
              icon: Icons.local_bar,
              label: l10n.hostEditTonightsMenu,
              value: l10n.hostDraftDrinks(party.availableCocktailIds.length),
              onTap: () => choose(ManagePartyAction.editMenu),
            ),
            _ManageRow(
              icon: Icons.qr_code_2,
              label: l10n.hostInviteMore,
              value: party.joinCode,
              monoValue: true,
              onTap: () => choose(ManagePartyAction.invite),
            ),
            _ManageRow(
              icon: Icons.group,
              label: l10n.hostWhosHere,
              value: '$guests',
            ),
            _ManageRow(
              icon: Icons.person_add,
              label: l10n.hostAddCoHost,
              tag: l10n.hostSoon,
              dim: true,
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Apart from the reversible rows, and quieter than Pause.
        Material(
          color: AppColors.fillSubtle,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => choose(ManagePartyAction.end),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
              child: Row(
                children: [
                  const Icon(Icons.flag, size: 19, color: AppColors.low),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.hostEndParty,
                      style: AppTypography.cardTitle.copyWith(
                        color: kHostLowLight,
                      ),
                    ),
                  ),
                  Text(
                    l10n.hostEndPartyHint,
                    style: AppTypography.meta.copyWith(
                      fontSize: 11.5,
                      color: AppColors.ink.withValues(alpha: .4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  });
}

class _LiveChip extends StatelessWidget {
  const _LiveChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
      decoration: const BoxDecoration(
        color: AppColors.signalWash,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.signal,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label.toUpperCase(),
            style: AppTypography.label.copyWith(color: AppColors.signalLight),
          ),
        ],
      ),
    );
  }
}

class _ManageRow extends StatelessWidget {
  const _ManageRow({
    required this.icon,
    required this.label,
    this.value,
    this.monoValue = false,
    this.tag,
    this.dim = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final bool monoValue;
  final String? tag;
  final bool dim;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final valueStyle = monoValue
        ? AppTypography.measure.copyWith(
            fontSize: 12,
            color: AppColors.ink.withValues(alpha: .45),
          )
        : AppTypography.meta.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.ink.withValues(alpha: .45),
          );

    return Material(
      color: AppColors.row,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          child: Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: dim
                    ? AppColors.ink.withValues(alpha: .3)
                    : AppColors.signalLight,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.cardTitle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: dim
                        ? AppColors.ink.withValues(alpha: .45)
                        : AppColors.ink,
                  ),
                ),
              ),
              if (value != null) Text(value!, style: valueStyle),
              if (tag != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.signalWash,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    tag!.toUpperCase(),
                    style: AppTypography.label.copyWith(
                      fontSize: 9.5,
                      color: AppColors.signalLight,
                    ),
                  ),
                ),
              if (onTap != null) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.ink.withValues(alpha: .3),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
