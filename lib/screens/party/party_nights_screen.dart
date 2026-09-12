import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../generated/l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/party_cocktails.dart';
import '../../services/menu_presets.dart';
import '../../services/party_service.dart';
import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/party/recap_bits.dart';
import '../../widgets/party/save_menu_sheet.dart';

/// Flow 08 · screen 06 — every night, because recaps don't expire.
///
/// The host's own archive: one card for the night just gone, a row for each
/// one before it, and the saved menus that came out of them. Nothing here is
/// a leaderboard — the running total is a fact about the shelf, not a score.
class PartyNightsScreen extends StatefulWidget {
  const PartyNightsScreen({super.key});

  @override
  State<PartyNightsScreen> createState() => _PartyNightsScreenState();
}

class _PartyNightsScreenState extends State<PartyNightsScreen> {
  final PartyCocktails _cocktails = PartyCocktails();
  late final Stream<List<Party>> _hosted = PartyService().getHostedParties();

  int _presets = 0;

  @override
  void initState() {
    super.initState();
    _countPresets();
  }

  @override
  void dispose() {
    _cocktails.dispose();
    super.dispose();
  }

  Future<void> _countPresets() async {
    final presets = await MenuPresets.list();
    if (mounted) setState(() => _presets = presets.length);
  }

  /// Newest first. A party whose end was never stamped still sorts by when
  /// it was created, which is close enough to put it in the right place.
  List<Party> _nights(List<Party> parties) =>
      parties.where((p) => p.isEnded).toList()
        ..sort(
          (a, b) => (b.endedAt ?? b.createdAt).compareTo(a.endedAt ?? a.createdAt),
        );

  /// What the night served. Parties that ended before Flow 08 carry no
  /// stamped total and fall back to what was ordered.
  int _drinks(Party party) => party.drinksPoured ?? party.totalOrders;

  String? _image(Party party) {
    final id = party.availableCocktailIds.firstOrNull;
    return id == null ? null : _cocktails.byId(id)?.image;
  }

  void _openRecap(Party party) =>
      context.push('${AppRoutes.partyRecap}/${party.id}', extra: party);

  /// Reopening a saved menu is starting a party with it — the menu travels,
  /// the party it came from does not.
  Future<void> _openPresets() async {
    final preset = await showMenuPresetPicker(context);
    if (preset == null || !mounted) return;
    context.push(AppRoutes.createParty, extra: preset);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: AppBar(
        backgroundColor: AppColors.ground,
        surfaceTintColor: Colors.transparent,
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: StreamBuilder<List<Party>>(
        stream: _hosted,
        builder: (context, snapshot) {
          final nights = _nights(snapshot.data ?? const []);
          _cocktails.ensure([
            for (final party in nights)
              if (party.availableCocktailIds.firstOrNull case final id?) id,
          ]);

          return ListenableBuilder(
            listenable: _cocktails,
            builder: (context, _) => _body(context, l10n, nights),
          );
        },
      ),
    );
  }

  Widget _body(BuildContext context, AppLocalizations l10n, List<Party> nights) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final poured = nights.fold<int>(0, (sum, party) => sum + _drinks(party));
    final since = nights.isEmpty
        ? null
        : DateFormat.MMMM(locale).format(
            nights.map((p) => p.createdAt).reduce((a, b) => a.isBefore(b) ? a : b),
          );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        0,
        AppSpacing.screenEdge,
        30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.nightsTitle,
            style: AppTypography.title.copyWith(fontSize: 30, height: 1),
          ),
          const SizedBox(height: 12),
          Text(
            since == null
                ? l10n.nightsEmptyTitle
                : l10n.nightsSummary(
                    l10n.nightsParties(nights.length),
                    l10n.nightsDrinks(poured),
                    since,
                  ),
            style: AppTypography.meta.copyWith(
              fontSize: 12.5,
              color: AppColors.ink.withValues(alpha: .5),
            ),
          ),
          const SizedBox(height: 22),
          if (nights.isEmpty)
            Text(
              l10n.nightsEmptyBody,
              style: AppTypography.body.copyWith(fontSize: 13.5),
            )
          else ...[
            NightHeroCard(
              badge: l10n.recapLastNight,
              title: nights.first.name,
              drinks: l10n.nightsDrinksShort(_drinks(nights.first)),
              meta: [
                if (nights.first.guestCount case final guests?)
                  l10n.recapGuests(guests),
                DateFormat.MMMd(locale).format(
                  nights.first.endedAt ?? nights.first.createdAt,
                ),
              ],
              image: _image(nights.first),
              onTap: () => _openRecap(nights.first),
            ),
            for (final party in nights.skip(1)) ...[
              const SizedBox(height: 10),
              NightRow(
                title: party.name,
                subtitle: l10n.nightsRowMeta(
                  DateFormat.MMMd(locale).format(party.endedAt ?? party.createdAt),
                  l10n.nightsDrinksShort(_drinks(party)),
                  l10n.recapGuests(party.guestCount ?? 0),
                ),
                image: _image(party),
                onTap: () => _openRecap(party),
              ),
            ],
          ],
          const SizedBox(height: 10),
          _PresetsRow(count: _presets, onTap: _openPresets),
        ],
      ),
    );
  }
}

/// The menus that came out of those nights. Always present, even at zero —
/// it is the only place in the app that explains what a saved menu is.
class _PresetsRow extends StatelessWidget {
  const _PresetsRow({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.sheet,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(
                Icons.bookmark,
                size: 19,
                color: AppColors.ink.withValues(alpha: .55),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  context.l10n.presetSavedMenus(count),
                  style: AppTypography.cardTitle.copyWith(fontSize: 13.5),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.ink.withValues(alpha: .3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The entry the party tab offers once a host has closed at least one night.
class YourNightsRow extends StatelessWidget {
  const YourNightsRow({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Material(
      color: AppColors.fillMuted,
      borderRadius: AppRadius.pillAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.pillAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history,
                size: 17,
                color: AppColors.ink.withValues(alpha: .6),
              ),
              const SizedBox(width: 9),
              Text(
                l10n.hostYourNights,
                style: AppTypography.cardTitle.copyWith(
                  fontSize: 12.5,
                  color: AppColors.ink.withValues(alpha: .8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kept out of the screen so the party tab can offer it without importing a
/// whole archive it does not draw.
void openYourNights(BuildContext context) => context.push(AppRoutes.partyNights);
