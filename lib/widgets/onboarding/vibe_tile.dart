import 'package:flutter/material.dart';

import '../../models/onboarding.dart';
import '../../theme/theme.dart';

/// One flavour direction on step 04.
///
/// Vibes that have a photograph get one; the rest carry a glyph on a flat
/// fill rather than a stock image that says nothing.
class VibeTile extends StatelessWidget {
  const VibeTile({
    super.key,
    required this.vibe,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final DrinkVibe vibe;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const _height = 112.0;

  @override
  Widget build(BuildContext context) {
    final image = vibe.image;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          height: _height,
          child: ClipRRect(
            borderRadius: AppRadius.tileAll,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (image != null) ...[
                  Image.asset(image, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x000B0B0C), Color(0xCC0B0B0C)],
                        stops: [0.3, 1.0],
                      ),
                    ),
                  ),
                ] else
                  const ColoredBox(color: AppColors.row),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: image != null
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.spaceBetween,
                    children: [
                      if (vibe.icon != null)
                        Icon(vibe.icon, size: 22, color: AppColors.signalLight),
                      Text(
                        label,
                        style: AppTypography.cardTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (selected)
                  const Positioned(
                    top: 9,
                    right: 9,
                    child: _SelectedBadge(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedBadge extends StatelessWidget {
  const _SelectedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: AppColors.signal,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check, size: 15, color: AppColors.ink),
    );
  }
}
