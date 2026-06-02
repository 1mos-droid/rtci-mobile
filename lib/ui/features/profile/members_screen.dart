import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:rtc_mobile/providers/members_provider.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  String _searchTerm = '';

  @override
  Widget build(BuildContext context) {
    final membersProv = Provider.of<MembersProvider>(context);
    final filteredMembers = membersProv.members.where((m) => 
      m.name.toLowerCase().contains(_searchTerm.toLowerCase()) ||
      m.email.toLowerCase().contains(_searchTerm.toLowerCase())
    ).toList();

    return Scaffold(
      backgroundColor: ObsidianTheme.backgroundDark,
      body: MeshGradientBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              pinned: true,
              expandedHeight: 140.0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 48, bottom: 16),
                title: Text(
                  "Member Directory",
                  style: GoogleFonts.cinzel(
                    color: ObsidianTheme.textVibrant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchTerm = val),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search registry...",
                      hintStyle: const TextStyle(color: ObsidianTheme.textMuted),
                      prefixIcon: const Icon(Icons.search, color: ObsidianTheme.textMuted),
                      filled: true,
                      fillColor: ObsidianTheme.surfaceDark.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20.0),
              sliver: membersProv.isLoading && filteredMembers.isEmpty
                ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                : filteredMembers.isEmpty
                  ? const SliverFillRemaining(child: Center(child: Text("No members found.", style: TextStyle(color: Colors.white))))
                  : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final member = filteredMembers[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: ObsidianTheme.primaryCrimson.withOpacity(0.2),
                              child: Text(
                                member.name[0],
                                style: const TextStyle(
                                  color: ObsidianTheme.primaryCrimson,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member.name,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  if (member.department != null)
                                    Text(
                                      member.department!,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: ObsidianTheme.secondaryGold,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  Text(
                                    member.email,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.more_vert, color: ObsidianTheme.textMuted),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: filteredMembers.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}
