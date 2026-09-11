import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n/app_localizations.dart';
import '../../models/onboarding.dart';
import '../../providers/onboarding_provider.dart';
import '../../theme/theme.dart';
import '../../utils/bar_labels.dart';
import '../../utils/localization_helper.dart';
import 'bottle_row.dart';
import 'onboarding_chrome.dart';
import 'onboarding_step.dart';

/// Flow 01 · step 05 — the shelf itself.
///
/// Five bottles, not twenty: enough for the unlock number to mean something,
/// short enough that people finish. "Later" leaves with whatever is ticked.
class BottlesStep extends StatefulWidget {
  const BottlesStep({super.key, required this.nav});

  final OnboardingStepNav nav;

  @override
  State<BottlesStep> createState() => _BottlesStepState();
}

class _BottlesStepState extends State<BottlesStep> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StarterBottle> _visibleBottles(AppLocalizations l10n) {
    if (_query.isEmpty) return kStarterBottles;

    final needle = _query.toLowerCase();
    return kStarterBottles
        .where(
          (bottle) =>
              starterLabel(l10n, bottle.id).toLowerCase().contains(needle),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onboarding = context.watch<OnboardingProvider>();
    final bottles = _visibleBottles(l10n);
    final bestUnlock = onboarding.bestUnlock;

    return SafeArea(
      child: Column(
        children: [
          OnboardingTopBar(
            actionLabel: l10n.later,
            onAction: widget.nav.onSkip,
            onBack: widget.nav.onBack,
          ),
          _Header(controller: _searchController, onChanged: _onQueryChanged),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                AppSpacing.md,
                AppSpacing.screenEdge,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_query.isEmpty) ...[
                    Text(
                      l10n.onboardingBottlesSection.toUpperCase(),
                      style: AppTypography.label.copyWith(
                        color: AppColors.inkMeta,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  Expanded(
                    child: bottles.isEmpty
                        ? Text(
                            l10n.onboardingBottlesNoMatch,
                            style: AppTypography.meta,
                          )
                        : ClipRRect(
                            borderRadius: AppRadius.tileAll,
                            child: ColoredBox(
                              color: AppColors.fillSubtle,
                              child: ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount: bottles.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 1),
                                itemBuilder: (context, index) {
                                  final bottle = bottles[index];
                                  final isBest = bottle.id == bestUnlock?.id;
                                  return BottleRow(
                                    bottle: bottle,
                                    name: starterLabel(l10n, bottle.id),
                                    subtitle: isBest
                                        ? l10n.bottleUnlocksMore(bottle.unlocks)
                                        : l10n.bottleInCocktails(
                                            bottle.cocktailCount,
                                          ),
                                    highlighted: isBest,
                                    selected: onboarding.isBottleSelected(
                                      bottle.id,
                                    ),
                                    onTap: () =>
                                        onboarding.toggleBottle(bottle.id),
                                  );
                                },
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          _Footer(nav: widget.nav),
        ],
      ),
    );
  }

  void _onQueryChanged(String value) => setState(() => _query = value.trim());
}

class _Header extends StatelessWidget {
  const _Header({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
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
            l10n.onboardingBottlesTitle,
            style: AppTypography.title.copyWith(
              fontSize: 32,
              letterSpacing: -1.12,
              height: 1.02,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.onboardingBottlesBody,
            style: AppTypography.body.copyWith(height: 1.6),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: controller,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            style: AppTypography.body.copyWith(color: AppColors.ink),
            decoration: InputDecoration(
              isDense: true,
              hintText: l10n.onboardingBottlesSearchHint,
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
              prefixIcon: const Icon(
                Icons.search,
                size: 19,
                color: AppColors.inkMeta,
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 45),
              border: const OutlineInputBorder(
                borderRadius: AppRadius.pillAll,
                borderSide: BorderSide.none,
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: AppRadius.pillAll,
                borderSide: BorderSide.none,
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: AppRadius.pillAll,
                borderSide: BorderSide(color: AppColors.signal, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.nav});

  final OnboardingStepNav nav;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onboarding = context.watch<OnboardingProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        18,
        AppSpacing.screenEdge,
        30,
      ),
      child: Column(
        children: [
          // Both labels grow with translation and text scale, so neither may
          // size itself off the Row.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  l10n.onboardingBottlesAdded(
                    onboarding.selectedBottleCount,
                    kStarterBottleTarget,
                  ),
                  style: AppTypography.meta.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkBody,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  l10n.onboardingDrinksUnlocked(onboarding.pourableCount),
                  style: AppTypography.measure.copyWith(color: AppColors.ready),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: onboarding.stockingProgress,
              minHeight: 5,
              backgroundColor: AppColors.fillStrong,
              valueColor: const AlwaysStoppedAnimation(AppColors.signal),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: nav.onNext,
            icon: const Icon(Icons.local_bar, size: 21),
            label: Text(l10n.onboardingOpenBar),
          ),
        ],
      ),
    );
  }
}
