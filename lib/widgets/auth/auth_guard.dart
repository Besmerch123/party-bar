import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/auth_barrier_screen.dart';

/// A wrapper widget that guards routes requiring authentication.
/// If the user is not authenticated, shows the AuthBarrierScreen instead.
class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key, required this.child, this.redirectPath});

  /// The widget to display when user is authenticated
  final Widget child;

  /// The current path to redirect to after authentication
  final String? redirectPath;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(
      builder: (context, authProvider, _) {
        // Show loading indicator while checking authentication state
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is authenticated, show the protected content
        if (authProvider.isAuthenticated) {
          return child;
        }

        // If not authenticated, show the authentication barrier
        return AuthBarrierScreen(redirectPath: redirectPath);
      },
    );
  }
}
