import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/onboarding/onboarding_chrome.dart';

/// Flow 01 · step 01 — the brand held for a beat on cold launch.
///
/// It asks for nothing and answers nothing; it exists so the first thing the
/// app shows is a drink rather than a form. A tap skips the wait.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

const _heroImage = 'assets/images/onboarding/midnight_orchard.jpg';

class _WelcomeScreenState extends State<WelcomeScreen> {
  static const _hold = Duration(milliseconds: 800);

  /// Ceiling on waiting for the photograph. A slow disk must not strand the
  /// first screen the app ever shows.
  static const _maxDecodeWait = Duration(seconds: 2);

  Timer? _holdTimer;
  Timer? _decodeTimeout;
  bool _prepared = false;
  bool _holding = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prepared) return;
    _prepared = true;

    // The hold is only worth 800ms once there is something to look at: on a
    // cold start the asset has not decoded yet, and counting from mount would
    // spend the whole splash on an empty screen.
    _decodeTimeout = Timer(_maxDecodeWait, _beginHold);
    unawaited(_precacheHero());
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _decodeTimeout?.cancel();
    super.dispose();
  }

  Future<void> _precacheHero() async {
    try {
      await precacheImage(const AssetImage(_heroImage), context);
    } catch (_) {
      // A missing or undecodable asset still leaves a readable wordmark.
    }
    _beginHold();
  }

  void _beginHold() {
    if (_holding || !mounted) return;
    _holding = true;
    _decodeTimeout?.cancel();
    _holdTimer = Timer(_hold, _advance);
  }

  void _advance() {
    _holdTimer?.cancel();
    if (!mounted) return;
    context.go(AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _advance,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            const OnboardingHero(
              image: _heroImage,
              fullBleed: true,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  0,
                  AppSpacing.screenEdge,
                  64,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.signal,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.nightlife,
                        size: 28,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      context.l10n.appTitle,
                      style: AppTypography.display.copyWith(
                        fontSize: 46,
                        letterSpacing: -1.84,
                        height: 0.96,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      context.l10n.splashTagline,
                      style: AppTypography.body.copyWith(
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
