import 'package:rtc_mobile/ui/features/messaging/messaging_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/modern_widgets.dart';
import 'package:rtc_mobile/widgets/custom_logo_loader.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:rtc_mobile/providers/riverpod_providers.dart';
import 'package:rtc_mobile/ui/features/events/events_screen.dart';
import 'package:rtc_mobile/ui/features/spiritual/prayer_requests_screen.dart';
import 'package:rtc_mobile/ui/features/groups/groups_screen.dart';
import 'package:rtc_mobile/ui/features/spiritual/bible_studies_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedCategory = 'All';
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      ref.read(broadcastProvider.notifier).fetchBroadcasts();
      ref.read(sermonProvider.notifier).fetchSermons();
    });
  }

  void _open(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  Future<void> _refresh() async {
    await Future.wait([
      ref.read(broadcastProvider.notifier).fetchBroadcasts(),
      ref.read(sermonProvider.notifier).fetchSermons(),
      ref.read(eventsProvider).fetchEvents(),
      ref.read(dailyInsightsProvider).fetchLatestInsight(),
    ]);
  }

  Future<void> _play(String? link) async {
    final uri = Uri.tryParse(link ?? '');
    final valid =
        uri != null &&
        ['https', 'http'].contains(uri.scheme) &&
        uri.host.isNotEmpty;
    if (valid) {
      try {
        if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
      } catch (_) {}
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          valid
              ? 'Unable to open this sermon. Please try again.'
              : 'Media is not available for this sermon yet.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final user = ref.watch(authNotifierProvider).value;
    final insights = ref.watch(dailyInsightsProvider);
    final events = ref.watch(eventsProvider);
    final broadcasts = ref.watch(broadcastProvider);
    final sermons = ref.watch(sermonProvider);
    final isLeader = user?.isDeptHead ?? false;
    final care = isLeader ? ref.watch(careProvider) : null;
    final name = user?.name.trim().split(' ').first ?? 'friend';
    final upcoming =
        events.events
            .where((e) => !e.date.isBefore(DateUtils.dateOnly(DateTime.now())))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1060),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/church_logo.png',
                                width: 38,
                                height: 38,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'RTCI CONNECT',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              IconButton.filledTonal(
                                tooltip: 'Church announcements',
                                onPressed: () => _open(const MessagingScreen()),
                                icon: Badge(
                                  isLabelVisible:
                                      broadcasts.messages.isNotEmpty,
                                  child: const Icon(
                                    Icons.notifications_none_rounded,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Text(
                            DateFormat('EEEE, d MMMM').format(DateTime.now()),
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Welcome home, $name.',
                            style: theme.textTheme.displayLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'A little closer to God. A little closer to each other.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 28),
                          _hero(context),
                          const SizedBox(height: 28),
                          LayoutBuilder(
                            builder: (context, box) {
                              final actions = [
                                _action(
                                  Icons.favorite_border_rounded,
                                  'Prayer',
                                  'Share a request',
                                  () => _open(const PrayerRequestsScreen()),
                                ),
                                _action(
                                  Icons.people_outline_rounded,
                                  'Connect',
                                  'Find your people',
                                  () => _open(const GroupsScreen()),
                                ),
                                _action(
                                  Icons.auto_stories_outlined,
                                  'Grow',
                                  'Explore Bible studies',
                                  () => _open(const BibleStudiesScreen()),
                                ),
                              ];
                              return Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: actions
                                    .map(
                                      (a) => SizedBox(
                                        width: box.maxWidth < 360
                                            ? box.maxWidth
                                            : (box.maxWidth - 24) / 3,
                                        child: a,
                                      ),
                                    )
                                    .toList(),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          _heading(
                            'A moment in the Word',
                            'Pause. Reflect. Carry it with you.',
                          ),
                          const SizedBox(height: 16),
                          GlassCard(
                            child: insights.isLoading
                                ? const CustomLogoLoader(size: 36)
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.format_quote_rounded,
                                        color: scheme.secondary,
                                        size: 30,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        insights.currentInsight?.content ??
                                            'Your daily reflection will appear here when it is shared by the church.',
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                              height: 1.65,
                                              fontWeight: FontWeight.w400,
                                            ),
                                      ),
                                      if (insights.currentInsight != null) ...[
                                        const SizedBox(height: 16),
                                        Text(
                                          insights.currentInsight!.reference ??
                                              insights.currentInsight!.author ??
                                              'Daily reflection',
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(color: scheme.primary),
                                        ),
                                      ],
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: _heading(
                                  'Life in our community',
                                  'Messages and moments that bring us together.',
                                ),
                              ),
                              if (isLeader)
                                IconButton(
                                  tooltip: 'Add sermon',
                                  onPressed: () => _showAddSermonSheet(context),
                                  icon: const Icon(Icons.add_rounded),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ['All', 'Sermons', 'Announcements']
                                .map(
                                  (category) => ChoiceChip(
                                    label: Text(category),
                                    selected: _selectedCategory == category,
                                    onSelected: (_) => setState(
                                      () => _selectedCategory = category,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 20),
                          if (_selectedCategory != 'Announcements') ...[
                            if (sermons.isLoading)
                              const CustomLogoLoader(
                                size: 40,
                                message: 'Loading sermons…',
                              )
                            else if (sermons.sermons.isEmpty)
                              _empty(
                                Icons.headphones_outlined,
                                'Room for the next message',
                                'New sermons will appear here when they are published.',
                              )
                            else
                              ...sermons.sermons.map(
                                (s) => ContentCard(
                                  title: s.title,
                                  category: s.speaker,
                                  time: DateFormat('d MMM yyyy').format(s.date),
                                  duration: s.duration,
                                  imageUrl: s.imageUrl,
                                  tag: s.tag.isEmpty ? null : s.tag,
                                  onTap: () => _play(
                                    (s.videoUrl?.trim().isNotEmpty ?? false)
                                        ? s.videoUrl
                                        : s.audioUrl,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),
                          ],
                          if (_selectedCategory != 'Sermons') ...[
                            if (broadcasts.isLoading)
                              const CustomLogoLoader(size: 40)
                            else if (broadcasts.error != null &&
                                broadcasts.messages.isEmpty)
                              _empty(
                                Icons.cloud_off_rounded,
                                'Updates are unavailable',
                                'Pull down to try again.',
                              )
                            else if (broadcasts.messages.isEmpty)
                              _empty(
                                Icons.campaign_outlined,
                                'You’re all caught up',
                                'Church announcements will appear here.',
                              )
                            else
                              ...broadcasts.messages.map(
                                (message) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GlassCard(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          message.subject,
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          message.body,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(height: 1.6),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: _heading(
                                  'Gather with us',
                                  'Make space for fellowship.',
                                ),
                              ),
                              TextButton(
                                onPressed: () => _open(const EventsScreen()),
                                child: const Text('All events'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (events.isLoading)
                            const CustomLogoLoader(size: 36)
                          else if (events.error != null && upcoming.isEmpty)
                            _empty(
                              Icons.cloud_off_rounded,
                              'The calendar is unavailable',
                              'Pull down to try again, or open all events.',
                            )
                          else if (upcoming.isEmpty)
                            _empty(
                              Icons.event_outlined,
                              'More moments ahead',
                              'Upcoming gatherings will be shared here.',
                            )
                          else
                            ...upcoming
                                .take(3)
                                .map(
                                  (event) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: GlassCard(
                                      onTap: () => _open(const EventsScreen()),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 58,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: scheme.primary.withValues(
                                                alpha: .08,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  DateFormat('MMM')
                                                      .format(event.date)
                                                      .toUpperCase(),
                                                  style: theme
                                                      .textTheme
                                                      .labelSmall,
                                                ),
                                                Text(
                                                  '${event.date.day}',
                                                  style: theme
                                                      .textTheme
                                                      .headlineMedium,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  event.name,
                                                  style: theme
                                                      .textTheme
                                                      .titleMedium,
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  '${event.time} · ${event.location}',
                                                  style:
                                                      theme.textTheme.bodySmall,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.chevron_right_rounded,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                          if (care != null && care.careQueue.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _heading(
                              'Care for our family',
                              'Reach out to members who may need support.',
                            ),
                            const SizedBox(height: 12),
                            ...care.careQueue.map(
                              (item) => Card(
                                child: ListTile(
                                  title: Text(item.memberName),
                                  subtitle: Text(
                                    '${item.absenceCount} missed gatherings',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: 'Contact member',
                                        onPressed: () => _contactMember(
                                          context,
                                          item.memberId,
                                          item.memberName,
                                        ),
                                        icon: const Icon(Icons.mail_outline),
                                      ),
                                      IconButton(
                                        tooltip: 'Resolve care request',
                                        onPressed: () =>
                                            care.resolveTicket(item.id),
                                        icon: const Icon(
                                          Icons.check_circle_outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heading(String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 6),
      Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
      ),
    ],
  );
  Widget _empty(IconData icon, String title, String description) => GlassCard(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 16),
        Expanded(child: _heading(title, description)),
      ],
    ),
  );
  Widget _action(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) => GlassCard(
    padding: const EdgeInsets.all(16),
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 16),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
  Widget _hero(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/church_sanctuary.jpg',
            fit: BoxFit.cover,
            excludeFromSemantics: true,
          ),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xEE1F352C), Color(0x991F352C)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BETTER TOGETHER',
                style: TextStyle(
                  color: Color(0xFFF0D7A9),
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Faith is a journey.\nLet’s walk it together.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  height: 1.2,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -.6,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF7F5F0),
                  foregroundColor: const Color(0xFF20382C),
                  minimumSize: const Size(0, 48),
                ),
                onPressed: () => _open(const EventsScreen()),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Explore gatherings'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  Future<void> _contactMember(
    BuildContext context,
    String memberId,
    String memberName,
  ) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CustomLogoLoader(size: 48)),
      );

      final profileDoc = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(memberId)
          .get();
      if (!context.mounted) return;
      Navigator.pop(context); // Dismiss loading indicator

      final email = profileDoc.data()?['email'] as String?;
      if (email != null && email.isNotEmpty) {
        final Uri emailLaunchUri = Uri(
          scheme: 'mailto',
          path: email,
          queryParameters: {
            'subject':
                'Fellowship Care Follow-up - Redeemed Transformation Chapel',
            'body':
                'Dear $memberName,\n\nWe missed you at our recent services and wanted to check in on you. Please let us know if there is anything we can support or pray with you for.\n\nBlessings,\nChurch Leadership Team',
          },
        );
        if (await canLaunchUrl(emailLaunchUri)) {
          await launchUrl(emailLaunchUri);
        } else {
          throw 'Could not launch email client';
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No email address registered for $memberName'),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error contacting member: $e')));
    }
  }

  void _showAddSermonSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final speakerController = TextEditingController();
    final durationController = TextEditingController();
    final imageController = TextEditingController();
    final tagController = TextEditingController();
    final videoController = TextEditingController();

    String selectedCategory = 'Sermon';
    final categories = ['Sermon', 'Media'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return GlassCard(
              borderRadius: 24,
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Post New Sermon",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: titleController,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: const InputDecoration(
                          labelText: "Sermon Title",
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? "Title is required"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: speakerController,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: const InputDecoration(
                          labelText: "Speaker",
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? "Speaker is required"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedCategory,
                              dropdownColor: isDark
                                  ? const Color(0xFF1E202C)
                                  : Colors.white,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              decoration: const InputDecoration(
                                labelText: "Category",
                                prefixIcon: Icon(Icons.category_outlined),
                              ),
                              items: categories
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() => selectedCategory = val);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: durationController,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              decoration: const InputDecoration(
                                labelText: "Duration (e.g. 45:12)",
                                prefixIcon: Icon(Icons.timer_outlined),
                              ),
                              validator: (val) =>
                                  val == null || val.trim().isEmpty
                                  ? "Duration is required"
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: imageController,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: const InputDecoration(
                          labelText: "Cover Image URL (Optional)",
                          prefixIcon: Icon(Icons.image_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: tagController,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: const InputDecoration(
                          labelText: "Tag (e.g. Featured, Trending, New)",
                          prefixIcon: Icon(Icons.label_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: videoController,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: const InputDecoration(
                          labelText: "Video / YouTube URL (Optional)",
                          prefixIcon: Icon(Icons.video_library_outlined),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ObsidianTheme.primaryCrimson,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final title = titleController.text.trim();
                            final speaker = speakerController.text.trim();
                            final duration = durationController.text.trim();
                            final image = imageController.text.trim();
                            final tag = tagController.text.trim();
                            final video = videoController.text.trim();

                            Navigator.pop(ctx); // Close sheet

                            // Show loading dialog
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const Center(
                                child: CustomLogoLoader(size: 48),
                              ),
                            );

                            final success = await ref
                                .read(sermonProvider.notifier)
                                .addSermon(
                                  title: title,
                                  speaker: speaker,
                                  category: selectedCategory,
                                  duration: duration,
                                  imageUrl: image,
                                  tag: tag,
                                  videoUrl: video,
                                );

                            if (context.mounted) {
                              Navigator.pop(context); // Close loading dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? "Sermon posted successfully!"
                                        : "Failed to post sermon. Try again.",
                                  ),
                                  backgroundColor: success
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text("POST SERMON"),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
