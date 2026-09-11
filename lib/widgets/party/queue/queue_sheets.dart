import 'package:flutter/material.dart';

import '../../../theme/theme.dart';
import '../../../utils/localization_helper.dart';
import '../../auth/auth_controls.dart';
import '../host_sheets.dart';

/// Flow 06 · screen 09 — the small sheet a tap on an in-line row opens: pour
/// it now, out of turn, or skip it.
enum InLineRowChoice { pourNow, skip }

Future<InLineRowChoice?> showInLineRowSheet(BuildContext context) {
  return showHostSheet<InLineRowChoice>(context, (context) {
    final l10n = context.l10n;
    return HostSheet(
      children: [
        AuthPillButton(
          label: l10n.queueRowSheetPourNow,
          icon: Icons.play_arrow,
          primary: true,
          height: AppSizes.buttonGhost,
          onPressed: () => Navigator.of(context).pop(InLineRowChoice.pourNow),
        ),
        const SizedBox(height: 8),
        AuthPillButton(
          label: l10n.queueSkipCantMake,
          height: AppSizes.buttonGhost,
          onPressed: () => Navigator.of(context).pop(InLineRowChoice.skip),
        ),
      ],
    );
  });
}

/// Screen 09 — "Skip · can't make it" and the pouring screen's "Cancel
/// order" both close the door on an order; both ask once, plainly, before
/// doing it.
Future<bool> showSkipConfirmSheet(
  BuildContext context, {
  required String cocktailName,
}) async {
  final go = await showHostSheet<bool>(context, (context) {
    final l10n = context.l10n;
    return HostSheet(
      children: [
        HostSheetTitle(l10n.queueSkipConfirmTitle(cocktailName), size: 22),
        const SizedBox(height: 10),
        HostSheetBody(l10n.queueSkipConfirmBody),
        const SizedBox(height: 16),
        AuthPillButton(
          label: l10n.queueSkipCantMake,
          height: 50,
          background: AppColors.low,
          foreground: AppColors.ground,
          onPressed: () => Navigator.of(context).pop(true),
        ),
        const SizedBox(height: 8),
        AuthPillButton(
          label: l10n.queueSkipConfirmCancel,
          height: 48,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  });
  return go ?? false;
}

/// Screen 10 — "Cancel order" mid-pour, plainer still: pouring has started,
/// so the guest is told rather than just left waiting.
Future<bool> showCancelOrderConfirmSheet(
  BuildContext context, {
  required String cocktailName,
  required String guestName,
}) async {
  final go = await showHostSheet<bool>(context, (context) {
    final l10n = context.l10n;
    return HostSheet(
      children: [
        HostSheetTitle(l10n.queueCancelOrderConfirmTitle(cocktailName), size: 22),
        const SizedBox(height: 10),
        HostSheetBody(l10n.queueCancelOrderConfirmBody(guestName)),
        const SizedBox(height: 16),
        AuthPillButton(
          label: l10n.queueCancelOrder,
          height: 50,
          background: AppColors.low,
          foreground: AppColors.ground,
          onPressed: () => Navigator.of(context).pop(true),
        ),
        const SizedBox(height: 8),
        AuthPillButton(
          label: l10n.queueCancelOrderConfirmKeep,
          height: 48,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  });
  return go ?? false;
}
