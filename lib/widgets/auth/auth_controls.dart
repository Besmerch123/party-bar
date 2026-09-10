import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../models/auth.dart';
import '../../theme/theme.dart';
import '../../utils/localization_helper.dart';
import '../common/glass.dart';

/// The shared vocabulary of flow 03.
///
/// Nine screens ask the same few things — pick a provider, type one line,
/// agree to be an adult, back out — so those live here once. The only axis
/// that varies is [onGlass]: over photography the controls are blurred glass,
/// and on [AppColors.ground] they are flat fills, because glass over a flat
/// dark surface reads as mud.

/// Height of every pill in the flow. Providers, commits and ghosts all match,
/// so a stack of them is a single column of one rhythm.
const double _kPillHeight = 54.0;

/// Google's and Apple's marks are placeholders here.
///
/// TODO(flow-03): ship the official Google and Apple assets and their required
/// button geometry before release — both vendors specify it and neither
/// permits a hand-drawn stand-in.
class _GoogleMark extends StatelessWidget {
  const _GoogleMark({this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.ground,
        shape: BoxShape.circle,
      ),
      child: Text(
        'G',
        style: AppTypography.buttonPrimary.copyWith(
          fontSize: size * 0.55,
          color: AppColors.ink,
          height: 1.0,
        ),
      ),
    );
  }
}

class _AppleMark extends StatelessWidget {
  const _AppleMark({this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.ink.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(size * 0.27),
      ),
      child: Icon(Icons.apple, size: size * 0.72, color: AppColors.ground),
    );
  }
}

/// One provider button.
///
/// Google carries the white fill because it is the lane that works; the rest
/// sit on a translucent fill so the column has one obvious answer.
class AuthProviderButton extends StatelessWidget {
  const AuthProviderButton({
    super.key,
    required this.kind,
    required this.onPressed,
    this.label,
    this.primary = false,
    this.onGlass = false,
    this.badge,
    this.height = _kPillHeight,
    this.compact = false,
  });

  final AuthProviderKind kind;

  /// Null disables the button — used while an attempt is in flight.
  final VoidCallback? onPressed;

  /// Overrides the default wording. Screen 09 says "Save with Google" where
  /// screens 01 and 02 say "Continue with Google".
  final String? label;

  /// The white fill. At most one per column.
  final bool primary;

  final bool onGlass;

  /// The SOON tag on Apple.
  final String? badge;

  final double height;

  /// Drops the icon gap for the split row on screen 09.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final text =
        label ??
        switch (kind) {
          AuthProviderKind.google => l10n.authContinueGoogle,
          AuthProviderKind.apple => l10n.authContinueApple,
          AuthProviderKind.email => l10n.authContinueEmail,
        };

    final foreground = primary
        ? AppColors.ground
        : AppColors.ink.withValues(alpha: .9);

    final Widget mark = switch (kind) {
      AuthProviderKind.google => _GoogleMark(size: compact ? 20 : 22),
      AuthProviderKind.apple => _AppleMark(size: compact ? 20 : 22),
      AuthProviderKind.email => Icon(
        Icons.mail_outline,
        size: compact ? 19 : 20,
        color: foreground,
      ),
    };

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: compact ? 8 : 10),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.buttonPrimary.copyWith(
              fontSize: compact ? 13.5 : 14.5,
              color: foreground,
            ),
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 10),
          _Badge(label: badge!),
        ],
      ],
    );

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: text,
      child: Opacity(
        opacity: onPressed == null ? .5 : 1,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: primary
              ? Material(
                  color: AppColors.ink,
                  borderRadius: AppRadius.pillAll,
                  child: InkWell(
                    borderRadius: AppRadius.pillAll,
                    onTap: onPressed,
                    child: Center(child: content),
                  ),
                )
              : onGlass
              ? GlassSurface(
                  onTap: onPressed,
                  child: Center(child: content),
                )
              : Material(
                  color: AppColors.fillStrong,
                  borderRadius: AppRadius.pillAll,
                  child: InkWell(
                    borderRadius: AppRadius.pillAll,
                    onTap: onPressed,
                    child: Center(child: content),
                  ),
                ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.signalWash,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.label.copyWith(
          fontSize: 9.5,
          color: AppColors.signalLight,
        ),
      ),
    );
  }
}

