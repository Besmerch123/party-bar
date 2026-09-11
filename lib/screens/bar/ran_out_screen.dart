import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/bar_item.dart';
import '../../providers/bar_provider.dart';
import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/bar_labels.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/auth/auth_controls.dart' show AuthGhostAction;
import '../../widgets/bar/bar_row.dart';
import '../../widgets/common/glass.dart';

/// What screen 08 arrives already knowing about the party that just ended —
/// all optional, since it can also be opened cold from My bar.
class RanOutArgs {
  const RanOutArgs({
    this.partyName,
    this.drinksPoured,
    this.pourCounts = const {},
  });

  final String? partyName;
  final int? drinksPoured;

  /// How many times each [barKey] was poured tonight, for the "poured N
  /// times" subtitle on a stocked row.
  final Map<String, int> pourCounts;
}

/// Flow 04 · screen 08 — "Anything run out?", asked once a party ends.
///
/// Nothing changes on the shelf until "Update my bar" is pressed: tapping a
/// row only marks it gone in this screen's own memory, so a wrong tap earlier
/// in a long shelf is undone by tapping it again, not by backing out and
/// losing every other answer already given.
class RanOutScreen extends StatefulWidget {
  const RanOutScreen({super.key, this.args});

  final RanOutArgs? args;

  @override
  State<RanOutScreen> createState() => _RanOutScreenState();
}

class _RanOutScreenState extends State<RanOutScreen> {
  final Set<String> _gone = {};

  void _toggle(String key) => setState(() {
    if (!_gone.remove(key)) _gone.add(key);
  });

  Future<void> _update() async {
    final bar = context.read<BarProvider>();
    final partyName = widget.args?.partyName;
    await bar.applyRanOut(_gone, partyName: partyName);
    if (!mounted) return;
    _exit();
  }

  void _exit() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.myBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bar = context.watch<BarProvider>();
    final candidates = _orderedCandidates(
      bar.stocked,
      widget.args?.pourCounts ?? const {},
    );
    final hasCandidates = candidates.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: Stack(
        children: [
          const _HeroPhoto(),
          SafeArea(
            child: Column(
              children: [
                _CloseRow(onClose: _exit),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenEdge,
                      96,
                      AppSpacing.screenEdge,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Eyebrow(args: widget.args),
                        Text(
                          l10n.ranOutTitle,
                          style: AppTypography.heading.copyWith(
                            fontSize: 32,
                            height: 1.05,
                            letterSpacing: -1.12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: Text(
                            hasCandidates ? l10n.ranOutBody : l10n.ranOutEmpty,
                            style: AppTypography.body.copyWith(
                              fontSize: 13.5,
                              height: 1.6,
                            ),
                          ),
                        ),
                        if (hasCandidates) ...[
                          const SizedBox(height: 24),
                          for (final (index, item) in candidates.indexed) ...[
                            if (index > 0) const SizedBox(height: 8),
                            _RanOutRow(
                              item: item,
                              gone: _gone.contains(item.key),
                              pourCount: widget.args?.pourCounts[item.key],
                              onTap: () => _toggle(item.key),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
                _BottomBar(
                  showUpdate: hasCandidates,
                  count: _gone.length,
                  onUpdate: _gone.isEmpty ? null : _update,
                  onNothing: _exit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Which stocked bottles the checklist opens with, and in what order.
///
/// A party that logged pours puts the busiest bottles first — the ones most
/// likely to actually be empty — with the rest of the shelf trailing behind,
/// fresh things first since those are what actually goes off between one
/// party and the next. A party with nothing logged (or no party at all) just
/// shows the whole shelf that way.
List<BarItem> _orderedCandidates(
  List<BarItem> stocked,
  Map<String, int> pourCounts,
) {
  int sectionRank(BarSection section) => switch (section) {
    BarSection.fresh => 0,
    BarSection.spirits => 1,
    BarSection.mixers => 2,
    BarSection.syrups => 3,
    BarSection.tools => 4,
    BarSection.ice => 5,
    BarSection.other => 6,
  };

  if (pourCounts.isEmpty) {
    return List<BarItem>.of(stocked)
      ..sort((a, b) => sectionRank(a.section).compareTo(sectionRank(b.section)));
  }

  final counted = stocked.where((item) => pourCounts.containsKey(item.key)).toList()
    ..sort((a, b) => pourCounts[b.key]!.compareTo(pourCounts[a.key]!));
  final rest = stocked.where((item) => !pourCounts.containsKey(item.key)).toList()
    ..sort((a, b) => sectionRank(a.section).compareTo(sectionRank(b.section)));

  return [...counted, ...rest];
}

/// The 300px cosmopolitan hero, fading into [AppColors.ground] so the
/// scrollable checklist below never fights the photo for attention.
class _HeroPhoto extends StatelessWidget {
  const _HeroPhoto();

  static const _height = 300.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: _height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/onboarding/cosmopolitan.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) =>
                const ColoredBox(color: AppColors.row),
          ),
          const PhotoScrim(),
        ],
      ),
    );
  }
}

class _CloseRow extends StatelessWidget {
  const _CloseRow({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, 8, AppSpacing.screenEdge, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GlassIconButton(
          icon: Icons.close,
          size: 34,
          tooltip: context.l10n.close,
          onTap: onClose,
        ),
      ),
    );
  }
}

/// "KATE'S BIRTHDAY · 31 DRINKS POURED" — omits whichever half [RanOutArgs]
/// did not carry, and disappears entirely rather than showing an empty chip
/// when it carried neither.
class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.args});

  final RanOutArgs? args;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final partyName = args?.partyName;
    final drinksPoured = args?.drinksPoured;

    final parts = <String>[
      if (partyName != null && partyName.isNotEmpty) partyName,
      if (drinksPoured != null) l10n.ranOutDrinksPoured(drinksPoured),
    ];
    if (parts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.signalWash,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          parts.join(' · ').toUpperCase(),
          style: AppTypography.label.copyWith(
            fontSize: 10,
            color: AppColors.signalLight,
          ),
        ),
      ),
    );
  }
}

