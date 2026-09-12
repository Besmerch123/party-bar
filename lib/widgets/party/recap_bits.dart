import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../common/glass.dart';
import 'menu_cocktail_tile.dart';

/// Flow 08 — the pieces the recap, the history and the guest's night are all
/// drawn from. One number and its label, a drink and how many went out, and
/// the two cards that hang the night's leftovers off the recap.

/// One number the host earned, under a word saying what it is. No score, no
/// streak: a quiet night has to read as a quiet night.
class RecapStat extends StatelessWidget {
  const RecapStat({
    super.key,
    required this.value,
    required this.label,
    this.accent = false,
    this.mono = false,
    this.background = AppColors.sheet,
    this.valueSize = 30,
  });

  final String value;
  final String label;

  /// The first tile in a row — the one number the night is actually about.
  final bool accent;

  /// Space Mono, for a value that is a measure rather than a count.
  final bool mono;

  final Color background;
  final double valueSize;

  @override
  Widget build(BuildContext context) {
    final color = accent ? AppColors.signalLight : AppColors.ink;
    final style = mono
        ? AppTypography.measure.copyWith(
            fontSize: valueSize,
            fontWeight: FontWeight.w800,
            height: 1,
            color: color,
          )
        : AppTypography.heading.copyWith(
            fontSize: valueSize,
            height: 1,
            letterSpacing: -valueSize * .03,
            color: color,
          );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: style),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.meta.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: AppColors.ink.withValues(alpha: .5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Equal tiles across the width, all as tall as the tallest — a label that
/// wraps at 1.5x text must not leave its neighbours short. [IntrinsicHeight]
/// is what makes that work inside a scrolling column, where the row's own
/// height is unbounded and a bare stretch would ask for infinity.
class RecapStatRow extends StatelessWidget {
  const RecapStatRow({super.key, required this.stats, this.gap = 12});

  final List<RecapStat> stats;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, stat) in stats.indexed) ...[
            if (index > 0) SizedBox(width: gap),
            Expanded(child: stat),
          ],
        ],
      ),
    );
  }
}

/// "Cosmopolitan — 12", with a bar as wide as its share of the busiest
/// drink. A [share] of null draws no bar at all: one drink is not a chart.
class DrinkTallyRow extends StatelessWidget {
  const DrinkTallyRow({
    super.key,
    required this.name,
    required this.image,
    required this.count,
    required this.share,
    this.leader = false,
  });

  final String name;
  final String? image;
  final int count;

  /// 0..1, or null to leave the bar off.
  final double? share;

  /// The busiest drink of the night gets the solid accent.
  final bool leader;

  @override
  Widget build(BuildContext context) {
    final fraction = share;

    return Semantics(
      label: '$name, $count',
      excludeSemantics: true,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: SizedBox(
              width: 44,
              height: 44,
              child: MenuCocktailImage(image: image),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.cardTitle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$count',
                      style: AppTypography.measure.copyWith(
                        fontSize: 12,
                        color: leader
                            ? AppColors.signalLight
                            : AppColors.inkBody,
                      ),
                    ),
                  ],
                ),
                if (fraction != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: fraction.clamp(0.0, 1.0),
                      minHeight: 5,
                      backgroundColor: AppColors.fillStrong,
                      valueColor: AlwaysStoppedAnimation(
                        leader
                            ? AppColors.signal
                            : AppColors.signalLight.withValues(alpha: .55),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One of the things the night leaves behind — a card with an icon chip,
/// what it is, and a line of why it is worth tapping.
class RecapActionCard extends StatelessWidget {
  const RecapActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.tone = AppColors.signalLight,
    this.wash = AppColors.signalWash,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color tone;
  final Color wash;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      excludeSemantics: true,
      child: Material(
        color: AppColors.sheet,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: wash,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, size: 18, color: tone),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: AppTypography.cardTitle.copyWith(
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.meta.copyWith(
                    fontSize: 11.5,
                    height: 1.3,
                    color: AppColors.inkMeta,
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

/// The night at the top of the history: a photo card carrying its own chip,
/// name and numbers.
class NightHeroCard extends StatelessWidget {
  const NightHeroCard({
    super.key,
    required this.badge,
    required this.title,
    required this.drinks,
    required this.meta,
    required this.image,
    required this.onTap,
  });

  final String badge;
  final String title;

  /// "31 DRINKS" — the one thing on the card set in Space Mono.
  final String drinks;

  /// "9 guests", "4 Sep".
  final List<String> meta;

  final String? image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = '$title. $drinks, ${meta.join(', ')}';

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: AppColors.row,
        borderRadius: AppRadius.cardAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 168,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MenuCocktailImage(image: image),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x260B0B0C), Color(0xE00B0B0C)],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GlassSurface(
                        color: AppColors.glass,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: Text(
                          badge.toUpperCase(),
                          style: AppTypography.label.copyWith(fontSize: 9.5),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.heading.copyWith(
                          fontSize: 21,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          Text(
                            drinks.toUpperCase(),
                            style: AppTypography.measure.copyWith(
                              fontSize: 12,
                              color: AppColors.signalLight,
                            ),
                          ),
                          for (final part in meta) ...[
                            const _Dot(),
                            Flexible(
                              child: Text(
                                part,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.meta.copyWith(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink.withValues(alpha: .7),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
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

/// An older night, or the drink a guest's recap ends on: thumbnail, a line,
/// a quieter line, and something on the right.
class NightRow extends StatelessWidget {
  const NightRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.onTap,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final String? image;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: '$title. $subtitle',
      excludeSemantics: true,
      child: Material(
        color: AppColors.sheet,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: MenuCocktailImage(image: image),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.cardTitle.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.meta.copyWith(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkMeta,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                trailing ??
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.inkGhost,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: AppColors.ink.withValues(alpha: .4),
        shape: BoxShape.circle,
      ),
    );
  }
}
