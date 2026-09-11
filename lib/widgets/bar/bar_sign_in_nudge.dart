import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/auth.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bar_provider.dart';
import '../auth/auth_barrier_sheet.dart';

/// Flow 04's only sign-in moment — once, when the shelf is worth losing.
///
/// Not a gate: stocking works signed out, start to finish. Call this after an
/// action that just added something to the shelf. If the shelf has crossed
/// [kBarSignInNudgeThreshold](models/bar_item.dart) stocked items and nobody
/// is signed in, it shows the barrier once and marks it seen either way, so
/// it never asks again.
Future<void> maybeNudgeSignIn(BuildContext context) async {
  final auth = context.read<AuthenticationProvider>();
  final bar = context.read<BarProvider>();

  if (auth.isAuthenticated || !bar.signInNudgeDue) return;

  await bar.markSignInNudgeSeen();
  if (!context.mounted) return;

  await showAuthBarrierSheet(context, reason: AuthReason.editBar);
}
