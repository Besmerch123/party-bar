import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'menu_cocktail_tile.dart';

/// Flow 08 · screen 03 — the image that goes to the group chat.
///
/// Two shapes, because a story and a square are two different places. Both
/// are laid out at a fixed logical size so what the host previews is exactly
/// what gets rasterised: the preview scales, the card does not.
enum ShareCardShape { story, square }

extension ShareCardSize on ShareCardShape {
  Size get logicalSize => switch (this) {
    ShareCardShape.story => const Size(360, 640),
    ShareCardShape.square => const Size(400, 400),
  };

  /// 3x gets a 1080-wide story out of a 360pt card — the size every chat app
  /// expects, without asking the phone to lay out a 1080pt widget.
  double get pixelRatio => switch (this) {
    ShareCardShape.story => 3,
    ShareCardShape.square => 2.7,
  };
}

/// What the card says. Everything optional here is a toggle the host had to
/// reach for — guest names never leave by accident.
class ShareCardData {
  const ShareCardData({
    required this.headline,
    required this.partyLine,
    required this.dateLine,
    required this.chips,
    required this.image,
    this.guestNames,
  });

  /// "31 drinks".
  final String headline;

  /// "Kate's Birthday · 9 people".
  final String partyLine;

  /// "Fri 4 Sep, until 01:24".
  final String dateLine;

  /// "Cosmopolitan ×12", and the average wait when that toggle is on.
  final List<String> chips;

  /// The busiest drink of the night carries the card.
  final String? image;

  /// Only when the host turned names on.
  final String? guestNames;
}

class ShareCard extends StatelessWidget {
  const ShareCard({super.key, required this.shape, required this.data});

  final ShareCardShape shape;
  final ShareCardData data;

  @override
  Widget build(BuildContext context) {
    final size = shape.logicalSize;
    final story = shape == ShareCardShape.story;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: ColoredBox(
        color: AppColors.ground,
        child: Stack(
          fit: StackFit.expand,
          children: [
            MenuCocktailImage(image: data.image),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x800B0B0C),
                    Color(0x260B0B0C),
                    Color(0xE00B0B0C),
                  ],
                  stops: [0.0, 0.38, 1.0],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PARTYBAR',
                    style: AppTypography.mono.copyWith(
                      fontSize: 9,
                      letterSpacing: 2,
                      color: AppColors.ink.withValues(alpha: .85),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    data.headline,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.heading.copyWith(
                      fontSize: story ? 27 : 30,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    '${data.partyLine}\n${data.dateLine}',
                    style: AppTypography.cardTitle.copyWith(
                      fontSize: 13,
                      height: 1.35,
                      color: AppColors.ink.withValues(alpha: .85),
                    ),
                  ),
                  if (data.guestNames case final names?) ...[
                    const SizedBox(height: 8),
                    Text(
                      names,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.meta.copyWith(
                        fontSize: 12,
                        height: 1.35,
                        color: AppColors.inkBody,
                      ),
                    ),
                  ],
                  if (data.chips.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final chip in data.chips) _CardChip(label: chip),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardChip extends StatelessWidget {
  const _CardChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.ink.withValues(alpha: .18),
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        label,
        style: AppTypography.cardTitle.copyWith(fontSize: 10.5),
      ),
    );
  }
}
