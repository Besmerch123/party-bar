import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../common/glass.dart';

/// Photograph filling the top of an onboarding slide, dissolving into the
/// ground so the copy below can start without a hard edge.
///
/// The band is 62% of the slide — the ratio the flow is drawn at — except on
/// the splash, where [fullBleed] lets the photo own the whole screen.
class OnboardingHero extends StatelessWidget {
  const OnboardingHero({
    super.key,
    required this.image,
    this.fullBleed = false,
  });

  final String image;
  final bool fullBleed;

  static const _bandRatio = 0.62;

  @override
  Widget build(BuildContext context) {
    final height = fullBleed
        ? null
        : MediaQuery.sizeOf(context).height * _bandRatio;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: fullBleed ? 0 : null,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(image, fit: BoxFit.cover),
          const PhotoScrim(),
        ],
      ),
    );
  }
}

/// Back affordance plus the always-visible escape hatch.
///
/// Skip is never hidden on steps 02–05, but the widget renders differently
/// over a photograph than over the ground: glass only reads on photography.
class OnboardingTopBar extends StatelessWidget {
  const OnboardingTopBar({
    super.key,
    required this.actionLabel,
    required this.onAction,
    this.onBack,
    this.onGlass = false,
  });

  final String actionLabel;
  final VoidCallback onAction;

  /// Omitted on the first step, which has nothing to go back to.
  final VoidCallback? onBack;

  final bool onGlass;

  static const _visualSize = 34.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        8,
        AppSpacing.screenEdge,
        0,
      ),
      child: Row(
        children: [
          if (onBack != null)
            _TapTarget(
              onTap: onBack!,
              child: onGlass
                  ? const GlassIconButton(
                      icon: Icons.arrow_back,
                      size: _visualSize,
                    )
                  : Container(
                      width: _visualSize,
                      height: _visualSize,
                      decoration: const BoxDecoration(
                        color: AppColors.fillMuted,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, size: 18),
                    ),
            ),
          const Spacer(),
          _TapTarget(
            onTap: onAction,
            child: _ActionPill(label: actionLabel, onGlass: onGlass),
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({required this.label, required this.onGlass});

  final String label;
  final bool onGlass;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      style: AppTypography.body.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        height: 1.0,
        color: onGlass ? AppColors.ink.withValues(alpha: .85) : AppColors.inkMeta,
      ),
    );

    const padding = EdgeInsets.symmetric(horizontal: 14);

    if (onGlass) {
      return SizedBox(
        height: 34,
        child: GlassSurface(
          padding: padding,
          child: Center(widthFactor: 1, child: text),
        ),
      );
    }

    return Container(
      height: 34,
      padding: padding,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.fillMuted,
        borderRadius: AppRadius.pillAll,
      ),
      child: text,
    );
  }
}

/// Keeps a 34px visual inside a 44px hit box so nothing tappable falls below
/// [AppSizes.minTap].
class _TapTarget extends StatelessWidget {
  const _TapTarget({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: AppSizes.minTap,
        child: Center(widthFactor: 1, child: child),
      ),
    );
  }
}

/// Body of a value slide: sits on the bottom edge when the screen is tall
/// enough, scrolls instead of overflowing when it is not.
class OnboardingSlideBody extends StatelessWidget {
  const OnboardingSlideBody({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenEdge,
          AppSpacing.md,
          AppSpacing.screenEdge,
          34,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight - AppSpacing.md - 34,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: children,
          ),
        ),
      ),
    );
  }
}

/// Small tinted overline naming what a value slide is about.
class OnboardingEyebrow extends StatelessWidget {
  const OnboardingEyebrow({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.signalWash,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.label.copyWith(color: AppColors.signalLight),
      ),
    );
  }
}

/// Position within steps 02–05.
class OnboardingDots extends StatelessWidget {
  const OnboardingDots({
    super.key,
    required this.count,
    required this.activeIndex,
  });

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return Container(
          margin: EdgeInsets.only(right: index == count - 1 ? 0 : 6),
          width: isActive ? 22 : 5,
          height: 5,
          decoration: BoxDecoration(
            color: isActive ? AppColors.ink : AppColors.ink.withValues(alpha: .28),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

/// The white advance button the value slides end on.
class OnboardingNextButton extends StatelessWidget {
  const OnboardingNextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.badgeCount,
  });

  final String label;
  final VoidCallback onPressed;

  /// Shown instead of the arrow when the step counts a selection.
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 9),
          if (badgeCount == null)
            const Icon(Icons.arrow_forward, size: 19)
          else
            Container(
              constraints: const BoxConstraints(minWidth: 22),
              height: 22,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.signal,
                borderRadius: AppRadius.pillAll,
              ),
              child: Text(
                '$badgeCount',
                style: AppTypography.buttonSecondary.copyWith(
                  fontSize: 12,
                  color: AppColors.ink,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
