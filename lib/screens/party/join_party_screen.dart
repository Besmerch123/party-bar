import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../generated/l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../services/party_service.dart';
import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/auth/auth_controls.dart';
import '../../widgets/common/glass.dart';
import '../../widgets/party/join_code_field.dart';

const _heroImage = 'assets/images/onboarding/midnight_orchard.jpg';

/// Flow 07 · screens 01 and 04 — the slow door.
///
/// Six characters and nothing else: no name, no account, no age gate. Those
/// are asked at the first order, where they mean something. The link and the
/// QR skip this screen entirely, which is why the one card above the fold
/// says so.
///
/// Screens 01 and 04 are the same screen. A refused code does not navigate
/// anywhere — it paints the boxes amber, replaces the link card with a
/// sentence naming what actually went wrong, and leaves the code in place to
/// be edited rather than retyped.
class JoinPartyScreen extends StatefulWidget {
  const JoinPartyScreen({super.key, this.initialCode, this.initialFailure});

  /// Prefilled by a link that could not be opened, so the guest lands on the
  /// slow door with the typing already done.
  final String? initialCode;

  final JoinFailure? initialFailure;

  @override
  State<JoinPartyScreen> createState() => _JoinPartyScreenState();
}

class _JoinPartyScreenState extends State<JoinPartyScreen> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();

  bool _busy = false;
  JoinFailure? _failure;
  DateTime? _endedAt;

  /// The code as of the last real edit, so a bare selection change can be
  /// told from someone actually typing.
  String _lastCode = '';

  /// The one automatic retry a network failure gets. Never more: a guest who
  /// walked out of wifi range should not watch a button spin forever.
  Timer? _retry;
  bool _retriedOnce = false;

  @override
  void initState() {
    super.initState();
    _lastCode = widget.initialCode ?? '';
    _controller = TextEditingController(text: _lastCode);
    _failure = widget.initialFailure;
    _controller.addListener(_onTyped);
  }

  @override
  void dispose() {
    _retry?.cancel();
    _controller
      ..removeListener(_onTyped)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _code => _controller.text;
  bool get _complete => _code.length == kJoinCodeLength;

  /// Editing is the guest answering the failure; the amber goes away as soon
  /// as they do, rather than sitting there through a corrected code.
  ///
  /// A [TextEditingController] also notifies when only the selection moves —
  /// which it does the moment the field takes focus — and that is not the
  /// guest answering anything. Without this the failure a link handed over
  /// would be wiped before it was ever drawn.
  void _onTyped() {
    if (_controller.text == _lastCode) return;
    _lastCode = _controller.text;
    _retry?.cancel();
    if (_failure != null) {
      setState(() {
        _failure = null;
        _endedAt = null;
        _retriedOnce = false;
      });
    } else {
      setState(() {});
    }
  }

  Future<void> _submit() async {
    if (!_complete || _busy) return;
    _retry?.cancel();

    final code = _code;
    final router = GoRouter.of(context);

    setState(() {
      _busy = true;
      _failure = null;
      _endedAt = null;
    });

    Party? party;
    try {
      party = await PartyService().joinPartyByCode(code);
    } catch (_) {
      if (!mounted) return;
      _fail(JoinFailure.offline);
      if (!_retriedOnce) {
        _retriedOnce = true;
        _retry = Timer(const Duration(seconds: 2), _submit);
      }
      return;
    }

    if (!mounted) return;

    // A draft's code is dead until the host goes live, and a guest holding
    // one has no way to tell that from a typo — so it reads as one.
    if (party == null || party.isDraft) return _fail(JoinFailure.notFound);
    if (party.isEnded) {
      return _fail(JoinFailure.ended, endedAt: party.endedAt);
    }

    _focusNode.unfocus();
    setState(() => _busy = false);
    router.pushReplacement(
      '${AppRoutes.activePartyGuest}/${party.id}',
      extra: party,
    );
  }

  void _fail(JoinFailure failure, {DateTime? endedAt}) {
    setState(() {
      _busy = false;
      _failure = failure;
      _endedAt = endedAt;
    });
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.partyHub);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: _Hero(),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenEdge,
                    8,
                    AppSpacing.screenEdge,
                    0,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GlassIconButton(
                      icon: Icons.close,
                      size: 34,
                      tooltip: l10n.joinClose,
                      onTap: _close,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenEdge,
                      34,
                      AppSpacing.screenEdge,
                      AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.joinTitle,
                          style: AppTypography.title.copyWith(fontSize: 34),
                        ),
                        const SizedBox(height: 12),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 290),
                          child: Text(
                            l10n.joinSubtitle,
                            style: AppTypography.body.copyWith(
                              color: AppColors.inkBody,
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        JoinCodeField(
                          controller: _controller,
                          focusNode: _focusNode,
                          errored: _failure != null,
                          onSubmitted: _submit,
                        ),
                        const SizedBox(height: 15),
                        if (_failure case final failure?) ...[
                          _FailureCard(failure: failure, endedAt: _endedAt),
                          const SizedBox(height: 12),
                          _AskForLinkRow(
                            onTap: () =>
                                Share.share(l10n.joinAskForLinkMessage),
                          ),
                        ] else
                          const _LinkHintCard(),
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
                  child: _submitButton(l10n),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton(AppLocalizations l10n) {
    if (_busy) {
      return Container(
        height: AppSizes.buttonPrimary,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.fillStrong,
          borderRadius: AppRadius.pillAll,
        ),
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.ink,
          ),
        ),
      );
    }

    if (!_complete) {
      return AuthPillButton(
        label: l10n.joinCodeMore(kJoinCodeLength - _code.length),
        height: AppSizes.buttonPrimary,
        onPressed: null,
      );
    }

    return AuthPillButton(
      label: _failure == null ? l10n.joinCta : l10n.joinRetry,
      primary: true,
      height: AppSizes.buttonPrimary,
      onPressed: _submit,
    );
  }
}

