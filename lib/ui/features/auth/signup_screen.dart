import 'package:flutter/foundation.dart';
import 'package:rtc_mobile/services/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:rtc_mobile/ui/features/dashboard/main_tab_screen.dart';
import 'package:rtc_mobile/widgets/modern_widgets.dart';
import 'package:rtc_mobile/widgets/auth_page.dart';
import 'package:rtc_mobile/widgets/feature_state.dart';
import 'package:rtc_mobile/ui/features/auth/login_screen.dart';
import 'package:rtc_mobile/utils/auth_error_message.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _acceptTerms = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  String? _errorMessage;
  bool _signupSuccess = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    setState(() => _errorMessage = null);

    if (_formKey.currentState!.validate()) {
      if (!_acceptTerms) {
        setState(
          () => _errorMessage =
              "Please read and acknowledge the privacy policy before creating an account.",
        );
        return;
      }

      final authNotifier = ref.read(authNotifierProvider.notifier);

      await authNotifier.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        department: "Member",
      );

      if (!mounted) return;
      final authState = ref.read(authNotifierProvider);
      if (!authState.hasError && authState.value != null) {
        setState(() => _signupSuccess = true);
      } else {
        setState(
          () => _errorMessage = authState.hasError
              ? authErrorMessage(authState.error!)
              : 'Registration failed. Try again.',
        );
      }
    }
  }

  Future<void> _handleGoogleSignup() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    await authNotifier.signInWithGoogle();
    if (!mounted) return;

    final authState = ref.read(authNotifierProvider);
    if (!authState.hasError && authState.value != null && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainTabScreen()),
        (route) => false,
      );
    } else if (mounted && authState.hasError) {
      final error = authState.error!;
      if (!isAuthCancellation(error)) {
        setState(() => _errorMessage = authErrorMessage(error));
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    await authNotifier.signInWithApple();
    if (!mounted) return;

    final authState = ref.read(authNotifierProvider);
    if (!authState.hasError && authState.value != null && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainTabScreen()),
        (route) => false,
      );
    } else if (mounted && authState.hasError) {
      final error = authState.error!;
      if (!isAuthCancellation(error)) {
        setState(() => _errorMessage = authErrorMessage(error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(authNotifierProvider).isLoading;
    final theme = Theme.of(context);
    if (_signupSuccess) {
      return Scaffold(
        body: SafeArea(
          child: FeatureState(
            icon: Icons.check_circle_outline_rounded,
            title: 'You belong here.',
            message: 'Your account is ready. Welcome to your church community.',
            actionLabel: 'Continue to home',
            onAction: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainTabScreen()),
              (_) => false,
            ),
          ),
        ),
      );
    }
    return AuthPage(
      title: 'Make yourself at home.',
      description:
          'Create your account and become part of our connected community.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null) ...[
              Semantics(
                liveRegion: true,
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
              const SizedBox(height: 20),
            ],
            TextFormField(
              controller: _nameController,
              enabled: !busy,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter your name'
                  : null,
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _emailController,
              enabled: !busy,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'Email address',
                prefixIcon: Icon(Icons.mail_outline),
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
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                labelText: 'Password',
                helperText: 'Use at least 8 characters',
                prefixIcon: const Icon(Icons.lock_outline),
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
              validator: (value) => value == null || value.length < 8
                  ? 'Use at least 8 characters'
                  : null,
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _confirmPasswordController,
              enabled: !busy,
              obscureText: !_showConfirmPassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                if (!busy) _handleSignup();
              },
              decoration: InputDecoration(
                labelText: 'Confirm password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  tooltip: _showConfirmPassword
                      ? 'Hide password'
                      : 'Show password',
                  onPressed: () => setState(
                    () => _showConfirmPassword = !_showConfirmPassword,
                  ),
                  icon: Icon(
                    _showConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
              validator: (value) => value != _passwordController.text
                  ? 'Passwords do not match'
                  : null,
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _acceptTerms,
              onChanged: busy
                  ? null
                  : (value) => setState(() => _acceptTerms = value ?? false),
              title: Text(
                'I have read the privacy policy.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            TextButton(
              onPressed: () => AppLinks.open(context, AppLinks.privacy),
              child: const Text('Read privacy policy'),
            ),
            const SizedBox(height: 20),
            CustomPrimaryButton(
              text: 'Create account',
              isLoading: busy,
              onPressed: _handleSignup,
            ),
            const SizedBox(height: 16),
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
              onPressed: busy ? null : _handleGoogleSignup,
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
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
              child: const Text(
                'Already part of the family? Sign in',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
