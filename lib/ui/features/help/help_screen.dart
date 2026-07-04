import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {"q": "How is data synchronization handled?", "a": "The RTCI system utilizes real-time Firebase listeners to ensure that congregational and financial data is updated instantly across all active ministerial sessions."},
      {"q": "Is the platform accessible offline?", "a": "Yes. As a Progressive Web App (PWA) and Mobile App, core registry and curriculum files are cached locally on your device."},
      {"q": "Who manages system privileges?", "a": "Ministerial access levels are governed by the Security module, accessible only by the Senior Administrator in the Main Sanctuary environment."},
    ];

    return Scaffold(
      backgroundColor: ObsidianTheme.backgroundDark,
      body: MeshGradientBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              pinned: true,
              expandedHeight: 120.0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 48, bottom: 16),
                title: Text(
                  "Help & Support",
                  style: GoogleFonts.cinzel(
                    color: ObsidianTheme.primaryCrimson,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final faq = faqs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(faq['q']!, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: ObsidianTheme.secondaryGold)),
                            const SizedBox(height: 8),
                            Text(faq['a']!, style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: faqs.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.support_agent, size: 48, color: ObsidianTheme.primaryCrimson),
                      const SizedBox(height: 16),
                      Text("Still need help?", style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Text("Contact the RTCI support team for further assistance.", style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final Uri emailLaunchUri = Uri(
                              scheme: 'mailto',
                          child: const Text("CONTACT SUPPORT"),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}