import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  "Audit Reports",
                  style: GoogleFonts.cinzel(
                    color: ObsidianTheme.primaryCrimson,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final reports = [
                      {"title": "Member Registry", "desc": "Comprehensive list of all registered congregation members.", "icon": Icons.people},
                      {"title": "Financial Ledger", "desc": "Audit-ready logs of all contributions and expenditures.", "icon": Icons.attach_money},
                      {"title": "Attendance Logs", "desc": "Historical data of service participation.", "icon": Icons.calendar_today},
                    ];
                    final report = reports[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(report['icon'] as IconData, size: 40, color: ObsidianTheme.primaryCrimson),
                            const SizedBox(height: 16),
                            Text(report['title'] as String, style: Theme.of(context).textTheme.headlineMedium),
                            const SizedBox(height: 8),
                            Text(report['desc'] as String, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _exportReport(context, report['title'] as String, "PDF"),
                                    icon: const Icon(Icons.picture_as_pdf),
                                    label: const Text("PDF"),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _exportReport(context, report['title'] as String, "EXCEL"),
                                    icon: const Icon(Icons.table_chart),
                                    label: const Text("EXCEL"),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportReport(BuildContext context, String title, String format) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _ExportingDialog(
          title: title,
          format: format,
          onComplete: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("$title exported as $format successfully!"),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
        );
      },
    );
  }
}

class _ExportingDialog extends StatefulWidget {
  final String title;
  final String format;
  final VoidCallback onComplete;

  const _ExportingDialog({
    required this.title,
    required this.format,
    required this.onComplete,
  });

  @override
  State<_ExportingDialog> createState() => _ExportingDialogState();
}

class _ExportingDialogState extends State<_ExportingDialog> {
  double _progress = 0.0;
  bool _finished = false;