// ----------------------------------------------------------------- pieces

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        Image(
          image: AssetImage(_heroImage),
          fit: BoxFit.cover,
          excludeFromSemantics: true,
        ),
        PhotoScrim(),
      ],
    );
  }
}

/// The card that exists to make this screen unnecessary.
class _LinkHintCard extends StatelessWidget {
  const _LinkHintCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.fillSubtle,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.link, size: 18, color: AppColors.signalLight),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.joinLinkHint,
              style: AppTypography.meta.copyWith(fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Screen 04 — one sentence for what went wrong, one for what to do about
/// it. Never the same pair twice.
class _FailureCard extends StatelessWidget {
  const _FailureCard({required this.failure, this.endedAt});

  final JoinFailure failure;
  final DateTime? endedAt;

  static const _amber = Color(0xFFF5C97A);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final (icon, headline, detail) = switch (failure) {
      JoinFailure.notFound => (
        Icons.error,
        l10n.joinFailedNotFound,
        l10n.joinFailedNotFoundHint,
      ),
      JoinFailure.ended => (
        Icons.bedtime,
        endedAt == null
            ? l10n.joinFailedEndedNoTime
            : l10n.joinFailedEnded(
                DateFormat.Hm(
                  Localizations.localeOf(context).toLanguageTag(),
                ).format(endedAt!),
              ),
        l10n.joinFailedEndedHint,
      ),
      JoinFailure.offline => (
        Icons.wifi_off,
        l10n.joinFailedOffline,
        l10n.joinFailedOfflineHint,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.low.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.low),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  headline,
                  style: AppTypography.cardTitle.copyWith(
                    fontSize: 12.5,
                    height: 1.5,
                    color: _amber,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: AppTypography.body.copyWith(
                    fontSize: 12.5,
                    height: 1.5,
                    color: _amber.withValues(alpha: .75),
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

/// The way out of the slow door: hand the problem back to the host, who can
/// send the link that skips this screen.
class _AskForLinkRow extends StatelessWidget {
  const _AskForLinkRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.sheet,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          child: Row(
            children: [
              const Icon(
                Icons.forward_to_inbox,
                size: 18,
                color: AppColors.signalLight,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  context.l10n.joinAskForLink,
                  style: AppTypography.cardTitle.copyWith(
                    fontSize: 12.5,
                    height: 1.5,
                    color: AppColors.ink.withValues(alpha: .72),
                  ),
                ),
              ),
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
