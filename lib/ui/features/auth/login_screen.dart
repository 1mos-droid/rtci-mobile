import 'package:flutter/foundation.dart';
import 'package:rtc_mobile/widgets/custom_logo_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rtc_mobile/widgets/modern_widgets.dart';
import 'package:rtc_mobile/widgets/auth_page.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:rtc_mobile/ui/features/dashboard/main_tab_screen.dart';
import 'package:rtc_mobile/ui/features/auth/signup_screen.dart';
import 'package:rtc_mobile/utils/auth_error_message.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Shared outcome handling for every sign-in method on this screen.
  void _handleAuthResult() {
    if (!mounted) return;
    final authState = ref.read(authNotifierProvider);
    if (!authState.hasError && authState.value != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainTabScreen()),
        (route) => false,
      );
    } else if (authState.hasError) {
      final error = authState.error!;
      if (!isAuthCancellation(error)) _showError(authErrorMessage(error));
    } else {
      _showError('Sign in failed. Please try again.');
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authNotifierProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);
    _handleAuthResult();
  }

  Future<void> _handleGoogleLogin() async {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
    _handleAuthResult();
  }

  Future<void> _handleAppleSignIn() async {
    await ref.read(authNotifierProvider.notifier).signInWithApple();
    _handleAuthResult();
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('Please enter your email address first.');
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CustomLogoLoader(size: 48)),
      );

      await ref.read(authRepositoryProvider).sendPasswordReset(email);

      if (mounted) {
        Navigator.pop(context); // Dismiss loading
        showAdaptiveDialog(
          context: context,
          builder: (_) => AlertDialog.adaptive(
            title: const Text("Password Reset Sent"),
            content: Text(
              "A link to reset your password has been sent to $email. Please follow instructions in the email.",
            ),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading
        _showError(authErrorMessage(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(authNotifierProvider).isLoading;
    return AuthPage(
      title: 'Welcome back.',
      description: 'Sign in to stay close to your church family.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              enabled: !busy,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Email address',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
              validator: (value) =>
                  value == null ||
                      !RegExp(
                        r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                      ).hasMatch(value.trim())
                  ? 'Enter a valid email address'
                  : null,
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _passwordController,
              enabled: !busy,
              obscureText: !_showPassword,
              autofillHints: const [AutofillHints.password],
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                if (!busy) _handleLogin();
              },
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: _showPassword ? 'Hide password' : 'Show password',
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                  icon: Icon(
                    _showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter your password' : null,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: busy ? null : _handleForgotPassword,
                child: const Text('Forgot password?'),
              ),
            ),
            const SizedBox(height: 12),
            CustomPrimaryButton(
              text: 'Sign in',
              isLoading: busy,
              onPressed: _handleLogin,
              icon: Icons.arrow_forward_rounded,
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or'),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),
            if (!kIsWeb &&
                (defaultTargetPlatform == TargetPlatform.iOS ||
                    defaultTargetPlatform == TargetPlatform.macOS)) ...[
              OutlinedButton.icon(
                onPressed: busy ? null : _handleAppleSignIn,
                icon: const FaIcon(FontAwesomeIcons.apple, size: 20),
                label: const Text('Continue with Apple'),
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton(
              onPressed: busy ? null : _handleGoogleLogin,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.google, size: 18),
                  SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Continue with Google',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: busy
                  ? null
                  : () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    ),
              child: const Text(
                'New to RTCI Connect? Create an account',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
