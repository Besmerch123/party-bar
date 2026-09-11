import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/cocktail_repository.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bar_provider.dart';
import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/cocktail_labels.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/bar/two_away_sheet.dart';
import '../../widgets/common/app_chip.dart';
import '../../widgets/common/glass.dart';
import '../../widgets/cocktails/auth_gate_sheet.dart';

/// The solo cocktail detail: a held photograph with a sheet risen over it.
///
/// There is no party attached here, so the primary action is making the
/// drink rather than ordering it — "Make it now" outranks "Add to a party"
/// the way it does on the card that led here.
class CocktailDetailsScreen extends StatefulWidget {
  const CocktailDetailsScreen({super.key, required this.cocktailId});

  final String cocktailId;

  @override
  State<CocktailDetailsScreen> createState() => _CocktailDetailsScreenState();
}

class _CocktailDetailsScreenState extends State<CocktailDetailsScreen> {
  final CocktailRepository _cocktailRepo = CocktailRepository();

  Cocktail? _cocktail;
  bool _isLoading = true;
  String? _errorMessage;

  // Purely a display toggle. An account-side saved list is separate work;
  // this only exists so a signed-in tap does not look like it did nothing.
  bool _bookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadCocktail();
  }

  Future<void> _loadCocktail() async {
    if (_cocktail == null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final fetched = await _cocktailRepo.getCocktail(widget.cocktailId);

      if (fetched == null) {
        setState(() {
          // The repository swallows its own fetch failures and returns null
          // either way, so a missing document and a dropped connection look
          // identical from here — retry is the only honest recovery either
          // one offers.
          _errorMessage = 'This cocktail could not be loaded.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _cocktail = fetched;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onBookmarkTap(Cocktail cocktail) {
    final authenticated = context.read<AuthenticationProvider>().isAuthenticated;

    if (!authenticated) {
      showAuthGateSheet(context, cocktailName: cocktail.title.translate(context));
      return;
    }

    setState(() => _bookmarked = !_bookmarked);
  }

  Future<void> _shareCocktail(Cocktail cocktail) async {
    final l10n = context.l10n;
    final title = cocktail.title.translate(context);
    final description = cocktail.description.translate(context);

    final ingredientLines = cocktail.ingredients
        .map((ingredient) {
          final name = ingredient.title.translate(context);
          final measure = cocktail.measureFor(ingredient.id);
          return measure == null
              ? '• $name'
              : '• $name — ${measureLabel(l10n, measure)}';
        })
        .join('\n');

    final equipmentLines = cocktail.equipments
        .map((equipment) => '• ${equipment.title.translate(context)}')
        .join('\n');

    final buffer = StringBuffer()
      ..writeln('🍸 $title')
      ..writeln()
      ..writeln(description)
      ..writeln()
      ..writeln(ingredientLines);

    if (equipmentLines.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(equipmentLines);
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString().trimRight()));
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.cocktailRecipeCopied)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.ground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final cocktail = _cocktail;
    if (cocktail == null) {
      return Scaffold(
        backgroundColor: AppColors.ground,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenEdge,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppColors.low),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.errorLoadingCocktails,
                  style: AppTypography.section,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _errorMessage ?? '',
                  style: AppTypography.meta,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(onPressed: _loadCocktail, child: Text(l10n.retry)),
              ],
            ),
          ),
        ),
      );
    }

    final screenHeight = MediaQuery.sizeOf(context).height;
    final photoHeight = math.min(screenHeight * 0.55, 470.0);
    final authenticated = context.watch<AuthenticationProvider>().isAuthenticated;

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: Stack(
        children: [
          _Photo(imageUrl: cocktail.image, height: photoHeight),
          _DetailSheet(cocktail: cocktail, photoHeight: photoHeight),
          _TopChrome(
            authenticated: authenticated,
            bookmarked: _bookmarked,
            onBack: () => Navigator.of(context).pop(),
            onBookmark: () => _onBookmarkTap(cocktail),
            onShare: () => _shareCocktail(cocktail),
          ),
        ],
      ),
    );
  }
}

/// The pinned hero image. Fixed behind the sheet rather than scrolling with
/// it — the sheet is what moves, the photo is what it rises over.
class _Photo extends StatelessWidget {
  const _Photo({required this.imageUrl, required this.height});

  final String imageUrl;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const _PhotoFallback(),
            )
          else
            const _PhotoFallback(),
          // Only the top third needs the scrim — that is where the glass
          // chrome sits, and the rest dissolves into the sheet below anyway.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: height / 3,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x800B0B0C), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoFallback extends StatelessWidget {
  const _PhotoFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.row,
      child: Center(
        child: Icon(Icons.local_bar, size: 40, color: AppColors.inkMeta),
      ),
    );
  }
}

/// The back/bookmark/share row, painted above the sheet so it stays
/// reachable no matter how far the sheet has been scrolled up.
class _TopChrome extends StatelessWidget {
  const _TopChrome({
    required this.authenticated,
    required this.bookmarked,
    required this.onBack,
    required this.onBookmark,
    required this.onShare,
  });

