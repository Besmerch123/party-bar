import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/models.dart';
import '../../theme/theme.dart';
import '../../utils/cocktail_labels.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/common/glass.dart';

/// The hands-busy guided pour: one instruction at a time, in the largest type
/// in the app, for someone reading a phone propped against a bottle while
/// they hold a shaker.
///
/// A solo pour never touches a party or an account — there is nowhere for it
/// to report to, and nobody watching it happen. Finishing it does not bump a
/// drink's "poured" count either; that number belongs to parties, and folding
/// a private rehearsal into it would make it mean something looser than it
/// does today. That is a deliberate line, not a gap to fill in later.
class MakeItNowScreen extends StatefulWidget {
  const MakeItNowScreen({super.key, required this.cocktail});

  final Cocktail cocktail;

  @override
  State<MakeItNowScreen> createState() => _MakeItNowScreenState();
}

class _MakeItNowScreenState extends State<MakeItNowScreen> {
  late final PageController _pageController;
  int _index = 0;

  Timer? _ticker;
  int _remainingSeconds = 0;
  bool _timerRunning = false;
  bool _timerDone = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Duration lookup never needs a translation, so it is safe to seed here
    // rather than waiting for the first build.
    _remainingSeconds = _durationForIndex(0) ?? 0;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  int? _durationForIndex(int index) {
    final pourSteps = widget.cocktail.pourSteps;
    if (pourSteps.isEmpty) return null; // the fallback text never carries a timer
    if (index < 0 || index >= pourSteps.length) return null;
    final step = pourSteps[index];
    return step.hasTimer ? step.durationSeconds : null;
  }

  /// [PourStep.title]/[body] need a [BuildContext] to translate, but the
  /// fallback to [Cocktail.preparationSteps] is the only place that
  /// difference actually shows: most of the catalogue has not been broken
  /// into pour steps yet, so this is what lets "Make it now" work on every
  /// drink today, one line per step, just without a timer or a body.
  List<_PourStepView> _steps(BuildContext context) {
    final cocktail = widget.cocktail;
    if (cocktail.pourSteps.isNotEmpty) {
      return [
        for (final step in cocktail.pourSteps)
          _PourStepView(
            title: step.title.translate(context),
            body: step.body?.translate(context),
            durationSeconds: step.hasTimer ? step.durationSeconds : null,
          ),
      ];
    }

    final plainSteps =
        cocktail.preparationSteps?.translate(context) ?? const <String>[];
    return [for (final line in plainSteps) _PourStepView(title: line)];
  }

