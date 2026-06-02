import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:rtc_mobile/ui/features/auth/login_screen.dart';
import 'package:rtc_mobile/ui/features/applications/application_form_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MeshGradientBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              
              // Serene Golden Cross Emblem representing Faith
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: ObsidianTheme.backgroundDark,
                    shape: BoxShape.circle,
                    border: Border.all(color: ObsidianTheme.secondaryGold.withOpacity(0.4), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: ObsidianTheme.secondaryGold.withOpacity(0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.church_outlined,
                      size: 42,
                      color: ObsidianTheme.secondaryGold,
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 800.ms)
              .scaleXY(begin: 0.85, end: 1.0, curve: Curves.easeOutBack),
              
              const SizedBox(height: 32),
              
              // Brand Sacred Heading
              Text(
                "Redeemed Transformation",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26, color: ObsidianTheme.textVibrant),
              ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
              
              const SizedBox(height: 4),
              
              Text(
                "Chapel International",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: 18,
                      color: ObsidianTheme.secondaryGold,
                      fontStyle: FontStyle.italic,
                    ),
              ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
              
              const SizedBox(height: 12),
              
              Text(
                "CONNECTING SOULS • SERVING COMMUNITIES",
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  letterSpacing: 2.0,
                  color: ObsidianTheme.textMuted,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
              
              const Spacer(flex: 3),
              
              // Pure clean white card plate
              GlassCard(
                padding: const EdgeInsets.all(26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "MEMBER COVENANT PORTAL",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: ObsidianTheme.textVibrant,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Submit your registration to align with local ministries and access the secure community hub.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: ObsidianTheme.textMuted),
                    ),
                    const SizedBox(height: 24),
                    
                    ElevatedButton.icon(
                      icon: const Icon(Icons.assignment_outlined),
                      label: const Text("Submit Membership Form"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ApplicationFormScreen()),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    OutlinedButton.icon(
                      icon: const Icon(Icons.login_outlined),
                      label: const Text("Sign In to Portal"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 750.ms, duration: 600.ms).slideY(begin: 0.08, end: 0),
              
              const SizedBox(height: 24),
              
              Text(
                "SUPPORT & PRIVACY VER. 1.0.0",
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  color: ObsidianTheme.textMuted,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

