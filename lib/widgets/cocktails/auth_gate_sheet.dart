import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/bar_provider.dart';
import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/localization_helper.dart';

/// Opens the sheet that marks where browsing ends and an account begins.
///
/// Everything up to this point — browsing, searching, filtering, making a
/// drink solo, stocking the bar — works with nothing signed in. Saving is the
/// first thing that has to leave the device, so this is the first place the
/// app asks for an account, and it asks by naming what the person keeps
/// rather than what they are missing.
Future<void> showAuthGateSheet(BuildContext context, {required String cocktailName}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (_) => AuthGateSheet(cocktailName: cocktailName),
  );
}

class AuthGateSheet extends StatelessWidget {
  const AuthGateSheet({super.key, required this.cocktailName});

  final String cocktailName;

  void _continueToAuth(BuildContext context) {
    // Captured before the pop: once the sheet is gone so is the route state
    // this context resolved against.
    final redirect = GoRouterState.of(context).uri.toString();
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.push('${AppRoutes.auth}?redirect=${Uri.encodeComponent(redirect)}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottleCount = context.read<BarProvider>().bottleCount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
      decoration: const BoxDecoration(
        color: AppColors.sheet,
        borderRadius: AppRadius.sheetTop,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const _DragHandle(),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: _CloseButton(onTap: () => Navigator.of(context).pop()),
          ),
          const SizedBox(height: 6),
          const _BookmarkBadge(),
          const SizedBox(height: 18),
          Text(
            l10n.authGateSaveTitle(cocktailName),
            style: AppTypography.title.copyWith(fontSize: 30, height: 1.05),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.authGateSaveBody,
            style: AppTypography.body.copyWith(fontSize: 13.5, height: 1.6),
          ),
          const SizedBox(height: 20),
          _BenefitList(bottleCount: bottleCount),
          const SizedBox(height: 20),
          _AuthPill(
            background: AppColors.ink,
            foreground: AppColors.ground,
            icon: Icons.phone_iphone,
            label: l10n.authGateApple,
            // Apple sign-in itself is separate work; this only routes to the
            // account screen that will host it.
            onTap: () => _continueToAuth(context),
          ),
          const SizedBox(height: 10),
          _AuthPill(
            background: AppColors.fillStrong,
            foreground: AppColors.ink,
            icon: Icons.mail_outline,
            label: l10n.authGateEmail,
            onTap: () => _continueToAuth(context),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.authGateKeepBrowsing,
                style: const TextStyle(color: AppColors.inkMeta),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom + 28),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 38,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.glassStroke,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).closeButtonTooltip,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Material(
          color: AppColors.fillMuted,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: const Icon(Icons.close, size: 18, color: AppColors.inkBody),
          ),
        ),
      ),
    );
  }
}

class _BookmarkBadge extends StatelessWidget {
  const _BookmarkBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.signalWash,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.bookmark, size: 24, color: AppColors.signalLight),
    );
  }
}

/// Naming what the shelf already holds is the whole argument for signing
/// in — the other two rows promise something new, this one names what
/// would otherwise be lost.
class _BenefitList extends StatelessWidget {
  const _BenefitList({required this.bottleCount});

  final int bottleCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: ColoredBox(
        color: AppColors.fillSubtle,
        child: Column(
          children: [
            _BenefitRow(
              icon: Icons.bookmark,
              iconColor: AppColors.signalLight,
              iconBackground: AppColors.fillMuted,
              label: l10n.authGateLists,
            ),
            const SizedBox(height: 1),
            _BenefitRow(
              icon: Icons.celebration_outlined,
              iconColor: AppColors.signalLight,
              iconBackground: AppColors.fillMuted,
              label: l10n.authGateHost,
            ),
            const SizedBox(height: 1),
            _BenefitRow(
              icon: Icons.local_bar,
              iconColor: AppColors.ready,
              iconBackground: AppColors.readyWash,
              label: l10n.authGateShelf(bottleCount),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.row,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTypography.body.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthPill extends StatelessWidget {
  const _AuthPill({
    required this.background,
    required this.foreground,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Color background;
  final Color foreground;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: Material(
          color: background,
          borderRadius: AppRadius.pillAll,
          child: InkWell(
            borderRadius: AppRadius.pillAll,
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 19, color: foreground),
                const SizedBox(width: 9),
                Flexible(
                  child: Text(
                    label,
                    style: AppTypography.buttonPrimary.copyWith(color: foreground),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
