import 'package:flutter/material.dart';

import '../../generated/l10n/app_localizations.dart';
import '../../models/recipe.dart';
import '../../theme/theme.dart';
import '../../utils/cocktail_labels.dart';
import '../../utils/localization_helper.dart';

/// A real Cosmopolitan, run through the real conversion — so switching ml/oz
/// on this screen previews the exact rounding a pour card will show tonight,
/// rather than a mocked-up number that could quietly drift from it.
const kMeasurePreviewIngredients = [
  ('Citrus vodka', IngredientMeasure(amount: 40, unit: MeasureUnit.ml)),
  ('Cointreau', IngredientMeasure(amount: 15, unit: MeasureUnit.ml)),
  ('Lime juice', IngredientMeasure(amount: 15, unit: MeasureUnit.ml)),
  ('Cranberry', IngredientMeasure(amount: 30, unit: MeasureUnit.ml)),
];

/// The one-line version on the settings index — "40 ml vodka · 15 ml lime".
String measurePreviewSummary(AppLocalizations l10n, MeasureUnit unit) {
  return kMeasurePreviewIngredients
      .take(2)
      .map(
        (entry) =>
            '${measureLabel(l10n, entry.$2, displayUnit: unit)} ${entry.$1}',
      )
      .join(' · ');
}

/// The full ingredient list on the dedicated Measures screen.
class MeasurePreviewList extends StatelessWidget {
  const MeasurePreviewList({super.key, required this.unit});

  final MeasureUnit unit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        for (final entry in kMeasurePreviewIngredients) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              SizedBox(
                width: 66,
                child: Text(
                  measureLabel(l10n, entry.$2, displayUnit: unit),
                  style: AppTypography.mono.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.signalLight,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  entry.$1,
                  style: AppTypography.cardTitle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink.withValues(alpha: .8),
                  ),
                ),
              ),
            ],
          ),
          if (entry != kMeasurePreviewIngredients.last)
            const SizedBox(height: 11),
        ],
      ],
    );
  }
}

/// The ml/oz pill. [compact] is the index card's small version; the full
/// Measures screen uses the larger one, with the unit code spelled out.
class MeasureUnitSegment extends StatelessWidget {
  const MeasureUnitSegment({
    super.key,
    required this.unit,
    required this.onChanged,
    this.compact = false,
  });

  final MeasureUnit unit;
  final ValueChanged<MeasureUnit> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: EdgeInsets.all(compact ? 3 : 5),
      decoration: BoxDecoration(
        color: AppColors.fillStrong,
        borderRadius: BorderRadius.circular(compact ? 999 : 20),
      ),
      child: Row(
        mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
        children: [
          _segment(l10n.measureUnitMl, l10n.unitMl, MeasureUnit.ml),
          if (!compact) const SizedBox(width: 10),
          _segment(l10n.measureUnitOz, l10n.unitOz, MeasureUnit.oz),
        ],
      ),
    );
  }

  Widget _segment(String label, String code, MeasureUnit value) {
    final selected = unit == value;
    final labelColor = selected
        ? AppColors.ground
        : AppColors.inkBody;
    final codeColor = selected
        ? AppColors.ground.withValues(alpha: .5)
        : AppColors.inkFaint;

    // The compact pill (index card) only has room for the short code — the
    // full mode's spelled-out label doesn't fit next to a card title even at
    // 1.0x, and every extra pixel of text scale made it worse.
    final child = AnimatedContainer(
      duration: AppMotion.tap,
      constraints: compact ? null : const BoxConstraints(minHeight: 52),
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 15, vertical: 7)
          : const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(compact ? 999 : 16),
      ),
      child: compact
          ? Text(
              code,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.buttonSecondary.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: labelColor,
              ),
            )
          // `Wrap` instead of a fixed-width `Row`: at the plain 1.0x baseline
          // the label and code sit on one line same as before, and only drop
          // to a second line once a narrower phone or a bumped text scale
          // leaves no room for both side by side.
          : Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 2,
              children: [
                Text(
                  label,
                  style: AppTypography.cardTitle.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: labelColor,
                  ),
                ),
                Text(
                  code,
                  style: AppTypography.mono.copyWith(
                    fontSize: 11.5,
                    color: codeColor,
                  ),
                ),
              ],
            ),
    );

    return compact
        ? GestureDetector(onTap: () => onChanged(value), child: child)
        : Expanded(
            child: GestureDetector(onTap: () => onChanged(value), child: child),
          );
  }
}