  void _goToIndex(int index) {
    _pageController.animateToPage(
      index,
      duration: AppMotion.sheet,
      curve: AppMotion.curve,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _index = index;
      _ticker?.cancel();
      _timerRunning = false;
      _timerDone = false;
      _remainingSeconds = _durationForIndex(index) ?? 0;
    });
  }

  void _toggleTimer() {
    if (_remainingSeconds <= 0) return;
    if (_timerRunning) {
      setState(() {
        _ticker?.cancel();
        _timerRunning = false;
      });
      return;
    }

    setState(() => _timerRunning = true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _remainingSeconds = math.max(0, _remainingSeconds - 1);
        if (_remainingSeconds == 0) {
          _timerRunning = false;
          _timerDone = true;
          _ticker?.cancel();
          // The phone is out of reach and the person is mid-shake — this has
          // to be felt, not read.
          HapticFeedback.heavyImpact();
        }
      });
    });
  }

  Future<void> _openRecipeSheet() {
    final cocktail = widget.cocktail;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => _RecipeSheet(cocktail: cocktail),
    );
  }

  void _finish(String cocktailName) {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final message = l10n.pourFinished(cocktailName);
    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cocktail = widget.cocktail;
    final steps = _steps(context);

    if (steps.isEmpty) {
      return _NoStepsScreen(message: l10n.pourNoSteps);
    }

    final total = steps.length;
    final cocktailName = cocktail.title.translate(context);
    final photoHeight = math.min(430.0, MediaQuery.sizeOf(context).height * 0.5);

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: photoHeight,
            child: _Photo(image: cocktail.image),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: photoHeight,
            child: const PhotoScrim(),
          ),
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenEdge,
                  ),
                  child: _TopChrome(
                    index: _index,
                    total: total,
                    onExit: () => Navigator.of(context).pop(),
                    onShowRecipe: _openRecipeSheet,
                  ),
                ),
              ),
              Expanded(
                // A shaker leaves wet, unsteady hands, and the buttons below
                // are a normal thumb's reach at best — a swipeable PageView
                // makes the whole width of the screen a valid "next", with
                // the footer buttons only there for when a swipe is not
                // trustworthy (the first and last step, or anyone who prefers
                // them).
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: total,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) => _StepArea(
                    steps: steps,
                    index: index,
                    cocktailName: cocktailName,
                    remainingSeconds: index == _index ? _remainingSeconds : (_durationForIndex(index) ?? 0),
                    timerRunning: index == _index && _timerRunning,
                    timerDone: index == _index && _timerDone,
                    onToggleTimer: _toggleTimer,
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: _Footer(
                  isLast: _index == total - 1,
                  onBack: _index == 0 ? null : () => _goToIndex(_index - 1),
                  onNext: () {
                    if (_index == total - 1) {
                      _finish(cocktailName);
                    } else {
                      _goToIndex(_index + 1);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A single pour step, already translated. Kept separate from [PourStep]
/// because the fallback path has no [PourStep] to translate — only plain
/// lines of text — and both need to render through the same widgets.
class _PourStepView {
  const _PourStepView({required this.title, this.body, this.durationSeconds});

  final String title;
  final String? body;
  final int? durationSeconds;

  bool get hasTimer => (durationSeconds ?? 0) > 0;
}

class _Photo extends StatelessWidget {
  const _Photo({required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    if (image.isEmpty) return const _PhotoFallback();
    return Image.network(
      image,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stack) => const _PhotoFallback(),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const _PhotoFallback(),
    );
  }
}

/// Never a spinner and never grey: a missing photo should read as part of the
/// same dark room, not as a hole in it.
class _PhotoFallback extends StatelessWidget {
  const _PhotoFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.row,
      child: Center(child: Icon(Icons.local_bar, size: 48, color: AppColors.inkMeta)),
    );
  }
}

/// Exit, the step progress, and the way back to the full recipe — everything
/// that has to stay reachable no matter which step is on screen.
class _TopChrome extends StatelessWidget {
  const _TopChrome({
    required this.index,
    required this.total,
    required this.onExit,
    required this.onShowRecipe,
  });

  final int index;
  final int total;
  final VoidCallback onExit;
  final VoidCallback onShowRecipe;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        GlassIconButton(
          icon: Icons.close,
          size: 36,
          tooltip: l10n.pourExit,
          onTap: onExit,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _ProgressBar(index: index, total: total)),
        const SizedBox(width: AppSpacing.sm),
        _RecipePill(label: l10n.pourShowRecipe, onTap: onShowRecipe),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.index, required this.total});

  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0) const SizedBox(width: 5),
          Expanded(
            child: AnimatedContainer(
              duration: AppMotion.tap,
              curve: AppMotion.curve,
              height: 4,
              decoration: BoxDecoration(
                color: i <= index ? AppColors.ink : const Color(0x3DFFFFFF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _RecipePill extends StatelessWidget {
  const _RecipePill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GlassSurface(
        padding: const EdgeInsets.symmetric(horizontal: 13),
        onTap: onTap,
        child: SizedBox(
          height: 36,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.visibility, size: 16, color: AppColors.ink),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.body.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The step itself: eyebrow, headline, optional body, the timer when this
/// step has one, and a glance at what just happened and what is next.
///
/// Bottom-aligned when it fits, scrolling when a long instruction or a large
/// text scale pushes it past the available height.
class _StepArea extends StatelessWidget {
  const _StepArea({
    required this.steps,
    required this.index,
    required this.cocktailName,
    required this.remainingSeconds,
    required this.timerRunning,
    required this.timerDone,
    required this.onToggleTimer,
  });

  final List<_PourStepView> steps;
  final int index;
  final String cocktailName;
  final int remainingSeconds;
  final bool timerRunning;
  final bool timerDone;
  final VoidCallback onToggleTimer;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final step = steps[index];
    final total = steps.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n
                      .pourStepCounter(index + 1, total, cocktailName)
                      .toUpperCase(),
                  style: AppTypography.mono.copyWith(
                    fontSize: 10.5,
                    color: AppColors.signalLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Text(step.title, style: AppTypography.display),
                if (step.body case final body?) ...[
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 310),
                    child: Text(
                      body,
                      style: AppTypography.body.copyWith(
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
                if (step.hasTimer) ...[
                  const SizedBox(height: 24),
                  _TimerCard(
                    remainingSeconds: remainingSeconds,
                    running: timerRunning,
                    done: timerDone,
                    onTap: onToggleTimer,
                  ),
                ],
                if (total > 1) ...[
                  const SizedBox(height: 12),
                  _Checklist(steps: steps, index: index),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TimerCard extends StatelessWidget {
  const _TimerCard({
    required this.remainingSeconds,
    required this.running,
    required this.done,
    required this.onTap,
  });

  final int remainingSeconds;
  final bool running;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hint = done
        ? l10n.pourTimerDone
        : running
            ? l10n.pourTimerRunning
            : l10n.pourTimerHint;
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final clock =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Semantics(
      button: true,
      label: hint,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.sheet,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.signalWash,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.timer,
                    size: 23,
                    color: AppColors.signalLight,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        clock,
                        style: AppTypography.measure.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        hint,
                        style: AppTypography.meta.copyWith(fontSize: 11.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.ink,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    running ? Icons.pause : Icons.play_arrow,
                    size: 18,
                    color: AppColors.ground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The step just finished and the step just ahead — not the whole recipe,
/// which is what the recipe pill up top is for.
class _Checklist extends StatelessWidget {
  const _Checklist({required this.steps, required this.index});

  final List<_PourStepView> steps;
  final int index;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      if (index > 0)
        _ChecklistRow(title: steps[index - 1].title, done: true),
      if (index + 1 < steps.length)
        _ChecklistRow(title: steps[index + 1].title, done: false),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: AppRadius.tileAll,
      child: ColoredBox(
        color: AppColors.fillSubtle,
        child: Column(
          children: [
            for (final (i, row) in rows.indexed) ...[
              if (i > 0) const SizedBox(height: 1),
              row,
            ],
          ],
        ),
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.title, required this.done});

  final String title;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.row,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      child: Row(
        children: [
          if (done)
            const Icon(Icons.check_circle, size: 16, color: AppColors.ready)
          else
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x47FFFFFF), width: 1.5),
              ),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: AppTypography.body.copyWith(
                fontSize: 13,
                fontWeight: done ? FontWeight.w500 : FontWeight.w600,
                color: done ? AppColors.inkMeta : AppColors.inkBody,
                decoration: done ? TextDecoration.lineThrough : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Back a step, or finish. The primary pill always carries the current
/// action's own label rather than a generic "continue" so the last tap reads
/// as a different kind of action from the ones before it.
class _Footer extends StatelessWidget {
  const _Footer({
    required this.isLast,
    required this.onBack,
    required this.onNext,
  });

  final bool isLast;
  final VoidCallback? onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 22, 30),
      child: Row(
        children: [
          _BackButton(onTap: onBack),
          const SizedBox(width: 10),
          Expanded(
            child: _NextButton(
              label: isLast ? l10n.pourFinish : l10n.pourNext,
              showArrow: !isLast,
              onTap: onNext,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final enabled = onTap != null;

    return Tooltip(
      message: l10n.pourBack,
      child: Semantics(
        button: true,
        enabled: enabled,
        child: Opacity(
          opacity: enabled ? 1 : 0.35,
          child: SizedBox(
            width: 58,
            height: 58,
            child: Material(
              color: AppColors.fillStrong,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onTap,
                customBorder: const CircleBorder(),
                child: const Icon(
                  Icons.arrow_back,
                  size: 22,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({
    required this.label,
    required this.showArrow,
    required this.onTap,
  });

  final String label;
  final bool showArrow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.ground,
          textStyle: AppTypography.buttonPrimary,
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            if (showArrow) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward,
                size: 20,
                color: AppColors.ground,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The full ingredient list, reached without leaving the pour — for the
/// moment someone loses track of which bottle they already poured from.
class _RecipeSheet extends StatelessWidget {
  const _RecipeSheet({required this.cocktail});

  final Cocktail cocktail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        16,
        AppSpacing.screenEdge,
        0,
      ),
      decoration: const BoxDecoration(
        color: AppColors.sheet,
        borderRadius: AppRadius.sheetTop,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.glassStroke,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.pourShowRecipe,
              style: AppTypography.title.copyWith(
                fontSize: 22,
                letterSpacing: -0.55,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: ClipRRect(
                borderRadius: AppRadius.tileAll,
                child: ColoredBox(
                  color: AppColors.fillSubtle,
                  child: Column(
                    children: [
                      for (final (i, ingredient) in cocktail.ingredients.indexed) ...[
                        if (i > 0) const SizedBox(height: 1),
                        _IngredientRow(
                          name: ingredient.title.translate(context),
                          measure: cocktail.measureFor(ingredient.id),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom + 20),
        ],
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.name, required this.measure});

  final String name;
  final IngredientMeasure? measure;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      color: AppColors.row,
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: AppTypography.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (measure case final measure?) ...[
            const SizedBox(width: 12),
            Text(measureLabel(l10n, measure), style: AppTypography.measure),
          ],
        ],
      ),
    );
  }
}

/// Neither crashes nor an empty progress bar: a drink the catalogue has not
/// written a recipe for yet gets a calm, honest dead end instead.
class _NoStepsScreen extends StatelessWidget {
  const _NoStepsScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenEdge,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Tooltip(
                    message: l10n.pourExit,
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: Material(
                        color: AppColors.fillMuted,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          customBorder: const CircleBorder(),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenEdge,
                  ),
                  child: Text(
                    message,
                    style: AppTypography.body,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
