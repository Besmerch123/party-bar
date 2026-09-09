import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../utils/localization_helper.dart';
import '../common/app_chip.dart';
import 'mock_order_card.dart';
import 'onboarding_chrome.dart';
import 'onboarding_step.dart';

/// Flow 01 · step 03 — what guests do, and what the host gets back.
class ValueOrdersStep extends StatelessWidget {
  const ValueOrdersStep({super.key, required this.nav});

  final OnboardingStepNav nav;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Stack(
      fit: StackFit.expand,
      children: [
        const OnboardingHero(
          image: 'assets/images/onboarding/cosmopolitan.jpg',
        ),
        SafeArea(
          child: Column(
            children: [
              OnboardingTopBar(
                actionLabel: l10n.skip,
                onAction: nav.onSkip,
                onBack: nav.onBack,
                onGlass: true,
              ),
              Expanded(
                child: OnboardingSlideBody(
                  children: [
                    OnboardingEyebrow(label: l10n.onboardingOrdersEyebrow),
                    const SizedBox(height: 16),
                    Text(
                      l10n.onboardingOrdersTitle,
                      style: AppTypography.title.copyWith(
                        fontSize: 38,
                        letterSpacing: -1.33,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Text(
                        l10n.onboardingOrdersBody,
                        style: AppTypography.body.copyWith(height: 1.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    MockOrderCard(
                      image: 'assets/images/onboarding/gin_tonic.jpg',
                      title: l10n.onboardingSampleGinTonic,
                      subtitle: l10n.onboardingSampleOrderNote,
                      statusLabel: l10n.orderStatusNew,
                      quantity: 2,
                      tone: ChipTone.signal,
                    ),
                    const SizedBox(height: 10),
                    MockOrderCard(
                      image: 'assets/images/onboarding/cosmopolitan.jpg',
                      title: l10n.onboardingSampleCosmopolitan,
                      subtitle: l10n.onboardingSampleOrderWaiting,
                      statusLabel: l10n.orderStatusQueued,
                      dimmed: true,
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
                            label: l10n.onboardingOrdersCta,
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
