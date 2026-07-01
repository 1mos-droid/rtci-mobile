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
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Post Service Moment",
                        style: GoogleFonts.cinzel(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ObsidianTheme.textVibrant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(image.path),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: titleController,
                        style: TextStyle(color: ObsidianTheme.textVibrant),
                        decoration: const InputDecoration(
                          labelText: "Title",
                          hintText: "e.g. Sunday Service",
                        ),
                        validator: (val) => val == null || val.isEmpty ? "Title is required" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descController,
                        style: TextStyle(color: ObsidianTheme.textVibrant),
                        decoration: const InputDecoration(
                          labelText: "Description / Caption",
                          hintText: "e.g. Worship team pop off fr",
                        ),
                        validator: (val) => val == null || val.isEmpty ? "Description is required" : null,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text("Service Date", style: TextStyle(color: ObsidianTheme.textVibrant, fontSize: 14)),
                        subtitle: Text(
                          DateFormat('yyyy-MM-dd').format(selectedDate),
                          style: TextStyle(color: ObsidianTheme.secondaryGold, fontWeight: FontWeight.bold),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.calendar_month, color: ObsidianTheme.secondaryGold),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setSheetState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: provider.isLoading
                            ? null
                            : () async {
                                if (formKey.currentState!.validate()) {
                                  setSheetState(() {});
                                  try {
                                    // 1. Upload the image file
                                    final downloadUrl = await provider.uploadImage(File(image.path));
                                    
                                    // 2. Add item to Firestore collection
                                    final success = await provider.addGalleryItem(
                                      imageUrl: downloadUrl,
                                      title: titleController.text.trim(),
                                      description: descController.text.trim(),
                                      date: selectedDate,
                                    );

                                    if (success && context.mounted) {
                                      Navigator.pop(context); // Close dialog
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Moment added to service gallery!"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Upload failed: $e"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                        child: provider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text("UPLOAD MOMENT"),
                      ),
                      const SizedBox(height: 24),
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

  void _showDeleteConfirmation(BuildContext context, GalleryProvider provider, GalleryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text("Delete Moment"),
        content: const Text("Are you sure you want to remove this moment from the service gallery?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              final success = await provider.deleteGalleryItem(item.id, item.imageUrl);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Moment deleted successfully.")),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _viewFullImage(BuildContext context, GalleryProvider provider, GalleryItem item, bool canManage) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const SizedBox(
                      height: 300,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                    height: 200,
                    child: Center(child: Icon(Icons.broken_image, size: 48, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ObsidianTheme.surfaceDark.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ObsidianTheme.borderHairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (canManage)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () {
                              Navigator.pop(context); // Close view image dialog
                              _showDeleteConfirmation(context, provider, item);
                            },
                          ),
                      ],
                    ),
                    if (item.description != null && item.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        item.description!,
                        style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 13),
                      ),
                    ],
                    Divider(color: ObsidianTheme.borderHairline, height: 24),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 12, color: ObsidianTheme.textMuted),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMMM dd, yyyy').format(item.date),
                          style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.value;
    final isAdmin = user?.isAdmin ?? false;
    final isDeptHead = user?.isDeptHead ?? false;
    final canManage = isAdmin || isDeptHead;

    final galleryProv = ref.watch(galleryProvider);
    final images = galleryProv.images;

    return Scaffold(
      backgroundColor: ObsidianTheme.backgroundDark,
      body: MeshGradientBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
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
              actions: [
                if (canManage)
                  IconButton(
                    icon: Icon(Icons.add_a_photo_outlined, color: ObsidianTheme.secondaryGold),
                    onPressed: () => _pickAndUploadImage(context, galleryProv),
                  ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20.0),
              sliver: galleryProv.isLoading && images.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : images.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Text(
                              "No gallery images found.",
                              style: TextStyle(color: ObsidianTheme.textVibrant),
                            ),
                          ),
                        )
                      : SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16.0,
                            crossAxisSpacing: 16.0,
                            childAspectRatio: 0.8,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
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
