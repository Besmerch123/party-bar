import 'package:flutter/foundation.dart';

/// What every onboarding step needs from its host: where it sits, and the
/// three ways out of it.
///
/// Passing this down keeps the steps ignorant of the [PageController] and of
/// the route they eventually hand off to.
@immutable
class OnboardingStepNav {
  const OnboardingStepNav({
    required this.stepIndex,
    required this.stepCount,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  /// Zero-based position among the steps that show a progress indicator.
  final int stepIndex;
  final int stepCount;

  final VoidCallback onNext;
  final VoidCallback onBack;

  /// Leaves the flow entirely, keeping whatever has been chosen so far.
  final VoidCallback onSkip;
}
