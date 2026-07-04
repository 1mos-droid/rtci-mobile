import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:rtc_mobile/providers/riverpod_providers.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:rtc_mobile/widgets/skeleton_loader.dart';

class BibleStudiesScreen extends ConsumerStatefulWidget {
  const BibleStudiesScreen({super.key});

  @override
  ConsumerState<BibleStudiesScreen> createState() => _BibleStudiesScreenState();
}

class _BibleStudiesScreenState extends ConsumerState<BibleStudiesScreen> with SingleTickerProviderStateMixin {
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

  void _showAddModuleDialog() {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final descController = TextEditingController();
    final imgController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E202C) : const Color(0xFFE0E5EC),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            "Add Study Module",
            style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: ObsidianTheme.textVibrant),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController, 
                  decoration: const InputDecoration(labelText: "Title"),
                  style: TextStyle(color: ObsidianTheme.textVibrant),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: subtitleController, 
                  decoration: const InputDecoration(labelText: "Subtitle"),
                  style: TextStyle(color: ObsidianTheme.textVibrant),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descController, 
                  decoration: const InputDecoration(labelText: "Description"),
                  style: TextStyle(color: ObsidianTheme.textVibrant),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: imgController, 
                  decoration: const InputDecoration(labelText: "Image URL"),
                  style: TextStyle(color: ObsidianTheme.textVibrant),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), 
              child: Text("CANCEL", style: TextStyle(color: ObsidianTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final subtitle = subtitleController.text.trim();
                final desc = descController.text.trim();
                final img = imgController.text.trim();
                if (title.isNotEmpty && desc.isNotEmpty) {
                  Navigator.pop(dialogContext);
                  final success = await ref.read(bibleStudiesProvider).addModule(
                    title: title,
                    subtitle: subtitle.isEmpty ? "" : subtitle,
                    description: desc,
                    imageUrl: img.isEmpty ? "https://images.unsplash.com/photo-1504052434569-70ad58c6744a" : img,
                  );
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Module added successfully!"))
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: ObsidianTheme.primaryCrimson, foregroundColor: Colors.white),
              child: const Text("ADD"),
            ),
          ],
        );
      },
    );
  }

  void _showAddResourceDialog(String moduleId) {
    final titleController = TextEditingController();
    final typeController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E202C) : const Color(0xFFE0E5EC),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            "Add Study Resource",
            style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: ObsidianTheme.textVibrant),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController, 
                decoration: const InputDecoration(labelText: "Resource Title"),
                style: TextStyle(color: ObsidianTheme.textVibrant),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: typeController, 
                decoration: const InputDecoration(labelText: "Type (e.g. PDF, Audio, Video)"),
                style: TextStyle(color: ObsidianTheme.textVibrant),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: urlController, 
                decoration: const InputDecoration(labelText: "Resource URL"),
                style: TextStyle(color: ObsidianTheme.textVibrant),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), 
              child: Text("CANCEL", style: TextStyle(color: ObsidianTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final type = typeController.text.trim();
                final url = urlController.text.trim();
                if (title.isNotEmpty && type.isNotEmpty && url.isNotEmpty) {
                  Navigator.pop(dialogContext);
                  final success = await ref.read(bibleStudiesProvider).addResource(
                    moduleId: moduleId,
                    title: title,
                    type: type.toLowerCase(),
                    url: url,
                  );
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Resource added successfully!"))
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: ObsidianTheme.primaryCrimson, foregroundColor: Colors.white),
              child: const Text("ADD"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final libProv = ref.watch(bibleStudiesProvider);
    final user = ref.watch(authNotifierProvider).value;
    final isAdmin = user?.isAdmin ?? false;

    return MeshGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: ObsidianTheme.textVibrant, size: 18),
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
        floatingActionButton: isAdmin ? FloatingActionButton(
          backgroundColor: ObsidianTheme.primaryCrimson,
          onPressed: _showAddModuleDialog,
          child: const Icon(Icons.add, color: Colors.white),
        ) : null,
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildModulesTab(libProv, isAdmin),
            _buildResourcesTab(libProv, isAdmin),
          ],
        ),
      ),
    );
  }

  Widget _buildModulesTab(BibleStudiesProvider libProv, bool isAdmin) {
    if (libProv.isLoading && libProv.modules.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 3,
        itemBuilder: (context, index) => const Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: GlassCard(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonContainer(width: 24, height: 24, borderRadius: 12),
                    SkeletonContainer(width: 40, height: 16),
                  ],
                ),
                SizedBox(height: 16),
                SkeletonContainer(width: 200, height: 28),
                SizedBox(height: 8),
                SkeletonContainer(width: 140, height: 16),
                SizedBox(height: 24),
                SkeletonContainer(height: 6, borderRadius: 3),
                SizedBox(height: 24),
                SkeletonContainer(height: 48, borderRadius: 24),
              ],
            ),
          ),
        ),
      );
    }

    if (libProv.modules.isEmpty) {
      return Center(child: Text("No study modules found.", style: TextStyle(color: ObsidianTheme.textVibrant)));
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
                    Icon(Icons.bookmark, color: ObsidianTheme.secondaryGold),
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
      return Center(child: Text("No resources found.", style: TextStyle(color: ObsidianTheme.textVibrant)));
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
                backgroundColor: ObsidianTheme.secondaryGold.withValues(alpha: 0.1),
                child: Icon(Icons.file_present_outlined, color: ObsidianTheme.secondaryGold),
              ),
              title: Text(res.title, style: TextStyle(color: ObsidianTheme.textVibrant, fontWeight: FontWeight.bold)),
              subtitle: Text(res.type.toUpperCase(), style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 10)),
              trailing: IconButton(
                icon: Icon(Icons.download, color: ObsidianTheme.textVibrant, size: 20),
                onPressed: () {},
              ),
            ),
          ),
        );
      },
    );
  }
}