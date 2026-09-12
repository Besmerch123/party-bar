import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/cocktail_repository.dart';
import '../../models/models.dart';
import '../../providers/bar_provider.dart';
import '../../services/party_service.dart';
import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/auth/auth_controls.dart';
import '../../widgets/common/glass.dart';
import '../../widgets/party/host_sheets.dart';
import '../../widgets/party/host_state_pill.dart';
import '../../widgets/party/menu_cocktail_tile.dart';
import 'menu_all_cocktails_screen.dart';

const _fallbackHero = 'assets/images/onboarding/cosmopolitan.jpg';
const _lowLight = Color(0xFFF5C97A);

/// Flow 05 · screen 07 — the draft, ready to open.
///
/// Everything is still editable here and nothing has been promised to
/// anyone: the code is shown, dimmed and marked dead, so the host learns
/// what Go live changes before a guest does. What the menu is short of is
/// said once, as a shopping card, rather than on every drink.
class DraftPartyScreen extends StatefulWidget {
  const DraftPartyScreen({
    super.key,
    required this.party,
    required this.onPartyChanged,
  });

  final Party party;

  /// Called with the updated party after an edit here is saved.
  final ValueChanged<Party> onPartyChanged;

  @override
  State<DraftPartyScreen> createState() => _DraftPartyScreenState();
}

class _DraftPartyScreenState extends State<DraftPartyScreen> {
  final _service = PartyService();

  /// The menu, whole. Null while it loads.
  List<Cocktail>? _cocktails;
  bool _busy = false;

