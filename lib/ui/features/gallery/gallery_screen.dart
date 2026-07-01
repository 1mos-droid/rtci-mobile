import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:rtc_mobile/providers/riverpod_providers.dart';
import 'package:rtc_mobile/providers/gallery_provider.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUploadImage(BuildContext context, GalleryProvider provider) async {
    final theme = Theme.of(context);

    // Pick source
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: ObsidianTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: ObsidianTheme.secondaryGold),
              title: Text("Take Photo", style: TextStyle(color: ObsidianTheme.textVibrant)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: ObsidianTheme.secondaryGold),
              title: Text("Choose from Gallery", style: TextStyle(color: ObsidianTheme.textVibrant)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 75,
      maxWidth: 800,
    );

    if (image == null) return;

    if (!context.mounted) return;

    // Show details input dialog
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ObsidianTheme.backgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(

  @override
  Widget build(BuildContext context) {
    final galleryProv = Provider.of<GalleryProvider>(context);
    final images = galleryProv.images;

    return Scaffold(
      backgroundColor: ObsidianTheme.backgroundDark,
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
                  "Service Gallery",
                  style: GoogleFonts.cinzel(
                    color: ObsidianTheme.textVibrant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20.0),
              sliver: galleryProv.isLoading && images.isEmpty
                ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                : images.isEmpty
                  ? const SliverFillRemaining(child: Center(child: Text("No gallery images found.", style: TextStyle(color: Colors.white))))
                  : SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio: 0.8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final img = images[index];
                    return GlassCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Image.network(
                              img.url,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: ObsidianTheme.borderHairline,
                                child: const Icon(Icons.broken_image, color: ObsidianTheme.textMuted),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  img.description ?? "Worship Service",
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  DateFormat('MMM dd, yyyy').format(img.serviceDate),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 9, color: ObsidianTheme.textMuted),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                  childCount: images.length,
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
