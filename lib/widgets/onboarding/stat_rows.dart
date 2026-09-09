import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// What a stat row is reporting. Drives colour — never pick it directly.
enum StatTone { neutral, ready, low }

extension on StatTone {
  Color get accent => switch (this) {
    StatTone.neutral => AppColors.signalLight,
    StatTone.ready => AppColors.ready,
    StatTone.low => AppColors.low,
  };

  Color get wash => switch (this) {
    StatTone.neutral => AppColors.fillMuted,
    StatTone.ready => AppColors.readyWash,
    StatTone.low => AppColors.lowWash,
  };

  Color get label => switch (this) {
    StatTone.neutral => AppColors.ink,
    StatTone.ready => AppColors.ink,
    // The one row that is a suggestion rather than a fact reads warm.
    StatTone.low => const Color(0xFFF5C97A),
  };
}

/// One line of the "what your shelf is worth" summary.
class StatRow {
  const StatRow({
    required this.icon,
    required this.label,
    required this.value,
    this.tone = StatTone.neutral,
  });

  final IconData icon;
  final String label;
  final String value;
  final StatTone tone;
}

/// Hairline-separated stack of [StatRow]s.
///
/// The gaps are the container showing through rather than borders, so the
/// group reads as one object with seams instead of six stacked cards.
class StatRowList extends StatelessWidget {
  const StatRowList({super.key, required this.rows});

  final List<StatRow> rows;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.tileAll,
      child: ColoredBox(
        color: AppColors.fillSubtle,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const SizedBox(height: 1),
              _StatRowTile(row: rows[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatRowTile extends StatelessWidget {
  const _StatRowTile({required this.row});

  final StatRow row;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.row,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: row.tone.wash,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(row.icon, size: 17, color: row.tone.accent),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              row.label,
              style: AppTypography.cardTitle.copyWith(
                fontWeight: FontWeight.w600,
                color: row.tone.label,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            row.value,
            style: AppTypography.measure.copyWith(
              color: row.tone == StatTone.neutral
                  ? AppColors.inkBody
                  : row.tone.accent,
            ),
          ),
        ],
      ),
    );
  }
}
