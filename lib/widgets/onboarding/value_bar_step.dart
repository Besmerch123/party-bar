import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../utils/localization_helper.dart';
import 'onboarding_chrome.dart';
import 'onboarding_step.dart';
import 'stat_rows.dart';

/// Flow 01 · step 02 — what the app does with a shelf.
///
/// The three rows are a worked example, not the user's own bar: they promise
/// the arithmetic that step 05 then performs for real.
class ValueBarStep extends StatelessWidget {
  const ValueBarStep({super.key, required this.nav});

  final OnboardingStepNav nav;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Stack(
      children: [
        const OnboardingHero(image: 'assets/images/onboarding/gin.jpg'),
        SafeArea(
          child: Column(
            children: [
              OnboardingTopBar(
                actionLabel: l10n.skip,
                onAction: nav.onSkip,
                onGlass: true,
              ),
              Expanded(
                child: OnboardingSlideBody(
                  children: [
                    OnboardingEyebrow(label: l10n.onboardingBarEyebrow),
                    const SizedBox(height: 16),
                    Text(
                      l10n.onboardingBarTitle,
                      style: AppTypography.title.copyWith(
                        fontSize: 38,
                        letterSpacing: -1.33,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Text(
                        l10n.onboardingBarBody,
                        style: AppTypography.body.copyWith(height: 1.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    StatRowList(
                      rows: [
                        StatRow(
                          icon: Icons.liquor,
                          label: l10n.onboardingBarStatShelf,
                          value: '3',
                        ),
                        StatRow(
                          icon: Icons.local_bar,
                          label: l10n.onboardingBarStatPourable,
                          value: '14',
                          tone: StatTone.ready,
                        ),
                        StatRow(
                          icon: Icons.add_shopping_cart,
                          label: l10n.onboardingBarStatUnlock,
                          value: '+11',
                          tone: StatTone.low,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        OnboardingDots(
                          count: nav.stepCount,
                          activeIndex: nav.stepIndex,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: OnboardingNextButton(
                            label: l10n.next,
                            onPressed: nav.onNext,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
