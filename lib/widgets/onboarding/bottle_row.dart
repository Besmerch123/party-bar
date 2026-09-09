import 'package:flutter/material.dart';

import '../../models/onboarding.dart';
import '../../theme/theme.dart';

/// One shelf item on step 05.
///
/// The subtitle is the row's whole argument: normally how many cocktails the
/// bottle appears in, but the single best addition says what it unlocks
/// instead, in the accent, so one row stands out without shouting.
class BottleRow extends StatelessWidget {
  const BottleRow({
    super.key,
    required this.bottle,
    required this.name,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.highlighted = false,
  });

  final StarterBottle bottle;
  final String name;
  final String subtitle;
  final bool selected;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final image = bottle.image;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: AppColors.row,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 34,
                  height: 34,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: image != null
                        ? Image.asset(image, fit: BoxFit.cover)
                        : ColoredBox(
                            color: AppColors.fillMuted,
                            child: Icon(
                              bottle.icon,
                              size: 18,
                              color: AppColors.signalLight,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: AppTypography.cardTitle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: AppTypography.meta.copyWith(
                          fontSize: 11.5,
                          height: 1.0,
                          color: highlighted
                              ? AppColors.signalLight
                              : AppColors.inkMeta,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.signal : AppColors.fillStrong,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    selected ? Icons.check : Icons.add,
                    size: 19,
                    color: selected ? AppColors.ink : AppColors.inkBody,
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