  Party get _party => widget.party;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    final repository = CocktailRepository();
    final loaded = await Future.wait(
      _party.availableCocktailIds.map((id) async {
        try {
          return await repository.getCocktail(id);
        } catch (_) {
          return null;
        }
      }),
    );
    if (!mounted) return;
    setState(() => _cocktails = loaded.whereType<Cocktail>().toList());
  }

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _editMenu() async {
    final picked = await pickPartyMenu(context, _cocktails ?? const []);
    if (picked == null || !mounted) return;

    final ids = picked.map((c) => c.id).toList(growable: false);
    setState(() => _cocktails = picked);
    try {
      await _service.updateAvailableCocktails(_party.id, ids);
      widget.onPartyChanged(_party.copyWith(availableCocktailIds: ids));
    } catch (_) {
      _saveFailed();
    }
  }

  Future<void> _editWhen() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _party.scheduledFor ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;

    final tonight = picked == today;
    try {
      await _service.updateParty(
        _party.id,
        scheduledFor: tonight ? null : picked,
        clearSchedule: tonight,
      );
      widget.onPartyChanged(
        tonight
            ? _party.copyWith(clearScheduledFor: true)
            : _party.copyWith(scheduledFor: picked),
      );
    } catch (_) {
      _saveFailed();
    }
  }

  /// Screen 08, and the two edge states around it: an empty menu is asked
  /// about first, and a second live party is caught by the service.
  Future<void> _goLive() async {
    if (_busy) return;

    if (_party.availableCocktailIds.isEmpty) {
      final choice = await showEmptyMenuSheet(context);
      if (!mounted) return;
      if (choice == EmptyMenuChoice.addFirst) {
        await _editMenu();
        return;
      }
      if (choice != EmptyMenuChoice.openAnyway) return;
    }

    final confirmed = await showGoLiveSheet(context, _party);
    if (!confirmed || !mounted) return;
    await _open();
  }

  Future<void> _open() async {
    setState(() => _busy = true);

    try {
      await _service.goLive(_party.id);
      if (!mounted) return;
      // Screen 09 over the Party tab, so closing it lands on the live hub.
      final live = _party.copyWith(
        status: PartyStatus.active,
        wentLiveAt: DateTime.now(),
      );
      context.go(AppRoutes.home);
      context.push('${AppRoutes.partyInvite}/${live.id}', extra: live);
    } on LivePartyConflict catch (conflict) {
      if (!mounted) return;
      setState(() => _busy = false);
      await _resolveConflict(conflict.liveParty);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      _saveFailed();
    }
  }

  Future<void> _resolveConflict(Party live) async {
    final choice = await showSecondPartySheet(context, live);
    if (!mounted) return;

    switch (choice) {
      case SecondPartyChoice.goThere:
        context.push('${AppRoutes.activePartyHost}/${live.id}', extra: live);
      case SecondPartyChoice.endAndStart:
        try {
          await _service.updatePartyStatus(live.id, PartyStatus.ended);
        } catch (_) {
          _saveFailed();
          return;
        }
        if (mounted) await _open();
      case null:
        break;
    }
  }

  void _saveFailed() {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.hostDraftSaveFailed)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shelf = context.watch<BarProvider>().shelf;
    final cocktails = _cocktails;
    final count = cocktails?.length ?? _party.availableCocktailIds.length;
    final locale = Localizations.localeOf(context).toLanguageTag();

    final short = [
      for (final cocktail in cocktails ?? const <Cocktail>[])
        if (makeabilityOf(cocktail, shelf).missing.isNotEmpty) cocktail,
    ];
    final toBuy = <String, String>{
      for (final cocktail in short)
        for (final ingredient in makeabilityOf(cocktail, shelf).missing)
          ingredient.id: ingredient.title.translate(context),
    };

    final heroImage = cocktails
        ?.map((c) => c.image)
        .where((image) => image.isNotEmpty)
        .firstOrNull;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 330,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (heroImage != null)
                  MenuCocktailImage(image: heroImage)
                else
                  Image.asset(_fallbackHero, fit: BoxFit.cover),
                const PhotoScrim(),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      GlassIconButton(
                        icon: Icons.arrow_back,
                        size: 34,
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).backButtonTooltip,
                        onTap: _leave,
                      ),
                      const Spacer(),
                      HostStatePill(label: l10n.hostDraftPill),
                      const Spacer(),
                      const SizedBox(width: 34),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenEdge,
                      110,
                      AppSpacing.screenEdge,
                      AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _party.name,
                          style: AppTypography.title.copyWith(fontSize: 34),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _party.scheduledFor == null
                              ? l10n.hostDraftMetaTonight(count)
                              : l10n.hostDraftMetaDate(
                                  DateFormat.MMMd(
                                    locale,
                                  ).format(_party.scheduledFor!),
                                  count,
                                ),
                          style: AppTypography.body.copyWith(
                            color: AppColors.inkBody,
                          ),
                        ),
                        const SizedBox(height: 22),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            children: [
                              _DraftRow(
                                icon: Icons.local_bar,
                                label: l10n.hostDraftMenuRow,
                                value: l10n.hostDraftDrinks(count),
                                onTap: cocktails == null ? null : _editMenu,
                              ),
                              const SizedBox(height: 1),
                              _DraftRow(
                                icon: Icons.schedule,
                                label: l10n.hostDraftWhenRow,
                                value: _party.scheduledFor == null
                                    ? l10n.hostDraftTonightOpen
                                    : DateFormat.MMMEd(
                                        locale,
                                      ).format(_party.scheduledFor!),
                                onTap: _editWhen,
                              ),
                              const SizedBox(height: 1),
                              _DeadCodeRow(
                                label: l10n.hostDraftInviteRow,
                                code: _party.joinCode,
                                tag: l10n.hostDraftDead,
                              ),
                            ],
                          ),
                        ),
                        if (toBuy.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _ShoppingCard(
                            title: l10n.hostDraftToBuy(toBuy.length),
                            body: l10n.hostDraftToBuyBody(
                              toBuy.values.join(', '),
                              short
                                  .map((c) => c.title.translate(context))
                                  .join(', '),
                            ),
                          ),
                        ],
                        if (cocktails != null && cocktails.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _StatTile(
                            label: l10n.hostDraftCanPour,
                            value: l10n.hostDraftCanPourValue(
                              cocktails.length - short.length,
                              cocktails.length,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenEdge,
                    6,
                    AppSpacing.screenEdge,
                    12,
                  ),
                  child: Column(
                    children: [
                      AuthPillButton(
                        label: l10n.hostGoLiveCta,
                        icon: Icons.bolt,
                        height: AppSizes.buttonPrimary,
                        background: AppColors.signal,
                        foreground: AppColors.ink,
                        onPressed: _busy ? null : _goLive,
                      ),
                      AuthGhostAction(
                        label: l10n.hostSaveForLater,
                        onPressed: () => context.go(AppRoutes.home),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DraftRow extends StatelessWidget {
  const _DraftRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.row,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.signalLight),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.cardTitle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Text(
                value,
                style: AppTypography.meta.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink.withValues(alpha: .5),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.inkGhost,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeadCodeRow extends StatelessWidget {
  const _DeadCodeRow({
    required this.label,
    required this.code,
    required this.tag,
  });

  final String label;
  final String code;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.row,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              Icons.qr_code_2,
              size: 18,
              color: AppColors.inkFaint,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTypography.cardTitle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink.withValues(alpha: .55),
                ),
              ),
            ),
            Text(
              code,
              style: AppTypography.measure.copyWith(
                fontSize: 12.5,
                color: AppColors.inkFaint,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.fillMuted,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                tag.toUpperCase(),
                style: AppTypography.label.copyWith(
                  fontSize: 9.5,
                  color: AppColors.ink.withValues(alpha: .5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShoppingCard extends StatelessWidget {
  const _ShoppingCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.low.withValues(alpha: .1),
        borderRadius: AppRadius.tileAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shopping_basket, size: 19, color: AppColors.low),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.cardTitle.copyWith(
                    fontSize: 13,
                    color: _lowLight,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: AppTypography.meta.copyWith(
                    fontSize: 12,
                    color: AppColors.inkBody,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: AppColors.sheet,
        borderRadius: AppRadius.tileAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.label.copyWith(
              fontSize: 10,
              color: AppColors.ink.withValues(alpha: .4),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: AppTypography.section.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.36,
              color: AppColors.ready,
            ),
          ),
        ],
      ),
    );
  }
}
