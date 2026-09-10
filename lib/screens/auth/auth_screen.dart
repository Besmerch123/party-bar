import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/auth.dart';
import '../../providers/auth_provider.dart';
import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/auth/auth_controls.dart';
import '../../widgets/common/glass.dart';

/// Flow 03 · screen 02 — the cold entry.
///
/// The barrier sheet is the usual way an account gets asked for, because there
/// is normally something waiting behind it. This screen is the other case:
/// the profile tab, or a guarded route opened from a link, where nothing is
/// held and the app has to make the argument on its own. So it argues — a
/// photograph, one sentence about what an account is for — rather than
/// presenting a form.
class AuthScreen extends StatelessWidget {
  const AuthScreen({
    super.key,
    this.redirectPath,
    this.reason = AuthReason.cold,
  });

  /// Where to land once someone is signed in. Null goes back the way it came.
  final String? redirectPath;

  /// What was being attempted, carried through to the name screen so its
  /// commit button can name the thing rather than say "Continue".
  final AuthReason reason;

  static const _hero = 'assets/images/onboarding/midnight_orchard.jpg';

  /// The photo owns the top 62% of the frame, the same band the onboarding
  /// slides use, so the two flows read as one product.
  static const _heroRatio = 0.62;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = context.watch<AuthenticationProvider>();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.sizeOf(context).height * _heroRatio,
            child: const Stack(
              fit: StackFit.expand,
              children: [
                Image(image: AssetImage(_hero), fit: BoxFit.cover),
                PhotoScrim(),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.screenEdge - 5,
                    top: 8,
                  ),
                  child: AuthIconAction(
                    icon: Icons.close,
                    onGlass: true,
                    semanticLabel: l10n.authClose,
                    onTap: () => _leave(context),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenEdge,
                        AppSpacing.md,
                        AppSpacing.screenEdge,
                        30,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - AppSpacing.md - 30,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AuthEyebrow(
                              label: l10n.authProvidersEyebrow,
                              tinted: true,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.authProvidersTitle,
                              style: AppTypography.display.copyWith(
                                fontSize: 38,
                                letterSpacing: -1.33,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 310),
                              child: Text(
                                l10n.authProvidersBody,
                                style: AppTypography.body.copyWith(height: 1.6),
                              ),
                            ),
                            if (auth.failure != null &&
                                !auth.failure!.isSilent) ...[
                              const SizedBox(height: AppSpacing.md),
                              AuthFailureNotice(
                                failure: auth.failure,
                                onRetry: () => _google(context),
                                onUseGoogle: () => _google(context),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                            AuthProviderColumn(
                              onGlass: true,
                              enabled: !auth.isBusy,
                              onGoogle: () => _google(context),
                              onEmail: () => _email(context),
                            ),
                            const SizedBox(height: 18),
                            AuthAssuranceLine(label: l10n.authAgeNote),
                            const SizedBox(height: 10),
                            AuthLegalLine(
                              sentence: l10n.authLegalLine(
                                l10n.authTerms,
                                l10n.authPrivacy,
                              ),
                              termsLabel: l10n.authTerms,
                              privacyLabel: l10n.authPrivacy,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _leave(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.explore);
    }
  }

  Future<void> _google(BuildContext context) async {
    final auth = context.read<AuthenticationProvider>();
    final signedIn = await auth.signInWithGoogle();
    if (!context.mounted || !signedIn) return;

    finishSignIn(context, redirectPath: redirectPath, reason: reason);
  }

  void _email(BuildContext context) {
    context.push(authLanePath(AppRoutes.authEmail, redirectPath, reason));
  }
}

/// Where the whole flow ends.
///
/// Google hands us a name, so it lands straight back on whatever was
/// interrupted. The email lane arrives nameless and owes screen 05 first —
/// that is the only difference between the two lanes.
void finishSignIn(
  BuildContext context, {
  String? redirectPath,
  AuthReason reason = AuthReason.cold,
}) {
  final auth = context.read<AuthenticationProvider>();

  if (auth.needsDisplayName) {
    context.pushReplacement(
      authLanePath(AppRoutes.authName, redirectPath, reason),
    );
    return;
  }

  if (redirectPath != null) {
    context.go(redirectPath);
  } else if (context.canPop()) {
    context.pop();
  } else {
    context.go(AppRoutes.explore);
  }
}

/// Builds a path in the auth lane carrying what the lane needs to know: where
/// the person was going, and what they were doing when they were stopped.
String authLanePath(String path, String? redirectPath, AuthReason reason) {
  final query = <String, String>{
    if (redirectPath != null) 'redirect': redirectPath,
    if (reason != AuthReason.cold) 'reason': reason.name,
  };

  if (query.isEmpty) return path;

  final encoded = query.entries
      .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
      .join('&');

  return '$path?$encoded';
}

/// Reads back what [authLanePath] wrote.
AuthReason authReasonFrom(GoRouterState state) {
  final name = state.uri.queryParameters['reason'];
  return AuthReason.values.where((reason) => reason.name == name).firstOrNull ??
      AuthReason.cold;
}
