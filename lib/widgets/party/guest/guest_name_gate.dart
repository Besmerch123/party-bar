import 'package:flutter/material.dart';

import '../../../theme/theme.dart';
import '../../../utils/localization_helper.dart';
import '../../auth/auth_controls.dart';
import '../host_sheets.dart';

/// Flow 07 · screen 03 — the only thing a guest is ever asked for, asked on
/// the tap that sends the first round.
///
/// Not a door: there is no version of this screen a guest meets before the
/// drinks. The 18+ line rides the same tap, because that tap is the commit —
/// an age gate at the door would stop someone who has not ordered anything
/// yet.
///
/// Returns the name, or null if the sheet was dismissed. Remembering it is
/// the caller's job — this sheet only asks. Pass [drinks] as null to reuse
/// it as the rename from screen 05, which has nothing to send and nothing to
/// confirm.
Future<String?> showGuestNameGate(
  BuildContext context, {
  required String hostName,
  required int? drinks,
  String? initialName,
}) {
  return showHostSheet<String>(
    context,
    (context) => _GuestNameGate(
      hostName: hostName,
      drinks: drinks,
      initialName: initialName,
    ),
  );
}

class _GuestNameGate extends StatefulWidget {
  const _GuestNameGate({
    required this.hostName,
    required this.drinks,
    required this.initialName,
  });

  final String hostName;
  final int? drinks;
  final String? initialName;

  @override
  State<_GuestNameGate> createState() => _GuestNameGateState();
}

class _GuestNameGateState extends State<_GuestNameGate> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();

  String? _nameError;
  bool _ageError = false;
  late bool _overEighteen;
  bool _busy = false;

  /// A rename has nothing to send, so it has nothing to confirm either —
  /// whoever is renaming already agreed to this on their first round.
  bool get _isRename => widget.drinks == null;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
    _overEighteen = _isRename;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _commit() {
    final l10n = context.l10n;
    final name = _controller.text.trim();

    setState(() {
      _nameError = name.isEmpty ? l10n.joinNameRequired : null;
      _ageError = !_overEighteen;
    });
    if (name.isEmpty || !_overEighteen) return;

    setState(() => _busy = true);
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      // The sheet's own route does not lift for the keyboard, and this is
      // the one sheet in the app with a field in it.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: HostSheet(
        children: [
          const HostSheetBadge(icon: Icons.waving_hand),
          const SizedBox(height: 18),
          HostSheetTitle(_isRename ? l10n.joinNameLabel : l10n.joinNameTitle),
          const SizedBox(height: 10),
          HostSheetBody(l10n.joinNameBody(widget.hostName)),
          const SizedBox(height: 22),
          AuthTextField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            hintText: l10n.joinNameHint,
            errorText: _nameError,
            autofillHints: const [AutofillHints.givenName],
            onSubmitted: (_) {
              if (!_busy) _commit();
            },
            semanticLabel: l10n.joinNameLabel,
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.visibility_outlined,
                size: 16,
                color: AppColors.ink.withValues(alpha: .35),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  l10n.joinNameVisibility(widget.hostName),
                  style: AppTypography.meta.copyWith(fontSize: 11.5),
                ),
              ),
            ],
          ),
          if (!_isRename) ...[
            const SizedBox(height: 18),
            _AgeConfirm(
              checked: _overEighteen,
              errored: _ageError,
              onChanged: (value) => setState(() {
                _overEighteen = value;
                if (value) _ageError = false;
              }),
            ),
            if (_ageError) ...[
              const SizedBox(height: 8),
              Text(
                l10n.joinAgeRequired,
                style: AppTypography.meta.copyWith(
                  fontSize: 11.5,
                  color: AppColors.low,
                ),
              ),
            ],
          ],
          const SizedBox(height: 20),
          AuthPillButton(
            label: _isRename
                ? l10n.joinNameSave
                : l10n.joinSendToBar(widget.drinks!),
            icon: _isRename ? null : Icons.send,
            primary: true,
            height: AppSizes.buttonPrimary,
            onPressed: _busy ? null : _commit,
          ),
          const SizedBox(height: 14),
          Text(
            l10n.joinNameRemember,
            textAlign: TextAlign.center,
            style: AppTypography.meta.copyWith(fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

/// A tick box and a sentence, both of them one tap target.
class _AgeConfirm extends StatelessWidget {
  const _AgeConfirm({
    required this.checked,
    required this.errored,
    required this.onChanged,
  });

  final bool checked;
  final bool errored;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final border = errored ? AppColors.low : AppColors.ink.withValues(alpha: .3);

    return Semantics(
      checked: checked,
      child: InkWell(
        onTap: () => onChanged(!checked),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              AnimatedContainer(
                duration: AppMotion.tap,
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: checked ? AppColors.signal : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: checked ? null : Border.all(color: border, width: 1.5),
                ),
                child: checked
                    ? const Icon(Icons.check, size: 16, color: AppColors.ink)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.joinAgeConfirm,
                  style: AppTypography.body.copyWith(
                    fontSize: 12.5,
                    height: 1.45,
                    color: AppColors.ink.withValues(alpha: .78),
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
