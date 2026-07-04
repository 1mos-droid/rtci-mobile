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
                        padding: EdgeInsets.only(bottom: 12.0),
                        child: GlassCard(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SkeletonContainer(width: 140, height: 16),
                                  SizedBox(height: 6),
                                  SkeletonContainer(width: 80, height: 11),
                                ],
                              ),
                              SkeletonContainer(width: 70, height: 16),
                            ],
                          ),
                        ),
                      ),
                      childCount: 4,
                    ),
                  )
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

  void _showAddTransactionSheet(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final descController = TextEditingController();
    
    String selectedType = 'contribution';
    String selectedCategory = 'Tithe';
    String selectedCampus = 'Main';
    
    final types = ['contribution', 'expense'];
    final categories = ['Tithe', 'Offering', 'Special Seeds', 'Building Fund', 'Administrative Expense', 'Welfare Support'];
    final campuses = ['Main', 'Adenta Branch', 'Virtual Sanctuary'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return GlassCard(
              borderRadius: 24,
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Log Transaction",
                          style: GoogleFonts.cinzel(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ObsidianTheme.textVibrant,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: ObsidianTheme.textVibrant),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Amount Field
                    TextFormField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: ObsidianTheme.textVibrant),
                      decoration: const InputDecoration(
                        labelText: "Amount (GHC)",
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Please enter amount";
                        if (double.tryParse(val) == null) return "Enter a valid number";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Transaction Type
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      dropdownColor: isDark ? const Color(0xFF1E202C) : Colors.white,
                      style: TextStyle(color: ObsidianTheme.textVibrant),
                      decoration: const InputDecoration(
                        labelText: "Transaction Type",
                        prefixIcon: Icon(Icons.swap_horiz),
                      ),
                      items: types.map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.toUpperCase()),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            selectedType = val;
                            // Automatically select sensible category
                            if (selectedType == 'expense') {
                              selectedCategory = 'Administrative Expense';
                            } else {
                              selectedCategory = 'Tithe';
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Category
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      dropdownColor: isDark ? const Color(0xFF1E202C) : Colors.white,
                      style: TextStyle(color: ObsidianTheme.textVibrant),
                      decoration: const InputDecoration(
                        labelText: "Category / Contributor",
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: categories.map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedCategory = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Campus
                    DropdownButtonFormField<String>(
                      value: selectedCampus,
                      dropdownColor: isDark ? const Color(0xFF1E202C) : Colors.white,
                      style: TextStyle(color: ObsidianTheme.textVibrant),
                      decoration: const InputDecoration(
                        labelText: "Campus",
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      items: campuses.map((cp) => DropdownMenuItem(
                        value: cp,
                        child: Text(cp),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedCampus = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Description
                    TextFormField(
                      controller: descController,
                      style: TextStyle(color: ObsidianTheme.textVibrant),
                      decoration: const InputDecoration(
                        labelText: "Description",
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                    ),
                    const SizedBox(height: 24),
}