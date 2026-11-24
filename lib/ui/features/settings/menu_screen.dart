import 'package:rtc_mobile/ui/features/admin/account_deletion_requests_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';
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
import 'package:rtc_mobile/widgets/custom_logo_loader.dart';
import 'package:rtc_mobile/widgets/feature_state.dart';
import 'package:rtc_mobile/ui/features/events/events_screen.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  void _open(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ref
        .watch(authNotifierProvider)
        .when(
          data: (user) {
            if (user == null) return const WelcomeScreen();
            return Scaffold(
              appBar: AppBar(title: const Text('Explore')),
              body: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                      children: [
                        Text(
                          'Your church, closer.',
                          style: theme.textTheme.displayMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Find your community. Make room to grow.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 28),
                        GlassCard(
                          padding: EdgeInsets.zero,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(20),
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              foregroundColor:
                                  theme.colorScheme.onPrimaryContainer,
                              child: Text(
                                user.name.trim().isEmpty
                                    ? 'R'
                                    : user.name
                                          .trim()
                                          .substring(0, 1)
                                          .toUpperCase(),
                              ),
                            ),
                            title: Text(
                              user.name.isEmpty ? 'Your profile' : user.name,
                              style: theme.textTheme.titleMedium,
                            ),
                            subtitle: Text(
                              user.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () =>
                                _open(context, const ProfileEditScreen()),
                          ),
                        ),
                        _section(context, 'Faith & community', [
                          _tile(
                            context,
                            'Church calendar',
                            'Services, gatherings and what’s ahead',
                            Icons.event_outlined,
                            const EventsScreen(),
                          ),
                          _tile(
                            context,
                            'Groups',
                            'Find a place to connect and serve',
                            Icons.people_outline_rounded,
                            const GroupsScreen(),
                          ),
                          _tile(
                            context,
                            'Prayer wall',
                            'Share a request. Pray for each other.',
                            Icons.favorite_border_rounded,
                            const PrayerRequestsScreen(),
                          ),
                          _tile(
                            context,
                            'Bible studies',
                            'Keep growing in the Word',
                            Icons.auto_stories_outlined,
                            const BibleStudiesScreen(),
                          ),
                          _tile(
                            context,
                            'Gallery',
                            'Moments from our life together',
                            Icons.photo_library_outlined,
                            const GalleryScreen(),
                          ),
                          _tile(
                            context,
                            'Leadership',
                            'Meet the people who guide our church',
                            Icons.shield_outlined,
                            const LeadershipScreen(),
                          ),
                        ]),
                        if (user.isDeptHead)
                          _section(context, 'Church administration', [
                            _tile(
                              context,
                              'Member directory',
                              null,
                              Icons.badge_outlined,
                              const MembersScreen(),
                            ),
                            _tile(
                              context,
                              'Children',
                              null,
                              Icons.child_care_outlined,
                              const ChildrenScreen(),
                            ),
                            _tile(
                              context,
                              'Attendance',
                              null,
                              Icons.checklist_rounded,
                              const AttendanceScreen(),
                            ),
                            _tile(
                              context,
                              'Financial ledger',
                              null,
                              Icons.account_balance_wallet_outlined,
                              const FinancialsScreen(),
                            ),
                            _tile(
                              context,
                              'Broadcasts',
                              null,
                              Icons.campaign_outlined,
                              const MessagingScreen(),
                            ),
                            _tile(
                              context,
                              'Reports',
                              null,
                              Icons.bar_chart_rounded,
                              const ReportsScreen(),
                            ),
                            if (user.isAdmin)
                              _tile(
                                context,
                                'Account deletion requests',
                                'Review requests to remove an account',
                                Icons.person_remove_outlined,
                                const AccountDeletionRequestsScreen(),
                              ),
                            if (user.isAdmin)
                              _tile(
                                context,
                                'User access',
                                null,
                                Icons.admin_panel_settings_outlined,
                                const UserManagementScreen(),
                              ),
                          ]),
                        _section(context, 'Make it yours', [
                          _tile(
                            context,
                            'Settings',
                            'Appearance and account preferences',
                            Icons.tune_rounded,
                            const SettingsScreen(),
                          ),
                          _tile(
                            context,
                            'Help & support',
                            'We’re here when you need a hand',
                            Icons.help_outline_rounded,
                            const HelpScreen(),
                          ),
                        ]),
                        const SizedBox(height: 24),
                        OutlinedButton.icon(
                          onPressed: () => _signOut(context, ref),
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: const Text('Sign out'),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'RTCI Connect · Faith. Fellowship. Family.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          loading: () => const Scaffold(
            body: Center(
              child: CustomLogoLoader(message: 'Loading your profile…'),
            ),
          ),
          error: (_, _) => Scaffold(
            body: FeatureState(
              icon: Icons.cloud_off_rounded,
              title: 'Your profile is unavailable',
              message: 'Check your connection and try again.',
              actionLabel: 'Try again',
              onAction: () => ref.invalidate(authNotifierProvider),
            ),
          ),
        );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    const Divider(height: 1, indent: 68, endIndent: 20),
                ],
              ],
            ),
          ),
        ],
      );

  Widget _tile(
    BuildContext context,
    String title,
    String? subtitle,
    IconData icon,
    Widget page,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: scheme.primary),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(height: 1.5),
            ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: scheme.onSurfaceVariant,
      ),
      onTap: () => _open(context, page),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can sign back in whenever you’re ready.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Stay here'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(authNotifierProvider.notifier).logout();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (_) => false,
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('We couldn’t sign you out. Please try again.'),
          ),
        );
      }
    }
  }
}
