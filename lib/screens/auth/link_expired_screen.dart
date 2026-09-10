import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/auth/auth_controls.dart';

/// Screen 07 — the common failure: a link opened after its 15 minutes, or a
/// second time.
///
/// Nothing here treats it as a mistake. The account is fine, the draft is
/// fine; only the link needs replacing.
class LinkExpiredScreen extends StatelessWidget {
  const LinkExpiredScreen({super.key});

  String _appendForwardedParams(BuildContext context, String path) {
    final params = GoRouterState.of(context).uri.queryParameters;
    final forwarded = <String, String>{
      if (params['redirect'] case final redirect?) 'redirect': redirect,
      if (params['reason'] case final reason?) 'reason': reason,
    };
    if (forwarded.isEmpty) return path;
    return '$path?${Uri(queryParameters: forwarded).query}';
  }

  Future<void> _sendNewLink(BuildContext context) async {
    final auth = context.read<AuthenticationProvider>();
    final ok = await auth.resendSignInLink();
    if (!context.mounted || !ok) return;
    context.pushReplacement(
      _appendForwardedParams(context, AppRoutes.authEmailSent),
    );
  }

  void _useDifferentAddress(BuildContext context) {
    context.read<AuthenticationProvider>().forgetPendingEmail();
    context.push(_appendForwardedParams(context, AppRoutes.authEmail));
  }

  void _keepGoing(BuildContext context) {
    final redirect = GoRouterState.of(context).uri.queryParameters['redirect'];
    context.go(redirect ?? AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = context.watch<AuthenticationProvider>();

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  8,
                  AppSpacing.screenEdge,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AuthIconAction(
                      icon: Icons.arrow_back,
                      onTap: () => context.pop(),
                      onGlass: false,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const _RoundedBadge(
                      icon: Icons.schedule,
                      background: AppColors.lowWash,
                      foreground: AppColors.low,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.authExpiredTitle,
                      style: AppTypography.title.copyWith(
                        fontSize: 32,
                        height: 1.02,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(l10n.authExpiredBody, style: AppTypography.body),
                    const SizedBox(height: AppSpacing.md),
                    AuthPillButton(
                      label: l10n.authSendNewLink,
                      icon: Icons.refresh,
                      primary: true,
                      onPressed: auth.isBusy
                          ? null
                          : () => _sendNewLink(context),
                    ),
                    const SizedBox(height: 10),
                    AuthPillButton(
                      label: l10n.authDifferentAddress,
                      background: AppColors.fillStrong,
                      onPressed: () => _useDifferentAddress(context),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.cardInset),
                      decoration: const BoxDecoration(
                        color: AppColors.sheet,
                        borderRadius: AppRadius.cardAll,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.authDraftSafeTitle,
                            style: AppTypography.cardTitle,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.authDraftSafeBody,
                            style: AppTypography.meta,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                0,
                AppSpacing.screenEdge,
                30,
              ),
              child: AuthGhostAction(
                label: l10n.authKeepGoing,
                onPressed: () => _keepGoing(context),
                tone: AppColors.signalLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundedBadge extends StatelessWidget {
  const _RoundedBadge({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, size: 27, color: foreground),
    );
  }
}
