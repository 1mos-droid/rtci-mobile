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
                          title: 'Cell Groups',
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
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Spiritual & Community'),
                  _buildMenuCard(
                    context,
                    title: 'Prayer Requests',
                    subtitle: 'Intercession Wall',
                    icon: Icons.volunteer_activism_outlined,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerRequestsScreen())),
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Service Gallery',
                    subtitle: 'Worship Moments',
                    icon: Icons.image_outlined,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen())),
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Ministerial Library',
                    subtitle: 'Study Modules',
                    icon: Icons.library_books_outlined,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BibleStudiesScreen())),
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Church Leadership',
                    subtitle: 'Directory of Officials',
                    icon: Icons.security_outlined,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeadershipScreen())),
                  ),
                  
                  if (auth.isDeptHead) ...[
                    const SizedBox(height: 24),
                    _buildSectionHeader('Administration (Dept Head)'),
                    _buildMenuCard(
                      context,
                      title: 'Member Directory',
                      subtitle: 'Congregation Registry',
                      icon: Icons.people_outline,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MembersScreen())),
                    ),
                    _buildMenuCard(
                      context,
                      title: 'Cell Groups',
                      subtitle: 'Manage Fellowships',
                      icon: Icons.diversity_3_outlined,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupsScreen())),
                    ),
                    _buildMenuCard(
                      context,
                      title: "Children's Ministry",
                      subtitle: 'Secure Check-in',
                      icon: Icons.child_care_outlined,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChildrenScreen())),
                    ),
                    _buildMenuCard(
                      context,
                      title: 'Attendance',
                      subtitle: 'Headcount & Roster',
                      icon: Icons.how_to_reg_outlined,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen())),
                    ),
                    _buildMenuCard(
                      context,
                      title: 'Financial Ledger',
                      subtitle: 'Revenue & Pledges',
                      icon: Icons.account_balance_wallet_outlined,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinancialsScreen())),
                    ),
                    _buildMenuCard(
                      context,
                      title: 'Pastoral Broadcasts',
                      subtitle: 'Sanctuary Messages',
                      icon: Icons.podcasts_outlined,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagingScreen())),
                    ),
                    _buildMenuCard(
                      context,
                      title: 'Audit Reports',
                      subtitle: 'Export Analytics',
                      icon: Icons.summarize_outlined,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
                    ),
                    if (auth.isAdmin)
                      _buildMenuCard(
                        context,
                        title: 'User Management',
                        subtitle: 'Control Access Levels',
                        icon: Icons.admin_panel_settings_outlined,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementScreen())),
                      ),
                  ],

                  const SizedBox(height: 24),
                  _buildSectionHeader('System'),
                  _buildMenuCard(
                    context,
                    title: 'Account Settings',
                    subtitle: 'Preferences & Security',
                    icon: Icons.settings_outlined,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Help & Guidance',
                    subtitle: 'Platform Documentation',
                    icon: Icons.help_outline,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen())),
                  ),

                  const SizedBox(height: 24),
                  
                  // Logout Button
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () async {
                      await auth.logout();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                          (route) => false,
                        );
                      }
                    },
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.logout_outlined, color: Colors.redAccent),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            "Revoke Active Session",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // padding for bottom nav
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 4.0),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: ObsidianTheme.secondaryGold,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ObsidianTheme.primaryCrimson.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ObsidianTheme.primaryCrimson.withValues(alpha: 0.2), width: 1),
              ),
              child: Icon(icon, color: ObsidianTheme.primaryCrimson, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: ObsidianTheme.textVibrant,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: ObsidianTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: ObsidianTheme.textMuted),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }
}
