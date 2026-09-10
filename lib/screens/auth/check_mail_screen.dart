import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/auth.dart';
import '../../providers/auth_provider.dart';
import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/auth/auth_controls.dart';

/// Screen 04 — the wait between sending a link and someone tapping it.
///
/// Two ways to finish this lane exist side by side: tap the link mailed to
/// this address, or type the six-digit code the same mail carries, for
/// whoever opened it on a different device. Neither is a fallback for the
/// other; both are always live.
class CheckMailScreen extends StatefulWidget {
  const CheckMailScreen({super.key});

  @override
  State<CheckMailScreen> createState() => _CheckMailScreenState();
}

class _CheckMailScreenState extends State<CheckMailScreen> {
  // Ticks the resend countdown once a second. The remaining time itself is
  // always read fresh from [AuthenticationProvider.resendAvailableAt], so
  // coming back to this screen mid-wait shows the real time left rather than
  // a clock that restarted at 0:45.
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _openMail() async {
    // A phone with no mail app configured is not an error worth a toast —
    // the person still has the code fallback below.
    try {
      await launchUrl(
        Uri(scheme: 'mailto'),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      // Nothing visible.
    }
  }

  Future<void> _handleCode(String code) async {
    final auth = context.read<AuthenticationProvider>();
    final ok = await auth.signInWithEmailCode(code);
    if (!mounted) return;

    if (ok) {
      final redirect = GoRouterState.of(
        context,
      ).uri.queryParameters['redirect'];
      if (auth.needsDisplayName) {
        context.push(_appendForwardedParams(context, AppRoutes.authName));
      } else {
        context.go(redirect ?? AppRoutes.home);
      }
      return;
    }

    if (auth.failure?.kind == AuthFailureKind.expiredLink) {
      context.pushReplacement(
        _appendForwardedParams(context, AppRoutes.authEmailExpired),
      );
    }
  }

  void _changeEmail() {
    context.read<AuthenticationProvider>().forgetPendingEmail();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthenticationProvider>();
    final l10n = context.l10n;
    final email = auth.pendingEmail;

    // A cold arrival — no address on file to check the mail for — has
    // nothing to say here; hand it back to the screen that collects one.
    if (email == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.pushReplacement(
            _appendForwardedParams(context, AppRoutes.authEmail),
          );
        }
      });
      return const Scaffold(backgroundColor: AppColors.ground);
    }

    final resendReady = _resendReady(auth);

    // One scroll view, two blocks: the mail is at the top and the code card
    // sits on the bottom edge while there is room for it, and the whole thing
    // scrolls as one on a short phone rather than pinning a card over the
    // sentence explaining it.
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenEdge,
                      8,
                      AppSpacing.screenEdge,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AuthIconAction(
                          icon: Icons.arrow_back,
                          onTap: () => context.pop(),
                          onGlass: false,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const _RoundedBadge(
                          icon: Icons.forward_to_inbox,
                          background: AppColors.signalWash,
                          foreground: AppColors.signalLight,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          l10n.authCheckMailTitle,
                          style: AppTypography.title.copyWith(
                            fontSize: 32,
                            height: 1.02,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _EmphasisedBody(
                          sentence: l10n.authCheckMailBody(email),
                          emphasis: email,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AuthPillButton(
                          label: l10n.authOpenMail,
                          icon: Icons.mail_outline,
                          primary: true,
                          onPressed: _openMail,
                        ),
                        const SizedBox(height: 10),
                        _ResendRow(
                          ready: resendReady,
                          remaining: _remaining(auth),
                          onResend: () => context
                              .read<AuthenticationProvider>()
                              .resendSignInLink(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenEdge,
                      AppSpacing.md,
                      AppSpacing.screenEdge,
                      30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.cardInset),
                          decoration: const BoxDecoration(
                            color: AppColors.sheet,
                            borderRadius: AppRadius.cardAll,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.authOtherDeviceTitle,
                                style: AppTypography.cardTitle,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.authOtherDeviceBody,
                                style: AppTypography.meta,
                              ),
                              const SizedBox(height: 14),
                              _CodeField(
                                semanticLabel: l10n.authCodeLabel,
                                onCompleted: _handleCode,
                              ),
                            ],
                          ),
                        ),
                        if (auth.failure != null &&
                            !auth.failure!.isSilent) ...[
                          const SizedBox(height: AppSpacing.sm),
                          AuthFailureNotice(failure: auth.failure),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        AuthGhostAction(
                          label: l10n.authChangeEmail,
                          onPressed: _changeEmail,
                          tone: AppColors.signalLight,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _resendReady(AuthenticationProvider auth) {
    final at = auth.resendAvailableAt;
    if (at == null) return true;
    return !DateTime.now().isBefore(at);
  }

  Duration _remaining(AuthenticationProvider auth) {
    final at = auth.resendAvailableAt;
    if (at == null) return Duration.zero;
    final left = at.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }
}

/// Forwards this screen's `redirect`/`reason` onto the next route in the
/// lane, the same way every screen in flow 03 hands them along.
String _appendForwardedParams(BuildContext context, String path) {
  final params = GoRouterState.of(context).uri.queryParameters;
  final forwarded = <String, String>{
    if (params['redirect'] case final redirect?) 'redirect': redirect,
    if (params['reason'] case final reason?) 'reason': reason,
  };
  if (forwarded.isEmpty) return path;
  return '$path?${Uri(queryParameters: forwarded).query}';
}

class _RoundedBadge extends StatelessWidget {
  const _RoundedBadge({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, size: 27, color: foreground),
    );
  }
}

/// The sent-to sentence with the address itself picked out in bold white.
///
/// The address is found by locating it in the finished, translated sentence
/// rather than by concatenating fragments — the same approach [AuthLegalLine]
/// uses for its two link labels.
class _EmphasisedBody extends StatelessWidget {
  const _EmphasisedBody({required this.sentence, required this.emphasis});

  final String sentence;
  final String emphasis;

  @override
  Widget build(BuildContext context) {
    final base = AppTypography.body;
    final index = sentence.indexOf(emphasis);

    if (index < 0) {
      // A translation that dropped the placeholder leaves the sentence
      // whole rather than losing text to a bad offset.
      return Text(sentence, style: base);
    }

    final strong = base.copyWith(
      color: AppColors.ink,
      fontWeight: FontWeight.w700,
    );
    final tail = index + emphasis.length;

    return Text.rich(
      TextSpan(
        style: base,
        children: [
          if (index > 0) TextSpan(text: sentence.substring(0, index)),
          TextSpan(text: emphasis, style: strong),
          if (tail < sentence.length) TextSpan(text: sentence.substring(tail)),
        ],
      ),
    );
  }
}

/// The resend affordance: a sleeping countdown row, then a tappable pill once
/// [AuthenticationProvider.resendCooldown] has passed.
class _ResendRow extends StatelessWidget {
  const _ResendRow({
    required this.ready,
    required this.remaining,
    required this.onResend,
  });

  final bool ready;
  final Duration remaining;
  final VoidCallback onResend;

  static String _format(Duration d) {
    final seconds = d.inSeconds;
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    return '$minutes:${rest.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (ready) {
      return AuthPillButton(
        label: l10n.authResend,
        onPressed: onResend,
        height: 52,
      );
    }

    return Semantics(
      label: l10n.authResendIn(_format(remaining)),
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.fillSubtle,
          borderRadius: AppRadius.pillAll,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.schedule, size: 18, color: AppColors.inkMeta),
            const SizedBox(width: 9),
            Flexible(
              child: Text(
                l10n.authResendIn(_format(remaining)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.measure.copyWith(
                  fontSize: 13,
                  color: AppColors.inkMeta,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Six painted boxes reacting to one hidden field, rather than six fields
/// hopping focus between each other — the hop breaks on autofill, which is
/// exactly the path this field exists for.
class _CodeField extends StatefulWidget {
  const _CodeField({required this.onCompleted, required this.semanticLabel});

  final ValueChanged<String> onCompleted;
  final String semanticLabel;

  static const _length = 6;

  @override
  State<_CodeField> createState() => _CodeFieldState();
}

class _CodeFieldState extends State<_CodeField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() => setState(() {});

  void _onChanged() {
    setState(() {});
    if (_controller.text.length == _CodeField._length) {
      widget.onCompleted(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final digits = _controller.text;
    final activeIndex =
        _focusNode.hasFocus && digits.length < _CodeField._length
        ? digits.length
        : -1;

    return SizedBox(
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: List.generate(_CodeField._length, (index) {
              final filled = index < digits.length;
              final active = index == activeIndex;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: index == _CodeField._length - 1 ? 0 : 8,
                  ),
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.row,
                    borderRadius: BorderRadius.circular(14),
                    border: active
                        ? Border.all(color: AppColors.signal, width: 1.5)
                        : null,
                  ),
                  child: Text(
                    filled ? digits[index] : '',
                    style: AppTypography.measure.copyWith(
                      fontSize: 20,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              );
            }),
          ),
          Opacity(
            opacity: 0,
            child: Semantics(
              textField: true,
              label: widget.semanticLabel,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLength: _CodeField._length,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autofillHints: const [AutofillHints.oneTimeCode],
                showCursor: false,
                decoration: const InputDecoration(border: InputBorder.none),
                buildCounter:
                    (
                      context, {
                      required currentLength,
                      required isFocused,
                      maxLength,
                    }) => null,
                style: const TextStyle(color: Colors.transparent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
