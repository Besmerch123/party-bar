import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// The one row every Flow 04 · My bar screen builds a list from — the empty
/// shelf's starters, a search result, a stocked bottle, a ran-out item, a
/// shopping-list entry. They differ only in thumbnail, colour and trailing
/// glyph, all of which the caller decides; this file just keeps the shape —
/// padding, radii, type sizes — the same everywhere it appears.

/// How [BarThumb] tints itself when it has no photo to show.
enum BarThumbTone { neutral, ready, low }

/// The 44px square a row leads with. A photo always wins; short of one, the
/// icon sits on a tinted disc that reports status at a glance — plain for
/// something not yet judged, green for "already yours", amber for "running
/// low on what it needs".
class BarThumb extends StatelessWidget {
  const BarThumb({
    super.key,
    this.image,
    required this.icon,
    this.tone = BarThumbTone.neutral,
    this.checked = false,
    this.size = 44,
  });

  /// `assets/...` renders with [Image.asset]; anything else is a network URL.
  final String? image;

  final IconData icon;
  final BarThumbTone tone;

  /// Forces the green "already on your shelf" check, in place of [icon] —
  /// the empty shelf and search results use this so status reads from the
  /// thumbnail itself rather than a badge fighting for the same 44px.
  final bool checked;

  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = size * (13 / 44);
    final borderRadius = BorderRadius.circular(radius);
    final hasImage = image != null && image!.isNotEmpty;

    if (hasImage) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: SizedBox(
          width: size,
          height: size,
          child: _BarThumbImage(image: image!, fallbackIcon: icon),
        ),
      );
    }

    final (Color background, Color iconColor, IconData glyph) = checked
        ? (AppColors.readyWash, AppColors.ready, Icons.check)
        : switch (tone) {
            BarThumbTone.neutral => (
              AppColors.fillSubtle,
              AppColors.signalLight,
              icon,
            ),
            BarThumbTone.ready => (AppColors.readyWash, AppColors.ready, icon),
            BarThumbTone.low => (AppColors.lowWash, AppColors.low, icon),
          };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, borderRadius: borderRadius),
      child: Icon(glyph, size: size * (22 / 44), color: iconColor),
    );
  }
}

class _BarThumbImage extends StatelessWidget {
  const _BarThumbImage({required this.image, required this.fallbackIcon});

  final String image;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    Widget errorBuilder(BuildContext context, Object error, StackTrace? stack) {
      return ColoredBox(
        color: AppColors.fillSubtle,
        child: Center(
          child: Icon(fallbackIcon, size: 22, color: AppColors.signalLight),
        ),
      );
    }

    if (image.startsWith('assets/')) {
      return Image.asset(image, fit: BoxFit.cover, errorBuilder: errorBuilder);
    }
    return Image.network(image, fit: BoxFit.cover, errorBuilder: errorBuilder);
  }
}

/// A tappable row: thumbnail, a title (or highlighted [titleSpan]), an
/// optional subtitle, an optional trailing widget.
///
/// [background] is [AppColors.sheet] on a plain screen and [AppColors.row]
/// inside a bottom sheet — the two surfaces the design ever puts a row on.
/// Nothing here takes a fixed height: a long title still ellipsizes on its
/// own line, but the row is free to grow with a taller subtitle or a bumped
/// text scale rather than clipping either one.
class BarRow extends StatelessWidget {
  const BarRow({
    super.key,
    required this.leading,
    required this.title,
    this.titleSpan,
    this.titleColor,
    this.titleDecoration,
    this.subtitle,
    this.subtitleColor,
    this.trailing,
    this.onTap,
    this.background = AppColors.sheet,
    this.outline,
    this.semanticsLabel,
  });

  final Widget leading;

  /// Always present, even when [titleSpan] renders instead — it is what
  /// [semanticsLabel] falls back to and what a11y tooling reads.
  final String title;

  /// Overrides the plain [title] text with rich spans — the search screen's
  /// way of colouring the part of the name that matched.
  final InlineSpan? titleSpan;

