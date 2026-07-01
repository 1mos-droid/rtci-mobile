import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:rtc_mobile/ui/features/dashboard/main_tab_screen.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/ui/features/auth/login_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

  bool _acceptTerms = true;
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
        setState(() => _errorMessage = "You must agree to the rules to create an account.");
        return;
      }

      final authNotifier = ref.read(authNotifierProvider.notifier);

      await authNotifier.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        department: "Member",
      );

      final authState = ref.read(authNotifierProvider);
      if (!authState.hasError) {
        setState(() => _signupSuccess = true);
      } else {
        setState(() => _errorMessage = authState.error?.toString() ?? "Registration failed. Try again.");
      }
    }
  }

  Future<void> _handleGoogleSignup() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    await authNotifier.signInWithGoogle();
    
    final authState = ref.read(authNotifierProvider);
    if (!authState.hasError && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainTabScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: MeshGradientBackground(
        child: SafeArea(
          child: _signupSuccess
              ? _buildSuccessScreen(context)
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Back Button
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios_new, size: 18, color: ObsidianTheme.textVibrant),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        
                        Text(
                          "Create Account",
                          style: Theme.of(context).textTheme.displayMedium,
                        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),
                        const SizedBox(height: 6),
                        Text(
                          "Fill in the fields below to create your account.",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),
                        const SizedBox(height: 25),

                        GlassCard(
                          padding: const EdgeInsets.all(24),
                          borderType: GlassBorderType.normal,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _nameController,
                                style: TextStyle(color: ObsidianTheme.textVibrant),
                                decoration: InputDecoration(
                                  labelText: "Your Full Name",
                                  hintText: "Enter your name",
                                  prefixIcon: Icon(Icons.person_outline, color: ObsidianTheme.textMuted, size: 20),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) return "Please enter your name";
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              TextFormField(
