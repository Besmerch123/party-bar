import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../utils/localization_helper.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.redirectPath});

  /// Path to redirect to after successful authentication
  final String? redirectPath;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isSignUp => _tabController.index == 1;

  Future<void> _handleEmailAuth() async {
    final formKey = _isSignUp ? _signUpFormKey : _signInFormKey;
    if (!formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthenticationProvider>();
    bool success;

    if (_isSignUp) {
      success = await authProvider.signUpWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      success = await authProvider.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }

    if (mounted) {
      if (success) {
        _handleSuccessfulAuth(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Authentication failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = context.read<AuthenticationProvider>();
    final success = await authProvider.signInWithGoogle();

    if (mounted) {
      if (success) {
        _handleSuccessfulAuth(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Google sign in failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.emailRequired;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return context.l10n.emailInvalid;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.passwordRequired;
    }
    if (value.length < 6) {
      return context.l10n.passwordTooShort;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (_isSignUp) {
      if (value == null || value.isEmpty) {
        return context.l10n.confirmPasswordRequired;
      }
      if (value != _passwordController.text) {
        return context.l10n.passwordsDoNotMatch;
      }
    }
    return null;
  }

  void _handleSuccessfulAuth(BuildContext context) {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isSignUp ? context.l10n.signUpSuccess : context.l10n.signInSuccess,
        ),
        backgroundColor: Colors.green,
      ),
    );

    // Handle redirect or go back
    if (widget.redirectPath != null) {
      // Replace the current route with the redirect path
      context.go(widget.redirectPath!);
    } else {
      // Just go back to the previous screen
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.authentication),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: context.l10n.signIn),
            Tab(text: context.l10n.signUp),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAuthForm(context, authProvider, isSignUp: false),
          _buildAuthForm(context, authProvider, isSignUp: true),
        ],
      ),
    );
  }

  Widget _buildAuthForm(
    BuildContext context,
    AuthenticationProvider authProvider, {
    required bool isSignUp,
  }) {
    final formKey = isSignUp ? _signUpFormKey : _signInFormKey;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),

            // Title
            Text(
              isSignUp ? context.l10n.createAccount : context.l10n.welcomeBack,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isSignUp
                  ? context.l10n.signUpSubtitle
                  : context.l10n.signInSubtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Email field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: context.l10n.email,
                hintText: context.l10n.emailHint,
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),

            // Password field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: context.l10n.password,
                hintText: context.l10n.passwordHint,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: _validatePassword,
            ),
            const SizedBox(height: 16),

            // Confirm Password field (only for sign up)
            if (isSignUp) ...[
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: context.l10n.confirmPassword,
                  hintText: context.l10n.confirmPasswordHint,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: _validateConfirmPassword,
              ),
              const SizedBox(height: 16),
            ],

            // Sign in/up button
            ElevatedButton(
              onPressed: authProvider.isLoading ? null : _handleEmailAuth,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: authProvider.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      isSignUp ? context.l10n.signUp : context.l10n.signIn,
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(height: 24),

            // Divider
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    context.l10n.orContinueWith,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 24),

            // Google sign in button
            OutlinedButton.icon(
              onPressed: authProvider.isLoading ? null : _handleGoogleSignIn,
              icon: Image.asset(
                'assets/icons/google_logo.png',
                height: 24,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.g_mobiledata, size: 24);
                },
              ),
              label: Text(context.l10n.continueWithGoogle),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
