import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/measure_unit_provider.dart';
import '../../theme/theme.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/settings/measure_preview.dart';
import '../../widgets/settings/settings_rows.dart';
import '../../widgets/settings/settings_subpage.dart';

/// Flow 09 · screen 05 — the only setting that changes the product.
///
/// The toggle itself already lives on the index, two taps and done; this is
/// the fuller read of what it does and does not touch, reached from the
/// index card's preview line.
class MeasuresScreen extends StatelessWidget {
  const MeasuresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final unit = context.watch<MeasureUnitProvider>().unit;

    return SettingsSubpageScaffold(
      title: l10n.settingsMeasures,
      body: l10n.settingsMeasuresBody,
      bodyStyle: AppTypography.body.copyWith(fontSize: 13, color: AppColors.inkBody),
      children: [
        MeasureUnitSegment(
          unit: unit,
          onChanged: (value) => context.read<MeasureUnitProvider>().setUnit(value),
        ),
        const SizedBox(height: 18),
        Container(
          decoration: BoxDecoration(color: AppColors.sheet, borderRadius: AppRadius.cardAll),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsMeasuresPreviewCaption,
                style: AppTypography.cardTitle.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 16),
              MeasurePreviewList(unit: unit),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SettingsRowGroup(
          children: [
            SettingsInfoRowGroupItem(
              icon: Icons.straighten,
              text: l10n.settingsMeasuresNoteRounding,
            ),
            SettingsInfoRowGroupItem(
              icon: Icons.local_drink_outlined,
              text: l10n.settingsMeasuresNoteDashes,
            ),
            SettingsInfoRowGroupItem(
              icon: Icons.group_outlined,
              text: l10n.settingsMeasuresNoteYoursOnly,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          l10n.settingsMeasuresFootnote,
          textAlign: TextAlign.center,
          style: AppTypography.caption.copyWith(color: AppColors.inkFaint),
        ),
      ],
    );
  }
}
