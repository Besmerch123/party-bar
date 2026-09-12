import 'package:flutter/material.dart';

import '../../../models/models.dart';
import '../../../providers/round_draft.dart';
import '../../../theme/theme.dart';
import '../../../utils/cocktail_labels.dart';
import '../../../utils/localization_helper.dart';
import '../../../widgets/auth/auth_controls.dart';
import '../../../widgets/common/glass.dart';
import '../../../widgets/party/host_sheets.dart';
import '../../../widgets/party/menu_cocktail_tile.dart';
import '../../../widgets/party/order_bits.dart' show GuestInitial, hostFirstName;

/// Flow 06 · screen 01 — who it's for, how many, and a note, then the drink
/// queues itself onto [RoundDraft]. Pushed from the Menu tab or a "While
/// you wait" tile; the caller passes the same [RoundDraft] instance the
/// guest shell already owns, since a pushed route does not see providers
/// created above it.
class AddToRoundScreen extends StatefulWidget {
  const AddToRoundScreen({
    super.key,
    required this.party,
    required this.cocktail,
    required this.draft,
    required this.aheadOfNewOrder,
    required this.orderedTonight,
    this.guestName,
  });

  final Party party;
  final Cocktail cocktail;
  final RoundDraft draft;

  /// The name this phone orders under — the "Me" chip carries its initial.
  /// Null before the first round is sent, when the chip falls back to the
  /// initial of the word "Me" itself.
  final String? guestName;

  /// [aheadOfNewOrder] from the orders snapshot at the moment the screen
  /// opened — good enough for a screen open only a few seconds.
  final int aheadOfNewOrder;
  final int orderedTonight;

  @override
  State<AddToRoundScreen> createState() => _AddToRoundScreenState();
}

class _AddToRoundScreenState extends State<AddToRoundScreen> {
  /// `null` is "me" — the default and the first chip.
  String? _forName;
  int _count = 1;
  String? _note;
  late List<String> _friends;

  @override
  void initState() {
    super.initState();
    _friends = List.of(widget.draft.friends);
  }

  Future<void> _pickSomeoneElse() async {
    final name = await showHostSheet<String>(context, (context) => _SomeoneElseSheet());
    if (name == null || name.trim().isEmpty) return;
    setState(() {
      _forName = name.trim();
      if (!_friends.any((f) => f.toLowerCase() == _forName!.toLowerCase())) {
        _friends = [_forName!, ..._friends];
      }
    });
  }

  Future<void> _editNote() async {
    final note = await showHostSheet<String>(context, (context) => _NoteSheet(initial: _note));
    if (note == null) return;
    setState(() => _note = note.trim().isEmpty ? null : note.trim());
  }

