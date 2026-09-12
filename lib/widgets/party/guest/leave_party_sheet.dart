import 'package:flutter/material.dart';

import '../../../models/models.dart';
import '../../../theme/theme.dart';
import '../../../utils/localization_helper.dart';
import '../../auth/auth_controls.dart';
import '../host_sheets.dart';

/// Flow 07 · screen 05 — leaving, which is allowed but never encouraged.
///
/// Worth a confirmation only because of what it does *not* do: drinks
/// already sent keep their place in the host's queue. Leaving is this phone
/// looking away, not a cancellation, and the sheet says so before anyone
/// finds out the hard way.
Future<bool?> showLeavePartySheet(
  BuildContext context, {
  required Party party,
}) {
  return showHostSheet<bool>(context, (context) {
    final l10n = context.l10n;

    return HostSheet(
      children: [
        const HostSheetBadge(icon: Icons.logout, low: true),
        const SizedBox(height: 18),
        HostSheetTitle(l10n.joinLeaveTitle(party.name)),
        const SizedBox(height: 10),
        HostSheetBody(l10n.joinLeaveBody),
        const SizedBox(height: 24),
        AuthPillButton(
          label: l10n.joinLeaveConfirm,
          primary: true,
          height: AppSizes.buttonPrimary,
          onPressed: () => Navigator.of(context).pop(true),
        ),
        const SizedBox(height: 10),
        AuthGhostAction(
          label: l10n.joinStay,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  });
}
