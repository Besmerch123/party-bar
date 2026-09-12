import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/auth/auth_controls.dart';
import '../../widgets/common/app_chip.dart';
import '../../widgets/onboarding/onboarding_chrome.dart';

const _heroImage = 'assets/images/onboarding/gin_tonic.jpg';

/// Screen 08 — the guest lane, reached by scanning a party's code.
///
/// This lane never touches [AuthenticationProvider]'s account surface: a
/// name is enough to order, and nothing here creates an account. When
/// [onStart] is null the screen behaves like a form pushed for its answer —
/// it pops with the name a caller can `await`.
class GuestNameScreen extends StatefulWidget {
  const GuestNameScreen({
    super.key,
    this.partyName,
    this.hostName,
    this.onStart,
  });

  final String? partyName;
  final String? hostName;
  final ValueChanged<String>? onStart;

  @override
  State<GuestNameScreen> createState() => _GuestNameScreenState();
}

class _GuestNameScreenState extends State<GuestNameScreen> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();
  String? _nameError;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<AuthenticationProvider>().guestName ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _commit() async {
    final l10n = context.l10n;
    final name = _controller.text.trim();

    setState(() => _nameError = name.isEmpty ? l10n.guestNameRequired : null);
    if (name.isEmpty) return;

    setState(() => _busy = true);
    await context.read<AuthenticationProvider>().setGuestName(name);
    if (!mounted) return;
    setState(() => _busy = false);

    if (widget.onStart != null) {
      widget.onStart!(name);
    } else {
      context.pop(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const OnboardingHero(image: _heroImage),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.partyName != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenEdge,
                      8,
                      AppSpacing.screenEdge,
                      0,
                    ),
                    child: LiveChip(label: l10n.guestLiveAt(widget.partyName!)),
                  ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenEdge,
                        AppSpacing.md,
                        AppSpacing.screenEdge,
                        30,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - AppSpacing.md - 30,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              l10n.guestTitle,
                              style: AppTypography.display.copyWith(
                                fontSize: 38,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 310),
                              child: Text(
                                widget.hostName == null
                                    ? l10n.guestBodyNoHost
                                    : l10n.guestBody(widget.hostName!),
                                style: AppTypography.body,
                              ),
                            ),
                            const SizedBox(height: 24),
                            AuthEyebrow(label: l10n.guestNameLabel),
                            const SizedBox(height: 10),
                            AuthTextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              autofocus: true,
                              textCapitalization: TextCapitalization.words,
                              hintText: l10n.guestNameHint,
                              errorText: _nameError,
                              onSubmitted: (_) {
                                if (!_busy) _commit();
                              },
                              semanticLabel: l10n.guestNameLabel,
                            ),
                            const SizedBox(height: 16),
                            AuthPillButton(
                              primary: true,
                              icon: Icons.local_bar,
                              label: l10n.guestStartOrdering,
                              height: AppSizes.buttonPrimary,
                              onPressed: _busy ? null : _commit,
                            ),
                            const SizedBox(height: 16),
                            AuthAssuranceLine(label: l10n.guestAgeNote),
                            const SizedBox(height: 12),
                            AuthGhostAction(
                              label: l10n.guestHaveAccount,
                              tone: AppColors.signalLight,
                              onPressed: () => context.push(AppRoutes.auth),
                            ),
                          ],
                        ),
                      ),
                    ),
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
