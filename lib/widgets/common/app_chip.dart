import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// The status a chip reports. Drives colour — never pick the colour directly.
enum ChipTone { neutral, signal, ready, low }

extension on ChipTone {
  Color get foreground => switch (this) {
    ChipTone.neutral => AppColors.inkBody,
    ChipTone.signal => AppColors.signalLight,
    ChipTone.ready => AppColors.ready,
    ChipTone.low => AppColors.low,
  };

  Color get background => switch (this) {
    ChipTone.neutral => AppColors.fillMuted,
    ChipTone.signal => AppColors.signalWash,
    ChipTone.ready => AppColors.readyWash,
    ChipTone.low => AppColors.lowWash,
  };
}

/// Small uppercase status pill — SERVED, LOW, LIVE.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.tone = ChipTone.neutral,
    this.icon,
  });

  final String label;
  final ChipTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(icon == null ? 11 : 8, 6, 11, 6),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: tone.foreground),
            const SizedBox(width: 6),
          ],
          // A chip states a status; it must not push the row it sits in off
          // the screen because the status has a long name.
          Flexible(
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label.copyWith(color: tone.foreground),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pulsing dot + label used for anything happening right now.
class LiveChip extends StatelessWidget {
  const LiveChip({super.key, required this.label, this.onGlass = true});

  final String label;
  final bool onGlass;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
      decoration: BoxDecoration(
        color: onGlass ? AppColors.glass : AppColors.fillStrong,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.signal,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.signal, blurRadius: 8),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tag chip for taxonomy — flavour, method, category.
///
/// Taxonomy carries no colour of its own: identity comes from the icon and
/// label, and only selection promotes a chip to the accent.
class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
    this.onDeleted,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.signalLight : AppColors.inkBody;

    return Material(
      color: selected ? AppColors.signalWash : AppColors.fillMuted,
      borderRadius: AppRadius.pillAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.pillAll,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            icon == null ? 14 : 10,
            9,
            onDeleted == null ? 14 : 8,
            9,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: foreground),
                const SizedBox(width: 7),
              ],
              Text(
                label,
                style: AppTypography.body.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                  color: foreground,
                ),
              ),
              if (onDeleted != null) ...[
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: onDeleted,
                  child: Icon(Icons.close, size: 15, color: foreground),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
