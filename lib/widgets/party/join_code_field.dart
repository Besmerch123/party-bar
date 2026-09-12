import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/join.dart';
import '../../theme/theme.dart';

/// Flow 07 · screens 01 and 04 — six boxes for six characters.
///
/// One real field drives them: a transparent [TextField] laid over the boxes
/// so the platform keeps doing the parts it is good at — the keyboard, the
/// caret, select-all, and paste. Pasting a whole join link works because
/// [joinCodeFrom] is given the paste before the formatters see it.
///
/// The boxes are decoration. They never hold state of their own, so there is
/// no way for what is drawn and what will be sent to disagree.
class JoinCodeField extends StatefulWidget {
  const JoinCodeField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.errored = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  /// Paints every box amber after a code came back refused — the whole code
  /// is wrong, not one character of it.
  final bool errored;

  final VoidCallback? onSubmitted;

  @override
  State<JoinCodeField> createState() => _JoinCodeFieldState();
}

class _JoinCodeFieldState extends State<JoinCodeField> {
  static const _boxHeight = 68.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: MaterialLocalizations.of(context).searchFieldLabel,
      child: Stack(
        children: [
          ListenableBuilder(
            listenable: Listenable.merge([widget.controller, widget.focusNode]),
            builder: (context, _) => _boxes(),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                autofocus: true,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.go,
                textCapitalization: TextCapitalization.characters,
                autocorrect: false,
                enableSuggestions: false,
                style: const TextStyle(fontSize: _boxHeight * .4),
                inputFormatters: [
                  _JoinCodeFormatter(),
                  LengthLimitingTextInputFormatter(kJoinCodeLength),
                ],
                onSubmitted: (_) => widget.onSubmitted?.call(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _boxes() {
    final code = widget.controller.text;
    // The caret sits on the first empty box, and on the last one once the
    // code is full — there is nowhere further to go.
    final caret = widget.focusNode.hasFocus
        ? code.length.clamp(0, kJoinCodeLength - 1)
        : -1;

    return Row(
      children: [
        for (var i = 0; i < kJoinCodeLength; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _Box(
              character: i < code.length ? code[i] : null,
              focused: i == caret,
              errored: widget.errored,
              height: _boxHeight,
            ),
          ),
        ],
      ],
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({
    required this.character,
    required this.focused,
    required this.errored,
    required this.height,
  });

  final String? character;
  final bool focused;
  final bool errored;
  final double height;

  @override
  Widget build(BuildContext context) {
    final filled = character != null;

    final background = errored
        ? AppColors.low.withValues(alpha: .12)
        : focused
        ? AppColors.signal.withValues(alpha: .16)
        : filled
        ? AppColors.fillStrong
        : AppColors.fillSubtle;

    final border = errored
        ? AppColors.low.withValues(alpha: .55)
        : focused
        ? AppColors.signal
        : null;

    return Container(
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: border == null
            ? null
            : Border.all(color: border, width: 1.5),
      ),
      child: filled
          ? Text(
              character!,
              style: AppTypography.measure.copyWith(
                fontSize: 26,
                color: errored ? const Color(0xFFF5C97A) : AppColors.ink,
              ),
            )
          : focused
          ? Container(width: 2, height: 28, color: AppColors.signalLight)
          : null,
    );
  }
}

/// Uppercases, drops everything that is not `A–Z0–9`, and unwraps a pasted
/// join link into the code it carries.
class _JoinCodeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final pastedCode = joinCodeFrom(newValue.text);
    final text = pastedCode != null && newValue.text.length > kJoinCodeLength
        ? pastedCode
        : newValue.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

    if (text == newValue.text) return newValue;

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
