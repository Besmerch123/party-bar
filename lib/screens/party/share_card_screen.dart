import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/models.dart';
import '../../providers/party_cocktails.dart';
import '../../theme/theme.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/auth/auth_controls.dart';
import '../../widgets/party/order_bits.dart' show formatStopwatch;
import '../../widgets/party/share_card.dart';

/// How many drinks the card names before it stops listing.
const _chipLimit = 2;

/// Flow 08 · screen 03 — the image that goes to the group chat.
///
/// Guest names never leave by accident: the card counts people, and naming
/// them is a toggle the host has to reach for. Nothing here links back to
/// the party — the code is dead by now, and a share card that reopened a
/// closed bar would only disappoint whoever tapped it.
class ShareCardScreen extends StatefulWidget {
  const ShareCardScreen({
    super.key,
    required this.recap,
    required this.orders,
    required this.cocktails,
  });

  final PartyRecap recap;
  final List<CocktailOrder> orders;
  final PartyCocktails cocktails;

  @override
  State<ShareCardScreen> createState() => _ShareCardScreenState();
}

class _ShareCardScreenState extends State<ShareCardScreen> {
  final GlobalKey _cardKey = GlobalKey();

  ShareCardShape _shape = ShareCardShape.story;
  bool _nameGuests = false;
  bool _showWaits = true;
  bool _busy = false;

  PartyRecap get _recap => widget.recap;

  String? _title(String cocktailId) =>
      widget.cocktails.byId(cocktailId)?.title.translate(context);

  /// Everyone who ordered, each named once, in the order they first did.
  String _guestNames() {
    final names = <String>[];
    for (final order in oldestFirst(widget.orders)) {
      final name = order.guestName.trim();
      if (name.isEmpty || names.contains(name)) continue;
      names.add(name);
    }
    return names.join(', ');
  }

  ShareCardData _data() {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final party = _recap.party;

    final date = DateFormat('EEE d MMM', locale).format(_recap.startedAt);
    final endedAt = _recap.endedAt;

    final chips = [
      for (final tally in _recap.tallies.take(_chipLimit))
        l10n.shareCardDrinkChip(
          _title(tally.cocktailId) ?? tally.cocktailId,
          tally.poured,
        ),
      if (_showWaits && _recap.averageWait != null)
        l10n.shareCardWaitChip(formatStopwatch(_recap.averageWait!)),
    ];

    final names = _guestNames();

    return ShareCardData(
      headline: l10n.shareCardHeadline(_recap.poured),
      partyLine: '${party.name} · ${l10n.shareCardPeople(_recap.guests)}',
      dateLine: endedAt == null
          ? date
          : l10n.shareCardUntil(date, DateFormat.Hm(locale).format(endedAt)),
      chips: chips,
      image: _recap.tallies.isEmpty
          ? null
          : widget.cocktails.byId(_recap.tallies.first.cocktailId)?.image,
      guestNames: _nameGuests && names.isNotEmpty ? names : null,
    );
  }

  Future<void> _send() async {
    if (_busy) return;
    setState(() => _busy = true);

    final messenger = ScaffoldMessenger.of(context);
    final failed = context.l10n.shareCardFailed;

    try {
      final boundary =
          _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: _shape.pixelRatio);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (bytes == null) throw StateError('the card rendered to nothing');

      // A new name per share, so a chat app that caches by path never sends
      // last night's card again.
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/partybar-${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);

      await Share.shareXFiles([XFile(file.path, mimeType: 'image/png')]);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final size = _shape.logicalSize;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                8,
                AppSpacing.screenEdge,
                0,
              ),
              child: Row(
                children: [
                  _CloseButton(onTap: () => Navigator.of(context).pop()),
                  Expanded(
                    child: Center(
                      child: _ShapeToggle(
                        shape: _shape,
                        onChanged: (shape) => setState(() => _shape = shape),
                      ),
                    ),
                  ),
                  const SizedBox(width: 34),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(46, 18, 46, 0),
                child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: RepaintBoundary(
                      key: _cardKey,
                      child: SizedBox(
                        width: size.width,
                        height: size.height,
                        child: ShareCard(shape: _shape, data: _data()),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                18,
                AppSpacing.screenEdge,
                0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Column(
                  children: [
                    _ToggleRow(
                      icon: Icons.group,
                      label: l10n.shareCardNameGuests,
                      value: _nameGuests,
                      onChanged: (on) => setState(() => _nameGuests = on),
                    ),
                    const SizedBox(height: 1),
                    _ToggleRow(
                      icon: Icons.timer_outlined,
                      label: l10n.shareCardShowWaits,
                      value: _showWaits,
                      onChanged: (on) => setState(() => _showWaits = on),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                16,
                AppSpacing.screenEdge,
                24,
              ),
              child: Column(
                children: [
                  AuthPillButton(
                    label: l10n.shareCardSend,
                    icon: Icons.ios_share,
                    primary: true,
                    height: AppSizes.buttonPrimary,
                    onPressed: _busy ? null : _send,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.shareCardFootnote,
                    textAlign: TextAlign.center,
                    style: AppTypography.meta.copyWith(
                      fontSize: 11.5,
                      height: 1.5,
                      color: AppColors.inkFaint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShapeToggle extends StatelessWidget {
  const _ShapeToggle({required this.shape, required this.onChanged});

  final ShareCardShape shape;
  final ValueChanged<ShareCardShape> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.fillSubtle,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ShapeChip(
            label: l10n.shareCardStory,
            selected: shape == ShareCardShape.story,
            onTap: () => onChanged(ShareCardShape.story),
          ),
          const SizedBox(width: 6),
          _ShapeChip(
            label: l10n.shareCardSquare,
            selected: shape == ShareCardShape.square,
            onTap: () => onChanged(ShareCardShape.square),
          ),
        ],
      ),
    );
  }
}

class _ShapeChip extends StatelessWidget {
  const _ShapeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.ink : Colors.transparent,
        borderRadius: AppRadius.pillAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.pillAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            child: Text(
              label,
              style: AppTypography.cardTitle.copyWith(
                fontSize: 11.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected
                    ? AppColors.ground
                    : AppColors.inkBody,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.sheet,
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 7, 12, 7),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.ink.withValues(alpha: .5)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.cardTitle.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink.withValues(alpha: .78),
                  ),
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: AppColors.ink,
                activeTrackColor: AppColors.signal,
                inactiveThumbColor: AppColors.ink.withValues(alpha: .5),
                inactiveTrackColor: AppColors.fillStrong,
                trackOutlineColor: const WidgetStatePropertyAll(
                  Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
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
      label: MaterialLocalizations.of(context).closeButtonTooltip,
      child: Material(
        color: AppColors.fillStrong,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 34,
            height: 34,
            child: Icon(Icons.close, size: 19, color: AppColors.ink),
          ),
        ),
      ),
    );
  }
}
