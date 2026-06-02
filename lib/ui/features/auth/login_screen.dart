import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:rtc_mobile/providers/auth_provider.dart';
import 'package:rtc_mobile/ui/features/dashboard/main_tab_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _asLeadership = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final success = await auth.login(
        _emailController.text,
        _passwordController.text,
        asLeadership: _asLeadership,
      );

      if (success && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainTabScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MeshGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: ObsidianTheme.textVibrant, size: 18),
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
                    "Sign In",
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Authenticate your church credentials to access your local hubs.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 35),
                  
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    borderType: _asLeadership ? GlassBorderType.gold : GlassBorderType.normal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Leader / Member Toggle
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: ObsidianTheme.backgroundDark,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: ChoiceChip(
                                  showCheckmark: false,
                                  label: const Center(child: Text("MEMBER")),
                                  selected: !_asLeadership,
                                  selectedColor: ObsidianTheme.surfaceDark,
                                  backgroundColor: Colors.transparent,
                                  labelStyle: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: !_asLeadership ? ObsidianTheme.primaryCrimson : ObsidianTheme.textMuted,
                                    letterSpacing: 0.5,
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  onSelected: (val) {
                                    if (val) setState(() => _asLeadership = false);
                                  },
                                ),
                              ),
                              Expanded(
                                child: ChoiceChip(
                                  showCheckmark: false,
                                  label: const Center(child: Text("OFFICIAL")),
                                  selected: _asLeadership,
                                  selectedColor: ObsidianTheme.surfaceDark,
                                  backgroundColor: Colors.transparent,
                                  labelStyle: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _asLeadership ? ObsidianTheme.secondaryGold : ObsidianTheme.textMuted,
                                    letterSpacing: 0.5,
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  onSelected: (val) {
                                    if (val) setState(() => _asLeadership = true);
                                  },
                                ),
                              ),
                            ],
                          ),
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
