import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/models.dart';
import '../../../theme/theme.dart';
import '../../../utils/cocktail_labels.dart';
import '../../../utils/localization_helper.dart';
import '../../auth/auth_controls.dart';
import '../host_sheets.dart';
import '../order_bits.dart';

/// One step, already translated — the pour-step breakdown when the recipe
/// has one, otherwise the plain preparation lines with no timer.
class _StepView {
  const _StepView({required this.title, this.body, this.durationSeconds});

  final String title;
  final String? body;
  final int? durationSeconds;

  bool get hasTimer => (durationSeconds ?? 0) > 0;
}

List<_StepView> _stepsOf(Cocktail cocktail, BuildContext context) {
  if (cocktail.pourSteps.isNotEmpty) {
    return [
      for (final step in cocktail.pourSteps)
        _StepView(
          title: step.title.translate(context),
          body: step.body?.translate(context),
          durationSeconds: step.hasTimer ? step.durationSeconds : null,
        ),
    ];
  }
  final plain = cocktail.preparationSteps?.translate(context) ?? const <String>[];
  return [for (final line in plain) _StepView(title: line)];
}

/// How many steps [cocktail] would show — used by the pouring screen's row
/// to decide whether "How {host} makes it" is worth offering at all.
int stepCountOf(Cocktail cocktail, BuildContext context) => _stepsOf(cocktail, context).length;

/// Flow 06 · screen 10b — the method, one tap up from the pour. Numbered
/// steps, a countdown on the ones that carry a shake or stir duration, and
/// the same "Ready" commit the pouring screen offers.
Future<void> showMethodSheet(
  BuildContext context, {
  required String host,
  required Cocktail cocktail,
  required String guestName,
  required VoidCallback onReady,
}) {
  return showHostSheet<void>(
    context,
    (context) => _MethodSheetContent(
      host: host,
      cocktail: cocktail,
      guestName: guestName,
      onReady: onReady,
    ),
  );
}

class _MethodSheetContent extends StatefulWidget {
  const _MethodSheetContent({
    required this.host,
    required this.cocktail,
    required this.guestName,
    required this.onReady,
  });

  final String host;
  final Cocktail cocktail;
  final String guestName;
  final VoidCallback onReady;

  @override
  State<_MethodSheetContent> createState() => _MethodSheetContentState();
}

class _MethodSheetContentState extends State<_MethodSheetContent> {
  final Map<int, int> _remaining = {};
  final Set<int> _running = {};
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _toggle(int index, int duration) {
    setState(() {
      if (_running.contains(index)) {
        _running.remove(index);
      } else {
        if ((_remaining[index] ?? 0) <= 0) _remaining[index] = duration;
        _running.add(index);
        _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
      }
    });
  }

  void _tick() {
    setState(() {
      for (final index in _running.toList()) {
        final left = (_remaining[index] ?? 0) - 1;
        _remaining[index] = left < 0 ? 0 : left;
        if (_remaining[index] == 0) {
          _running.remove(index);
          HapticFeedback.heavyImpact();
        }
      }
      if (_running.isEmpty) {
        _ticker?.cancel();
        _ticker = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cocktail = widget.cocktail;
    final steps = _stepsOf(cocktail, context);
    final host = hostFirstName(widget.host);

    return HostSheet(
      children: [
        HostSheetTitle(l10n.queueMethodSheetTitle(host), size: 22),
        const SizedBox(height: 8),
        Text(
          // No method on file: the drink's name alone, not a dangling joint.
          cocktail.method == null
              ? cocktail.title.translate(context)
              : l10n.queueMethodSubtitle(
                  cocktail.title.translate(context),
                  methodLabel(l10n, cocktail.method!),
                ),
          style: AppTypography.meta.copyWith(fontSize: 12.5),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final equipment in cocktail.equipments) _Chip(equipment.title.translate(context)),
            if (cocktail.prepTimeMinutes != null) _Chip(l10n.queueMethodMinutes(cocktail.prepTimeMinutes!)),
          ],
        ),
        const SizedBox(height: 16),
        for (final (i, step) in steps.indexed) ...[
          if (i > 0) const SizedBox(height: 10),
          _StepCard(
            index: i + 1,
            first: i == 0,
            step: step,
            remainingSeconds: _remaining[i] ?? step.durationSeconds ?? 0,
            running: _running.contains(i),
            onToggleTimer: step.hasTimer
                ? () => _toggle(i, step.durationSeconds!)
                : null,
          ),
        ],
        const SizedBox(height: 18),
        AuthPillButton(
          label: l10n.queueReadyBuzz(widget.guestName),
          primary: true,
          height: AppSizes.buttonPrimary,
          onPressed: () {
            Navigator.of(context).pop();
            widget.onReady();
          },
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.fillMuted,
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        label,
        style: AppTypography.buttonSecondary.copyWith(
          fontSize: 11,
          color: AppColors.ink.withValues(alpha: .7),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.index,
    required this.first,
    required this.step,
    required this.remainingSeconds,
    required this.running,
    required this.onToggleTimer,
  });

  final int index;
  final bool first;
  final _StepView step;
  final int remainingSeconds;
  final bool running;
  final VoidCallback? onToggleTimer;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: AppColors.row, borderRadius: AppRadius.tileAll),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: first ? AppColors.ink : AppColors.fillStrong,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$index',
              style: AppTypography.mono.copyWith(
                fontSize: 13,
                color: first ? AppColors.ground : AppColors.ink,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: AppTypography.body.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                    color: AppColors.ink.withValues(alpha: first ? 1 : .82),
                  ),
                ),
                if (step.body case final body?) ...[
                  const SizedBox(height: 6),
                  Text(body, style: AppTypography.meta.copyWith(fontSize: 12, height: 1.4)),
                ],
                if (onToggleTimer != null) ...[
                  const SizedBox(height: 9),
                  Material(
                    color: AppColors.signalWash,
                    borderRadius: AppRadius.pillAll,
                    child: InkWell(
                      onTap: onToggleTimer,
                      borderRadius: AppRadius.pillAll,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              running ? Icons.pause : Icons.timer,
                              size: 15,
                              color: AppColors.signalLight,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              l10n.queueMethodTimerSeconds(remainingSeconds),
                              style: AppTypography.mono.copyWith(
                                fontSize: 11.5,
                                color: kSignalPale,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
