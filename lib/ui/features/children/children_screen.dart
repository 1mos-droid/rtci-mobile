import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:rtc_mobile/providers/children_provider.dart';

class ChildrenScreen extends StatefulWidget {
  const ChildrenScreen({super.key});

  @override
  State<ChildrenScreen> createState() => _ChildrenScreenState();
}

class _ChildrenScreenState extends State<ChildrenScreen> {
  
  void _showCheckinSheet(BuildContext context) {
    final childController = TextEditingController();
    final parentController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: GlassCard(
            borderRadius: 24,
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "New Child Check-in",
                    style: GoogleFonts.cinzel(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ObsidianTheme.primaryCrimson,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: childController,
                    style: const TextStyle(color: ObsidianTheme.textVibrant),
                    decoration: const InputDecoration(labelText: "Child's Full Name"),
                    validator: (val) => val == null || val.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: parentController,
                    style: const TextStyle(color: ObsidianTheme.textVibrant),
                    decoration: const InputDecoration(labelText: "Parent/Guardian Name"),
                    validator: (val) => val == null || val.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: ObsidianTheme.textVibrant),
                    decoration: const InputDecoration(labelText: "Contact Phone"),
                    validator: (val) => val == null || val.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final prov = Provider.of<ChildrenProvider>(context, listen: false);
                        final success = await prov.checkIn(
                          childName: childController.text,
                          parentName: parentController.text,
                          parentPhone: phoneController.text,
                        );
                        if (success && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Check-in complete!")),
                          );
                        }
                      }
                    },
                    child: const Text("Confirm Check-in"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final childrenProv = Provider.of<ChildrenProvider>(context);

    return Scaffold(
      backgroundColor: ObsidianTheme.backgroundDark,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: ObsidianTheme.primaryCrimson,
        onPressed: () => _showCheckinSheet(context),
        icon: const Icon(Icons.child_care, color: Colors.white),
        label: Text("New Check-in", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
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
                  "Children's Ministry",
                  style: GoogleFonts.cinzel(
                    color: ObsidianTheme.textVibrant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20.0),
              sliver: childrenProv.isLoading && childrenProv.checkins.isEmpty
                ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                : childrenProv.checkins.isEmpty
                  ? const SliverFillRemaining(child: Center(child: Text("No children checked in.", style: TextStyle(color: Colors.white))))
                  : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = childrenProv.checkins[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.childName,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.person_outline, size: 14, color: ObsidianTheme.textMuted),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          "Parent: ${item.parentName}",
                                          style: Theme.of(context).textTheme.bodyMedium,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onLongPress: () => childrenProv.checkOut(item.id),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: ObsidianTheme.secondaryGold.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: ObsidianTheme.secondaryGold.withOpacity(0.3)),
                                ),
                                child: Column(
                                  children: [
                                    Text("TAG", style: GoogleFonts.plusJakartaSans(fontSize: 10, color: ObsidianTheme.secondaryGold, fontWeight: FontWeight.bold)),
                                    Text("#${item.tagNumber}", style: GoogleFonts.plusJakartaSans(fontSize: 18, color: ObsidianTheme.secondaryGold, fontWeight: FontWeight.w900)),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: childrenProv.checkins.length,
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
