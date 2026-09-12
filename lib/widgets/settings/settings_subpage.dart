import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/theme.dart';

/// The chrome every Flow 09 sub-page reached from the settings index shares:
/// a themed app bar with nothing but a back button, a 30pt title, an
/// optional 13pt intro line, then whatever the page wants to say below that.
///
/// [body] is omitted on screens with nothing to introduce (account & data) —
/// those get a shorter gap straight to [children] rather than a blank line
/// where the intro would have been.
class SettingsSubpageScaffold extends StatelessWidget {
  const SettingsSubpageScaffold({
    super.key,
    required this.title,
    this.body,
    this.bodyStyle,
    required this.children,
  });

  final String title;

  final String? body;

  /// Override for [body]'s style. The measures screen's intro line runs at a
  /// slightly different alpha than the others (.62 vs .6) — this keeps that
  /// pixel-for-pixel instead of quietly normalizing it away.
  final TextStyle? bodyStyle;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, 0, AppSpacing.screenEdge, 30),
          children: [
            Text(title, style: AppTypography.titleCompact),
            if (body case final text?) ...[
              const SizedBox(height: 14),
              Text(
                text,
                style:
                    bodyStyle ??
                    AppTypography.body.copyWith(fontSize: 13, color: AppColors.inkBody),
              ),
              const SizedBox(height: 22),
            ] else
              const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}
