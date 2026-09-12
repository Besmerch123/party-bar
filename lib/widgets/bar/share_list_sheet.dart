import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../generated/l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/bar_provider.dart';
import '../../theme/theme.dart';
import '../../utils/bar_labels.dart';
import '../../utils/localization_helper.dart';
import '../common/app_sheet.dart';

/// Flow 04 · screen 07 — the plain-text version of the shopping list, for
/// whoever is actually walking the aisles and has no reason to install
/// anything.
///
/// The sheet renders exactly the string it is about to hand off — no gap
/// between what someone previews and what a "Share" tap sends — and
/// [_ShareListSheetState._includeWhy] lives only for the life of the sheet,
/// not as a preference the shelf remembers between opens.
Future<void> showShareListSheet(BuildContext context) {
  return showAppSheet<void>(
    context,
    (_) => const SingleChildScrollView(child: _ShareListSheet()),
  );
}

/// The reason a shopping-list entry exists, on its own — no ticked or
/// blocking variant, since those describe where an entry stands right now
/// rather than why it was added in the first place. Shared with
/// [ShoppingListScreen]'s row subtitles so the two surfaces never disagree
/// about what "for the Old Fashioned" or "ran out at Kate's Birthday" means.
String shoppingReasonText(AppLocalizations l10n, ShoppingEntry entry) =>
    switch (entry.reason) {
      ShoppingReason.ranOut => entry.context != null
          ? l10n.shoppingListRanOutAt(entry.context!)
          : l10n.shoppingListRanOut,
      ShoppingReason.recipe => l10n.shoppingListForCocktail(entry.context ?? ''),
      ShoppingReason.manual => l10n.shoppingListAddedByYou,
    };

class _ShareListSheet extends StatefulWidget {
  const _ShareListSheet();

  @override
  State<_ShareListSheet> createState() => _ShareListSheetState();
}

class _ShareListSheetState extends State<_ShareListSheet> {
  bool _includeWhy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bar = context.watch<BarProvider>();
    final unticked = bar.shoppingList.where((entry) => !entry.ticked).toList(growable: false);

    final text = shoppingListText(
      unticked,
      heading: l10n.shareListHeading,
      nameOf: (entry) => shoppingEntryName(context, entry),
      whyOf: _includeWhy ? (entry) => shoppingReasonText(l10n, entry) : null,
    );

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        12,
        AppSpacing.screenEdge,
        MediaQuery.paddingOf(context).bottom + 26,
      ),
      decoration: const BoxDecoration(
        color: AppColors.sheet,
        borderRadius: AppRadius.sheetTop,
        boxShadow: [kSheetShadow],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.ink.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.shareListTitle,
                  style: AppTypography.heading.copyWith(fontSize: 20, height: 1),
                ),
              ),
              _CloseButton(onTap: () => Navigator.of(context).pop()),
            ],
          ),
          const SizedBox(height: 18),
          _PreviewBox(text: text),
          const SizedBox(height: 8),
          Text(
            l10n.shareListPlainNote,
            textAlign: TextAlign.center,
            style: AppTypography.caption,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _ActionTile(
                  icon: Icons.ios_share,
                  background: AppColors.readyWash,
                  iconColor: AppColors.ready,
                  label: l10n.shareListShare,
                  onTap: () => Share.share(text),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ActionTile(
                  icon: Icons.content_copy,
                  background: AppColors.fillStrong,
                  iconColor: AppColors.ink,
                  label: l10n.shareListCopy,
                  onTap: () => _copy(context, text),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _IncludeWhyRow(
            value: _includeWhy,
            onChanged: (value) => setState(() => _includeWhy = value),
          ),
        ],
      ),
    );
  }

  Future<void> _copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.shareListCopied)),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).closeButtonLabel,
      child: Material(
        color: AppColors.fillStrong,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 32,
            height: 32,
            child: Icon(Icons.close, size: 18, color: AppColors.ink),
          ),
        ),
      ),
    );
  }
}

/// Exactly the string a share or copy tap would send, in [AppTypography.measure]
/// so it reads like the plain text it is — no styling the receiving app
/// would strip anyway.
class _PreviewBox extends StatelessWidget {
  const _PreviewBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.ground, borderRadius: AppRadius.tileAll),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (index, line) in lines.indexed)
            if (index == 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  line,
                  style: AppTypography.measure.copyWith(
                    fontSize: 12.5,
                    height: 1.9,
                    color: AppColors.ink,
                  ),
                ),
              )
            else if (line.isEmpty)
              const SizedBox(height: 4)
            else
              Text(
                line,
                style: AppTypography.measure.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  height: 1.9,
                  color: AppColors.inkBody,
                ),
              ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.tileAll,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: background, borderRadius: AppRadius.tileAll),
                child: Icon(icon, size: 26, color: iconColor),
              ),
              const SizedBox(height: 9),
              Text(
                label,
                style: AppTypography.label.copyWith(
                  fontSize: 11,
                  letterSpacing: 0,
                  color: AppColors.inkBody,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IncludeWhyRow extends StatelessWidget {
  const _IncludeWhyRow({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Material(
      color: AppColors.row,
      borderRadius: AppRadius.tileAll,
      child: InkWell(
        borderRadius: AppRadius.tileAll,
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              const Icon(Icons.checklist, size: 19, color: AppColors.signalLight),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.shareListIncludeWhy,
                  style: AppTypography.cardTitle,
                ),
              ),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}
