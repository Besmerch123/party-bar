import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'glass.dart';

class AppNavDestination {
  const AppNavDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// Floating glass pill navigation. The active destination expands to carry its
/// label; the rest stay icon-only so the photography underneath keeps breathing.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final List<AppNavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  static const double height = AppSizes.navBar;

  /// Bottom padding a scrolling screen must reserve so its last item clears
  /// the floating bar instead of sliding under it.
  static double insetOf(BuildContext context) =>
      height + MediaQuery.paddingOf(context).bottom + AppSpacing.sm * 2;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        0,
        AppSpacing.screenEdge,
        MediaQuery.paddingOf(context).bottom + AppSpacing.sm,
      ),
      child: SizedBox(
        height: height,
        child: GlassSurface(
          color: AppColors.glassNav,
          stroke: AppColors.glassStroke,
          borderRadius: BorderRadius.circular(height / 2),
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              for (final (index, destination) in destinations.indexed)
                _NavItem(
                  destination: destination,
                  selected: index == currentIndex,
                  onTap: () => onDestinationSelected(index),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final AppNavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final content = AnimatedContainer(
      duration: AppMotion.tap,
      curve: AppMotion.curve,
      height: double.infinity,
      decoration: BoxDecoration(
        color: selected ? AppColors.glass : Colors.transparent,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            selected ? destination.activeIcon : destination.icon,
            size: 21,
            color: selected ? AppColors.ink : AppColors.inkMeta,
          ),
          if (selected) ...[
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.clip,
                softWrap: false,
                style: AppTypography.body.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return Expanded(
      flex: selected ? 3 : 2,
      child: Semantics(
        selected: selected,
        button: true,
        label: destination.label,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.pillAll,
            child: content,
          ),
        ),
      ),
    );
  }
}
