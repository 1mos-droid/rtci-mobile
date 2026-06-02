import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:rtc_mobile/providers/financial_provider.dart';
import 'package:rtc_mobile/providers/auth_provider.dart';

class GivingScreen extends StatefulWidget {
  const GivingScreen({super.key});

  @override
  State<GivingScreen> createState() => _GivingScreenState();
}

class _GivingScreenState extends State<GivingScreen> {
  final _amountController = TextEditingController();
  String _selectedFund = 'Tithe';
  double? _customAmount;

  final List<String> _funds = ['Tithe', 'Offering', 'Building Fund', 'Missions', 'Welfare', 'Seed'];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _confirmPayment(BuildContext context) {
    final amt = _customAmount ?? double.tryParse(_amountController.text) ?? 0;
    if (amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid amount")));
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return GlassCard(
          borderRadius: 24,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Authorize Transaction",
                style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.bold, color: ObsidianTheme.textVibrant),
              ),
              const SizedBox(height: 12),
              Text(
                "Confirm GHC $amt for $_selectedFund",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ObsidianTheme.primaryCrimson,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final auth = Provider.of<AuthProvider>(context, listen: false);
                  final finance = Provider.of<FinancialProvider>(context, listen: false);
                  final success = await finance.processGiving(
                    amount: amt, 
                    type: 'contribution', 
                    description: 'Payment via Apple Pay for $_selectedFund',
                    category: _selectedFund,
                    memberId: auth.isAuthenticated ? auth.userEmail : null,
                    campus: 'Main',
                  );
                  if (success && mounted) {
                    _amountController.clear();
                    setState(() => _customAmount = null);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Giving processed!"), backgroundColor: Colors.green));
                  }
                },
                child: const Text("PAY NOW WITH APPLE PAY"),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final finance = Provider.of<FinancialProvider>(context);

    return MeshGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "Giving Terminal",
            style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: ObsidianTheme.textVibrant),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Statistics Card
              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      "TOTAL GIVEN",
                      style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: ObsidianTheme.textMuted, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "GHC ${finance.totalRevenue.toStringAsFixed(2)}",
                      style: GoogleFonts.plusJakartaSans(fontSize: 36, fontWeight: FontWeight.bold, color: ObsidianTheme.secondaryGold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text(
                "SELECT FUND",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: ObsidianTheme.textVibrant, letterSpacing: 1.0),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _funds.map((f) {
                  final isSelected = _selectedFund == f;
                  return ChoiceChip(
                    label: Text(f.toUpperCase()),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedFund = f);
                    },
                    selectedColor: ObsidianTheme.primaryCrimson.withOpacity(0.2),
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? ObsidianTheme.primaryCrimson : ObsidianTheme.textMuted,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              Text(
                "GIVING AMOUNT",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: ObsidianTheme.textVibrant, letterSpacing: 1.0),
              ),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [50, 100, 200, 500].map((val) {
                        return OutlinedButton(
                          onPressed: () => setState(() => _customAmount = val.toDouble()),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: _customAmount == val ? ObsidianTheme.primaryCrimson : ObsidianTheme.borderHairline),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: Text("$val"),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      onChanged: (v) => setState(() => _customAmount = null),
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        prefixText: "GHC ",
                        prefixStyle: const TextStyle(color: ObsidianTheme.textMuted),
                        hintText: "Other Amount",
                        hintStyle: TextStyle(color: ObsidianTheme.textMuted.withOpacity(0.4)),
                        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: ObsidianTheme.borderHairline)),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: ObsidianTheme.primaryCrimson)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: finance.isLoading ? null : () => _confirmPayment(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ObsidianTheme.secondaryGold,
                  foregroundColor: ObsidianTheme.backgroundDark,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: finance.isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text("Next: Payment", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
