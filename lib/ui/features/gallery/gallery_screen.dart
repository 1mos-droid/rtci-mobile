import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:rtc_mobile/providers/gallery_provider.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

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