/// The provider column: Google, then Apple where it exists, then email.
///
/// The order is fixed. Apple is drawn only while [kAppleSignInEnabled] is
/// true, so hiding an unfinished lane is one constant rather than an `if` on
/// four screens.
class AuthProviderColumn extends StatelessWidget {
  const AuthProviderColumn({
    super.key,
    required this.onGoogle,
    required this.onEmail,
    this.onApple,
    this.onGlass = false,
    this.enabled = true,
  });

  final VoidCallback onGoogle;
  final VoidCallback onEmail;
  final VoidCallback? onApple;
  final bool onGlass;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AuthProviderButton(
          kind: AuthProviderKind.google,
          primary: true,
          onPressed: enabled ? onGoogle : null,
        ),
        if (kAppleSignInEnabled) ...[
          const SizedBox(height: 10),
          AuthProviderButton(
            kind: AuthProviderKind.apple,
            onGlass: onGlass,
            onPressed: enabled ? onApple : null,
          ),
        ],
        const SizedBox(height: 10),
        AuthProviderButton(
          kind: AuthProviderKind.email,
          onGlass: onGlass,
          onPressed: enabled ? onEmail : null,
        ),
      ],
    );
  }
}

/// A pill that is neither a provider nor the commit — "Open Mail", "Send a new
/// link", "Use a different address".
class AuthPillButton extends StatelessWidget {
  const AuthPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.primary = false,
    this.height = _kPillHeight,
    this.background,
    this.foreground,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Leads the label, for pills that name a destination — "Open Mail".
  final IconData? icon;

  /// Trails it, for pills that advance the flow — "Send the link →".
  final IconData? trailingIcon;

  /// The white fill.
  final bool primary;
  final double height;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final fill = background ?? (primary ? AppColors.ink : AppColors.fillStrong);
    final ink =
        foreground ??
        (primary ? AppColors.ground : AppColors.ink.withValues(alpha: .75));

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      child: Opacity(
        opacity: onPressed == null ? .5 : 1,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Material(
            color: fill,
            borderRadius: AppRadius.pillAll,
            child: InkWell(
              borderRadius: AppRadius.pillAll,
              onTap: onPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: ink),
                    const SizedBox(width: 9),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.buttonPrimary.copyWith(
                        fontSize: 14.5,
                        color: ink,
                      ),
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 9),
                    Icon(trailingIcon, size: 19, color: ink),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The accent commit at the bottom of a screen — the one button that finishes
/// what the barrier interrupted.
class AuthCommitButton extends StatelessWidget {
  const AuthCommitButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.buttonPrimary,
      width: double.infinity,
      child: FilledButton(
        onPressed: busy ? null : onPressed,
        child: busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.ink,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 9),
                    Icon(icon, size: 20),
                  ],
                ],
              ),
      ),
    );
  }
}

/// The quiet way out. Never styled as a button — leaving is allowed, not
/// encouraged.
class AuthGhostAction extends StatelessWidget {
  const AuthGhostAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.tone = AppColors.inkMeta,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.minTap,
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.buttonSecondary.copyWith(
            fontSize: 13.5,
            color: tone,
          ),
        ),
      ),
    );
  }
}

/// 34px visual inside a 44px hit box, so nothing tappable falls below
/// [AppSizes.minTap].
class AuthIconAction extends StatelessWidget {
  const AuthIconAction({
    super.key,
    required this.icon,
    required this.onTap,
    this.onGlass = false,
    this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool onGlass;
  final String? semanticLabel;

  static const _visualSize = 34.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: AppSizes.minTap,
          width: AppSizes.minTap,
          child: Center(
            child: onGlass
                ? GlassIconButton(icon: icon, size: _visualSize, onTap: onTap)
                : Container(
                    width: _visualSize,
                    height: _visualSize,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.fillMuted,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 18, color: AppColors.ink),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Uppercase overline naming what a block is about.
class AuthEyebrow extends StatelessWidget {
  const AuthEyebrow({super.key, required this.label, this.tinted = false});

  final String label;

  /// The tinted chip variant used over photography; plain text elsewhere.
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label.toUpperCase(),
      style: AppTypography.label.copyWith(
        color: tinted ? AppColors.signalLight : AppColors.inkMeta,
      ),
    );

    if (!tinted) return text;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.signalWash,
        borderRadius: BorderRadius.circular(8),
      ),
      child: text,
    );
  }
}