  final Color? titleColor;
  final TextDecoration? titleDecoration;
  final String? subtitle;
  final Color? subtitleColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color background;

  /// A ring around the row — the focused search-field-adjacent state some
  /// callers want; null paints no border.
  final Color? outline;

  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  titleSpan ?? TextSpan(text: title),
                  style: AppTypography.cardTitle.copyWith(
                    fontSize: 14.5,
                    letterSpacing: -0.1,
                    color: titleColor ?? AppColors.ink,
                    decoration: titleDecoration,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.meta.copyWith(
                      fontSize: 11.5,
                      color: subtitleColor ?? AppColors.inkMeta,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            // Loose, not tight: a text-based trailing action (the "Add to
            // list" pill) still has to give way to the title at a small
            // width and a bumped text scale, the same way the title gives
            // way to it the rest of the time. Align right so it hugs the
            // row's edge instead of centering in whatever flex space it's
            // handed.
            Flexible(
              child: Align(alignment: Alignment.centerRight, child: trailing!),
            ),
          ],
        ],
      ),
    );

    final decorated = Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.tileAll,
        border: outline != null ? Border.all(color: outline!, width: 1.5) : null,
      ),
      child: content,
    );

    return Semantics(
      button: onTap != null,
      label: semanticsLabel ?? title,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.tileAll,
          child: decorated,
        ),
      ),
    );
  }
}

/// The five looks a row's trailing action circle takes, from the design's
/// own vocabulary rather than a generic "selected/unselected" pair.
enum BarActionTone { neutral, primary, ready, dim, low }

/// The 44px circle that ends most rows — add, check, remove, restock.
class BarActionCircle extends StatelessWidget {
  const BarActionCircle({
    super.key,
    required this.icon,
    this.tone = BarActionTone.neutral,
    this.onTap,
    required this.semanticsLabel,
  });

  final IconData icon;
  final BarActionTone tone;
  final VoidCallback? onTap;
  final String semanticsLabel;

  static const double _size = AppSizes.minTap;

  @override
  Widget build(BuildContext context) {
    final (Color background, Color iconColor) = switch (tone) {
      BarActionTone.neutral => (AppColors.fillStrong, AppColors.ink),
      BarActionTone.primary => (Colors.white, AppColors.ground),
      BarActionTone.ready => (AppColors.readyWash, AppColors.ready),
      BarActionTone.dim => (AppColors.fillSubtle, AppColors.inkMeta),
      BarActionTone.low => (AppColors.low, AppColors.ground),
    };

    return Semantics(
      button: onTap != null,
      label: semanticsLabel,
      child: Material(
        type: MaterialType.transparency,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(color: background, shape: BoxShape.circle),
            child: Icon(icon, size: 22, color: iconColor),
          ),
        ),
      ),
    );
  }
}

/// The amber "Add to list" pill a ran-out row offers instead of a plain
/// circle, when the row has more to say than a glyph can carry alone.
class BarPillAction extends StatelessWidget {
  const BarPillAction({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: label,
      child: Material(
        color: AppColors.lowWash,
        borderRadius: AppRadius.pillAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.pillAll,
          child: Container(
            constraints: const BoxConstraints(minHeight: AppSizes.minTap),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            child: Text(
              label,
              style: AppTypography.meta.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.low,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

/// "SPIRITS & LIQUEURS · 9" — an eyebrow over a run of rows, with an optional
/// link on the right such as "Add all to list".
class BarGroupHeader extends StatelessWidget {
  const BarGroupHeader({
    super.key,
    required this.label,
    this.color = AppColors.inkMeta,
    this.actionLabel,
    this.onAction,
  });

  final String label;
  final Color color;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label.toUpperCase(),
      style: AppTypography.label.copyWith(color: color),
    );

    final actionLabel = this.actionLabel;
    final onAction = this.onAction;
    if (actionLabel == null || onAction == null) return text;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(child: text),
        const SizedBox(width: AppSpacing.sm),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            actionLabel,
            style: AppTypography.body.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.signalLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
