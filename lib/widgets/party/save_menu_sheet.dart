import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/models.dart';
import '../../services/menu_presets.dart';
import '../../theme/theme.dart';
import '../../utils/localization_helper.dart';
import '../auth/auth_controls.dart';
import 'host_sheets.dart';

/// Flow 08 · screen 05 — keep the menu, drop the party.
///
/// A preset is the recipes and their order. The name, the code and the guest
/// list stay with the night they belonged to, which is why the sheet says so
/// out loud rather than leaving the host to find out next time.
///
/// Returns the preset it saved, or null if the host backed out.
Future<MenuPreset?> showSaveMenuSheet(
  BuildContext context, {
  required String suggestedName,
  required List<String> cocktailIds,
}) {
  return showHostSheet<MenuPreset>(
    context,
    (context) => _SaveMenuSheet(
      suggestedName: suggestedName,
      cocktailIds: cocktailIds,
    ),
  );
}

class _SaveMenuSheet extends StatefulWidget {
  const _SaveMenuSheet({
    required this.suggestedName,
    required this.cocktailIds,
  });

  final String suggestedName;
  final List<String> cocktailIds;

  @override
  State<_SaveMenuSheet> createState() => _SaveMenuSheetState();
}

class _SaveMenuSheetState extends State<_SaveMenuSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.suggestedName.trim(),
  );
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _ready => _name.text.trim().isNotEmpty;

  Future<void> _save() async {
    if (_saving || !_ready) return;
    setState(() => _saving = true);

    final navigator = Navigator.of(context);
    final preset = await MenuPresets.save(
      name: _name.text,
      cocktailIds: widget.cocktailIds,
    );
    if (!mounted) return;

    if (preset == null) {
      setState(() => _saving = false);
      return;
    }
    navigator.pop(preset);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final count = widget.cocktailIds.length;

    return Padding(
      // The sheet holds a text field, so it has to climb over the keyboard
      // rather than let it cover the one button that finishes the job.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: HostSheet(
        children: [
          HostSheetTitle(l10n.presetTitle, size: 24),
          const SizedBox(height: 10),
          HostSheetBody(l10n.presetBody(count)),
          const SizedBox(height: 18),
          _NameField(controller: _name, hint: l10n.presetNameHint),
          const SizedBox(height: 14),
          HostRowGroup(
            children: [
              _KeepRow(
                icon: Icons.check_circle,
                label: l10n.presetKeepsRecipes(count),
                kept: true,
              ),
              _KeepRow(
                icon: Icons.remove_circle_outline,
                label: l10n.presetDropsParty,
                kept: false,
              ),
            ],
          ),
          const SizedBox(height: 16),
          AuthPillButton(
            label: l10n.presetSave,
            icon: Icons.bookmark_add,
            height: AppSizes.buttonPrimary,
            background: AppColors.signal,
            foreground: AppColors.ink,
            onPressed: _ready && !_saving ? _save : null,
          ),
          const SizedBox(height: 14),
          Text(
            _ready ? l10n.presetFootnote : l10n.presetNameRequired,
            textAlign: TextAlign.center,
            style: AppTypography.meta.copyWith(
              fontSize: 11.5,
              height: 1.5,
              color: _ready ? AppColors.inkFaint : AppColors.ink.withValues(alpha: .55),
            ),
          ),
        ],
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.row,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.signal, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(
            Icons.bookmark_outline,
            size: 19,
            color: AppColors.inkFaint,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              cursorColor: AppColors.signalLight,
              maxLength: 40,
              style: AppTypography.section.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                counterText: '',
                hintText: hint,
                hintStyle: AppTypography.section.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkGhost,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeepRow extends StatelessWidget {
  const _KeepRow({
    required this.icon,
    required this.label,
    required this.kept,
  });

  final IconData icon;
  final String label;

  /// Green and bright for what travels; grey and faded for what does not.
  final bool kept;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.row,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 17,
              color: kept ? AppColors.ready : AppColors.inkGhost,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                label,
                style: AppTypography.cardTitle.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink.withValues(alpha: kept ? .75 : .4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Flow 05 — reopening a menu kept from an earlier night. Returns the preset
/// the host picked, or null.
Future<MenuPreset?> showMenuPresetPicker(BuildContext context) async {
  final presets = await MenuPresets.list();
  if (!context.mounted) return null;

  return showHostSheet<MenuPreset>(context, (context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return HostSheet(
      children: [
        HostSheetTitle(l10n.presetPickTitle, size: 24),
        const SizedBox(height: 10),
        if (presets.isEmpty) ...[
          HostSheetBody(l10n.presetNone),
          const SizedBox(height: 20),
        ] else ...[
          HostSheetBody(l10n.presetSavedMenus(presets.length)),
          const SizedBox(height: 16),
          HostRowGroup(
            children: [
              for (final preset in presets)
                _PresetRow(
                  preset: preset,
                  meta: l10n.presetMeta(
                    preset.cocktailIds.length,
                    DateFormat.MMMd(locale).format(preset.savedAt),
                  ),
                  onTap: () => Navigator.of(context).pop(preset),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        AuthGhostAction(
          label: l10n.close,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  });
}

class _PresetRow extends StatelessWidget {
  const _PresetRow({
    required this.preset,
    required this.meta,
    required this.onTap,
  });

  final MenuPreset preset;
  final String meta;
  final VoidCallback onTap;

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
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.signalWash,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.bookmark,
                  size: 17,
                  color: AppColors.signalLight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preset.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.cardTitle.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      meta,
                      style: AppTypography.meta.copyWith(
                        fontSize: 11.5,
                        height: 1.3,
                        color: AppColors.inkMeta,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.inkGhost,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
