import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:rtc_mobile/providers/attendance_provider.dart';
import 'package:rtc_mobile/providers/auth_provider.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _headcountController = TextEditingController();

  @override
  void dispose() {
    _headcountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProv = Provider.of<AttendanceProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

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
                  "Attendance",
                  style: GoogleFonts.cinzel(
                    color: ObsidianTheme.textVibrant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(Icons.how_to_reg, size: 48, color: ObsidianTheme.primaryCrimson),
                          const SizedBox(height: 16),
                          Text("Service Headcount", style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text("Enter the total number of people in attendance.", style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _headcountController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "0",
                              hintStyle: TextStyle(color: ObsidianTheme.textMuted.withOpacity(0.5)),
                              border: InputBorder.none,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                final count = int.tryParse(_headcountController.text);
                                if (count != null) {
                                  final success = await attendanceProv.saveRecord(
                                    date: DateTime.now(),
                                    headcount: count,
                                    department: auth.department,
                                  );
                                  if (success && mounted) {
                                    _headcountController.clear();
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Attendance recorded!")));
                                  }
                                }
                              },
                              child: const Text("SAVE RECORD"),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "RECENT RECORDS",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: ObsidianTheme.textVibrant, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 12),
                    if (attendanceProv.isLoading && attendanceProv.records.isEmpty)
                      const CircularProgressIndicator()
                    else if (attendanceProv.records.isEmpty)
                      const Text("No recent records found.", style: TextStyle(color: ObsidianTheme.textMuted))
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: attendanceProv.records.length.clamp(0, 10),
                        itemBuilder: (context, index) {
                          final record = attendanceProv.records[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GlassCard(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('EEEE, MMM dd').format(record.date),
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      if (record.department != null)
                                        Text(record.department!, style: const TextStyle(color: ObsidianTheme.textMuted, fontSize: 11)),
                                    ],
                                  ),
                                  Text(
                                    record.headcount.toString(),
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: ObsidianTheme.secondaryGold),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
