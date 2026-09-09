import 'package:flutter/material.dart';

import '../../generated/l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../theme/theme.dart';
import '../common/app_chip.dart';
import '../../utils/cocktail_labels.dart';
import '../../utils/localization_helper.dart';

/// The three shapes a cocktail takes in Explore.
///
/// A poster owns a section, a tile sits in the grid, a row carries a list.
/// They differ in size, not in what they say: every one of them reports the
/// same shelf verdict in the same place, so scanning down a feed never means
/// re-learning where to look.

/// How a card reports the shelf. Passing null says "we do not know yet" — and
/// the card then says nothing rather than implying the drink is out of reach.
class ShelfStatus {
  const ShelfStatus({required this.makeability, this.missingName});

  final Makeability makeability;

  /// The name of the single missing ingredient, already translated. Only used
  /// when the drink is exactly one bottle short.
  final String? missingName;

  bool get isKnown => makeability.requiredCount > 0;
  bool get isMakeable => makeability.isMakeable;
}

/// Section-owning card with a photo, the shelf verdict, and the meta line.
class CocktailPosterCard extends StatelessWidget {
  const CocktailPosterCard({
    super.key,
    required this.cocktail,
    this.status,
    this.onTap,
    this.height = 246,
  });

  final Cocktail cocktail;
  final ShelfStatus? status;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final meta = cocktailMeta(l10n, cocktail);

