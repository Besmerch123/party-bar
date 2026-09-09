import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme/theme.dart';
import '../common/app_chip.dart';
import '../../utils/cocktail_labels.dart';
import '../../utils/localization_helper.dart';

/// The furniture Explore repeats: section headers, the eyebrow over a list,
/// and the row of filters currently in force.

/// Uppercase overline above a list — RECENT, ONE BOTTLE AWAY.
class EyebrowLabel extends StatelessWidget {
  const EyebrowLabel(this.text, {super.key, this.trailing});

  final String text;

  /// A quiet action on the right of the line, such as "Clear".
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text.toUpperCase(),
      style: AppTypography.label.copyWith(color: AppColors.inkMeta),
    );

    if (trailing == null) return label;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [Flexible(child: label), trailing!],
    );
  }
}

/// Section header inside the feed — a title, and optionally a way past it.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            title,
            style: AppTypography.section,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel!,
              style: AppTypography.body.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.signalLight,
              ),
            ),
          ),
      ],
    );
  }
}

/// The filter button and every active filter beside it.
///
/// The flow's rule is that no filter is ever invisible: the sheet and this row
/// read the same [ExploreFilters], so a chip here is the only evidence needed
/// that something is on — and pulling it off is the only way it comes off.
class ExploreFilterBar extends StatelessWidget {
  const ExploreFilterBar({
    super.key,
    required this.filters,
    required this.onOpenSheet,
    required this.onRemove,
    this.height = 34,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.screenEdge,
    ),
  });

  final ExploreFilters filters;
  final VoidCallback onOpenSheet;
  final ValueChanged<ExploreFilterTag> onRemove;
  final double height;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tags = filters.tags;

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: tags.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _FilterButton(
              count: filters.activeCount,
              onTap: onOpenSheet,
              height: height,
              label: l10n.filterOpen,
            );
          }

          final tag = tags[index - 1];
          final label = filterTagLabel(l10n, tag);
          return Semantics(
            label: l10n.filterRemove(label),
            button: true,
            child: TagChip(
              label: label,
              selected: true,
              onDeleted: () => onRemove(tag),
            ),
          );
        },
      ),
    );
  }
}

/// Opens the one filter surface. Carries the count so the row still reports
/// how much is on even when the chips have scrolled out of view.
class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.count,
    required this.onTap,
    required this.height,
    required this.label,
  });

  final int count;
  final VoidCallback onTap;
  final double height;
  final String label;

  @override
  Widget build(BuildContext context) {
    final active = count > 0;

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: active ? AppColors.signal : AppColors.fillMuted,
        borderRadius: AppRadius.pillAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.pillAll,
          child: Container(
            height: height,
            padding: EdgeInsets.symmetric(horizontal: active ? 12 : 13),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.tune,
                  size: 16,
                  color: active ? AppColors.ink : AppColors.inkBody,
                ),
                if (active) ...[
                  const SizedBox(width: 6),
                  Text(
                    '$count',
                    style: AppTypography.body.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Two-column grid of cards, sized in height rather than aspect ratio so a
/// tile keeps the same proportions on every phone width.
class CocktailGrid extends StatelessWidget {
  const CocktailGrid({
    super.key,
    required this.children,
    this.spacing = 10,
  });

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    for (var i = 0; i < children.length; i += 2) {
      final left = children[i];
      final right = i + 1 < children.length ? children[i + 1] : null;

      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            SizedBox(width: spacing),
            Expanded(child: right ?? const SizedBox.shrink()),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final (index, row) in rows.indexed) ...[
          if (index > 0) SizedBox(height: spacing),
          row,
        ],
      ],
    );
  }
}
