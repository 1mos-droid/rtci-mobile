import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rtc_mobile/ui/features/profile/profile_edit_screen.dart';
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
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileEditScreen()));
                              },
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
                            leading: Icon(Icons.palette_outlined, color: ObsidianTheme.secondaryGold),
                            title: Text("Theme Mode", style: TextStyle(color: ObsidianTheme.textVibrant, fontSize: 14)),
                            subtitle: Text(
                              ref.watch(themeNotifierProvider) == ThemeMode.system
                                  ? "System Default"
                                  : ref.watch(themeNotifierProvider) == ThemeMode.dark
                                      ? "Dark"
                                      : "Light",
                              style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 12),
                            ),
                            trailing: Icon(Icons.chevron_right, color: ObsidianTheme.textMuted),
                            onTap: () => _showThemeSelector(context, ref),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Security & Terminal", style: GoogleFonts.cinzel(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                          const SizedBox(height: 16),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.lock_outline, color: Colors.redAccent),
                            title: Text("Update Credentials", style: TextStyle(color: ObsidianTheme.textVibrant, fontSize: 14)),
                            trailing: Icon(Icons.chevron_right, color: ObsidianTheme.textMuted),
                            onTap: () async {
                              final email = user.email;
                              if (email.isNotEmpty) {
                                try {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (_) => const Center(child: CircularProgressIndicator()),
                                  );
                                  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                                  if (context.mounted) {
                                    Navigator.pop(context); // Dismiss loading
                                    showAdaptiveDialog(
                                      context: context,
                                      builder: (_) => AlertDialog.adaptive(
                                        title: const Text("Reset Email Sent"),
                                        content: Text("A password reset link has been dispatched to $email. Please check your inbox."),
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
                                  if (context.mounted) {
                                    Navigator.pop(context); // Dismiss loading
                                    showAdaptiveDialog(
                                      context: context,
                                      builder: (_) => AlertDialog.adaptive(
                                        title: const Text("Error"),
                                        content: Text("Unable to trigger password reset: ${e.toString()}"),
                                        actions: [
                                          TextButton(
                                            child: const Text("OK"),
                                            onPressed: () => Navigator.pop(context),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.logout, color: Colors.redAccent),
                            title: Text("Terminal Shutdown", style: TextStyle(color: ObsidianTheme.textVibrant, fontSize: 14)),
                            trailing: Icon(Icons.chevron_right, color: ObsidianTheme.textMuted),
                            onTap: () async {
                              await ref.read(authNotifierProvider.notifier).logout();
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
          Text(label, style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 12)),
          Text(value, style: TextStyle(color: ObsidianTheme.textVibrant, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.read(themeNotifierProvider);
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS || Theme.of(context).platform == TargetPlatform.macOS;

    if (isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (ctx) => CupertinoActionSheet(
          title: const Text("Select Theme Mode"),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                ref.read(themeNotifierProvider.notifier).setThemeMode(ThemeMode.system);
                Navigator.pop(ctx);
              },
              child: Text("System Default", style: TextStyle(fontWeight: currentTheme == ThemeMode.system ? FontWeight.bold : FontWeight.normal)),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                ref.read(themeNotifierProvider.notifier).setThemeMode(ThemeMode.light);
                Navigator.pop(ctx);
              },
              child: Text("Light", style: TextStyle(fontWeight: currentTheme == ThemeMode.light ? FontWeight.bold : FontWeight.normal)),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                ref.read(themeNotifierProvider.notifier).setThemeMode(ThemeMode.dark);
                Navigator.pop(ctx);
              },
              child: Text("Dark", style: TextStyle(fontWeight: currentTheme == ThemeMode.dark ? FontWeight.bold : FontWeight.normal)),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (ctx) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Select Theme Mode",
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.settings_suggest_outlined),
                title: const Text("System Default"),
                trailing: currentTheme == ThemeMode.system ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  ref.read(themeNotifierProvider.notifier).setThemeMode(ThemeMode.system);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.light_mode_outlined),
                title: const Text("Light"),
                trailing: currentTheme == ThemeMode.light ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  ref.read(themeNotifierProvider.notifier).setThemeMode(ThemeMode.light);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: const Text("Dark"),
                trailing: currentTheme == ThemeMode.dark ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  ref.read(themeNotifierProvider.notifier).setThemeMode(ThemeMode.dark);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      );
    }
  }
}