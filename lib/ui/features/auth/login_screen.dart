import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/modern_widgets.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:rtc_mobile/ui/features/dashboard/main_tab_screen.dart';
import 'package:rtc_mobile/ui/features/auth/signup_screen.dart';

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
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter your email address first."),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      
      await ref.read(authRepositoryProvider).sendPasswordReset(email);
      
      if (mounted) {
        Navigator.pop(context); // Dismiss loading
        showAdaptiveDialog(
          context: context,
          builder: (_) => AlertDialog.adaptive(
            title: const Text("Password Reset Sent"),
            content: Text("A link to reset your password has been sent to $email. Please follow instructions in the email."),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    
    // Modern solid white panel color or slate dark panel color
    final panelColor = isDark ? const Color(0xFF151B2C) : Colors.white;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 1. Background (Upper Section) Image with Blur
          Positioned.fill(
            child: Image.asset(
              'assets/church_sanctuary.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(
                color: Colors.black.withOpacity(isDark ? 0.45 : 0.25),
              ),
            ),
          ),

          // 2. Main Scrollable content containing upper logo space and the solid bottom panel
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  // Upper Space (approx 45% of height) for Logo & Title
                  SizedBox(
                    height: screenHeight * 0.42,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 84,
                            height: 84,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF151B2C) : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/church_logo.png',
                              fit: BoxFit.contain,
                            ),
                          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                          const SizedBox(height: 16),
                          Text(
                            "RTCI CONNECT",
                            style: GoogleFonts.cinzel(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              shadows: [
                                const Shadow(
                                  color: Colors.black45,
                                  offset: Offset(0, 4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                          const SizedBox(height: 4),
                          Text(
                            "Redeemed Transformation Chapel",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
                        ],
                      ),
                    ),
                  ),

                  // Lower Section (Solid panel flush with screen bottom and sides)
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: screenHeight * 0.58,
                    ),
                    decoration: BoxDecoration(
                      color: panelColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
                          blurRadius: 30,
                          offset: const Offset(0, -10),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(
                      24, 
                      32, 
                      24, 
                      mediaQuery.padding.bottom + 24
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "SIGN IN",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: ObsidianTheme.textVibrant,
                              letterSpacing: 0.5,
                            ),
                          ).animate().fadeIn(duration: 400.ms),
                          const SizedBox(height: 8),
                          Text(
                            "Welcome back! Sign in to access your member dashboard.",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: ObsidianTheme.textMuted,
                              height: 1.4,
                            ),
                          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                          const SizedBox(height: 28),

                          // Email field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: ObsidianTheme.textVibrant, fontSize: 15),
                            decoration: InputDecoration(
                              labelText: "Email Address",
                              hintText: "your.name@example.com",
                              prefixIcon: Icon(Icons.email_outlined, color: ObsidianTheme.textMuted, size: 20),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) return "Please enter your email";
                              if (!val.contains('@')) return "Please enter a valid email";
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_showPassword,
                            style: TextStyle(color: ObsidianTheme.textVibrant, fontSize: 15),
                            decoration: InputDecoration(
                              labelText: "Password",
                              hintText: "******",
                              prefixIcon: Icon(Icons.lock_outline_rounded, color: ObsidianTheme.textMuted, size: 20),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
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
                              if (val == null || val.isEmpty) return "Please enter your password";
                              return null;
                            },
                          ),
                          
                          // Forgot Password link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _handleForgotPassword,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: AppTheme.accentGold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Action Button
                          CustomPrimaryButton(
                            text: "SIGN IN",
                            isLoading: authState.isLoading,
                            backgroundColor: AppTheme.accentGold,
                            textColor: const Color(0xFF0B0F19),
                            onPressed: _handleLogin,
                          ),
                          const SizedBox(height: 24),

                          // Social Login Divider
                          Row(
                            children: [
                              Expanded(child: Divider(color: ObsidianTheme.borderHairline)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  "OR SIGN IN WITH",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: ObsidianTheme.textMuted,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: ObsidianTheme.borderHairline)),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Social Logins
                          InkWell(
                            onTap: authState.isLoading ? null : _handleGoogleLogin,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: 54,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.google,
                                    size: 18,
                                    color: ObsidianTheme.textVibrant,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Continue with Google",
                                    style: GoogleFonts.plusJakartaSans(
                                      color: ObsidianTheme.textVibrant,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Don't have an account Option
                          Center(
                            child: InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                                );
                              },
                              child: RichText(
                                text: TextSpan(
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: ObsidianTheme.textMuted,
                                  ),
                                  children: [
                                    const TextSpan(text: "Don't have an account? "),
                                    TextSpan(
                                      text: "Sign Up",
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
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
}