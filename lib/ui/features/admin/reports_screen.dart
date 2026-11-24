import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:rtc_mobile/providers/riverpod_providers.dart';
import 'package:rtc_mobile/utils/csv.dart';
import 'package:rtc_mobile/widgets/feature_state.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  Future<void> _copy(
    BuildContext context,
    String title,
    List<List<Object?>> rows,
  ) async {
    try {
      await Clipboard.setData(ClipboardData(text: encodeCsv(rows)));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$title copied as CSV. Paste it into your spreadsheet.',
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('We couldn’t copy this report. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    if (!(ref.watch(authNotifierProvider).value?.isDeptHead ?? false)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reports')),
        body: const FeatureState(
          icon: Icons.lock_outline_rounded,
          title: 'Church administration',
          message:
              'Ask your church administrator if you need access to reports.',
        ),
      );
    }
    final members = ref.watch(membersProvider);
    final finance = ref.watch(financialProvider);
    final attendance = ref.watch(attendanceProvider);
    final reports =
        <
          ({
            String title,
            String description,
            IconData icon,
            bool loading,
            List<List<Object?>> rows,
          })
        >[
          (
            title: 'Member directory',
            description: 'Names, email addresses, roles and departments.',
            icon: Icons.people_outline_rounded,
            loading: members.isLoading,
            rows: [
              ['Name', 'Email', 'Role', 'Department'],
              ...members.members.map(
                (member) => <Object?>[
                  member.name,
                  member.email,
                  member.role,
                  member.department,
                ],
              ),
            ],
          ),
          (
            title: 'Financial ledger',
            description: 'Completed transactions visible to your account.',
            icon: Icons.account_balance_wallet_outlined,
            loading: finance.isLoading,
            rows: [
              [
                'Reference',
                'Date',
                'Type',
                'Fund',
                'Amount (GHC)',
                'Description',
                'Status',
              ],
              ...finance.transactions.map(
                (transaction) => <Object?>[
                  transaction.id,
                  transaction.date.toIso8601String(),
                  transaction.type,
                  transaction.category,
                  transaction.amount.toStringAsFixed(2),
                  transaction.description,
                  transaction.status,
                ],
              ),
            ],
          ),
          (
            title: 'Attendance',
            description:
                'Recorded services, dates, headcounts and departments.',
            icon: Icons.event_available_outlined,
            loading: attendance.isLoading,
            rows: [
              ['Service', 'Date', 'Headcount', 'Department'],
              ...attendance.records.map(
                (record) => <Object?>[
                  record.serviceName,
                  record.date.toIso8601String(),
                  record.count,
                  record.department,
                ],
              ),
            ],
          ),
        ];
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: RefreshIndicator(
              onRefresh: () => Future.wait([
                members.fetchMembers(),
                finance.fetchTransactions(),
                attendance.fetchAttendance(),
              ]),
              child: ListView(
                padding: const EdgeInsets.all(24),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Text(
                    'A clearer view of church life.',
                    style: theme.textTheme.displayMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Copy the currently loaded records as CSV for your spreadsheet. Pull down to refresh before preparing a report.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 28),
                  for (final report in reports)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Icon(
                              report.icon,
                              color: theme.colorScheme.primary,
                              size: 28,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              report.title,
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              report.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              report.loading
                                  ? 'Loading records…'
                                  : '${report.rows.length - 1} records loaded',
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 20),
                            OutlinedButton.icon(
                              onPressed:
                                  report.loading || report.rows.length <= 1
                                  ? null
                                  : () => _copy(
                                      context,
                                      report.title,
                                      report.rows,
                                    ),
                              icon: const Icon(Icons.copy_outlined, size: 18),
                              label: const Text('Copy as CSV'),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
