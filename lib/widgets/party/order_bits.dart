import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'menu_cocktail_tile.dart';

/// Flow 06 — the small pieces both phones draw an order with.

/// The pale blue text sits on a signal wash in ("MIXING NOW", a note).
const kSignalPale = Color(0xFFC9D7FF);

/// The pale green text sits on a ready wash in.
const kReadyPale = Color(0xFF9DE9BE);

/// The fill behind somebody else's initial.
const kInitialFill = Color(0xFF3A3A40);

/// The quiet row fill for asides ("2 ahead of you", "Pocket it").
const kAsideFill = Color(0x0AFFFFFF);

/// "<1m", "4m", "1h 05m" — how long someone has waited. Never seconds, and
/// never "0m": "buzzed 0m ago" reads like a mistake.
String formatWait(Duration wait) {
  if (wait.isNegative) wait = Duration.zero;
  if (wait.inMinutes == 0) return '<1m';
  if (wait.inHours == 0) return '${wait.inMinutes}m';
  final minutes = wait.inMinutes.remainder(60).toString().padLeft(2, '0');
  return '${wait.inHours}h ${minutes}m';
}

/// "0:42", "12:05" — a running stopwatch.
String formatStopwatch(Duration elapsed) {
  if (elapsed.isNegative) elapsed = Duration.zero;
  final seconds = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '${elapsed.inMinutes}:$seconds';
}

/// The host's first name — "How Kate makes it" reads better than the full
/// name, and copy never falls back to a pronoun for the host.
String hostFirstName(String hostName) {
  final trimmed = hostName.trim();
  if (trimmed.isEmpty) return trimmed;
  return trimmed.split(RegExp(r'\s+')).first;
}

/// A round initial — signal for the person holding the phone (or the
/// sender, on the host's), grey for everyone else.
class GuestInitial extends StatelessWidget {
  const GuestInitial({
    super.key,
    required this.name,
    this.size = 22,
    this.highlighted = false,
  });

  final String name;
  final double size;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final initial = trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase();

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: highlighted ? AppColors.signal : kInitialFill,
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: AppTypography.cardTitle.copyWith(
          fontSize: size * .43,
          fontWeight: FontWeight.w800,
          height: 1,
          color: AppColors.ink,
        ),
      ),
    );
  }
}

/// A square cocktail photo with rounded corners.
class OrderThumb extends StatelessWidget {
  const OrderThumb({
    super.key,
    required this.image,
    this.size = 48,
    this.radius = 13,
    this.greyed = false,
  });

  final String? image;
  final double size;
  final double radius;

  /// A drink that is off — pulled, or nobody waiting on it.
  final bool greyed;

  static const _greyscale = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    Widget photo = MenuCocktailImage(image: image);
    if (greyed) {
      photo = Opacity(
        opacity: .5,
        child: ColorFiltered(colorFilter: _greyscale, child: photo),
      );
    }
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: photo,
      ),
    );
  }
}

/// The guest's note on a signal wash — "Heavy on the lime".
class OrderNoteChip extends StatelessWidget {
  const OrderNoteChip({super.key, required this.note, this.small = false});

  final String note;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 8 : 9, vertical: small ? 4 : 5),
      decoration: BoxDecoration(
        color: AppColors.signal.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(small ? 7 : 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit_note, size: small ? 12 : 13, color: AppColors.signalLight),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              note,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.meta.copyWith(
                fontSize: small ? 10.5 : 11,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: kSignalPale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// An aside on the quiet fill: an icon and a sentence.
class OrderAside extends StatelessWidget {
  const OrderAside({
    super.key,
    required this.icon,
    required this.child,
    this.iconColor = AppColors.inkMeta,
  });

  final IconData icon;
  final Widget child;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kAsideFill,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 11),
          Expanded(
            child: DefaultTextStyle.merge(
              style: AppTypography.meta.copyWith(
                fontSize: 12,
                height: 1.45,
                color: AppColors.ink.withValues(alpha: .5),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
