import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/bar_provider.dart';
import '../../providers/explore_provider.dart';
import '../../providers/party_menu_draft.dart';
import '../../services/party_service.dart';
import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/auth/auth_controls.dart';
import '../../widgets/auth/signed_in_banner.dart';
import '../../widgets/party/host_filter_pill.dart';
import '../../widgets/party/menu_cocktail_tile.dart';
import '../../widgets/party/missing_ingredient_sheet.dart';
import 'menu_all_cocktails_screen.dart';
import 'menu_search_screen.dart';

/// The longest name the field accepts — the design's "15/40".
const kPartyNameMaxLength = 40;

/// Flow 05 · screens 02 and 03 — two steps to a draft.
///
/// A name and a when, then a menu. Nothing is written until the draft is
/// finished, so backing out of step 1 leaves nothing behind; the draft is
/// the only thing this screen ever creates, and its code stays dead.
class CreatePartyScreen extends StatefulWidget {
  const CreatePartyScreen({super.key});

  @override
  State<CreatePartyScreen> createState() => _CreatePartyScreenState();
}

class _CreatePartyScreenState extends State<CreatePartyScreen> {
  final _name = TextEditingController();
  final _nameFocus = FocusNode();

  /// Null is tonight.
  DateTime? _scheduledFor;
  final _menu = PartyMenuDraft();

  /// 0 is name & when, 1 is the menu.
  int _step = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
    _nameFocus.addListener(() => setState(() {}));

