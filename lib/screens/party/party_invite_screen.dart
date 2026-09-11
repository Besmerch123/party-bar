import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/models.dart';
import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/auth/auth_controls.dart';
import '../../widgets/common/glass.dart';
import '../../widgets/party/host_state_pill.dart';

const _backdrop = 'assets/images/onboarding/midnight_orchard.jpg';

/// Flow 05 · screen 09 — pass the phone.
///
/// The first seconds of a live party, and the screen "Invite more people"
/// comes back to: a QR big enough to scan across a kitchen, the code to read
/// out, and the system share sheet.
///
/// The QR carries the bare code. There is no app link yet, so a camera
/// shows the code rather than opening the join screen (Flow 07's seam).
class PartyInviteScreen extends StatelessWidget {
  const PartyInviteScreen({super.key, required this.party});

  final Party party;

  void _toParty(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _copyCode(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final copied = context.l10n.hostCodeCopied;
    await Clipboard.setData(ClipboardData(text: party.joinCode));
    messenger.showSnackBar(SnackBar(content: Text(copied)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(_backdrop, fit: BoxFit.cover),
          ColoredBox(color: AppColors.ground.withValues(alpha: .82)),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenEdge,
                    8,
                    AppSpacing.screenEdge,
                    0,
                  ),
                  child: Row(
                    children: [
                      LiveElapsedPill(since: party.wentLiveAt),
                      const Spacer(),
                      GlassIconButton(
                        icon: Icons.close,
                        size: 34,
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).closeButtonTooltip,
                        onTap: () => _toParty(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: AppSpacing.md,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.hostBarOpenTitle,
                            textAlign: TextAlign.center,
                            style: AppTypography.heading.copyWith(
                              fontSize: 30,
                              letterSpacing: -1.05,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.hostBarOpenBody,
                            textAlign: TextAlign.center,
                            style: AppTypography.body.copyWith(
                              color: AppColors.ink.withValues(alpha: .62),
                            ),
                          ),
                          const SizedBox(height: 26),
                          Semantics(
                            image: true,
                            label: party.joinCode,
                            child: Container(
                              width: 238,
                              height: 238,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: QrImageView(
                                data: party.joinCode,
                                padding: EdgeInsets.zero,
                                backgroundColor: Colors.white,
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: AppColors.ground,
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: AppColors.ground,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Semantics(
                            button: true,
                            label: '${l10n.hostCopyCode} ${party.joinCode}',
                            excludeSemantics: true,
                            child: GlassSurface(
                              borderRadius: BorderRadius.circular(16),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              onTap: () => _copyCode(context),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    party.joinCode,
                                    style: AppTypography.measure.copyWith(
                                      fontSize: 22,
                                      letterSpacing: 2.2,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(
                                    Icons.content_copy,
                                    size: 19,
                                    color: AppColors.ink.withValues(alpha: .6),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenEdge,
                    0,
                    AppSpacing.screenEdge,
                    26,
                  ),
                  child: Column(
                    children: [
                      AuthPillButton(
                        label: l10n.hostShareLink,
                        icon: Icons.ios_share,
                        primary: true,
                        height: AppSizes.buttonPrimary,
                        onPressed: () => Share.share(
                          l10n.hostShareText(party.name, party.joinCode),
                        ),
                      ),
                      const SizedBox(height: 10),
                      AuthPillButton(
                        label: l10n.hostGoToTheParty,
                        height: AppSizes.buttonGhost,
                        background: AppColors.glass,
                        foreground: AppColors.ink,
                        onPressed: () => _toParty(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
