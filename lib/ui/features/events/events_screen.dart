import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:rtc_mobile/providers/riverpod_providers.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {

  void _showAddEventSheet(BuildContext context) {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final timeController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 2));
    bool isOnline = false;
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
                  child: SingleChildScrollView(
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
                        const SizedBox(height: 20),
                        Text(
                          "Schedule Sanctuary Event",
                          style: GoogleFonts.cinzel(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ObsidianTheme.primaryCrimson,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: nameController,
                          style: TextStyle(color: ObsidianTheme.textVibrant),
                          decoration: InputDecoration(
                            labelText: "Event Title",
                            hintText: "E.g., Midweek Revival",
                            labelStyle: TextStyle(color: ObsidianTheme.textMuted),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ObsidianTheme.borderHairline)),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: ObsidianTheme.primaryCrimson)),
                          ),
                          validator: (val) => val == null || val.isEmpty ? "Event title required" : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600,
                                  color: ObsidianTheme.textVibrant,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (date != null) {
                                  setModalState(() => selectedDate = date);
                                }
                              },
                              child: const Text("Select Date"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: timeController,
                          style: TextStyle(color: ObsidianTheme.textVibrant),
                          decoration: InputDecoration(
                            labelText: "Service Hours",
                            hintText: "E.g., 09:00 AM - 11:30 AM",
                            labelStyle: TextStyle(color: ObsidianTheme.textMuted),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ObsidianTheme.borderHairline)),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: ObsidianTheme.primaryCrimson)),
                          ),
                          validator: (val) => val == null || val.isEmpty ? "Service hours required" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: locationController,
                          style: TextStyle(color: ObsidianTheme.textVibrant),
                          decoration: InputDecoration(
                            labelText: "Physical / Virtual Location",
                            hintText: "E.g., Main Sanctuary or Zoom",
                            labelStyle: TextStyle(color: ObsidianTheme.textMuted),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ObsidianTheme.borderHairline)),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: ObsidianTheme.primaryCrimson)),
                          ),
                          validator: (val) => val == null || val.isEmpty ? "Location required" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: descController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: "Event Description & Focus",
                            hintText: "Focus of the gathering, scriptures, guidelines...",
                            labelStyle: const TextStyle(color: ObsidianTheme.textMuted),
                            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: ObsidianTheme.borderHairline)),
                            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: ObsidianTheme.primaryCrimson)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          title: Text(
                            "Broadcast Stream Online?",
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: ObsidianTheme.textVibrant),
                          ),
                          value: isOnline,
                          activeThumbColor: ObsidianTheme.secondaryGold,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) {
                            setModalState(() => isOnline = val);
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final eventsProv = Provider.of<EventsProvider>(context, listen: false);
                              final auth = Provider.of<AuthProvider>(context, listen: false);
                              
                              final success = await eventsProv.scheduleEvent(
                                name: nameController.text,
                                date: selectedDate,
                                time: timeController.text,
                                location: locationController.text,
                                isOnline: isOnline,
                                description: descController.text,
                                department: auth.department,
                              );

                              if (success && context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Event scheduled on Sanctuary Calendar!"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text("Publish Event to Calendar"),
                        ),
                      ],
                    ),
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
    final auth = Provider.of<AuthProvider>(context);
    final eventsProv = Provider.of<EventsProvider>(context);
    final isLeader = auth.isDeptHead;

    final sortedEvents = eventsProv.events;

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
            "Calendar of Service",
            style: GoogleFonts.cinzel(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: ObsidianTheme.textVibrant,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "UPCOMING SERVICES & ASSEMBLIES",
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            letterSpacing: 1.5,
                            color: ObsidianTheme.secondaryGold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Sanctuary Chronicles",
                      style: GoogleFonts.cinzel(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ObsidianTheme.textVibrant,
                      ),
                    ),
                    Text(
                      "Join the congregation in spiritual worship, local fellowships, and community works.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: eventsProv.isLoading && sortedEvents.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : sortedEvents.isEmpty
                    ? Center(
                        child: Text(
                          "No services scheduled on the calendar.",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: sortedEvents.length,
                        itemBuilder: (context, index) {
                          final event = sortedEvents[index];
                          final day = DateFormat('dd').format(event.date);
                          final month = DateFormat('MMM').format(event.date).toUpperCase();
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: GlassCard(
                              padding: const EdgeInsets.all(18),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 54,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: event.isOnline
                                          ? ObsidianTheme.secondaryGold.withValues(alpha: 0.1)
                                          : ObsidianTheme.surfaceDark.withValues(alpha: 0.5),
                                      border: Border.all(
                                        color: event.isOnline ? ObsidianTheme.secondaryGold : ObsidianTheme.borderHairline,
                                        width: 0.8,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          day,
                                          style: GoogleFonts.cinzel(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: event.isOnline ? ObsidianTheme.secondaryGold : ObsidianTheme.textVibrant,
                                            height: 1.0,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          month,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: ObsidianTheme.textMuted,
                                            letterSpacing: 0.5,
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
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            if (event.department != null)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: ObsidianTheme.secondaryGold.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: ObsidianTheme.secondaryGold.withValues(alpha: 0.3), width: 0.5),
                                                ),
                                                child: Text(
                                                  event.department!.toUpperCase(),
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                    color: ObsidianTheme.secondaryGold,
                                                  ),
                                                ),
                                              ),
                                            if (event.isOnline)
                                              Row(
                                                children: [
                                                  const Icon(Icons.videocam_outlined, size: 14, color: ObsidianTheme.secondaryGold),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "ONLINE",
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 8.5,
                                                      color: ObsidianTheme.secondaryGold,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          event.name,
                                          style: GoogleFonts.cinzel(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: ObsidianTheme.textVibrant,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          event.description,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontSize: 12,
                                                color: ObsidianTheme.textMuted,
                                              ),
                                        ),
                                        const Divider(color: ObsidianTheme.borderHairline, height: 20),
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time_outlined, size: 13, color: ObsidianTheme.textMuted),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                event.time,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: ObsidianTheme.textVibrant,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.map_outlined, size: 13, color: ObsidianTheme.textMuted),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                event.location,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: ObsidianTheme.textVibrant,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text("Attendance confirmed for this service!"),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.check_circle_outline, size: 20),
                                            label: const Text("I'M ATTENDING", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: ObsidianTheme.secondaryGold,
                                              foregroundColor: ObsidianTheme.backgroundDark,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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
        ),
        floatingActionButton: isLeader
            ? FloatingActionButton(
                backgroundColor: ObsidianTheme.primaryCrimson,
                shape: const CircleBorder(),
                elevation: 4,
                onPressed: () => _showAddEventSheet(context),
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
      ),
    );
  }
}