/// The one field shape in the flow: 58 tall, [AppRadius.tile], and a signal
/// ring while it holds focus.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.hintText,
    this.icon,
    this.keyboardType,
    this.textInputAction = TextInputAction.done,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.autofocus = false,
    this.errorText,
    this.onSubmitted,
    this.onChanged,
    this.semanticLabel,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? hintText;
  final IconData? icon;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final bool autofocus;

  /// Rendered under the field rather than inside it, so the field keeps its
  /// height and the column below does not jump by a hair.
  final String? errorText;

  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 58,
          child: Semantics(
            textField: true,
            label: semanticLabel,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: autofocus,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              textCapitalization: textCapitalization,
              autofillHints: autofillHints,
              onSubmitted: onSubmitted,
              onChanged: onChanged,
              cursorColor: AppColors.signal,
              style: AppTypography.body.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: AppColors.ink,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: icon == null
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(left: 16, right: 10),
                        child: Icon(
                          icon,
                          size: 19,
                          color: AppColors.signalLight,
                        ),
                      ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0),
                contentPadding: EdgeInsets.fromLTRB(
                  icon == null ? 16 : 0,
                  0,
                  16,
                  0,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.tileAll,
                  borderSide: errorText == null
                      ? BorderSide.none
                      : const BorderSide(color: AppColors.low, width: 1.5),
                ),
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: AppTypography.meta.copyWith(color: AppColors.low),
          ),
        ],
      ],
    );
  }
}

/// The age gate. One checkbox, at the point an identity is created — never a
/// date-of-birth wheel, and never on launch.
class AuthAgeGate extends StatelessWidget {
  const AuthAgeGate({
    super.key,
    required this.checked,
    required this.onChanged,
    this.errorText,
  });

  final bool checked;
  final ValueChanged<bool> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          checked: checked,
          child: Material(
            color: AppColors.sheet,
            borderRadius: AppRadius.tileAll,
            child: InkWell(
              borderRadius: AppRadius.tileAll,
              onTap: () => onChanged(!checked),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: AppMotion.tap,
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: checked ? AppColors.signal : AppColors.fillMuted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.check,
                        size: 17,
                        color: checked
                            ? AppColors.ink
                            : AppColors.ink.withValues(alpha: .25),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.l10n.authAgeConfirm,
                        style: AppTypography.body.copyWith(
                          fontSize: 13.5,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: AppTypography.meta.copyWith(color: AppColors.low),
          ),
        ],
      ],
    );
  }
}

/// The terms and privacy sentence, with both documents tappable.
///
/// The sentence comes from one translated string carrying both names as
/// placeholders, so a translator can move them; the spans are found by
/// locating those names in the finished sentence rather than by concatenating
/// fragments.
class AuthLegalLine extends StatefulWidget {
  const AuthLegalLine({
    super.key,
    required this.sentence,
    required this.termsLabel,
    required this.privacyLabel,
    this.onTerms,
    this.onPrivacy,
    this.textAlign = TextAlign.center,
  });

  /// Already-substituted sentence, e.g. `l10n.authLegalLine(terms, privacy)`.
  final String sentence;
  final String termsLabel;
  final String privacyLabel;
  final VoidCallback? onTerms;
  final VoidCallback? onPrivacy;
  final TextAlign textAlign;

  @override
  State<AuthLegalLine> createState() => _AuthLegalLineState();
}