    return _PhotoCard(
      image: cocktail.image,
      height: height,
      radius: AppRadius.card,
      onTap: onTap,
      semanticLabel: cocktail.title.translate(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (status?.isKnown ?? false)
            _ShelfBadge(status: status!, l10n: l10n)
          else
            const SizedBox.shrink(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                cocktail.title.translate(context),
                style: AppTypography.heading,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (meta.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs + 2),
                Text(meta, style: AppTypography.measure.copyWith(fontSize: 12)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Grid tile. Half the width of a poster and a quarter of the words.
class CocktailTile extends StatelessWidget {
  const CocktailTile({
    super.key,
    required this.cocktail,
    this.status,
    this.onTap,
    this.height = 194,
    this.showMeta = true,
  });

  final Cocktail cocktail;
  final ShelfStatus? status;
  final VoidCallback? onTap;
  final double height;

  /// The zero-results fallback grid drops the meta line — there the drinks are
  /// a consolation, not a comparison.
  final bool showMeta;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = this.status;
    final subtitle = _subtitle(l10n);

    return _PhotoCard(
      image: cocktail.image,
      height: height,
      radius: AppRadius.tile,
      onTap: onTap,
      semanticLabel: cocktail.title.translate(context),
      overlays: [
        if (status != null && status.isKnown && status.isMakeable)
          const Positioned(top: 10, right: 10, child: _MakeableDot()),
        if (status != null && status.isKnown && !status.isMakeable)
          Positioned(
            top: 10,
            left: 10,
            child: StatusChip(
              label: l10n.exploreMissingBadge(status.makeability.missingCount),
              tone: ChipTone.low,
            ),
          ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            cocktail.title.translate(context),
            style: AppTypography.section,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (showMeta && subtitle.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: AppTypography.measure.copyWith(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  /// What is missing beats how long it takes: on a tile one bottle short, the
  /// bottle is the only thing worth the line.
  String _subtitle(AppLocalizations l10n) {
    final missingName = status?.missingName;
    if (status != null && status!.makeability.isOneAway && missingName != null) {
      return l10n.exploreNeedsIngredient(missingName);
    }
    return cocktailMeta(l10n, cocktail, includeAbv: false);
  }
}

/// List row — thumbnail, name, one line of detail, and a trailing verdict.
class CocktailListRow extends StatelessWidget {
  const CocktailListRow({
    super.key,
    required this.cocktail,
    this.status,
    this.onTap,
    this.subtitle,
    this.trailing,
  });

  final Cocktail cocktail;
  final ShelfStatus? status;
  final VoidCallback? onTap;

  /// Overrides the derived line. The near-miss list uses it to say what the
  /// missing bottle would unlock.
  final String? subtitle;

  /// Overrides the derived trailing widget.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = this.status;
    final unmakeable = status != null && status.isKnown && !status.isMakeable;
    final line = subtitle ?? _derivedSubtitle(l10n);

    final row = Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.sheet,
        borderRadius: AppRadius.tileAll,
      ),
      child: Row(
        children: [
          _Thumbnail(image: cocktail.image),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  cocktail.title.translate(context),
                  style: AppTypography.cardTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (line.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    line,
                    style: AppTypography.meta.copyWith(
                      fontSize: 12,
                      height: 1.2,
                      color: unmakeable ? AppColors.low : AppColors.inkMeta,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ] else if (status != null && status.isKnown) ...[
            const SizedBox(width: AppSpacing.sm),
            Icon(
              status.isMakeable ? Icons.check_circle : Icons.add_shopping_cart,
              size: 18,
              color: status.isMakeable ? AppColors.ready : AppColors.low,
            ),
          ],
        ],
      ),
    );

    return Semantics(
      button: onTap != null,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.tileAll,
          // Dimming, not greying: the drink is still readable, just clearly
          // not tonight's.
          child: Opacity(opacity: unmakeable && trailing == null ? .62 : 1, child: row),
        ),
      ),
    );
  }

  String _derivedSubtitle(AppLocalizations l10n) {
    final missingName = status?.missingName;
    if (status != null && status!.makeability.isOneAway && missingName != null) {
      return l10n.exploreNeedsIngredient(missingName);
    }
    return cocktailMeta(l10n, cocktail, includeAbv: false);
  }
}

/// Photo, scrim, content — the one construction every card shares.
class _PhotoCard extends StatelessWidget {
  const _PhotoCard({
    required this.image,
    required this.height,
    required this.radius,
    required this.child,
    this.onTap,
    this.overlays = const [],
    this.semanticLabel,
  });

  final String? image;
  final double height;
  final double radius;
  final Widget child;
  final VoidCallback? onTap;
  final List<Widget> overlays;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);

    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: SizedBox(
            height: height,
            child: ClipRRect(
              borderRadius: borderRadius,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _CardImage(image: image),
                  const DecoratedBox(
                    decoration: BoxDecoration(gradient: _cardScrim),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm + 2),
                    child: child,
                  ),
                  ...overlays,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lighter than the full-screen photo scrim: a card only has to carry two
/// lines at its foot, so the top stays as photographic as possible.
const _cardScrim = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0x400B0B0C), Color(0x000B0B0C), Color(0xD90B0B0C)],
  stops: [0.0, 0.36, 1.0],
);

class _CardImage extends StatelessWidget {
  const _CardImage({required this.image});

  final String? image;

  @override
  Widget build(BuildContext context) {
    if (image == null || image!.isEmpty) return const _CardImageFallback();

    return Image.network(
      image!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => const _CardImageFallback(),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const _CardImageFallback(),
    );
  }
}

/// Never a spinner and never grey: a missing photo should read as part of the
/// same dark room, not as a hole in it.
class _CardImageFallback extends StatelessWidget {
  const _CardImageFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.row,
      child: Center(
        child: Icon(Icons.local_bar, size: 34, color: AppColors.inkMeta),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.image});

  final String? image;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 52,
        height: 52,
        child: _CardImage(image: image),
      ),
    );
  }
}

/// "4 on your shelf" / "1 missing", in the poster's own voice.
class _ShelfBadge extends StatelessWidget {
  const _ShelfBadge({required this.status, required this.l10n});

  final ShelfStatus status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (status.isMakeable) {
      return StatusChip(
        label: l10n.exploreAllOnShelf(status.makeability.requiredCount),
        tone: ChipTone.ready,
        icon: Icons.circle,
      );
    }

    return StatusChip(
      label: l10n.exploreMissingBadge(status.makeability.missingCount),
      tone: ChipTone.low,
    );
  }
}

/// The quietest possible "yes" — a tick on the corner of a tile.
class _MakeableDot extends StatelessWidget {
  const _MakeableDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: Color(0x800B0B0C),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check, size: 14, color: AppColors.ready),
    );
  }
}
