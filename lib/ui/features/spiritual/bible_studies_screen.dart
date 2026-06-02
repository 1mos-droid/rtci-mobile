import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:rtc_mobile/providers/bible_studies_provider.dart';

class BibleStudiesScreen extends StatefulWidget {
  const BibleStudiesScreen({super.key});

  @override
  State<BibleStudiesScreen> createState() => _BibleStudiesScreenState();
}

class _BibleStudiesScreenState extends State<BibleStudiesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final libProv = Provider.of<BibleStudiesProvider>(context);

    return MeshGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: ObsidianTheme.textVibrant, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Ministerial Library",
            style: GoogleFonts.cinzel(
              fontWeight: FontWeight.bold,
              color: ObsidianTheme.textVibrant,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: ObsidianTheme.secondaryGold,
            labelColor: ObsidianTheme.primaryCrimson,
            unselectedLabelColor: ObsidianTheme.textMuted,
            labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: "Study Modules"),
              Tab(text: "Resources"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildModulesTab(libProv),
            _buildResourcesTab(libProv),
          ],
        ),
      ),
    );
  }

  Widget _buildModulesTab(BibleStudiesProvider libProv) {
    if (libProv.isLoading && libProv.modules.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (libProv.modules.isEmpty) {
      return const Center(child: Text("No study modules found.", style: TextStyle(color: Colors.white)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: libProv.modules.length,
      itemBuilder: (context, index) {
        final module = libProv.modules[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.bookmark, color: ObsidianTheme.secondaryGold),
                    Text("${module.progress}%", style: GoogleFonts.plusJakartaSans(color: ObsidianTheme.primaryCrimson, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(module.title, style: Theme.of(context).textTheme.headlineMedium),
                if (module.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(module.subtitle!, style: Theme.of(context).textTheme.bodyMedium),
                ],
                const SizedBox(height: 24),
                LinearProgressIndicator(
                  value: module.progress / 100,
                  backgroundColor: ObsidianTheme.borderHairline,
                  color: ObsidianTheme.primaryCrimson,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text("VIEW SYLLABUS"),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResourcesTab(BibleStudiesProvider libProv) {
    if (libProv.isLoading && libProv.resources.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (libProv.resources.isEmpty) {
      return const Center(child: Text("No resources found.", style: TextStyle(color: Colors.white)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: libProv.resources.length,
      itemBuilder: (context, index) {
        final res = libProv.resources[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: ObsidianTheme.secondaryGold.withOpacity(0.1),
                child: const Icon(Icons.file_present_outlined, color: ObsidianTheme.secondaryGold),
              ),
              title: Text(res.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(res.type?.toUpperCase() ?? 'DOCUMENT', style: const TextStyle(color: ObsidianTheme.textMuted, fontSize: 10)),
              trailing: IconButton(
                icon: const Icon(Icons.download, color: ObsidianTheme.textVibrant, size: 20),
                onPressed: () {},
              ),
            ),
          ),
        );
      },
    );
  }
}
