import 'package:rtc_mobile/widgets/custom_logo_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:rtc_mobile/providers/riverpod_providers.dart';

class LeadershipScreen extends ConsumerWidget {
  const LeadershipScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadershipProv = ref.watch(leadershipProvider);
    final leaders = leadershipProv.leaders;

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
                  "Church Leadership",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20.0),
              sliver: leadershipProv.isLoading && leaders.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(child: CustomLogoLoader(size: 48)),
                    )
                  : leaders.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Text(
                          "Leadership directory is currently empty.",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    )
                  : SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16.0,
                            crossAxisSpacing: 16.0,
                            childAspectRatio: 0.7,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final leader = leaders[index];
                        return GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: leader.avatarUrl != null
                                    ? NetworkImage(leader.avatarUrl!)
                                    : null,
                                backgroundColor: ObsidianTheme.primaryCrimson
                                    .withValues(alpha: 0.2),
                                child: leader.avatarUrl == null
                                    ? Text(
                                        leader.name[0],
                                        style: TextStyle(
                                          fontSize: 32,
                                          color: ObsidianTheme.primaryCrimson,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                leader.name,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.copyWith(fontSize: 16),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: ObsidianTheme.secondaryGold.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  (leader.title.isNotEmpty
                                          ? leader.title
                                          : (leader.department.isNotEmpty
                                                ? leader.department
                                                : 'Official'))
                                      .toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: ObsidianTheme.secondaryGold,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }, childCount: leaders.length),
                    ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}
