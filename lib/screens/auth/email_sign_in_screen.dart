import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/auth/auth_controls.dart';

/// Screen 03 — the one field the email lane needs.
///
/// No password screen ever follows this one: the same address signs someone
/// up or back in, so there is nothing to branch on here besides "is this a
/// real-looking address".
class EmailSignInScreen extends StatefulWidget {
  const EmailSignInScreen({super.key});

  @override
  State<EmailSignInScreen> createState() => _EmailSignInScreenState();
}

class _EmailSignInScreenState extends State<EmailSignInScreen> {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  late final TextEditingController _controller;
  final _focusNode = FocusNode();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<AuthenticationProvider>().pendingEmail ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Map<String, String> get _forwardedParams {
    final params = GoRouterState.of(context).uri.queryParameters;
    return {
      if (params['redirect'] case final redirect?) 'redirect': redirect,
      if (params['reason'] case final reason?) 'reason': reason,
    };
  }

  Future<void> _send() async {
    final l10n = context.l10n;
    final email = _controller.text.trim();

    if (!_emailPattern.hasMatch(email)) {
      setState(() => _errorText = l10n.authEmailInvalid);
      return;
    }
    setState(() => _errorText = null);

    final auth = context.read<AuthenticationProvider>();
    final sent = await auth.sendSignInLink(email);
    if (!mounted) return;

    if (sent) {
      final query = Uri(
        queryParameters: _forwardedParams.isEmpty ? null : _forwardedParams,
      ).query;
      context.push(
        query.isEmpty
            ? AppRoutes.authEmailSent
            : '${AppRoutes.authEmailSent}?$query',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = context.watch<AuthenticationProvider>();

    return Scaffold(
      backgroundColor: AppColors.ground,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenEdge,
              8,
              AppSpacing.screenEdge,
              24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 32,
              ),
              // Top-aligned: the keyboard owns the bottom of this screen, and
              // the one field has to stay where the thumb expects it.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AuthIconAction(
                    icon: Icons.arrow_back,
                    onTap: () => context.pop(),
                    onGlass: false,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.authEmailTitle,
                    style: AppTypography.title.copyWith(
                      fontSize: 32,
                      height: 1.02,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(l10n.authEmailBody, style: AppTypography.body),
                  const SizedBox(height: AppSpacing.md),
                  AuthTextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    icon: Icons.mail_outline,
                    hintText: l10n.authEmailHint,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.send,
                    autofillHints: const [AutofillHints.email],
                    autofocus: true,
                    errorText: _errorText,
                    onSubmitted: (_) {
                      if (!auth.isBusy) _send();
                    },
                    semanticLabel: l10n.email,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (auth.failure != null && !auth.failure!.isSilent) ...[
                    AuthFailureNotice(failure: auth.failure, onRetry: _send),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  AuthPillButton(
                    label: l10n.authEmailSend,
                    trailingIcon: Icons.arrow_forward,
                    primary: true,
                    onPressed: auth.isBusy ? null : _send,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.authEmailReturning,
                    textAlign: TextAlign.center,
                    style: AppTypography.meta.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
