import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:rtc_mobile/ui/features/dashboard/main_tab_screen.dart';
import 'package:rtc_mobile/ui/features/auth/signup_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      final authState = ref.read(authNotifierProvider);
      if (!authState.hasError && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainTabScreen()),
          (route) => false,
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error?.toString() ?? "Log in failed. Check your email and password."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
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
    final isDark = theme.brightness == Brightness.dark;

    return MeshGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: ObsidianTheme.textVibrant, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Log In",
                    style: Theme.of(context).textTheme.displayMedium,
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),
                  const SizedBox(height: 6),
                  Text(
                    "Type in your email and password to open the app.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),
                  const SizedBox(height: 35),
                  
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    borderType: GlassBorderType.normal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ),
                        
                        const SizedBox(height: 24),
                        
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: ObsidianTheme.textVibrant),
                          decoration: const InputDecoration(
                            labelText: "Email Address",
                            hintText: "member@rtci.org",
                            prefixIcon: Icon(Icons.email_outlined, color: ObsidianTheme.textMuted, size: 20),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return "Email is required";
                            if (!val.contains('@')) return "Enter a valid email";
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: ObsidianTheme.textVibrant),
                          decoration: const InputDecoration(
                            labelText: "Security Key",
                            hintText: "••••••••",
                            prefixIcon: Icon(Icons.lock_outline, color: ObsidianTheme.textMuted, size: 20),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return "Password is required";
                            if (val.length < 6) return "Password too short";
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 32),
                        
                        ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _asLeadership ? ObsidianTheme.secondaryGold : ObsidianTheme.primaryCrimson,
                            foregroundColor: _asLeadership ? ObsidianTheme.backgroundDark : Colors.white,
                          ),
                          child: const Text("AUTHENTICATE ACCESS"),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        "REQUEST SECURITY PASSPHRASE",
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              decoration: TextDecoration.underline,
                              color: ObsidianTheme.textMuted,
                            ),
                      ),
                    ),
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
