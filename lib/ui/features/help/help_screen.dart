import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        "q": "Why isn’t my content updating?",
        "a":
            "Check your internet connection, then refresh the screen. Some content is loaded when you open a feature. If it is still missing, contact your church administrator.",
      },
      {
        "q": "Can I use the app offline?",
        "a":
            "Previously loaded content may remain available on your device. Sign-in, new content, uploads and checkout require an internet connection.",
      },
      {
        "q": "How do I get access to church administration?",
        "a":
            "Ask your church administrator to review your account role. Administration features appear for the roles assigned to your account.",
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: ObsidianTheme.primaryCrimson,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final faq = faqs[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            faq['q']!,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: ObsidianTheme.secondaryGold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            faq['a']!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: faqs.length),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.support_agent,
                        size: 48,
                        color: ObsidianTheme.primaryCrimson,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Still need help?",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Contact the RTCI support team for further assistance.",
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final Uri emailLaunchUri = Uri(
                              scheme: 'mailto',
                              path: 'ea6971684@gmail.com',
                              queryParameters: {
                                'subject': 'RTCI Connect App Support Request',
                              },
                            );
                            if (await canLaunchUrl(emailLaunchUri)) {
                              await launchUrl(emailLaunchUri);
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Could not open default mail client.",
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text("Contact support"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
