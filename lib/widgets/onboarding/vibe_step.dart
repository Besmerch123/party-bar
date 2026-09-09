import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n/app_localizations.dart';
import '../../models/onboarding.dart';
import '../../providers/onboarding_provider.dart';
import '../../theme/theme.dart';
import '../../utils/localization_helper.dart';
import 'onboarding_chrome.dart';
import 'onboarding_step.dart';
import 'vibe_tile.dart';

/// Flow 01 · step 04 — a flavour direction to sort the first feed by.
///
/// Optional on purpose: picking nothing is a valid answer, so the step never
/// blocks, and the copy says outright that nothing gets hidden.
class VibeStep extends StatelessWidget {
  const VibeStep({super.key, required this.nav});

  final OnboardingStepNav nav;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onboarding = context.watch<OnboardingProvider>();
    final selectedCount = onboarding.vibes.length;

    return SafeArea(
      child: Column(
        children: [
          OnboardingTopBar(
            actionLabel: l10n.skip,
            onAction: nav.onSkip,
            onBack: nav.onBack,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenEdge,
              24,
              AppSpacing.screenEdge,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.onboardingVibeTitle,
                  style: AppTypography.title.copyWith(
                    fontSize: 32,
                    letterSpacing: -1.12,
                    height: 1.02,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.onboardingVibeBody,
                  style: AppTypography.body.copyWith(height: 1.6),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                22,
                AppSpacing.screenEdge,
                AppSpacing.sm,
              ),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 168 / 112,
              children: [
                for (final vibe in DrinkVibe.values)
                  VibeTile(
                    vibe: vibe,
                    label: vibeLabel(l10n, vibe),
                    selected: onboarding.isVibeSelected(vibe),
                    onTap: () => onboarding.toggleVibe(vibe),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenEdge,
              AppSpacing.md,
              AppSpacing.screenEdge,
              30,
            ),
            child: Row(
              children: [
                OnboardingDots(
                  count: nav.stepCount,
                  activeIndex: nav.stepIndex,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: OnboardingNextButton(
                    label: l10n.continueLabel,
                    onPressed: nav.onNext,
                    badgeCount: selectedCount > 0 ? selectedCount : null,
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

String vibeLabel(AppLocalizations l10n, DrinkVibe vibe) => switch (vibe) {
  DrinkVibe.sharpCitrus => l10n.vibeSharpCitrus,
  DrinkVibe.darkStirred => l10n.vibeDarkStirred,
  DrinkVibe.longFizzy => l10n.vibeLongFizzy,
  DrinkVibe.spicy => l10n.vibeSpicy,
  DrinkVibe.zeroProof => l10n.vibeZeroProof,
  DrinkVibe.threeIngredients => l10n.vibeThreeIngredients,
};