  void _add() {
    widget.draft.add(
      cocktailId: widget.cocktail.id,
      forName: _forName,
      note: _note,
      count: _count,
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cocktail = widget.cocktail;

    // Flow 07 · screen 07 — a round can still be built while the bar is
    // paused, but the pill must not claim it is open.
    final paused = widget.party.status == PartyStatus.paused;

    final chips = <String>[
      if (cocktail.equipments.where((e) => e.kind == EquipmentKind.glassware).firstOrNull
          case final glass?)
        glass.title.translate(context)
      else if (cocktail.method != null)
        methodLabel(l10n, cocktail.method!),
      l10n.roundIngredientsCount(cocktail.ingredients.length),
    ];

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: Stack(
        children: [
          SizedBox(height: 430, width: double.infinity, child: MenuCocktailImage(image: cocktail.image)),
          const SizedBox(height: 430, child: PhotoScrim()),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, 8, AppSpacing.screenEdge, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GlassIconButton(
                        icon: Icons.arrow_back,
                        size: 34,
                        tooltip: l10n.roundBack,
                        onTap: () => Navigator.of(context).pop(false),
                      ),
                      Flexible(
                        child: GlassSurface(
                          padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: paused ? AppColors.low : AppColors.signal,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: paused ? AppColors.low : AppColors.signal,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  (paused
                                          ? l10n.joinPausedPill
                                          : l10n.roundBarOpenPill)
                                      .toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.label,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 260),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cocktail.title.translate(context),
                        style: AppTypography.title.copyWith(fontSize: 36),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: [
                          for (final chip in chips)
                            _GlassChip(label: chip),
                          if (widget.orderedTonight > 0) _GlassChip(label: '×${widget.orderedTonight}', tinted: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, 0, AppSpacing.screenEdge, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.roundWhosItFor.toUpperCase(), style: AppTypography.label),
                    const SizedBox(height: 11),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _WhoChip(
                          label: l10n.roundMe,
                          initial: widget.guestName,
                          selected: _forName == null,
                          onTap: () => setState(() => _forName = null),
                        ),
                        for (final friend in _friends)
                          _WhoChip(
                            label: friend,
                            initial: friend,
                            selected: _forName == friend,
                            onTap: () => setState(() => _forName = friend),
                          ),
                        _WhoChip.addAction(label: l10n.roundSomeoneElse, onTap: _pickSomeoneElse),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.sheet, borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l10n.roundHowMany, style: AppTypography.cardTitle.copyWith(fontSize: 13.5)),
                                    const SizedBox(height: 5),
                                    Text(l10n.roundHowManySub, style: AppTypography.meta.copyWith(fontSize: 11.5)),
                                  ],
                                ),
                              ),
                              _Stepper(
                                count: _count,
                                onChanged: (n) => setState(() => _count = n),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Divider(height: 1),
                          const SizedBox(height: 14),
                          InkWell(
                            onTap: _editNote,
                            borderRadius: BorderRadius.circular(12),
                            child: Row(
                              children: [
                                const Icon(Icons.edit_note, size: 19, color: AppColors.signalLight),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Text(
                                    _note ?? l10n.roundNoteHint,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.cardTitle.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _note == null ? AppColors.ink.withValues(alpha: .5) : AppColors.ink,
                                    ),
                                  ),
                                ),
                                Text(
                                  _note == null ? l10n.roundAddNote : l10n.roundEditNote,
                                  style: AppTypography.meta.copyWith(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.signalLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(color: AppColors.fillSubtle, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.group, size: 17, color: AppColors.ink.withValues(alpha: .4)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                style: AppTypography.meta.copyWith(fontSize: 12, height: 1.5),
                                children: [
                                  TextSpan(
                                    text: l10n.roundAheadBold(widget.aheadOfNewOrder),
                                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
                                  ),
                                  TextSpan(text: l10n.roundAheadRest(hostFirstName(widget.party.hostName))),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AuthPillButton(
                      label: l10n.roundAddToRound,
                      icon: Icons.add,
                      primary: true,
                      height: AppSizes.buttonPrimary,
                      onPressed: _add,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({required this.label, this.tinted = false});

  final String label;
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: tinted ? AppColors.readyWash : AppColors.glass,
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        label,
        style: AppTypography.body.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1.0,
          color: tinted ? AppColors.ready : AppColors.ink,
        ),
      ),
    );
  }
}

class _WhoChip extends StatelessWidget {
  const _WhoChip({required this.label, required this.initial, required this.selected, required this.onTap})
    : _isAdd = false;

  const _WhoChip.addAction({required this.label, required this.onTap})
    : initial = null,
      selected = false,
      _isAdd = true;

  final String label;
  final String? initial;
  final bool selected;
  final bool _isAdd;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.ink : AppColors.fillMuted,
      borderRadius: AppRadius.pillAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.pillAll,
        child: Padding(
          padding: EdgeInsets.fromLTRB(_isAdd ? 14 : 8, 8, 14, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isAdd)
                Icon(Icons.add, size: 16, color: AppColors.ink.withValues(alpha: .55))
              else
                GuestInitial(name: initial ?? label, size: 22, highlighted: selected),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                    color: selected ? AppColors.ground : AppColors.ink.withValues(alpha: .72),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.count, required this.onChanged});

  final int count;
  final ValueChanged<int> onChanged;

  static const _min = 1;
  static const _max = 9;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepButton(
          icon: Icons.remove,
          enabled: count > _min,
          onTap: () => onChanged(count - 1),
        ),
        SizedBox(
          width: 28,
          child: Text(
            '$count',
            textAlign: TextAlign.center,
            style: AppTypography.cardTitle.copyWith(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ),
        _StepButton(
          icon: Icons.add,
          enabled: count < _max,
          filled: true,
          onTap: () => onChanged(count + 1),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.enabled, required this.onTap, this.filled = false});

  final IconData icon;
  final bool enabled;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : .35,
      child: Material(
        color: filled ? AppColors.fillStrong : AppColors.fillMuted,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: enabled ? onTap : null,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: AppSizes.minTap,
            height: AppSizes.minTap,
            child: Icon(icon, size: 20, color: AppColors.ink),
          ),
        ),
      ),
    );
  }
}

class _SomeoneElseSheet extends StatefulWidget {
  @override
  State<_SomeoneElseSheet> createState() => _SomeoneElseSheetState();
}

class _SomeoneElseSheetState extends State<_SomeoneElseSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return HostSheet(
      children: [
        HostSheetTitle(l10n.roundSomeoneElseTitle, size: 22),
        const SizedBox(height: 16),
        AuthTextField(
          controller: _controller,
          hintText: l10n.roundSomeoneElseHint,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          onSubmitted: (_) => Navigator.of(context).pop(_controller.text),
        ),
        const SizedBox(height: 16),
        AuthPillButton(
          label: l10n.roundSomeoneElseAdd,
          primary: true,
          height: AppSizes.buttonGhost,
          onPressed: () => Navigator.of(context).pop(_controller.text),
        ),
      ],
    );
  }
}

class _NoteSheet extends StatefulWidget {
  const _NoteSheet({this.initial});

  final String? initial;

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return HostSheet(
      children: [
        HostSheetTitle(l10n.roundNoteSheetTitle, size: 22),
        const SizedBox(height: 16),
        AuthTextField(
          controller: _controller,
          hintText: l10n.roundNoteSheetHint,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => Navigator.of(context).pop(_controller.text),
        ),
        const SizedBox(height: 16),
        AuthPillButton(
          label: l10n.roundNoteSheetSave,
          primary: true,
          height: AppSizes.buttonGhost,
          onPressed: () => Navigator.of(context).pop(_controller.text),
        ),
      ],
    );
  }
}
