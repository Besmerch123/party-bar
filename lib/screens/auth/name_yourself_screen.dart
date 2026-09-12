import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n/app_localizations.dart';
import '../../models/auth.dart';
import '../../providers/auth_provider.dart';
import '../../theme/theme.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/auth/auth_controls.dart';
import '../../widgets/common/app_chip.dart';

/// Screen 05 — the one thing the email lane needs that a provider lane does
/// not.
///
/// Google hands us a name on the way in, so anyone with a [AuthenticationProvider.displayName]
/// already set is routed straight past this screen; it exists only for
/// [AuthenticationProvider.needsDisplayName].
class NameYourselfScreen extends StatefulWidget {
  const NameYourselfScreen({super.key});

  @override
  State<NameYourselfScreen> createState() => _NameYourselfScreenState();
}

class _NameYourselfScreenState extends State<NameYourselfScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _ageChecked = false;
  String? _nameError;
  String? _ageError;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Map<String, String> get _params =>
      GoRouterState.of(context).uri.queryParameters;

  AuthReason get _reason =>
      AuthReason.values.where((r) => r.name == _params['reason']).firstOrNull ??
      AuthReason.cold;

  String _commitLabel(AppLocalizations l10n) => switch (_reason) {
    AuthReason.hostParty => l10n.authFinishHost,
    AuthReason.editBar => l10n.authFinishBar,
    AuthReason.saveCocktail => l10n.authFinishSave,
    AuthReason.cold => l10n.authFinishGeneric,
  };

  Future<void> _commit() async {
    final l10n = context.l10n;
    final name = _controller.text.trim();
    final ageOk = _ageChecked;

    setState(() {
      _nameError = name.isEmpty ? l10n.authNameRequired : null;
      _ageError = ageOk ? null : l10n.authAgeRequired;
    });
    if (name.isEmpty || !ageOk) return;

    final auth = context.read<AuthenticationProvider>();
    final saved = await auth.saveDisplayName(name);
    if (!mounted || !saved) return;

    context.go(_params['redirect'] ?? '/');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = context.watch<AuthenticationProvider>();

    // The commit is pinned to the bottom edge while everything it is
    // committing scrolls above it — with the keyboard up on a short phone,
    // the button someone is reaching for must not be the thing that scrolls
    // away.
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  22,
                  AppSpacing.screenEdge,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusChip(
                      label: l10n.authSignedInBadge,
                      tone: ChipTone.ready,
                      icon: Icons.check,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      l10n.authNameTitle,
                      style: AppTypography.title.copyWith(
                        fontSize: 32,
                        height: 1.02,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(l10n.authNameBody, style: AppTypography.body),
                    const SizedBox(height: 26),
                    _AvatarRow(l10n: l10n),
                    const SizedBox(height: AppSpacing.md),
                    AuthEyebrow(label: l10n.authDisplayNameLabel),
                    const SizedBox(height: 10),
                    AuthTextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.name],
                      hintText: l10n.authDisplayNameHint,
                      textInputAction: TextInputAction.done,
                      errorText: _nameError,
                      onSubmitted: (_) {
                        if (!auth.isBusy) _commit();
                      },
                      semanticLabel: l10n.authDisplayNameLabel,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AuthAgeGate(
                      checked: _ageChecked,
                      onChanged: (checked) => setState(() {
                        _ageChecked = checked;
                        if (checked) _ageError = null;
                      }),
                      errorText: _ageError,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AuthLegalLine(
                      sentence: l10n.authAgeLegal(
                        l10n.authTerms,
                        l10n.authPrivacy,
                      ),
                      termsLabel: l10n.authTerms,
                      privacyLabel: l10n.authPrivacy,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
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
                  if (auth.failure != null && !auth.failure!.isSilent) ...[
                    AuthFailureNotice(failure: auth.failure, onRetry: _commit),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  AuthCommitButton(
                    label: _commitLabel(l10n),
                    onPressed: _commit,
                    busy: auth.isBusy,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The avatar row: a placeholder circle, a camera badge, and a caption.
///
/// TODO(flow-03): wire an avatar picker once an image-picker dependency is
/// added to the project — nothing here is tappable in the meantime.
class _AvatarRow extends StatelessWidget {
  const _AvatarRow({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${l10n.authAddPhoto}. ${l10n.authAddPhotoNote}',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.row,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 34,
                    color: AppColors.inkGhost,
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.signal,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.ground, width: 3),
                    ),
                    child: const Icon(
                      Icons.photo_camera,
                      size: 16,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.authAddPhoto,
                  style: AppTypography.body.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkMeta,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.authAddPhotoNote,
                  style: AppTypography.meta.copyWith(
                    fontSize: 12,
                    height: 1.45,
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
