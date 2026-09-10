import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/theme.dart';
import '../../utils/localization_helper.dart';
import '../common/glass.dart';

/// Screen 06 is not a screen: it is the screen a barrier interrupted, shown
/// again with two pieces of evidence that the interruption cost nothing —
/// this file's two widgets. The barrier promises identity and a draft both
/// survive signing in; these are the app keeping that promise.

/// The glass pill confirming a sign-in just completed.
///
/// It appears once, over whatever photography the screen behind it is
/// showing, and then gets out of the way on its own: [AuthenticationProvider]
/// only knows "just signed in" as a fact until [AuthenticationProvider.
/// acknowledgeSignIn] clears it, so this widget owns the timing — stay up
/// long enough to be read, fade rather than vanish, then tell the provider
/// it has done its job.
class SignedInChip extends StatefulWidget {
  const SignedInChip({super.key});

  @override
  State<SignedInChip> createState() => _SignedInChipState();
}

class _SignedInChipState extends State<SignedInChip> {
  static const _visibleFor = Duration(seconds: 4);
  static const _fadeOut = Duration(milliseconds: 320);

  Timer? _timer;
  bool _armed = false;
  bool _fadingOut = false;
  bool _collapsed = false;

  /// Starts the one-shot countdown the first time this chip actually has
  /// something to show. Guarded so a rebuild mid-countdown never restarts it.
  void _arm() {
    if (_armed) return;
    _armed = true;
    _timer = Timer(_visibleFor, () {
      if (!mounted) return;
      setState(() => _fadingOut = true);
      // Deferred a frame so the fade this setState just kicked off actually
      // renders before the provider notifies its other listeners — otherwise
      // the chip risks disappearing between two frames instead of dissolving.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<AuthenticationProvider>().acknowledgeSignIn();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_collapsed) return const SizedBox.shrink();

    final auth = context.watch<AuthenticationProvider>();
    final name = auth.displayName;

    // Once armed, a rebuild that clears justSignedIn (the acknowledgement
    // this very chip triggers) must not cut the fade short.
    final hasSomethingToShow = _armed || (auth.justSignedIn && name.isNotEmpty);
    if (!hasSomethingToShow) return const SizedBox.shrink();

    _arm();
    final l10n = context.l10n;

    return IgnorePointer(
      ignoring: _fadingOut,
      child: AnimatedOpacity(
        opacity: _fadingOut ? 0 : 1,
        duration: _fadeOut,
        onEnd: () {
          if (_fadingOut && mounted) setState(() => _collapsed = true);
        },
        child: GlassSurface(
          padding: const EdgeInsets.fromLTRB(8, 0, 12, 0),
          child: SizedBox(
            height: 34,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.ready,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 13,
                    color: AppColors.ground,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.authSignedInAs(name),
                  style: AppTypography.label.copyWith(fontSize: 11.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The row confirming a draft survived the trip through sign-in.
///
/// This widget makes no judgment about whether a draft exists — the screen
/// that actually held one onto local state decides whether to show it. All
/// this owns is the one honest sentence for when it does.
class DraftRestoredRow extends StatelessWidget {
  const DraftRestoredRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
                color: AppColors.readyWash,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.save, size: 17, color: AppColors.ready),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.authDraftKept,
                style: AppTypography.body.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ),
            Text(
              l10n.authDraftRestored.toUpperCase(),
              style: AppTypography.label.copyWith(
                fontSize: 11.5,
                color: AppColors.ready,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