    // The menu is built from what Explore has fetched; start that now so the
    // grid is usually ready by the time step 2 opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final explore = context.read<ExploreProvider>();
      if (!explore.hasLoaded && !explore.isLoading) explore.load();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _nameFocus.dispose();
    _menu.dispose();
    super.dispose();
  }

  bool get _nameReady => _name.text.trim().isNotEmpty;

  void _useIdea(String idea) {
    _name.value = TextEditingValue(
      text: idea,
      selection: TextSelection.collapsed(offset: idea.length),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledFor ?? today.add(const Duration(days: 1)),
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;

    // Picking today is just tonight by another route.
    setState(() => _scheduledFor = picked == today ? null : picked);
  }

  void _toMenu() {
    if (!_nameReady) return;
    FocusScope.of(context).unfocus();
    setState(() => _step = 1);
  }

  /// Search and the full list are pushed over this step and share its
  /// selection, so whatever they pick is already picked here on return.
  Future<void> _pushWithMenu(Widget screen) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: const RouteSettings(name: kMenuPickerRouteName),
      builder: (_) =>
          ChangeNotifierProvider<PartyMenuDraft>.value(value: _menu, child: screen),
    ),
  );

  /// The only write in the two steps: the draft, with its menu, code dead.
  Future<void> _review() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final party = await PartyService().createParty(
        name: _name.text.trim(),
        scheduledFor: _scheduledFor,
        cocktailIds: _menu.ids,
      );
      if (!mounted) return;
      context.go('${AppRoutes.partyDetails}/${party.id}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.hostDraftSaveFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    // System back on the menu steps back to the name, never out of the flow.
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _step = 0);
      },
      child: Scaffold(
        backgroundColor: AppColors.ground,
        body: SafeArea(
          child: _step == 0 ? _buildNameStep() : _buildMenuStep(),
        ),
      ),
    );
  }

  // ------------------------------------------------------ 02 · name & when

  Widget _buildNameStep() {
    final l10n = context.l10n;
    final ideas = [
      l10n.hostNameIdeaFriday,
      l10n.hostNameIdeaHousewarming,
      l10n.hostNameIdeaJustUs,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepBar(
          step: 1,
          leading: Icons.close,
          leadingLabel: MaterialLocalizations.of(context).closeButtonTooltip,
          onLeading: () => context.pop(),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenEdge,
              14,
              AppSpacing.screenEdge,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.hostNameTitle,
                  style: AppTypography.title.copyWith(
                    fontSize: 32,
                    height: 1.02,
                    letterSpacing: -1.12,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.hostNameBody,
                  style: AppTypography.body.copyWith(height: 1.6),
                ),
                const SizedBox(height: 20),
                _NameField(controller: _name, focusNode: _nameFocus),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final idea in ideas)
                      _QuietChip(label: idea, onTap: () => _useIdea(idea)),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.hostWhenLabel.toUpperCase(),
                  style: AppTypography.label.copyWith(
                    color: AppColors.ink.withValues(alpha: .45),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _WhenToggle(
                        icon: Icons.bolt,
                        label: l10n.hostWhenTonight,
                        selected: _scheduledFor == null,
                        onTap: () => setState(() => _scheduledFor = null),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _WhenToggle(
                        icon: Icons.event,
                        label: _scheduledFor == null
                            ? l10n.hostWhenPickDate
                            : DateFormat.MMMd(
                                Localizations.localeOf(context).toLanguageTag(),
                              ).format(_scheduledFor!),
                        selected: _scheduledFor != null,
                        onTap: _pickDate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                HostInfoNote(
                  icon: Icons.lock_clock,
                  text: l10n.hostCodeDeadNote,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenEdge,
            0,
            AppSpacing.screenEdge,
            14,
          ),
          child: AuthPillButton(
            label: l10n.hostNextMenu,
            trailingIcon: Icons.arrow_forward,
            primary: true,
            height: AppSizes.buttonPrimary,
            onPressed: _nameReady ? _toMenu : null,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------- 03 · the menu

  Widget _buildMenuStep() {
    final l10n = context.l10n;
    final explore = context.watch<ExploreProvider>();
    final shelf = context.watch<BarProvider>().shelf;
    final makeable = explore.fetched
        .where((cocktail) => makeabilityOf(cocktail, shelf).isMakeable)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepBar(
          step: 2,
          leading: Icons.arrow_back,
          leadingLabel: MaterialLocalizations.of(context).backButtonTooltip,
          onLeading: () => setState(() => _step = 0),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenEdge,
            20,
            AppSpacing.screenEdge,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.hostMenuTitle,
                style: AppTypography.title.copyWith(
                  fontSize: 28,
                  height: 1.04,
                  letterSpacing: -0.98,
                ),
              ),
              if (explore.hasLoaded) ...[
                const SizedBox(height: 10),
                Text(
                  l10n.hostMenuBody(makeable.length),
                  style: AppTypography.body.copyWith(fontSize: 13),
                ),
              ],
              const SizedBox(height: 16),
              _MenuSearchPill(
                hint: l10n.hostMenuSearchHint,
                onTap: () => _pushWithMenu(const MenuSearchScreen()),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  HostFilterPill(
                    label: l10n.hostMenuFilterCanMake(makeable.length),
                    icon: Icons.local_bar,
                    selected: true,
                  ),
                  HostFilterPill(
                    label: l10n.hostMenuFilterAll,
                    onTap: () => _pushWithMenu(const MenuAllCocktailsScreen()),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(child: _buildMenuGrid(explore, makeable)),
        _buildMenuFooter(),
      ],
    );
  }

  Widget _buildMenuGrid(ExploreProvider explore, List<Cocktail> makeable) {
    final l10n = context.l10n;

    if (!explore.hasLoaded) {
      if (explore.error == null) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.signal),
        );
      }
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.hostMenuLoadFailed, style: AppTypography.body),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => explore.refresh(),
              child: Text(l10n.hostRetry),
            ),
          ],
        ),
      );
    }

    return ListenableBuilder(
      listenable: _menu,
      builder: (context, _) => GridView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenEdge,
          16,
          AppSpacing.screenEdge,
          16,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: 172,
        ),
        itemCount: makeable.length,
        itemBuilder: (context, index) {
          final cocktail = makeable[index];
          final name = cocktail.title.translate(context);
          final picked = _menu.contains(cocktail.id);
          return MenuCocktailTile(
            name: name,
            image: cocktail.image,
            picked: picked,
            semanticLabel: picked
                ? l10n.hostMenuRemove(name)
                : l10n.hostMenuAdd(name),
            onTap: () => _menu.toggle(cocktail),
          );
        },
      ),
    );
  }

  Widget _buildMenuFooter() {
    final l10n = context.l10n;

    return ListenableBuilder(
      listenable: _menu,
      builder: (context, _) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenEdge,
          14,
          AppSpacing.screenEdge,
          16,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.hostMenuCount(_menu.count),
                    style: AppTypography.section.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.hostMenuAddLater,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.meta.copyWith(
                      fontSize: 11.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _ReviewButton(
              label: l10n.hostMenuReview,
              busy: _saving,
              onTap: _review,
            ),
          ],
        ),
      ),
    );
  }
}

