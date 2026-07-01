import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:rtc_mobile/providers/riverpod_providers.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';

class PrayerRequestsScreen extends ConsumerStatefulWidget {
  const PrayerRequestsScreen({super.key});

  @override
  ConsumerState<PrayerRequestsScreen> createState() => _PrayerRequestsScreenState();
}

class _PrayerRequestsScreenState extends ConsumerState<PrayerRequestsScreen> {

  void _showAddPrayerSheet(BuildContext context, String userEmail) {
    final contentController = TextEditingController();
    bool isPrivate = false;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: ObsidianTheme.borderHairline,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "File Prayer Petition",
                        style: GoogleFonts.cinzel(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ObsidianTheme.textVibrant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: contentController,
                        maxLines: 4,
                        style: TextStyle(color: ObsidianTheme.textVibrant),
                        decoration: InputDecoration(
                          hintText: "State your intercession request here...",
                          hintStyle: TextStyle(color: ObsidianTheme.textMuted),
                          filled: true,
                          fillColor: ObsidianTheme.surfaceDark.withValues(alpha: 0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: ObsidianTheme.borderHairline),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: Text(
                          "Private (Pastors only)",
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: ObsidianTheme.textVibrant),
                        ),
                        value: isPrivate,
                        activeThumbColor: ObsidianTheme.secondaryGold,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) {
                          setModalState(() => isPrivate = val);
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ObsidianTheme.primaryCrimson,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final auth = Provider.of<AuthProvider>(context, listen: false);
                            final prayerProv = Provider.of<PrayerProvider>(context, listen: false);
                            await prayerProv.submitPrayer(
                              contentController.text,
                              isPrivate,
                              auth.userEmail, // Using email as temp ID or get real profile ID
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Petition filed! 我们在为您祷告。"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text("Submit Petition"),
                      ),
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

  @override
  Widget build(BuildContext context) {
    final prayerProv = Provider.of<PrayerProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final list = prayerProv.prayers;

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
            "Intercession Wall",
            style: GoogleFonts.cinzel(
              fontWeight: FontWeight.bold,
              color: ObsidianTheme.textVibrant,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: prayerProv.isLoading && list.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : list.isEmpty
                      ? Center(child: Text("No petitions filed.", style: Theme.of(context).textTheme.bodyMedium))
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final prayer = list[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GlassCard(
                                padding: const EdgeInsets.all(20),
                                borderType: prayer.status == 'answered' ? GlassBorderType.gold : GlassBorderType.normal,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Chip(
                                          label: Text(prayer.status.toUpperCase()),
                                          backgroundColor: prayer.status == 'answered' ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                                          labelStyle: TextStyle(
                                            color: prayer.status == 'answered' ? Colors.green : Colors.orange,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          padding: EdgeInsets.zero,
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        if (prayer.isPrivate)
                                          const Icon(Icons.lock_outline, size: 16, color: ObsidianTheme.textMuted),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      prayer.request,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        height: 1.5,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    const Divider(height: 30, color: ObsidianTheme.borderHairline),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "BY: ${prayer.memberName?.toUpperCase() ?? 'ANONYMOUS'}",
                                          style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: ObsidianTheme.textMuted),
                                        ),
                                        if (auth.isAdmin || auth.isDeptHead)
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.check_circle_outline, size: 18),
                                                onPressed: () => prayerProv.updateStatus(prayer.id, 'answered'),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.volunteer_activism_outlined, size: 18),
                                                onPressed: () => prayerProv.updateStatus(prayer.id, 'praying'),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: ObsidianTheme.primaryCrimson,
          onPressed: () => _showAddPrayerSheet(context),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Petition", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
