import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/auth.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bar_provider.dart';
import '../../services/menu_presets.dart';
import '../../services/party_service.dart';
import '../../theme/theme.dart';
import '../../utils/localization_helper.dart';

/// Flow 09 · screen 07's overlay — "This deletes six nights".
///
/// Everything it counts is real: hosted nights and the shelf come off
/// providers already in the tree, saved menus off the device. What it does
/// *not* do is reach into another host's parties — a guest's drink count
/// survives inside them, only the account that placed it is gone.
///
/// Returns true once the account is actually deleted.
Future<bool?> showDeleteAccountSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _DeleteAccountSheet(),
  );
}

class _DeleteAccountSheet extends StatefulWidget {
  const _DeleteAccountSheet();

  @override
  State<_DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<_DeleteAccountSheet> {
  final _confirmController = TextEditingController();
  final _partyService = PartyService();

  // Fields, not `build()`-time calls: every keystroke toward "DELETE" calls
  // `setState`, and a fresh `.getHostedParties()`/`MenuPresets.list()` on
  // each of those would tear down and re-subscribe or re-fetch the
  // manifest's data per letter.
  late final Stream<List<Party>> _hosted = _partyService.getHostedParties();
  late final Future<int> _presetCount = MenuPresets.list().then((p) => p.length);

  bool _confirmed = false;
  bool _deleting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _confirmController.addListener(() {
      final matches = _confirmController.text.trim().toUpperCase() == 'DELETE';
      if (matches != _confirmed) setState(() => _confirmed = matches);
    });
  }

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final bar = context.read<BarProvider>();
    final auth = context.read<AuthenticationProvider>();

    setState(() {
      _deleting = true;
      _error = null;
    });

    await MenuPresets.clear();
    await bar.clearEverything();
    final ok = await auth.deleteAccount();

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _deleting = false;
      _error = auth.failure?.kind == AuthFailureKind.requiresRecentLogin
          ? l10n.settingsDeleteNeedsRecentLogin
          : l10n.settingsDeleteFailed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        decoration: BoxDecoration(
          color: AppColors.sheet,
          borderRadius: AppRadius.cardAll,
          boxShadow: const [kSheetShadow],
        ),
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: AppColors.ink.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              l10n.settingsDeleteTitle,
              style: AppTypography.heading.copyWith(fontSize: 24, height: 1.05),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.settingsDeleteBody,
              style: AppTypography.body.copyWith(fontSize: 12.5, color: AppColors.ink.withValues(alpha: .6)),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<Party>>(
              stream: _hosted,
              builder: (context, snapshot) {
                final nights = (snapshot.data ?? const []).where((p) => p.isEnded).toList();
                final poured = nights.fold<int>(
                  0,
                  (sum, p) => sum + (p.drinksPoured ?? p.totalOrders),
                );
                final bottles = context.watch<BarProvider>().bottleCount;

                return FutureBuilder<int>(
                  future: _presetCount,
                  builder: (context, presetSnapshot) {
                    final presets = presetSnapshot.data ?? 0;
                    return _DeleteManifest(nights: nights.length, poured: poured, bottles: bottles, presets: presets);
                  },
                );
              },
            ),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                color: AppColors.row,
                borderRadius: AppRadius.tileAll,
                border: Border.all(color: AppColors.danger.withValues(alpha: .55), width: 1.5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _confirmController,
                textCapitalization: TextCapitalization.characters,
                style: AppTypography.mono.copyWith(
                  fontSize: 16,
                  letterSpacing: 1.2,
                  color: AppColors.ink,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'DELETE',
                  hintStyle: AppTypography.mono.copyWith(
                    fontSize: 16,
                    letterSpacing: 1.2,
                    color: AppColors.ink.withValues(alpha: .25),
                  ),
                  suffixText: l10n.settingsDeleteTypeToConfirm,
                  suffixStyle: AppTypography.meta.copyWith(
                    fontSize: 11,
                    color: AppColors.ink.withValues(alpha: .35),
                  ),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: AppTypography.meta.copyWith(fontSize: 12, color: AppColors.dangerLight),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonPrimary,
              child: ElevatedButton.icon(
                onPressed: _confirmed && !_deleting ? _delete : null,
                icon: _deleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2B0808)),
                      )
                    : const Icon(Icons.delete_forever, size: 20, color: Color(0xFF2B0808)),
                label: Text(
                  l10n.settingsDeleteConfirm,
                  style: AppTypography.buttonPrimary.copyWith(color: const Color(0xFF2B0808)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  disabledBackgroundColor: AppColors.danger.withValues(alpha: .3),
                  shape: const StadiumBorder(),
                ),
              ),
            ),
            const SizedBox(height: 11),
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonGhost,
              child: TextButton(
                onPressed: _deleting ? null : () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.fillMuted,
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  l10n.settingsDeleteKeep,
                  style: AppTypography.buttonSecondary.copyWith(
                    color: AppColors.ink.withValues(alpha: .75),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteManifest extends StatelessWidget {
  const _DeleteManifest({
    required this.nights,
    required this.poured,
    required this.bottles,
    required this.presets,
  });

  final int nights;
  final int poured;
  final int bottles;
  final int presets;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ClipRRect(
      borderRadius: AppRadius.tileAll,
      child: Column(
        children: [
          _row(Icons.history, l10n.settingsDeleteManifestNights(nights, poured)),
          const SizedBox(height: 1),
          _row(Icons.local_bar, l10n.settingsDeleteManifestBar(bottles)),
          const SizedBox(height: 1),
          _row(Icons.bookmark, l10n.settingsDeleteManifestMenus(presets)),
          const SizedBox(height: 1),
          _row(Icons.group, l10n.settingsDeleteManifestGuests, dim: true),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text, {bool dim = false}) {
    return ColoredBox(
      color: AppColors.row,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 17, color: dim ? AppColors.ink.withValues(alpha: .3) : AppColors.dangerLight),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                text,
                style: AppTypography.meta.copyWith(
                  fontSize: 12,
                  fontWeight: dim ? FontWeight.w500 : FontWeight.w600,
                  height: 1.4,
                  color: dim ? AppColors.ink.withValues(alpha: .45) : AppColors.ink.withValues(alpha: .8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
