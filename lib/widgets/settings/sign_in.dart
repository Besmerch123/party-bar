import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_router.dart';
import '../../utils/localization_helper.dart';

/// A menu item widget for settings screen that handles user authentication.
/// Shows "Log in" button when user is not authenticated, navigating to auth screen.
/// Shows "Logout" button when user is authenticated, signing out the user.
class SignInMenuItem extends StatelessWidget {
  const SignInMenuItem({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.logoutSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.logoutError),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleLogin(BuildContext context) {
    context.push(AppRoutes.auth);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final isLoggedIn = snapshot.hasData && snapshot.data != null;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Card(
          child: ListTile(
            leading: Icon(
              isLoggedIn ? Icons.logout : Icons.login,
              color: isLoggedIn ? Colors.red : Colors.green,
            ),
            title: Text(
              isLoggedIn ? context.l10n.logout : context.l10n.login,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            subtitle: isLoggedIn && snapshot.data?.email != null
                ? Text(snapshot.data!.email!)
                : null,
            trailing: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
            onTap: isLoading
                ? null
                : () {
                    if (isLoggedIn) {
                      _handleLogout(context);
                    } else {
                      _handleLogin(context);
                    }
                  },
          ),
        );
      },
    );
  }
}
