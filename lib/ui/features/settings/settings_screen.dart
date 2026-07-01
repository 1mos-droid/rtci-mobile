import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:rtc_mobile/application/theme/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).value;

    if (user == null) {
      return Scaffold(
        backgroundColor: ObsidianTheme.backgroundDark,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
                  "Account Settings",
                  style: GoogleFonts.cinzel(
                    color: ObsidianTheme.textVibrant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: ObsidianTheme.primaryCrimson.withValues(alpha: 0.1),
                                child: Text(user.name.isNotEmpty ? user.name[0] : 'U', style: TextStyle(fontSize: 24, color: ObsidianTheme.primaryCrimson, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                     Text(user.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ObsidianTheme.textVibrant)),
                                    Text(user.email, style: TextStyle(fontSize: 12, color: ObsidianTheme.textMuted)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Divider(height: 40, color: ObsidianTheme.borderHairline),
                          Text("Official Profile", style: GoogleFonts.cinzel(fontSize: 14, fontWeight: FontWeight.bold, color: ObsidianTheme.secondaryGold)),
                          const SizedBox(height: 16),
                          _buildInfoRow("Role", user.role.name.toUpperCase()),
                          if (user.department != null) _buildInfoRow("Department", user.department!),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: ObsidianTheme.primaryCrimson, foregroundColor: Colors.white),
                              onPressed: () {},
                              child: const Text("EDIT PROFILE"),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Preferences", style: GoogleFonts.cinzel(fontSize: 14, fontWeight: FontWeight.bold, color: ObsidianTheme.secondaryGold)),
                          const SizedBox(height: 16),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                          Text("Security & Terminal", style: GoogleFonts.cinzel(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                          const SizedBox(height: 16),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.lock_outline, color: Colors.redAccent),
                            title: const Text("Update Credentials", style: TextStyle(color: Colors.white, fontSize: 14)),
                            trailing: const Icon(Icons.chevron_right, color: ObsidianTheme.textMuted),
                            onTap: () {},
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.logout, color: Colors.redAccent),
                            title: const Text("Terminal Shutdown", style: TextStyle(color: Colors.white, fontSize: 14)),
                            trailing: const Icon(Icons.chevron_right, color: ObsidianTheme.textMuted),
                            onTap: () async {
                              await auth.logout();
                              if (context.mounted) {
                                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: ObsidianTheme.textMuted, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