/// Looks like a field, opens search — typing happens on screen 04.
class _MenuSearchPill extends StatelessWidget {
  const _MenuSearchPill({required this.hint, required this.onTap});

  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: hint,
      excludeSemantics: true,
      child: Material(
        color: AppColors.row,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  size: 19,
                  color: AppColors.ink.withValues(alpha: .4),
                ),
                const SizedBox(width: 10),
                Text(
                  hint,
                  style: AppTypography.body.copyWith(
                    color: AppColors.ink.withValues(alpha: .38),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The white, content-width commit at the foot of the menu step.
class _ReviewButton extends StatelessWidget {
  const _ReviewButton({
    required this.label,
    required this.busy,
    required this.onTap,
  });

  final String label;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.ink,
      borderRadius: AppRadius.pillAll,
      child: InkWell(
        onTap: busy ? null : onTap,
        borderRadius: AppRadius.pillAll,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          alignment: Alignment.center,
          child: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.ground,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AppTypography.buttonSecondary.copyWith(
                        color: AppColors.ground,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: AppColors.ground,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- chrome

/// Close or back, a two-segment progress bar and "1 / 2" — the only chrome
/// the draft steps have. The signed-in chip rides along for the one visit
/// that came back through the barrier.
class _StepBar extends StatelessWidget {
  const _StepBar({
    required this.step,
    required this.leading,
    required this.leadingLabel,
    required this.onLeading,
  });

  final int step;
  final IconData leading;
  final String leadingLabel;
  final VoidCallback onLeading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge - 5, 3, 22, 0),
      child: Row(
        children: [
          AuthIconAction(
            icon: leading,
            semanticLabel: leadingLabel,
            onTap: onLeading,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Row(
              children: [
                for (var i = 1; i <= 2; i++) ...[
                  if (i > 1) const SizedBox(width: 5),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: i <= step
                            ? AppColors.ink
                            : AppColors.ink.withValues(alpha: .16),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 14),
          Text(
            '$step / 2',
            style: AppTypography.mono.copyWith(
              letterSpacing: 0,
              color: AppColors.ink.withValues(alpha: .45),
            ),
          ),
          const SignedInChip(),
        ],
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({required this.controller, required this.focusNode});

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.tap,
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.row,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          width: 1.5,
          color: focusNode.hasFocus ? AppColors.signal : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              maxLength: kPartyNameMaxLength,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              cursorColor: AppColors.signal,
              style: AppTypography.section.copyWith(
                fontSize: 17,
                letterSpacing: -0.34,
                color: AppColors.ink,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                counterText: '',
                hintText: context.l10n.hostNameHint,
                hintStyle: AppTypography.section.copyWith(
                  fontSize: 17,
                  color: AppColors.ink.withValues(alpha: .3),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${controller.text.characters.length}/$kPartyNameMaxLength',
            style: AppTypography.mono.copyWith(
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
              color: AppColors.ink.withValues(alpha: .35),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuietChip extends StatelessWidget {
  const _QuietChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.fillMuted,
      borderRadius: AppRadius.pillAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.pillAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          child: Text(
            label,
            style: AppTypography.cardTitle.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.ink.withValues(alpha: .7),
            ),
          ),
        ),
      ),
    );
  }
}

class _WhenToggle extends StatelessWidget {
  const _WhenToggle({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ink = selected ? AppColors.ground : AppColors.ink.withValues(alpha: .6);

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.ink : AppColors.fillMuted,
        borderRadius: AppRadius.pillAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.pillAll,
          child: SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected ? AppColors.ground : AppColors.inkMeta,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.cardTitle.copyWith(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A quiet sheet-coloured note with an accent icon — "nobody can join until
/// you go live", "Campari goes on tonight's shopping list".
class HostInfoNote extends StatelessWidget {
  const HostInfoNote({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.sheet,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.signalLight),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTypography.meta.copyWith(
                fontSize: 12,
                color: AppColors.ink.withValues(alpha: .6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
