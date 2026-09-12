import 'package:flutter/material.dart';

import '../../../models/models.dart';
import '../../../providers/party_cocktails.dart';
import '../../../theme/theme.dart';
import '../../../utils/localization_helper.dart';
import '../../common/app_bottom_nav.dart';
import '../menu_cocktail_tile.dart';
import '../order_bits.dart' show hostFirstName;

/// Flow 06 — the Menu tab: the party's whole menu as photo tiles, each
/// carrying how many have already gone out tonight. Tapping one opens
/// screen 01. Loading and empty states stay calm — never a bare spinner.
class MenuTab extends StatelessWidget {
  const MenuTab({
    super.key,
    required this.party,
    required this.allOrders,
    required this.cocktails,
    required this.onTapCocktail,
  });

  final Party party;
  final List<CocktailOrder> allOrders;
  final PartyCocktails cocktails;
  final ValueChanged<Cocktail> onTapCocktail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ids = party.availableCocktailIds;

    if (ids.isEmpty) {
      return _Empty(title: l10n.roundMenuEmptyTitle, body: l10n.roundMenuEmptyBody(hostFirstName(party.hostName)));
    }

    final menu = cocktails.resolve(ids);
    if (menu.isEmpty && !cocktails.isSettled(ids)) {
      return _Empty(title: l10n.roundMenuLoading, body: null);
    }

    final ordered = orderedTonight(allOrders);

    return GridView.builder(
      // The tab has no app bar above it, so the grid clears the status bar
      // itself rather than sliding its first row under the clock.
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        MediaQuery.paddingOf(context).top + AppSpacing.md,
        AppSpacing.screenEdge,
        AppBottomNav.insetOf(context) + 70,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: .8,
      ),
      itemCount: menu.length,
      itemBuilder: (context, index) {
        final cocktail = menu[index];
        return _MenuGridTile(
          cocktail: cocktail,
          ordered: ordered[cocktail.id] ?? 0,
          onTap: () => onTapCocktail(cocktail),
        );
      },
    );
  }
}

class _MenuGridTile extends StatelessWidget {
  const _MenuGridTile({required this.cocktail, required this.ordered, required this.onTap});

  final Cocktail cocktail;
  final int ordered;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: AppRadius.tileAll,
        child: Stack(
          fit: StackFit.expand,
          children: [
            MenuCocktailImage(image: cocktail.image),
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
            if (ordered > 0)
              Positioned(
                top: 9,
                right: 9,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.readyWash, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    '×$ordered',
                    style: AppTypography.label.copyWith(fontSize: 9.5, letterSpacing: 0, color: AppColors.ready),
                  ),
                ),
              ),
            Positioned(
              left: 11,
              right: 11,
              bottom: 11,
              child: Text(
                cocktail.title.translate(context),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.cardTitle.copyWith(color: AppColors.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.title, required this.body});

  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_bar_outlined, size: 34, color: AppColors.inkGhost),
            const SizedBox(height: 14),
            Text(title, style: AppTypography.section, textAlign: TextAlign.center),
            if (body != null) ...[
              const SizedBox(height: 8),
              Text(body!, style: AppTypography.meta, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
