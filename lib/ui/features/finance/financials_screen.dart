import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:rtc_mobile/providers/riverpod_providers.dart';
import 'package:rtc_mobile/widgets/skeleton_loader.dart';

class FinancialsScreen extends ConsumerWidget {
  const FinancialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financialProvider);
    final transactions = finance.transactions;

    return Scaffold(
      backgroundColor: ObsidianTheme.backgroundDark,
      floatingActionButton: FloatingActionButton(
        backgroundColor: ObsidianTheme.primaryCrimson,
        onPressed: () => _showAddTransactionSheet(context, ref),
        child: const Icon(Icons.add, color: Colors.white),
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
                  "Financial Ledger",
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
                child: Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.trending_up, color: Colors.greenAccent, size: 20),
                            const SizedBox(height: 8),
                            Text("Revenue", style: Theme.of(context).textTheme.labelLarge?.copyWith(color: ObsidianTheme.textMuted, fontSize: 10)),
                            Text("GHC ${finance.totalRevenue.toStringAsFixed(0)}", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.trending_down, color: Colors.redAccent, size: 20),
                            const SizedBox(height: 8),
                            Text("Expenses", style: Theme.of(context).textTheme.labelLarge?.copyWith(color: ObsidianTheme.textMuted, fontSize: 10)),
                            Text("GHC ${finance.totalExpense.toStringAsFixed(0)}", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              sliver: finance.isLoading && transactions.isEmpty
                ? SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const Padding(
                : transactions.isEmpty
                  ? SliverFillRemaining(child: Center(child: Text("No records logged.", style: TextStyle(color: ObsidianTheme.textVibrant))))
                  : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tx = transactions[index];
                    final bool isRevenue = tx.type == 'contribution';
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
                                    tx.description, 
                                    style: TextStyle(color: ObsidianTheme.textVibrant, fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    DateFormat('MMM dd, yyyy').format(tx.date), 
                                    style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "${isRevenue ? '+' : '-'} GHC ${tx.amount.toStringAsFixed(0)}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isRevenue ? Colors.greenAccent : Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: transactions.length,
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