class _RanOutRow extends StatelessWidget {
  const _RanOutRow({
    required this.item,
    required this.gone,
    required this.pourCount,
    required this.onTap,
  });

  final BarItem item;
  final bool gone;
  final int? pourCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = barItemName(context, item);
    final count = pourCount;

    final subtitle = gone
        ? l10n.ranOutGone
        : (count != null && count > 0 ? l10n.ranOutPoured(count) : null);

    return BarRow(
      leading: BarThumb(
        image: item.image,
        icon: barSectionIcon(item.section),
        tone: gone ? BarThumbTone.low : BarThumbTone.neutral,
      ),
      title: name,
      subtitle: subtitle,
      subtitleColor: gone ? AppColors.low : null,
      background: gone ? AppColors.low.withValues(alpha: .14) : AppColors.sheet,
      outline: gone ? AppColors.low.withValues(alpha: .5) : null,
      trailing: BarActionCircle(
        icon: Icons.check,
        tone: gone ? BarActionTone.low : BarActionTone.dim,
        onTap: onTap,
        semanticsLabel: gone ? l10n.barPutBack(name) : l10n.barMarkRanOut(name),
      ),
      onTap: onTap,
      semanticsLabel: gone ? l10n.barPutBack(name) : l10n.barMarkRanOut(name),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.showUpdate,
    required this.count,
    required this.onUpdate,
    required this.onNothing,
  });

  /// False on the empty-shelf state, where the primary pill has nothing to
  /// apply and only the ghost exit remains.
  final bool showUpdate;
  final int count;
  final VoidCallback? onUpdate;
  final VoidCallback onNothing;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        18,
        AppSpacing.screenEdge,
        22,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showUpdate) ...[
            SizedBox(
              height: AppSizes.buttonPrimary,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onUpdate,
                icon: const Icon(Icons.local_bar),
                label: Text(l10n.ranOutUpdate(count)),
              ),
            ),
            const SizedBox(height: 10),
          ],
          AuthGhostAction(label: l10n.ranOutNothing, onPressed: onNothing),
        ],
      ),
    );
  }
}
