import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/auth.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/auth_barrier_screen.dart';

/// Guards the few routes that genuinely need an owner.
///
/// Deliberately not many. Browsing, searching, the guided pour, the shelf and
/// the whole guest lane are unguarded — a guest orders on a name alone, which
/// is why the join and guest-menu routes came out from behind this.
class AuthGuard extends StatelessWidget {
  const AuthGuard({
    super.key,
    required this.child,
    this.redirectPath,
    this.reason = AuthReason.hostParty,
  });

  /// The widget to display once there is an owner.
  final Widget child;

  /// Where to come back to after signing in.
  final String? redirectPath;

  /// What this route was for, so the barrier can argue for it specifically.
  final AuthReason reason;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(
      builder: (context, auth, _) {
        // Firebase restores a session asynchronously. Showing the barrier
        // before it answers would flash "you need an account" at someone who
        // has had one all along.
        if (!auth.isResolved) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (auth.isAuthenticated) return child;

        return AuthBarrierScreen(redirectPath: redirectPath, reason: reason);
      },
    );
  }
}
