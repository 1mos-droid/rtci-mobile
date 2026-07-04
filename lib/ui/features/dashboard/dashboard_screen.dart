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
    final user = ref.watch(authNotifierProvider).value;
    final finance = ref.watch(financialProvider);
    final prayers = ref.watch(prayerProvider);
    final care = ref.watch(careProvider);
    final insights = ref.watch(dailyInsightsProvider);
    final eventsProv = ref.watch(eventsProvider);

    final isLeader = user?.isDeptHead ?? false;
    final primaryAccent = isLeader
        ? ObsidianTheme.secondaryGold
        : ObsidianTheme.primaryCrimson;

    return MeshGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              expandedHeight: 140.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                title: Text(
                  "Sanctuary",
                  style: GoogleFonts.cinzel(
                    fontWeight: FontWeight.bold,
                    color: ObsidianTheme.textVibrant,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Overview Card
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: primaryAccent.withValues(
                              alpha: 0.08,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primaryAccent.withValues(alpha: 0.3),
                                  width: 1.0,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  (user?.name.isNotEmpty ?? false)
                                      ? user!.name.substring(0, 1)
                                      : 'U',
                                  style: GoogleFonts.cinzel(
                                    color: primaryAccent,
                                    fontSize: 24,
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
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        letterSpacing: 1.0,
                                        color: ObsidianTheme.textMuted,
                                        fontSize: 10,
                                      ),
                                ),
                                Text(
                                  (user?.name.isNotEmpty ?? false)
                                      ? user!.name
                                      : 'User',
                                  style: GoogleFonts.cinzel(
                                    color: ObsidianTheme.textVibrant,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryAccent.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isLeader
                                        ? (user?.role.name.toUpperCase() ?? '')
                                        : "COVENANT MEMBER",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
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

                    // Daily Revelation
                    Text(
                      "DAILY REVELATION",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: ObsidianTheme.textVibrant,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: insights.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : insights.currentInsight == null
                          ? Center(
                              child: Text(
                                "No revelation available today.",
                                style: TextStyle(
                                  color: ObsidianTheme.textMuted,
                                ),
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "\"${insights.currentInsight!.content}\"",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: ObsidianTheme.textVibrant,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "— ${insights.currentInsight!.reference ?? insights.currentInsight!.author ?? ''}",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: ObsidianTheme.secondaryGold,
                                  ),
                                ),
                              ],
                            ),
                    ).animate().fadeIn(delay: 150.ms, duration: 500.ms),

                    const SizedBox(height: 24),

                    // Care Queue for Leaders
                    if (isLeader && care.careQueue.isNotEmpty) ...[
                      Text(
                        "FELLOWSHIP CARE QUEUE",
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: ObsidianTheme.textVibrant,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 140,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: care.careQueue.length,
                          itemBuilder: (context, index) {
                            final item = care.careQueue[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: GlassCard(
                                padding: const EdgeInsets.all(16),
                                borderType: GlassBorderType.crimson,
                                child: SizedBox(
                                  width: 220,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withValues(
                                                alpha: 0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.check_circle_outline,
                                              size: 18,
                                              color: Colors.green,
                                            ),
                                            onPressed: () =>
                                                care.resolveTicket(item.id),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.mail_outline,
                                              size: 18,
                                              color: Colors.blue,
                                            ),
                                            onPressed: () {},
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
                      ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                      const SizedBox(height: 24),
                    ],

                    // Glanceable Metrics
                    SizedBox(
                      height: 110,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildMetricCard(
                            context,
                            title: "CONTRIBUTIONS",
                            value:
                                "GHC ${finance.totalRevenue.toStringAsFixed(0)}",
                            subtitle: "Audit Ledger",
                            color: ObsidianTheme.primaryCrimson,
                          ),
                          const SizedBox(width: 12),
                          _buildMetricCard(
                            context,
                            title: "INTERCESSIONS",
                            value: "${prayers.prayers.length}",
                            subtitle: "Active Petitions",
                            color: ObsidianTheme.secondaryGold,
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
                    ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

                    const SizedBox(height: 24),

                    // Upcoming Sermons
                    Text(
                      "RECENT SERMONS",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: ObsidianTheme.textVibrant,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSermonsList(context),
                    const SizedBox(height: 24),

                    // Upcoming Events Feed
                    Text(
                      "UPCOMING THIS WEEK",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: ObsidianTheme.textVibrant,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    eventsProv.events.isEmpty
                        ? Center(
                            child: Text(
                              "No events scheduled.",
                              style: TextStyle(color: ObsidianTheme.textMuted),
                            ),
                          )
                        : Column(
                            children: eventsProv.events
                                .take(3)
                                .map(
                                  (e) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildEventCard(context, e),
                                  ),
                                )
                                .toList(),
                          ).animate().fadeIn(delay: 450.ms, duration: 500.ms),

                    const SizedBox(height: 80), // Padding for BottomNav
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