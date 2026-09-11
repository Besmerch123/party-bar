import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Flow 05 · screens 03 and 05 — a filter pill: white when on, a quiet fill
/// when off. Without [onTap] it only states the filter in force.
class HostFilterPill extends StatelessWidget {
  const HostFilterPill({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ink = selected ? AppColors.ground : AppColors.ink.withValues(alpha: .6);

    return Semantics(
      button: onTap != null,
      selected: selected,
      child: Material(
        color: selected ? AppColors.ink : AppColors.fillMuted,
        borderRadius: AppRadius.pillAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.pillAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 15, color: ink),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: AppTypography.cardTitle.copyWith(
                    fontSize: 12,
                    height: 1.0,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: ink,
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
