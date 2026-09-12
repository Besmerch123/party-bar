import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme/theme.dart';
import '../../utils/localization_helper.dart';
import '../auth/auth_controls.dart';
import '../common/app_sheet.dart';

/// The pale amber a warning title is set in.
const kHostLowLight = Color(0xFFF5C97A);

/// Opens a Flow 05 sheet: transparent route, the sheet draws its own top.
Future<T?> showHostSheet<T>(BuildContext context, WidgetBuilder builder) =>
    showAppSheet<T>(context, builder);

/// The sheet every Flow 05 decision rises in — go live, manage, end.
class HostSheet extends StatelessWidget {
  const HostSheet({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.sheet,
        borderRadius: AppRadius.sheetTop,
        boxShadow: [kSheetShadow],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenEdge,
          12,
          AppSpacing.screenEdge,
          30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.ink.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// The 52px icon tile that opens a decision sheet.
class HostSheetBadge extends StatelessWidget {
  const HostSheetBadge({super.key, required this.icon, this.low = false});

  final IconData icon;
  final bool low;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: low ? AppColors.lowWash : AppColors.signalWash,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          size: 27,
          color: low ? AppColors.low : AppColors.signalLight,
        ),
      ),
    );
  }
}

class HostSheetTitle extends StatelessWidget {
  const HostSheetTitle(this.text, {super.key, this.size = 28});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.heading.copyWith(
        fontSize: size,
        height: 1.06,
        letterSpacing: -size * .035,
      ),
    );
  }
}

class HostSheetBody extends StatelessWidget {
  const HostSheetBody(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTypography.body.copyWith(height: 1.6));
  }
}

/// A row saying what an action changes: a tinted icon, a line, a detail.
class HostConsequenceRow extends StatelessWidget {
  const HostConsequenceRow({
    super.key,
    required this.icon,
    required this.title,
    required this.detail,
    this.ready = false,
  });

  final IconData icon;
  final String title;
  final String detail;

  /// Green for the reassurance; signal otherwise.
  final bool ready;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.row,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: ready ? AppColors.readyWash : AppColors.signalWash,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                icon,
                size: 17,
                color: ready ? AppColors.ready : AppColors.signalLight,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.cardTitle.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    detail,
                    style: AppTypography.meta.copyWith(
                      fontSize: 11.5,
                      height: 1.3,
                      color: AppColors.inkMeta,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rows 1px apart inside one rounded outline.
class HostRowGroup extends StatelessWidget {
  const HostRowGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          for (final (i, child) in children.indexed) ...[
            if (i > 0) const SizedBox(height: 1),
            child,
          ],
        ],
      ),
    );
  }
}

// ------------------------------------------------------------ 08 · go live

/// Flow 05 · screen 08 — the only commitment in the flow. True means go.
Future<bool> showGoLiveSheet(BuildContext context, Party party) async {
  final go = await showHostSheet<bool>(context, (context) {
    final l10n = context.l10n;
    return HostSheet(
      children: [
        const HostSheetBadge(icon: Icons.bolt),
        const SizedBox(height: 20),
        HostSheetTitle(l10n.hostGoLiveTitle),
        const SizedBox(height: 12),
        HostSheetBody(l10n.hostGoLiveBody),
        const SizedBox(height: 18),
        HostRowGroup(
          children: [
            HostConsequenceRow(
              icon: Icons.key,
              title: l10n.hostGoLiveCodeWorks(party.joinCode),
              detail: l10n.hostGoLiveCodeWorksSub,
            ),
            HostConsequenceRow(
              icon: Icons.notifications_active,
              title: l10n.hostGoLiveOrders,
              detail: l10n.hostGoLiveOrdersSub,
            ),
            HostConsequenceRow(
              icon: Icons.undo,
              title: l10n.hostGoLiveUndo,
              detail: l10n.hostGoLiveUndoSub,
              ready: true,
            ),
          ],
        ),
        const SizedBox(height: 18),
        AuthPillButton(
          label: l10n.hostGoLive,
          icon: Icons.bolt,
          height: AppSizes.buttonPrimary,
          background: AppColors.signal,
          foreground: AppColors.ink,
          onPressed: () => Navigator.of(context).pop(true),
        ),
        const SizedBox(height: 10),
        AuthPillButton(
          label: l10n.hostNotYet,
          height: AppSizes.buttonGhost,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 15,
              color: AppColors.ink.withValues(alpha: .4),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.hostOneLiveParty,
              style: AppTypography.meta.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.inkMeta,
              ),
            ),
          ],
        ),
      ],
    );
  });
  return go ?? false;
}

// ------------------------------------------------------------ edge states

enum SecondPartyChoice { goThere, endAndStart }

/// Hosting a second party while one is live: go there, or end it first —
/// never a silent switch.
Future<SecondPartyChoice?> showSecondPartySheet(
  BuildContext context,
  Party live,
) {
  return showHostSheet<SecondPartyChoice>(context, (context) {
    final l10n = context.l10n;
    return HostSheet(
      children: [
        HostSheetTitle(l10n.hostSecondLiveTitle(live.name), size: 22),
        const SizedBox(height: 10),
        HostSheetBody(l10n.hostSecondLiveBody),
        const SizedBox(height: 16),
        AuthPillButton(
          label: l10n.hostGoToParty(live.name),
          primary: true,
          height: 50,
          onPressed: () =>
              Navigator.of(context).pop(SecondPartyChoice.goThere),
        ),
        const SizedBox(height: 8),
        AuthPillButton(
          label: l10n.hostEndAndStartFresh,
          height: 48,
          onPressed: () =>
              Navigator.of(context).pop(SecondPartyChoice.endAndStart),
        ),
      ],
    );
  });
}

enum EmptyMenuChoice { openAnyway, addFirst }

/// Going live with nothing on the menu is allowed — it becomes a request
/// bar — but it is asked, not assumed.
Future<EmptyMenuChoice?> showEmptyMenuSheet(BuildContext context) {
  return showHostSheet<EmptyMenuChoice>(context, (context) {
    final l10n = context.l10n;
    return HostSheet(
      children: [
        HostSheetTitle(l10n.hostEmptyMenuTitle, size: 22),
        const SizedBox(height: 10),
        HostSheetBody(l10n.hostEmptyMenuBody),
        const SizedBox(height: 16),
        AuthPillButton(
          label: l10n.hostOpenAsRequestBar,
          height: 50,
          background: AppColors.signal,
          foreground: AppColors.ink,
          onPressed: () =>
              Navigator.of(context).pop(EmptyMenuChoice.openAnyway),
        ),
        const SizedBox(height: 8),
        AuthPillButton(
          label: l10n.hostAddACoupleFirst,
          height: 48,
          onPressed: () => Navigator.of(context).pop(EmptyMenuChoice.addFirst),
        ),
      ],
    );
  });
}