class _AuthLegalLineState extends State<AuthLegalLine> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = AppTypography.meta.copyWith(fontSize: 11.5, height: 1.5);
    final link = base.copyWith(
      color: AppColors.signalLight,
      fontWeight: FontWeight.w600,
    );

    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();

    // Both link labels, in the order they actually appear in this language's
    // sentence — which is not necessarily terms first.
    final links = <({int start, String label, VoidCallback? onTap})>[
      (
        start: widget.sentence.indexOf(widget.termsLabel),
        label: widget.termsLabel,
        onTap: widget.onTerms,
      ),
      (
        start: widget.sentence.indexOf(widget.privacyLabel),
        label: widget.privacyLabel,
        onTap: widget.onPrivacy,
      ),
    ]..sort((a, b) => a.start.compareTo(b.start));

    final spans = <InlineSpan>[];
    var cursor = 0;

    for (final entry in links) {
      // A translation that dropped or reworded a label leaves the sentence
      // whole rather than losing text to a bad offset.
      if (entry.start < cursor) continue;

      if (entry.start > cursor) {
        spans.add(
          TextSpan(text: widget.sentence.substring(cursor, entry.start)),
        );
      }

      final recognizer = TapGestureRecognizer()..onTap = entry.onTap;
      _recognizers.add(recognizer);
      spans.add(
        TextSpan(text: entry.label, style: link, recognizer: recognizer),
      );
      cursor = entry.start + entry.label.length;
    }

    if (cursor < widget.sentence.length) {
      spans.add(TextSpan(text: widget.sentence.substring(cursor)));
    }

    return Text.rich(
      TextSpan(style: base, children: spans),
      textAlign: widget.textAlign,
    );
  }
}

/// The "18+ only · we never post anything" reassurance under a provider
/// column.
class AuthAssuranceLine extends StatelessWidget {
  const AuthAssuranceLine({
    super.key,
    required this.label,
    this.icon = Icons.shield_outlined,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.inkMeta),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.meta.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// The four failures worth writing, and nothing else.
///
/// A dismissed provider sheet renders nothing at all: back to where you were,
/// no error, no toast.
class AuthFailureNotice extends StatelessWidget {
  const AuthFailureNotice({
    super.key,
    required this.failure,
    this.onRetry,
    this.onUseGoogle,
  });

  final AuthFailure? failure;
  final VoidCallback? onRetry;

  /// The way out of [AuthFailureKind.differentProvider]: this error is never a
  /// dead end, it is a button.
  final VoidCallback? onUseGoogle;

  @override
  Widget build(BuildContext context) {
    final f = failure;
    if (f == null || f.isSilent) return const SizedBox.shrink();

    final l10n = context.l10n;

    final (
      String message,
      IconData icon,
      Color tone,
      String action,
      VoidCallback? onAction,
    ) = switch (f.kind) {
      AuthFailureKind.differentProvider => (
        f.email == null
            ? l10n.authErrorDifferentProviderNoEmail
            : l10n.authErrorDifferentProvider(f.email!),
        Icons.merge_type,
        AppColors.signalLight,
        l10n.authContinueGoogle,
        onUseGoogle,
      ),
      AuthFailureKind.offline => (
        l10n.authErrorOffline,
        Icons.wifi_off,
        AppColors.low,
        l10n.authErrorRetry,
        onRetry,
      ),
      AuthFailureKind.expiredLink => (
        l10n.authExpiredBody,
        Icons.schedule,
        AppColors.low,
        l10n.authSendNewLink,
        onRetry,
      ),
      _ => (
        l10n.authErrorGeneric,
        Icons.error_outline,
        AppColors.low,
        l10n.authErrorRetry,
        onRetry,
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tone == AppColors.low ? AppColors.lowWash : AppColors.signalWash,
        borderRadius: AppRadius.tileAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: tone),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: AppTypography.meta.copyWith(
                    fontSize: 12,
                    color: AppColors.ink.withValues(alpha: .85),
                  ),
                ),
                if (onAction != null) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: onAction,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        action,
                        style: AppTypography.buttonSecondary.copyWith(
                          fontSize: 12.5,
                          color: tone,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
