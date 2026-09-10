import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/auth.dart';
import '../../providers/auth_provider.dart';
import '../../theme/theme.dart';
import '../../utils/localization_helper.dart';
import 'auth_controls.dart';

/// Opens the one offer to keep a guest's night, made after the party ends.
///
/// [AuthenticationProvider.canPromptClaim] already carries the "once per
/// person, ever" rule; this only has to honour it — skip the sheet entirely
/// once the offer has gone out, and mark it seen the instant it appears
/// rather than only when it is answered, so tapping "No thanks" still counts
/// as having asked.
Future<void> showClaimAccountSheet(
  BuildContext context, {
  required String partyName,
  required List<String> drinkImageUrls,
  required int drinkCount,
}) {
  final auth = context.read<AuthenticationProvider>();
  if (!auth.canPromptClaim) return Future.value();

  unawaited(auth.markClaimPromptSeen());

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    // Scrollable, because a small phone with the text turned up runs out of
    // room before this sheet runs out of argument.
    builder: (_) => SingleChildScrollView(
      child: ClaimAccountSheet(
        partyName: partyName,
        drinkImageUrls: drinkImageUrls,
        drinkCount: drinkCount,
      ),
    ),
  );
}

/// The politest surface in the product: one screen, once, naming exactly
/// what staying signed out costs — nothing tonight, a blank slate next time.
///
/// [partyName] names the party for the recap screen behind this sheet
/// ([showClaimAccountSheet]'s caller); the sheet itself only ever shows the
/// drinks and the offer, never the headline.
class ClaimAccountSheet extends StatelessWidget {
  const ClaimAccountSheet({
    super.key,
    required this.partyName,
    required this.drinkImageUrls,
    required this.drinkCount,
  });

  final String partyName;
  final List<String> drinkImageUrls;
  final int drinkCount;

  Future<void> _continueWithGoogle(BuildContext context) async {
    final auth = context.read<AuthenticationProvider>();
    final signedIn = await auth.signInWithGoogle();
    if (signedIn && context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = context.watch<AuthenticationProvider>();

    final photoCount = drinkImageUrls.length < 3 ? drinkImageUrls.length : 3;
    final photos = drinkImageUrls.take(photoCount).toList();
    final showOverflow = drinkCount > 3;
    final showFailure = auth.failure != null && !auth.failure!.isSilent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
      decoration: const BoxDecoration(
        color: AppColors.sheet,
        borderRadius: AppRadius.sheetTop,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Center(child: _DragHandle()),
          const SizedBox(height: 20),
          Text(l10n.claimTitle(drinkCount), style: AppTypography.heading),
          const SizedBox(height: 12),
          Text(l10n.claimBody, style: AppTypography.body),
          if (photos.isNotEmpty || showOverflow) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                for (var i = 0; i < photos.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(child: _DrinkTile(imageUrl: photos[i])),
                ],
                if (showOverflow) ...[
                  if (photos.isNotEmpty) const SizedBox(width: 10),
                  Expanded(
                    child: _OverflowTile(label: l10n.claimMore(drinkCount - 3)),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 20),
          AuthProviderButton(
            kind: AuthProviderKind.google,
            primary: true,
            label: l10n.claimWithGoogle,
            onPressed: auth.isBusy ? null : () => _continueWithGoogle(context),
          ),
          if (kAppleSignInEnabled) ...[
            const SizedBox(height: 10),
            AuthProviderButton(
              kind: AuthProviderKind.apple,
              label: l10n.claimWithApple,
              onPressed: null,
            ),
          ],
          if (showFailure) ...[
            const SizedBox(height: 14),
            AuthFailureNotice(
              failure: auth.failure,
              onRetry: () => _continueWithGoogle(context),
              onUseGoogle: () => _continueWithGoogle(context),
            ),
          ],
          const SizedBox(height: 8),
          AuthGhostAction(
            label: l10n.claimNoThanks,
            onPressed: () => Navigator.of(context).pop(),
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom + 12),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.glassStroke,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// One of the up-to-three drink photographs.
///
/// A sheet about keeping memories must not show a broken-image glyph, so a
/// plain [AppColors.row] fill stands in for both "still loading" and
/// "failed" — never an icon that reads as something went wrong.
class _DrinkTile extends StatelessWidget {
  const _DrinkTile({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 86,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => const ColoredBox(color: AppColors.row),
          errorWidget: (context, url, error) =>
              const ColoredBox(color: AppColors.row),
        ),
      ),
    );
  }
}

/// The fourth tile, shown only when more drinks were poured than fit the row.
class _OverflowTile extends StatelessWidget {
  const _OverflowTile({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.row,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: AppTypography.measure),
    );
  }
}
