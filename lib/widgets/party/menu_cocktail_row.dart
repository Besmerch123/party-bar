import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'menu_cocktail_tile.dart';

/// Rows in a menu list sit 1px apart and share one rounded outline: the
/// first row rounds its top, the last its bottom.
BorderRadius menuGroupRadius(int index, int count) {
  const big = Radius.circular(16);
  const small = Radius.circular(2);
  return BorderRadius.vertical(
    top: index == 0 ? big : small,
    bottom: index == count - 1 ? big : small,
  );
}

/// Flow 05 · screens 04 and 05 — a cocktail in a menu list: thumbnail, name,
/// a line of detail, an optional stock badge, and the add/picked circle.
class MenuCocktailRow extends StatelessWidget {
  const MenuCocktailRow({
    super.key,
    required this.name,
    required this.image,
    required this.picked,
    required this.semanticLabel,
    required this.onToggle,
    this.subtitle,
    this.subtitleColor,
    this.badge,
    this.emphasiseAdd = false,
    this.dimmed = false,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.thumbSize = 54,
  });

  final String name;
  final String? image;
  final bool picked;
  final String semanticLabel;
  final VoidCallback onToggle;
  final String? subtitle;
  final Color? subtitleColor;
  final Widget? badge;

  /// A white add circle — the one drink that needs nothing more.
  final bool emphasiseAdd;

  /// "Needs shopping" rows fade their photo and name back.
  final bool dimmed;
  final BorderRadius borderRadius;
  final double thumbSize;

  @override
  Widget build(BuildContext context) {
    final circle = thumbSize > 50 ? 38.0 : 36.0;
    final white = emphasiseAdd && !picked;

    return Semantics(
      button: true,
      selected: picked,
      label: semanticLabel,
      excludeSemantics: true,
      child: Material(
        color: AppColors.row,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onToggle,
          borderRadius: borderRadius,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: thumbSize > 50 ? 13 : 12,
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(thumbSize > 50 ? 14 : 12),
                  child: SizedBox(
                    width: thumbSize,
                    height: thumbSize,
                    child: MenuCocktailImage(image: image, dimmed: dimmed),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.cardTitle.copyWith(
                          fontSize: thumbSize > 50 ? 14.5 : 14,
                          color: dimmed
                              ? AppColors.ink.withValues(alpha: .82)
                              : AppColors.ink,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 5),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.meta.copyWith(
                            fontSize: 11.5,
                            height: 1.2,
                            fontWeight: subtitleColor == null
                                ? FontWeight.w500
                                : FontWeight.w600,
                            color:
                                subtitleColor ??
                                AppColors.ink.withValues(alpha: .5),
                          ),
                        ),
                      ],
                      if (badge != null) ...[
                        const SizedBox(height: 7),
                        badge!,
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 13),
                AnimatedContainer(
                  duration: AppMotion.tap,
                  width: circle,
                  height: circle,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: picked
                        ? AppColors.signal
                        : white
                        ? AppColors.ink
                        : AppColors.fillStrong,
                  ),
                  child: Icon(
                    picked ? Icons.check : Icons.add,
                    size: circle > 37 ? 20 : 19,
                    color: white ? AppColors.ground : AppColors.ink,
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

/// "NO CAMPARI", "MISSING 2", "ALL IN STOCK".
class MenuStockBadge extends StatelessWidget {
  const MenuStockBadge({super.key, required this.label, required this.ready});

  final String label;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    final tone = ready ? AppColors.ready : AppColors.low;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: ready ? AppColors.readyWash : AppColors.lowWash,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ready ? Icons.check : Icons.error, size: 13, color: tone),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label.copyWith(letterSpacing: 0, color: tone),
            ),
          ),
        ],
      ),
    );
  }
}
