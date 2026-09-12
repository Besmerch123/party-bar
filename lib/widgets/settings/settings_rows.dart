import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// The grouped-row look every Flow 09 screen shares: a stack of rows on a
/// hairline background, so a 1px gap reads as a divider without either row
/// needing to know about the one next to it.
class SettingsRowGroup extends StatelessWidget {
  const SettingsRowGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.tileAll,
      child: Column(
        children: [
          for (final (i, child) in children.indexed) ...[
            if (i > 0) const SizedBox(height: 1),
            child,
          ],
        ],
      ),
    );
  }
}

/// One row inside a [SettingsRowGroup] — an icon, a label, an optional value
/// on the trailing edge, and a chevron only when it actually goes somewhere.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.iconColor,
    this.labelColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Color? iconColor;
  final Color? labelColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.sheet,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: iconColor ?? AppColors.inkMeta,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.cardTitle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: labelColor ?? AppColors.ink.withValues(alpha: .85),
                  ),
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    value!,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.meta.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink.withValues(alpha: .4),
                    ),
                  ),
                ),
              ],
              if (onTap != null) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 19,
                  color: AppColors.inkGhost,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A row that carries a switch instead of a chevron — Flow 09 screen 06.
class SettingsToggleRow extends StatelessWidget {
  const SettingsToggleRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.dim = false,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  /// The row still shows what it is for, but greyed — the drink-ready row
  /// while notifications are off at the OS level, say.
  final bool dim;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.sheet,
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.cardTitle.copyWith(
                        color: dim
                            ? AppColors.ink.withValues(alpha: .7)
                            : AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTypography.meta.copyWith(
                        fontSize: 11.5,
                        color: AppColors.inkMeta,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.signal,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: AppColors.fillStrong,
                trackOutlineColor: const WidgetStatePropertyAll(
                  Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The same static note as [SettingsInfoRow], shaped to sit inside a
/// [SettingsRowGroup] instead of standing as its own card.
class SettingsInfoRowGroupItem extends StatelessWidget {
  const SettingsInfoRowGroupItem({
    super.key,
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.sheet,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.ink.withValues(alpha: .4)),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                text,
                style: AppTypography.meta.copyWith(
                  fontSize: 11.5,
                  height: 1.5,
                  color: AppColors.ink.withValues(alpha: .55),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A short line of static, non-interactive context — the "dashes never
/// convert" and "a party has no language" notes every Flow 09 screen uses to
/// explain the edge it just drew.
class SettingsInfoRow extends StatelessWidget {
  const SettingsInfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.color,
  });

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.sheet,
        borderRadius: AppRadius.tileAll,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: color ?? AppColors.ink.withValues(alpha: .4),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              text,
              style: AppTypography.meta.copyWith(
                fontSize: 11.5,
                height: 1.5,
                color: color ?? AppColors.ink.withValues(alpha: .5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
