import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:rtc_mobile/ui/features/dashboard/main_tab_screen.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:rtc_mobile/widgets/modern_widgets.dart';
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: MeshGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: ObsidianTheme.textVibrant, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              Expanded(
                child: _signupSuccess
                    ? _buildSuccessScreen(context)
                    : SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "Create Account",
                                style: theme.textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),
                              
                              const SizedBox(height: 6),
                              
                              Text(
                                "Join the fellowship by creating your digital member profile.",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: ObsidianTheme.textMuted,
                                  height: 1.4,
                                ),
                              ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),
                              
                              const SizedBox(height: 28),

                              GlassCard(
                                borderRadius: 24,
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    TextFormField(
                                      controller: _nameController,
                                      style: TextStyle(color: ObsidianTheme.textVibrant, fontSize: 16),
                                      decoration: InputDecoration(
                                        labelText: "Your Full Name",
                                        hintText: "Enter your name",
                                        prefixIcon: Icon(Icons.person_outline_rounded, color: ObsidianTheme.textMuted, size: 20),
                                        filled: true,
                                        fillColor: isDark ? const Color(0xFF151B2C) : Colors.black.withOpacity(0.02),
                                      ),
                                      validator: (val) {
                                        if (val == null || val.isEmpty) return "Please enter your name";
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      style: TextStyle(color: ObsidianTheme.textVibrant, fontSize: 16),
                                      decoration: InputDecoration(
                                        labelText: "Email Address",
                                        hintText: "your@email.com",
                                        prefixIcon: Icon(Icons.email_outlined, color: ObsidianTheme.textMuted, size: 20),
                                        filled: true,
                                        fillColor: isDark ? const Color(0xFF151B2C) : Colors.black.withOpacity(0.02),
                                      ),
                                      validator: (val) {
                                        if (val == null || val.isEmpty) return "Please enter your email";
                                        if (!val.contains('@')) return "Please enter a valid email";
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),

                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: !_showPassword,
                                      style: TextStyle(color: ObsidianTheme.textVibrant, fontSize: 16),
                                      decoration: InputDecoration(
                                        labelText: "Choose a Password",
                                        hintText: "Min 6 characters",
                                        prefixIcon: Icon(Icons.lock_outline_rounded, color: ObsidianTheme.textMuted, size: 20),
                                        filled: true,
                                        fillColor: isDark ? const Color(0xFF151B2C) : Colors.black.withOpacity(0.02),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                            color: ObsidianTheme.textMuted,
                                            size: 20,
                                          ),
                                          onPressed: () => setState(() => _showPassword = !_showPassword),
                                        ),
                                      ),
                                      validator: (val) {
                                        if (val == null || val.isEmpty) return "Please enter a password";
                                        if (val.length < 6) return "Password must be at least 6 characters";
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),

                                    TextFormField(
                                      controller: _confirmPasswordController,
                                      obscureText: !_showConfirmPassword,
                                      style: TextStyle(color: ObsidianTheme.textVibrant, fontSize: 16),
                                      decoration: InputDecoration(
                                        labelText: "Type Password Again",
                                        hintText: "Confirm your password",
                                        prefixIcon: Icon(Icons.lock_outline_rounded, color: ObsidianTheme.textMuted, size: 20),
                                        filled: true,
                                        fillColor: isDark ? const Color(0xFF151B2C) : Colors.black.withOpacity(0.02),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _showConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                            color: ObsidianTheme.textMuted,
                                            size: 20,
                                          ),
                                          onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                                        ),
                                      ),
                                      validator: (val) {
                                        if (val == null || val.isEmpty) return "Please confirm your password";
                                        if (val != _passwordController.text) return "Passwords do not match";
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),

                                    CheckboxListTile(
                                      title: Text(
                                        "I agree to the guidelines and rules of the church fellowship.",
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: ObsidianTheme.textMuted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      value: _acceptTerms,
                                      activeColor: theme.colorScheme.primary,
                                      checkColor: Colors.white,
                                      contentPadding: EdgeInsets.zero,
                                      controlAffinity: ListTileControlAffinity.leading,
                                      onChanged: (val) => setState(() => _acceptTerms = val ?? false),
                                    ),
                                    
                                    const SizedBox(height: 24),

                                    CustomPrimaryButton(
                                      text: "Create Account",
                                      isLoading: authState.isLoading,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              "Sign Up with Google",
                                              style: TextStyle(
                                                color: isDark ? Colors.black : Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 200.ms, duration: 600.ms).scaleXY(begin: 0.95, end: 1.0, curve: Curves.easeOutBack).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),

                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 32),
                        
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              );
                            },
                            child: Text(
                              "Already have an account? Sign In here",
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: ObsidianTheme.secondaryGold,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 450.ms, duration: 500.ms),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSuccessScreen(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GlassCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, size: 72, color: Colors.greenAccent),
              const SizedBox(height: 24),
              Text(
                "Welcome to Fellowship",
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.bold, color: ObsidianTheme.textVibrant),
              ),
              const SizedBox(height: 12),
              Text(
                "Your account has been successfully created. You can now log in to the portal.",
                textAlign: TextAlign.center,
                style: TextStyle(color: ObsidianTheme.textMuted, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MainTabScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text("CONTINUE TO DASHBOARD"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}