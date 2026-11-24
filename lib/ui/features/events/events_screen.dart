import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/custom_logo_loader.dart';
import 'package:rtc_mobile/widgets/feature_state.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:rtc_mobile/providers/riverpod_providers.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  final Set<String> _savingRsvps = {};
  final Set<String> _attending = {};

  Future<void> _rsvp(String eventId) async {
    if (_savingRsvps.contains(eventId) || _attending.contains(eventId)) return;
    setState(() => _savingRsvps.add(eventId));
    final saved = await ref.read(eventsProvider).rsvp(eventId);
    if (!mounted) return;
    setState(() {
      _savingRsvps.remove(eventId);
      if (saved) _attending.add(eventId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'Your attendance response has been saved.'
              : 'We couldn’t save your response. Please try again.',
        ),
      ),
    );
  }

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
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
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
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Schedule an event",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ObsidianTheme.primaryCrimson,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: nameController,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            labelText: "Event Title",
                            hintText: "E.g., Midweek Revival",
                            labelStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ObsidianTheme.primaryCrimson,
                              ),
                            ),
                          ),
                          validator: (val) => val == null || val.isEmpty
                              ? "Event title required"
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
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
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            labelText: "Service Hours",
                            hintText: "E.g., 09:00 AM - 11:30 AM",
                            labelStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ObsidianTheme.primaryCrimson,
                              ),
                            ),
                          ),
                          validator: (val) => val == null || val.isEmpty
                              ? "Service hours required"
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: locationController,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            labelText: "Physical / Virtual Location",
                            hintText: "E.g., Main Sanctuary or Zoom",
                            labelStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ObsidianTheme.primaryCrimson,
                              ),
                            ),
                          ),
                          validator: (val) => val == null || val.isEmpty
                              ? "Location required"
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: descController,
                          maxLines: 3,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            labelText: "Event Description & Focus",
                            hintText:
                                "Focus of the gathering, scriptures, guidelines...",
                            labelStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ObsidianTheme.primaryCrimson,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          title: Text(
                            "Broadcast Stream Online?",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
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
                              final eventsProv = ref.read(eventsProvider);
                              final auth = ref
                                  .read(authNotifierProvider)
                                  .value!;

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
                                    content: Text(
                                      "Event added to the church calendar.",
                                    ),
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
    final auth = ref.watch(authNotifierProvider).value;
    final eventsProv = ref.watch(eventsProvider);
    final isLeader = auth?.isDeptHead ?? false;

    final sortedEvents = [...eventsProv.events]
      ..sort((a, b) => a.date.compareTo(b.date));

    return MeshGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Theme.of(context).colorScheme.onSurface,
              size: 18,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Church calendar",
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "LIFE TOGETHER",
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        letterSpacing: 1.5,
                        color: ObsidianTheme.secondaryGold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Gather with your church family",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
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
                    ? const Center(
                        child: CustomLogoLoader(
                          size: 48,
                          message: 'Loading events…',
                        ),
                      )
                    : eventsProv.error != null && sortedEvents.isEmpty
                    ? FeatureState(
                        icon: Icons.cloud_off_rounded,
                        title: 'The calendar is unavailable',
                        message: eventsProv.error!,
                        actionLabel: 'Try again',
                        onAction: eventsProv.fetchEvents,
                      )
                    : sortedEvents.isEmpty
                    ? FeatureState(
                        icon: Icons.event_outlined,
                        title: 'Good things are ahead',
                        message:
                            'Services and gatherings will appear here when they are scheduled.',
                        actionLabel: 'Refresh',
                        onAction: eventsProv.fetchEvents,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        itemCount: sortedEvents.length,
                        itemBuilder: (context, index) {
                          final event = sortedEvents[index];
                          final day = DateFormat('dd').format(event.date);
                          final month = DateFormat(
                            'MMM',
                          ).format(event.date).toUpperCase();

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: GlassCard(
                              padding: const EdgeInsets.all(18),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 54,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: event.isOnline
                                          ? ObsidianTheme.secondaryGold
                                                .withValues(alpha: 0.1)
                                          : Theme.of(context)
                                                .colorScheme
                                                .surface
                                                .withValues(alpha: 0.5),
                                      border: Border.all(
                                        color: event.isOnline
                                            ? ObsidianTheme.secondaryGold
                                            : Theme.of(
                                                context,
                                              ).colorScheme.outlineVariant,
                                        width: 0.8,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          day,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: event.isOnline
                                                ? ObsidianTheme.secondaryGold
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                            height: 1.0,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          month,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            if (event.department != null)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: ObsidianTheme
                                                      .secondaryGold
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: ObsidianTheme
                                                        .secondaryGold
                                                        .withValues(alpha: 0.3),
                                                    width: 0.5,
                                                  ),
                                                ),
                                                child: Text(
                                                  event.department!
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: ObsidianTheme
                                                        .secondaryGold,
                                                  ),
                                                ),
                                              ),
                                            if (event.isOnline)
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.videocam_outlined,
                                                    size: 14,
                                                    color: ObsidianTheme
                                                        .secondaryGold,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "ONLINE",
                                                    style: TextStyle(
                                                      fontFamily: 'Inter',
                                                      fontSize: 12,
                                                      color: ObsidianTheme
                                                          .secondaryGold,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          event.name,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          event.description ?? '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontSize: 12,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                              ),
                                        ),
                                        Divider(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.outlineVariant,
                                          height: 20,
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time_outlined,
                                              size: 13,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                event.time,
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.map_outlined,
                                              size: 13,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                event.location,
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed:
                                                _savingRsvps.contains(
                                                      event.id,
                                                    ) ||
                                                    _attending.contains(
                                                      event.id,
                                                    )
                                                ? null
                                                : () => _rsvp(event.id),
                                            icon: const Icon(
                                              Icons.check_circle_outline,
                                              size: 20,
                                            ),
                                            label: Text(
                                              _savingRsvps.contains(event.id)
                                                  ? 'Saving…'
                                                  : _attending.contains(
                                                      event.id,
                                                    )
                                                  ? 'You’re on the list'
                                                  : 'I’m attending',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  ObsidianTheme.secondaryGold,
                                              foregroundColor: Theme.of(
                                                context,
                                              ).scaffoldBackgroundColor,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
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
