import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:rtc_mobile/domain/auth/user_model.dart';
import 'package:rtc_mobile/ui/features/auth/welcome_screen.dart';
import 'package:rtc_mobile/ui/features/spiritual/prayer_requests_screen.dart';
import 'package:rtc_mobile/ui/features/gallery/gallery_screen.dart';
import 'package:rtc_mobile/ui/features/spiritual/bible_studies_screen.dart';
import 'package:rtc_mobile/ui/features/leadership/leadership_screen.dart';
import 'package:rtc_mobile/ui/features/profile/members_screen.dart';
import 'package:rtc_mobile/ui/features/profile/profile_edit_screen.dart';
import 'package:rtc_mobile/ui/features/groups/groups_screen.dart';
import 'package:rtc_mobile/ui/features/children/children_screen.dart';
import 'package:rtc_mobile/ui/features/attendance/attendance_screen.dart';
import 'package:rtc_mobile/ui/features/finance/financials_screen.dart';
import 'package:rtc_mobile/ui/features/messaging/messaging_screen.dart';
import 'package:rtc_mobile/ui/features/admin/reports_screen.dart';
import 'package:rtc_mobile/ui/features/admin/user_management_screen.dart';
import 'package:rtc_mobile/ui/features/settings/settings_screen.dart';
import 'package:rtc_mobile/ui/features/help/help_screen.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/theme/app_theme.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return authState.when(
      data: (user) {
        if (user == null) return const WelcomeScreen();
        
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: false,
                expandedHeight: 120.0,
                backgroundColor: theme.scaffoldBackgroundColor,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    "Hub",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Profile Section
                    _buildGroupedSection([
                      _buildProfileTile(context, user),
                    ]),
                    
                    const SizedBox(height: 32),
                    
                    _buildSectionHeader("Spiritual & Community"),
                    _buildGroupedSection([
                      _buildMenuTile(
                        context,
                        title: 'Prayer Wall',
                        icon: Icons.favorite_rounded,
                        iconColor: AppTheme.systemPink,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerRequestsScreen())),
                      ),
                      _buildMenuTile(
                        context,
                        title: 'Service Gallery',
                        icon: Icons.photo_library_rounded,
                        iconColor: AppTheme.systemGreen,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen())),
                      ),
                      _buildMenuTile(
                        context,
                        title: 'Bible Studies',
                        icon: Icons.auto_stories_rounded,
                        iconColor: AppTheme.systemBlue,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BibleStudiesScreen())),
                      ),
                      _buildMenuTile(
                        context,
                        title: 'Leadership',
                        icon: Icons.shield_rounded,
                        iconColor: AppTheme.systemPurple,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeadershipScreen())),
                      ),
                    ]),
                    
                    if (user.isDeptHead) ...[
                      const SizedBox(height: 32),
                      _buildSectionHeader("Administration"),
                      _buildGroupedSection([
                        _buildMenuTile(
                          context,
                          title: 'Directory',
                          icon: Icons.people_alt_rounded,
                          iconColor: AppTheme.systemGray,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MembersScreen())),
                        ),
                        _buildMenuTile(
                          context,
                          title: 'Groups',
                          icon: Icons.groups_rounded,
                          iconColor: AppTheme.systemOrange,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupsScreen())),
                        ),
                        _buildMenuTile(
                          context,
                          title: "Children",
                          icon: Icons.face_rounded,
                          iconColor: AppTheme.systemPink,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChildrenScreen())),
                        ),
                        _buildMenuTile(
                          context,
                          title: 'Attendance',
                          icon: Icons.check_circle_rounded,
                          iconColor: AppTheme.systemTeal,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen())),
                        ),
                        _buildMenuTile(
                          context,
                          title: 'Ledger',
                          icon: Icons.credit_card_rounded,
                          iconColor: AppTheme.systemBlue,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinancialsScreen())),
                        ),
                        _buildMenuTile(
                          context,
                          title: 'Broadcasts',
                          icon: Icons.volume_up_rounded,
                          iconColor: AppTheme.systemPurple,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagingScreen())),
                        ),
                        _buildMenuTile(
                          context,
                          title: 'Reports',
                          icon: Icons.bar_chart_rounded,
                          iconColor: AppTheme.systemYellow,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
                        ),
                        if (user.isAdmin)
                          _buildMenuTile(
                            context,
                            title: 'User Access',
                            icon: Icons.admin_panel_settings_rounded,
                            iconColor: colorScheme.primary,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementScreen())),
                          ),
                      ]),
                    ],
      
                    const SizedBox(height: 32),
                    _buildSectionHeader("Preferences"),
                    _buildGroupedSection([
                      _buildMenuTile(
                        context,
                        title: 'Settings',
                        icon: Icons.settings_rounded,
                        iconColor: AppTheme.systemGray,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                      ),
                      _buildMenuTile(
                        context,
                        title: 'Help Center',
                        icon: Icons.help_outline_rounded,
                        iconColor: AppTheme.systemBlue,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen())),
                      ),
                    ]),
      
                    const SizedBox(height: 32),
                    
                    _buildGroupedSection([
                      _buildMenuTile(
                        context,
                        title: 'Sign Out',
                        icon: Icons.logout_rounded,
                        iconColor: const Color(0xFFFF3B30),
                        showChevron: false,
                        onTap: () async {
                          _showSignOutConfirmation(context, ref);
                        },
                      ),
                    ]),
                    
                    const SizedBox(height: 120),
                  ]),
                ),
              )
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator.adaptive())),
      error: (e, _) => Scaffold(body: Center(child: Text("Error: $e"))),
    );
  }

  void _showSignOutConfirmation(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardTheme.color ?? theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Sign Out",
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Text(
                "Are you sure you want to sign out of Sanctuary?",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16, 
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      child: const Text("Cancel"),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                      ),
                      onPressed: () async {
                        await ref.read(authNotifierProvider.notifier).logout();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                            (route) => false,
                          );
                        }
                      },
                      child: const Text("Sign Out"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.systemGray,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildGroupedSection(List<Widget> children) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final widget = entry.value;
          final isLast = index == children.length - 1;
          
          return Column(
            children: [
              widget,
              if (!isLast)
                Divider(
                  height: 0.5, 
                  indent: 56, 
                  thickness: 0.5, 
                  color: AppTheme.systemGray3.withOpacity(0.3),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProfileTile(BuildContext context, AppUser user) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.primary.withOpacity(0.2), width: 1.5),
        ),
        child: CircleAvatar(
          radius: 28,
          backgroundColor: colorScheme.primary.withOpacity(0.1),
          backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
          child: user.avatarUrl == null 
              ? Text(
                  user.name.isNotEmpty ? user.name.substring(0, 1) : 'U',
                  style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w700, fontSize: 24),
                )
              : null,
        ),
      ),
      title: Text(
        user.name,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20, letterSpacing: -0.5),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          user.email,
          style: TextStyle(color: AppTheme.systemGray, fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, size: 20, color: AppTheme.systemGray3),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileEditScreen())),
    );
  }

  Widget _buildMenuTile(BuildContext context, {
    required String title, 
    required IconData icon, 
    required Color iconColor,
    required VoidCallback onTap,
    bool showChevron = true,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: iconColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17, letterSpacing: -0.3)),
      trailing: showChevron 
          ? Icon(Icons.chevron_right_rounded, size: 20, color: AppTheme.systemGray3)
          : null,
      onTap: onTap,
    );
  }
}