  final bool authenticated;
  final bool bookmarked;
  final VoidCallback onBack;
  final VoidCallback onBookmark;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GlassIconButton(
              icon: Icons.arrow_back,
              size: 36,
              tooltip: l10n.cocktailBack,
              onTap: onBack,
            ),
            Row(
              children: [
                _BookmarkButton(
                  authenticated: authenticated,
                  bookmarked: bookmarked,
                  onTap: onBookmark,
                ),
                const SizedBox(width: 8),
                GlassIconButton(
                  icon: Icons.ios_share,
                  size: 36,
                  tooltip: l10n.cocktailShare,
                  onTap: onShare,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Signed out, saving would vanish the moment the app is reinstalled — the
/// lock says so before the tap, rather than letting the first save succeed
/// quietly and only asking on the second. That is the account line drawn
/// where it can actually be seen.
class _BookmarkButton extends StatelessWidget {
  const _BookmarkButton({
    required this.authenticated,
    required this.bookmarked,
    required this.onTap,
  });

  final bool authenticated;
  final bool bookmarked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GlassIconButton(
          icon: bookmarked ? Icons.bookmark : Icons.bookmark_border,
          size: 36,
          tooltip: l10n.cocktailSave,
          onTap: onTap,
        ),
        if (!authenticated)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 15,
              height: 15,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.signal,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.ground, width: 2),
              ),
              child: const Icon(Icons.lock, size: 9, color: AppColors.ink),
            ),
          ),
      ],
    );
  }
}

/// The scrollable sheet, rising up over the photo's bottom edge so its
/// rounded corners read as resting on the image rather than butting into it.
class _DetailSheet extends StatelessWidget {
  const _DetailSheet({required this.cocktail, required this.photoHeight});

  final Cocktail cocktail;
  final double photoHeight;

  static const _overlap = 24.0;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final topOffset = photoHeight - _overlap;
    final minHeight = screenHeight - topOffset;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: topOffset)),
        SliverToBoxAdapter(
          child: ConstrainedBox(
            // Short content still reaches the bottom of the screen instead
            // of leaving the photo showing beneath a stunted sheet; long
            // content still grows past the fold and scrolls.
            constraints: BoxConstraints(minHeight: minHeight),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.sheet,
                borderRadius: AppRadius.sheetTop,
                boxShadow: [kSheetShadow],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenEdge,
                ),
                child: CocktailSheetContent(cocktail: cocktail),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The sheet's body: title, recipe, and whichever nudge (one bottle away,
/// two or three away) the shelf earns. Kept public and free of any lookup
/// of its own — it takes the [Cocktail] it is handed and reads only
/// [BarProvider] from context — so tests can pump it directly against a
/// fake shelf without going anywhere near Firestore.
class CocktailSheetContent extends StatelessWidget {
  const CocktailSheetContent({super.key, required this.cocktail});

  final Cocktail cocktail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bar = context.watch<BarProvider>();
    final makeability = makeabilityOf(cocktail, bar.shelf);
    final eyebrow = cocktailEyebrow(l10n, cocktail);
    final meta = cocktailMeta(l10n, cocktail);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        const _DragHandle(),
        const SizedBox(height: 12),
        if (eyebrow.isNotEmpty || meta.isNotEmpty) ...[
          _EyebrowMetaRow(eyebrow: eyebrow, meta: meta),
          const SizedBox(height: 12),
        ],
        Text(
          cocktail.title.translate(context),
          style: AppTypography.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        Text(cocktail.description.translate(context), style: AppTypography.body),
        const SizedBox(height: 18),
        _IngredientList(cocktail: cocktail),
        if (makeability.isOneAway) ...[
          const SizedBox(height: 14),
          _UnlockPrompt(cocktail: cocktail, missing: makeability.missing.single),
        ] else if (makeability.requiredCount > 0 &&
            (makeability.missingCount == 2 || makeability.missingCount == 3)) ...[
          const SizedBox(height: 14),
          _TwoAwayPrompt(cocktail: cocktail, missingCount: makeability.missingCount),
        ],
        const SizedBox(height: 16),
        _ActionsRow(cocktail: cocktail),
        SizedBox(height: MediaQuery.paddingOf(context).bottom + 26),
      ],
    );
  }
}

/// The grab affordance at the top of the sheet, in the same barely-there
/// tone every other sheet in the app uses.
class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 38,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.glassStroke,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _EyebrowMetaRow extends StatelessWidget {
  const _EyebrowMetaRow({required this.eyebrow, required this.meta});

