import 'package:flutter/material.dart';

import '../../../models/models.dart';
import '../../../theme/theme.dart';
import '../../../utils/localization_helper.dart';

/// Flow 06 · "the buzz" — this app sends no push notification; instead a
/// ready order (or one whose [CocktailOrder.buzzedAt] moved) fires a heavy
/// haptic and this in-app banner, styled like the system notification card
/// design 06 draws (which is never built — the OS renders the real thing).
///
/// Auto-hides itself; a tap calls [onTap] and dismisses immediately.
class BuzzBanner extends StatefulWidget {
  const BuzzBanner({
    super.key,
    required this.order,
    required this.cocktail,
    required this.party,
    required this.nextUp,
    required this.onTap,
    required this.onDismissed,
  });

  final CocktailOrder order;
  final Cocktail? cocktail;
  final Party party;

  /// Another round drink still coming, named in the second clause — null
  /// when this was the last one.
  final Cocktail? nextUp;

  final VoidCallback onTap;
  final VoidCallback onDismissed;

  @override
  State<BuzzBanner> createState() => _BuzzBannerState();
}

class _BuzzBannerState extends State<BuzzBanner> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) widget.onDismissed();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final drinkName = widget.cocktail?.title.translate(context) ?? widget.order.cocktailId;
    final headline = widget.order.isForFriend
        ? l10n.roundBuzzReadyFriend(widget.order.forName!, drinkName)
        : l10n.roundBuzzReadyMine(drinkName);

    var body = l10n.roundBuzzBody(widget.party.name);
    if (widget.nextUp != null) {
      body = '$body ${l10n.roundBuzzNextUp(widget.nextUp!.title.translate(context))}';
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: const Color(0xB81C1C20),
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [BoxShadow(color: Color(0x4D000000), blurRadius: 24, offset: Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(color: AppColors.signal, borderRadius: BorderRadius.circular(6)),
                        child: const Icon(Icons.local_bar, size: 14, color: AppColors.ink),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'PARTYBAR',
                          style: AppTypography.label.copyWith(letterSpacing: .4),
                        ),
                      ),
                      Text(l10n.roundBuzzNow, style: AppTypography.caption),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    headline,
                    style: AppTypography.cardTitle.copyWith(fontSize: 15, letterSpacing: -.2),
                  ),
                  const SizedBox(height: 6),
                  Text(body, style: AppTypography.body.copyWith(fontSize: 13, color: AppColors.inkBody)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
