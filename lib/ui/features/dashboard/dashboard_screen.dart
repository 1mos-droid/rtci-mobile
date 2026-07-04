import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:rtc_mobile/widgets/modern_widgets.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:rtc_mobile/providers/riverpod_providers.dart';

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
    // Fetch broadcasts and sermons on startup
    Future.microtask(() {
      ref.read(broadcastProvider.notifier).fetchBroadcasts();
      ref.read(sermonProvider.notifier).fetchSermons();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).value;
    final finance = ref.watch(financialProvider);
    final prayers = ref.watch(prayerProvider);
    final care = ref.watch(careProvider);
    final insights = ref.watch(dailyInsightsProvider);
    final eventsProv = ref.watch(eventsProvider);
    final broadcasts = ref.watch(broadcastProvider);
    final sermonsProv = ref.watch(sermonProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLeader = user?.isDeptHead ?? false;
    final primaryAccent = isLeader ? AppTheme.accentGold : AppTheme.iosPrimaryLight;

    return Scaffold(
      body: MeshGradientBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Premium custom App Bar
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              expandedHeight: 120.0,
              pinned: true,
              centerTitle: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(),
                titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Sanctuary",
                      style: GoogleFonts.cinzel(
                        fontWeight: FontWeight.bold,
                        color: ObsidianTheme.textVibrant,
                        fontSize: 22,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showNotificationsBottomSheet(context, broadcasts.messages),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF151B2C) : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                            width: 1.0,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Icon(
                              Icons.notifications_outlined,
                              color: ObsidianTheme.textVibrant,
                              size: 20,
                            ),
                            if (broadcasts.messages.isNotEmpty)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.iosPrimaryLight,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Member Profile Overview Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: primaryAccent.withOpacity(0.1),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primaryAccent.withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  (user?.name.isNotEmpty ?? false)
                                      ? user!.name.substring(0, 1).toUpperCase()
                                      : 'U',
                                  style: GoogleFonts.cinzel(
                                    color: primaryAccent,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "WELCOME BACK",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: ObsidianTheme.textMuted,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user?.name ?? 'Fellow worshiper',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: ObsidianTheme.textVibrant,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: primaryAccent.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isLeader
                                        ? (user?.role.name.toUpperCase() ?? '')
                                        : "COVENANT MEMBER",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w800,
                                      color: primaryAccent,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),

                    const SizedBox(height: 24),

                    // Daily Scripture Revelation
                    Row(
                      children: [
                        const Icon(Icons.menu_book_rounded, color: AppTheme.accentGold, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "DAILY REVELATION",
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            color: ObsidianTheme.textVibrant,
                            fontSize: 12,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    GlassCard(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(20),
                      child: insights.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : insights.currentInsight == null
                              ? Center(
                                  child: Text(
                                    "No revelation available today.",
                                    style: TextStyle(color: ObsidianTheme.textMuted),
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "\"${insights.currentInsight!.content}\"",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontStyle: FontStyle.italic,
                                        color: ObsidianTheme.textVibrant,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "— ${insights.currentInsight!.reference ?? insights.currentInsight!.author ?? ''}",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.accentGold,
                                      ),
                                    ),
                                  ],
                                ),
                    ).animate().fadeIn(delay: 100.ms, duration: 500.ms),

                    const SizedBox(height: 24),

                    // Care Queue for Leaders
                    if (isLeader && care.careQueue.isNotEmpty) ...[
                      Text(
                        "FELLOWSHIP CARE QUEUE",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          color: ObsidianTheme.textVibrant,
                          fontSize: 12,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 130,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: care.careQueue.length,
                          itemBuilder: (context, index) {
                            final item = care.careQueue[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppTheme.iosPrimaryLight.withOpacity(0.15),
                                    width: 1.0,
                                  ),
                                ),
                                child: SizedBox(
                                  width: 220,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.memberName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              "${item.absenceCount} MISS",
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
                                            onPressed: () => care.resolveTicket(item.id),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.mail_outline_rounded, size: 20, color: Colors.blue),
                                            onPressed: () => _contactMember(context, item.memberId, item.memberName),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ).animate().fadeIn(delay: 150.ms, duration: 500.ms),
                      const SizedBox(height: 24),
                    ],

                    // Glanceable Metrics Horizontal List
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildMetricCard(
                            context,
                            title: "CONTRIBUTIONS",
                            value: "GHC ${finance.totalRevenue.toStringAsFixed(0)}",
                            subtitle: "Audit Ledger",
                            color: AppTheme.iosPrimaryLight,
                          ),
                          const SizedBox(width: 12),
                          _buildMetricCard(
                            context,
                            title: "INTERCESSIONS",
                            value: "${prayers.prayers.length}",
                            subtitle: "Active Petitions",
                            color: AppTheme.accentGold,
                          ),
                          const SizedBox(width: 12),
                          _buildMetricCard(
                            context,
                            title: "SERVICES",
                            value: "${eventsProv.events.length}",
                            subtitle: "Upcoming Events",
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

                    const SizedBox(height: 28),

                    // Feed Filter Tabs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: ['All', 'Sermons', 'Announcements'].map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                cat,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isSelected ? Colors.white : ObsidianTheme.textVibrant,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (_) => setState(() => _selectedCategory = cat),
                              selectedColor: theme.colorScheme.primary,
                              backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Content Feed List
                    if (_selectedCategory == 'All' || _selectedCategory == 'Sermons') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "RECENT SERMONS",
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              color: ObsidianTheme.textVibrant,
                              fontSize: 12,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Row(
                            children: [
                              if (isLeader)
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                                  color: theme.colorScheme.primary,
                                  onPressed: () => _showAddSermonSheet(context),
                                ),
                              Text(
                                "See All",
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      sermonsProv.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : sermonsProv.sermons.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.symmetric(vertical: 32),
                                  alignment: Alignment.center,
                                  child: Column(
                                    children: [
                                      Icon(Icons.video_library_outlined, size: 40, color: ObsidianTheme.textMuted),
                                      const SizedBox(height: 8),
                                      Text(
                                        "No sermons posted yet.",
                                        style: TextStyle(color: ObsidianTheme.textMuted),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: sermonsProv.sermons.length,
                                  itemBuilder: (context, index) {
                                    final s = sermonsProv.sermons[index];
                                    return ContentCard(
                                      title: s.title,
                                      category: s.speaker,
                                      time: DateFormat('MMM dd, yyyy').format(s.date),
                                      duration: s.duration,
                                      imageUrl: s.imageUrl,
                                      tag: s.tag.isEmpty ? null : s.tag,
                                      onTap: () {
                                        _showVideoPlayer(context, s.title, s.speaker);
                                      },
                                    );
                                  },
                                ).animate().fadeIn(duration: 400.ms),
                      const SizedBox(height: 24),
                    ],

                    if (_selectedCategory == 'All' || _selectedCategory == 'Announcements') ...[
                      Text(
                        "CHURCH ANNOUNCEMENTS",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          color: ObsidianTheme.textVibrant,
                          fontSize: 12,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      broadcasts.isLoading
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: ObsidianTheme.surfaceDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ObsidianTheme.borderHairline),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: ObsidianTheme.textMuted,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 10,
              color: ObsidianTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, ChurchEvent event) {
    final day = DateFormat('dd').format(event.date);
    final month = DateFormat('MMM').format(event.date).toUpperCase();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: ObsidianTheme.secondaryGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ObsidianTheme.secondaryGold.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  day,
                  style: GoogleFonts.cinzel(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: ObsidianTheme.secondaryGold,
                  ),
                ),
                Text(
                  month,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: ObsidianTheme.secondaryGold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ObsidianTheme.textVibrant,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: ObsidianTheme.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event.time,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 11),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: ObsidianTheme.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSermonsList(BuildContext context) {
    return Center(
      child: Text(
        "No recent sermons available.",
        style: TextStyle(color: ObsidianTheme.textMuted),
      ),
    );
  }
}