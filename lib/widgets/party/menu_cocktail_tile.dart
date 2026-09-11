import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Flow 05 · screen 03 — a photo tile in the "from your bar" grid.
///
/// Picked tiles carry a signal ring and a filled check; unpicked ones a
/// glass plus. The whole tile toggles.
class MenuCocktailTile extends StatelessWidget {
  const MenuCocktailTile({
    super.key,
    required this.name,
    required this.image,
    required this.picked,
    required this.semanticLabel,
    required this.onTap,
    this.height = 172,
  });

  final String name;
  final String? image;
  final bool picked;
  final String semanticLabel;
  final VoidCallback onTap;
  final double height;

  static const _radius = BorderRadius.all(Radius.circular(18));

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: picked,
      label: semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: ClipRRect(
            borderRadius: _radius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MenuCocktailImage(image: image),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x000B0B0C), Color(0xCC0B0B0C)],
                      stops: [0.4, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  left: 11,
                  right: 11,
                  bottom: 11,
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.cardTitle.copyWith(color: AppColors.ink),
                  ),
                ),
                Positioned(
                  top: 9,
                  right: 9,
                  child: AnimatedContainer(
                    duration: AppMotion.tap,
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: picked
                          ? AppColors.signal
                          : AppColors.ground.withValues(alpha: .55),
                    ),
                    child: Icon(
                      picked ? Icons.check : Icons.add,
                      size: 17,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                if (picked)
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: _radius,
                      border: Border.fromBorderSide(
                        BorderSide(color: AppColors.signal, width: 2.5),
                      ),
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

/// A cocktail photo that never shows a spinner or a grey hole — a missing
/// picture reads as part of the same dark room.
class MenuCocktailImage extends StatelessWidget {
  const MenuCocktailImage({super.key, required this.image, this.dimmed = false});

  final String? image;

  /// The "needs shopping" rows fade their photo back.
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    const fallback = ColoredBox(
      color: AppColors.row,
      child: Center(
        child: Icon(Icons.local_bar, size: 22, color: AppColors.inkMeta),
      ),
    );

    if (image == null || image!.isEmpty) return fallback;

    final picture = Image.network(
      image!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => fallback,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : fallback,
    );

    return dimmed ? Opacity(opacity: .65, child: picture) : picture;
  }
}
