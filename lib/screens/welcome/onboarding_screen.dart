import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../widgets/onboarding/bottles_step.dart';
import '../../widgets/onboarding/onboarding_step.dart';
import '../../widgets/onboarding/value_bar_step.dart';
import '../../widgets/onboarding/value_orders_step.dart';
import '../../widgets/onboarding/vibe_step.dart';

/// Flow 01 · steps 02–05.
///
/// The forty seconds between install and the first cocktail on screen. No
/// account is asked for anywhere here: a vibe and five bottles are kept on
/// the device, and auth later claims them.
///
/// Step 06 of the flow is the first Explore, which this hands off to.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _stepCount = 4;

  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index >= _stepCount - 1) {
      _finish();
      return;
    }
    _controller.nextPage(duration: AppMotion.sheet, curve: AppMotion.curve);
  }

  void _back() {
    if (_index == 0) return;
    _controller.previousPage(duration: AppMotion.sheet, curve: AppMotion.curve);
  }

  /// Hand-off to step 06: the first Explore, seeded by whatever was chosen.
  void _finish() => context.go(AppRoutes.explore);

  OnboardingStepNav _navFor(int index) => OnboardingStepNav(
    stepIndex: index,
    stepCount: _stepCount,
    onNext: _next,
    onBack: _back,
    onSkip: _finish,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: (index) => setState(() => _index = index),
        children: [
          ValueBarStep(nav: _navFor(0)),
          ValueOrdersStep(nav: _navFor(1)),
          VibeStep(nav: _navFor(2)),
          BottlesStep(nav: _navFor(3)),
        ],
      ),
    );
  }
}
