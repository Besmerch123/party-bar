import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n/app_localizations.dart';
import '../../models/auth.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/auth_screen.dart';
import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/localization_helper.dart';
import 'auth_controls.dart';

/// Flow 03 · screen 01 — the barrier.
///
/// Not a gate. Browsing, searching, pouring solo, stocking the shelf and
/// ordering at someone else's party all work with nothing signed in; this
/// interrupts only the three things that genuinely need an owner, and it does
/// it in place, over the screen you were already on, so the draft behind is
/// visibly still there.
///
/// Saving a cocktail has its own version of this — `showAuthGateSheet` in
/// widgets/cocktails — which names the drink being kept. This one covers the
/// other two.
/// Returns true when the sheet closed with someone signed in and nothing else
/// standing between them and what they were doing — the caller can simply
/// carry on. False covers both "not now" and the email lane, which navigates
/// onward under its own steam.
Future<bool> showAuthBarrierSheet(
  BuildContext context, {
  required AuthReason reason,
  String? redirectPath,
}) async {
  final signedIn = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    // Scrollable, because a small phone with the text turned up runs out of
    // room before the barrier runs out of argument.
    builder: (_) => SingleChildScrollView(
      child: AuthBarrierSheet(reason: reason, redirectPath: redirectPath),
    ),
  );

  return signedIn ?? false;
}

/// The copy a barrier makes its case with.
///
/// [AuthReason.saveCocktail] and [AuthReason.cold] fall back to the argument
/// screen 02 makes, which is true of every reason — it is just less specific
/// than naming the thing you were doing.
({String title, String body}) _argumentFor(
  AppLocalizations l10n,
  AuthReason reason,
) => switch (reason) {
  AuthReason.hostParty => (
    title: l10n.authBarrierHostTitle,
    body: l10n.authBarrierHostBody,
  ),
  AuthReason.editBar => (
    title: l10n.authBarrierBarTitle,
    body: l10n.authBarrierBarBody,
  ),
  _ => (
    title: l10n.authProvidersTitle.replaceAll('\n', ' '),
    body: l10n.authProvidersBody,
  ),
};

class AuthBarrierSheet extends StatelessWidget {
  const AuthBarrierSheet({
    super.key,
    required this.reason,
    this.redirectPath,

    /// Set when the sheet is painted into a screen that already provides the
    /// bottom inset and the sheet shape — [AuthBarrierScreen] does both.
    this.embedded = false,
  });

  final AuthReason reason;
  final String? redirectPath;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = context.watch<AuthenticationProvider>();
    final argument = _argumentFor(l10n, reason);

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
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
        const SizedBox(height: AppSpacing.md),
        AuthEyebrow(label: l10n.authBarrierEyebrow),
        const SizedBox(height: AppSpacing.sm),
        Text(
          argument.title,
          style: AppTypography.heading.copyWith(height: 1.06),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(argument.body, style: AppTypography.body.copyWith(height: 1.6)),
        if (auth.failure != null && !auth.failure!.isSilent) ...[
          const SizedBox(height: AppSpacing.md),
          AuthFailureNotice(
            failure: auth.failure,
            onRetry: () => _google(context),
            onUseGoogle: () => _google(context),
          ),
        ],
        const SizedBox(height: 22),
        AuthProviderColumn(
          enabled: !auth.isBusy,
          onGoogle: () => _google(context),
          onEmail: () => _email(context),
        ),
        const SizedBox(height: 14),
        AuthGhostAction(
          label: l10n.authNotNow,
          onPressed: () => _dismiss(context),
        ),
        const SizedBox(height: AppSpacing.xs),
        AuthLegalLine(
          sentence: l10n.authLegalLine(l10n.authTerms, l10n.authPrivacy),
          termsLabel: l10n.authTerms,
          privacyLabel: l10n.authPrivacy,
        ),
      ],
    );

    if (embedded) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
        child: body,
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        0,
        AppSpacing.screenEdge,
        MediaQuery.paddingOf(context).bottom + 30,
      ),
      decoration: const BoxDecoration(
        color: AppColors.sheet,
        borderRadius: AppRadius.sheetTop,
        boxShadow: [kSheetShadow],
      ),
      child: body,
    );
  }

  /// The barrier is a modal over live content, so it closes itself before
  /// anything is routed — the context it was built against goes with it.
  void _dismiss(BuildContext context) {
    if (embedded) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.explore);
      }
      return;
    }
    Navigator.of(context).pop(false);
  }

  Future<void> _google(BuildContext context) async {
    final auth = context.read<AuthenticationProvider>();
    final navigator = Navigator.of(context);

    final signedIn = await auth.signInWithGoogle();
    if (!context.mounted || !signedIn) return;

    if (embedded) {
      finishSignIn(context, redirectPath: redirectPath, reason: reason);
      return;
    }

    // A sheet over the interrupted screen has nowhere to go: the screen behind
    // is the destination, and it is already there. The nameless lane is the
    // exception — it owes screen 05 first, and closes reporting nothing so
    // the caller does not also try to continue.
    if (auth.needsDisplayName) {
      final router = GoRouter.of(context);
      navigator.pop(false);
      router.push(authLanePath(AppRoutes.authName, redirectPath, reason));
      return;
    }

    navigator.pop(true);
  }

  void _email(BuildContext context) {
    final path = authLanePath(AppRoutes.authEmail, redirectPath, reason);

    if (embedded) {
      context.push(path);
      return;
    }

    // The router is read before the pop: the sheet's context is defunct the
    // moment it closes.
    final router = GoRouter.of(context);
    Navigator.of(context).pop(false);
    router.push(path);
  }
}