  final String eyebrow;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (eyebrow.isNotEmpty)
          Flexible(
            child: StatusChip(label: eyebrow, tone: ChipTone.signal),
          ),
        if (eyebrow.isNotEmpty && meta.isNotEmpty) const SizedBox(width: 8),
        if (meta.isNotEmpty)
          Flexible(
            child: Text(
              meta,
              style: AppTypography.meta.copyWith(fontSize: 11.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

/// The recipe itself — no header, because the sheet already opened on the
/// drink's name and this is the very next thing under it.
class _IngredientList extends StatelessWidget {
  const _IngredientList({required this.cocktail});

  final Cocktail cocktail;

  @override
  Widget build(BuildContext context) {
    final bar = context.watch<BarProvider>();
    final ingredients = cocktail.ingredients;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: ColoredBox(
        color: AppColors.fillSubtle,
        child: Column(
          children: [
            for (final (index, ingredient) in ingredients.indexed) ...[
              if (index > 0) const SizedBox(height: 1),
              _IngredientRow(
                cocktail: cocktail,
                ingredient: ingredient,
                held: bar.holds(ingredient),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({
    required this.cocktail,
    required this.ingredient,
    required this.held,
  });

  final Cocktail cocktail;
  final Ingredient ingredient;
  final bool held;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final measure = cocktail.measureFor(ingredient.id);

    return ColoredBox(
      color: AppColors.row,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
        child: Row(
          children: [
            _IngredientStatusSquare(held: held),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ingredient.title.translate(context),
                style: AppTypography.body.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: held ? AppColors.ink : AppColors.low,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            // What is missing matters more than how much of it the recipe
            // asked for, so an absent bottle wins the trailing slot even
            // when the recipe does state a measure.
            if (!held)
              Flexible(
                child: Text(
                  l10n.cocktailNotOnShelf,
                  style: AppTypography.body.copyWith(
                    fontSize: 12,
                    color: AppColors.low,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            else if (measure != null)
              Flexible(
                child: Text(
                  measureLabel(l10n, measure),
                  style: AppTypography.measure,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _IngredientStatusSquare extends StatelessWidget {
  const _IngredientStatusSquare({required this.held});

  final bool held;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: held ? AppColors.readyWash : AppColors.lowWash,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(
        held ? Icons.check : Icons.error_outline,
        size: held ? 16 : 17,
        color: held ? AppColors.ready : AppColors.low,
      ),
    );
  }
}

/// Shown only when one bottle stands between this shelf and this drink —
/// the same threshold the zero-results screen answers with elsewhere.
class _UnlockPrompt extends StatelessWidget {
  const _UnlockPrompt({required this.cocktail, required this.missing});

  final Cocktail cocktail;
  final Ingredient missing;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = missing.title.translate(context);
    final unlocks = missing.unlocks ?? 0;
    // A count of zero would be a guess dressed up as a fact, so an
    // unbackfilled bottle gets the plain prompt instead of an invented number.
    final label = unlocks > 0
        ? l10n.cocktailAddUnlocks(name, unlocks)
        : l10n.cocktailAddToBarPlain(name);

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppColors.lowWash,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await context.read<BarProvider>().addIngredient(missing);
            if (!context.mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.addedToBar(name))));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            child: Row(
              children: [
                const Icon(
                  Icons.add_shopping_cart,
                  size: 18,
                  color: AppColors.low,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.body.copyWith(
                      fontSize: 12.5,
                      height: 1.4,
                      color: AppColors.low,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  size: 17,
                  color: AppColors.inkMeta,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown when the shelf is two or three bottles short — the one other place
/// (besides the ran-out checklist) the design lets a gap be named, because
/// it answers a question this screen already raised rather than nagging
/// about one nobody asked.
class _TwoAwayPrompt extends StatelessWidget {
  const _TwoAwayPrompt({required this.cocktail, required this.missingCount});

  final Cocktail cocktail;
  final int missingCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = l10n.twoAwayPrompt(missingCount);

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppColors.lowWash,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => showTwoAwaySheet(context, cocktail),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 18,
                  color: AppColors.low,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.body.copyWith(
                      fontSize: 12.5,
                      height: 1.4,
                      color: AppColors.low,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  size: 17,
                  color: AppColors.inkMeta,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  const _ActionsRow({required this.cocktail});

  final Cocktail cocktail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 60,
            child: FilledButton.icon(
              // The guided pour already has the cocktail in hand, so it is
              // handed over as `extra` rather than making that screen fetch
              // what this one already paid for.
              onPressed: () => context.push(
                '${AppRoutes.makeItNow}/${cocktail.id}',
                extra: cocktail,
              ),
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.cocktailMakeItNow),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _PartyButton(onTap: () => context.push(AppRoutes.partyHub)),
      ],
    );
  }
}

class _PartyButton extends StatelessWidget {
  const _PartyButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Semantics(
      button: true,
      label: l10n.cocktailAddToParty,
      child: Tooltip(
        message: l10n.cocktailAddToParty,
        child: SizedBox(
          width: 60,
          height: 60,
          child: Material(
            color: AppColors.fillStrong,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: const Icon(
                Icons.celebration_outlined,
                size: 22,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
