import 'package:rtc_mobile/providers/riverpod_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:rtc_mobile/widgets/modern_widgets.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GivingScreen extends ConsumerStatefulWidget {
  const GivingScreen({super.key});

  @override
  ConsumerState<GivingScreen> createState() => _GivingScreenState();
}

class _GivingScreenState extends ConsumerState<GivingScreen> {
  final _amountController = TextEditingController();
  String _selectedFund = 'Tithe';
  double? _customAmount;

  final List<String> _funds = ['Tithe', 'Offering', 'Building Fund', 'Missions', 'Welfare', 'Seed'];
  final List<int> _presetAmounts = [50, 100, 200, 500];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _confirmPayment(BuildContext context) {
    final amt = _customAmount ?? double.tryParse(_amountController.text) ?? 0;
    if (amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter a valid amount"),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return GlassCard(
          borderRadius: 24,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Authorize Giving",
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.bold, color: ObsidianTheme.textVibrant),
              ),
              const SizedBox(height: 16),
              Text(
                "You are giving",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: ObsidianTheme.textMuted),
              ),
              const SizedBox(height: 8),
              Text(
                "GHC $amt",
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 48, fontWeight: FontWeight.w800, color: ObsidianTheme.secondaryGold),
              ),
              const SizedBox(height: 8),
              Text(
                "to $_selectedFund",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: ObsidianTheme.textMuted),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ObsidianTheme.primaryCrimson,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final user = ref.read(authNotifierProvider).value;
                  final finance = ref.read(financialProvider);
                  final success = await finance.processGiving(
                    amount: amt, 
                    type: 'contribution', 
                    description: 'Payment via Apple Pay for $_selectedFund',
                    category: _selectedFund,
                    memberId: user?.email,
                    campus: 'Main',
                  );
                  if (success && mounted) {
                    _amountController.clear();
                    setState(() => _customAmount = null);
                    scaffoldMessenger.showSnackBar(const SnackBar(content: Text("Giving successfully processed!"), backgroundColor: Colors.green));
                  }
                },
                child: const Text("CONFIRM PAYMENT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text("CANCEL", style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 16, fontWeight: FontWeight.bold)),
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
    final finance = ref.watch(financialProvider);

    return MeshGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "Give",
            style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 24, color: ObsidianTheme.textVibrant),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "SELECT PURPOSE",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: ObsidianTheme.textMuted, letterSpacing: 1.5),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _funds.map((f) {
                  final isSelected = _selectedFund == f;
                  return InkWell(
                    onTap: () => setState(() => _selectedFund = f),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? ObsidianTheme.primaryCrimson.withValues(alpha: 0.2) : ObsidianTheme.surfaceDark.withValues(alpha: 0.5),
                        border: Border.all(color: isSelected ? ObsidianTheme.primaryCrimson : ObsidianTheme.borderHairline, width: isSelected ? 2 : 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        f.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? ObsidianTheme.textVibrant : ObsidianTheme.textMuted,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              Text(
                "CHOOSE AMOUNT",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: ObsidianTheme.textMuted, letterSpacing: 1.5),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.2,
                children: _presetAmounts.map((val) {
                  final isSelected = _customAmount == val.toDouble();
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _customAmount = val.toDouble();
                        _amountController.clear();
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? ObsidianTheme.secondaryGold.withValues(alpha: 0.15) : ObsidianTheme.surfaceDark.withValues(alpha: 0.5),
                        border: Border.all(color: isSelected ? ObsidianTheme.secondaryGold : ObsidianTheme.borderHairline, width: isSelected ? 2 : 1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          "GHC $val",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? ObsidianTheme.secondaryGold : ObsidianTheme.textVibrant,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 16),
              
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) {
                    if (v.isNotEmpty && _customAmount != null) {
                      setState(() => _customAmount = null);
                    }
                  },
                  style: TextStyle(color: ObsidianTheme.textVibrant, fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixText: "GHC ",
                    prefixStyle: TextStyle(color: ObsidianTheme.textMuted, fontSize: 24, fontWeight: FontWeight.bold),
                    hintText: "Custom Amount",
                    hintStyle: TextStyle(color: ObsidianTheme.textMuted.withValues(alpha: 0.4), fontSize: 20),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              ElevatedButton(
                onPressed: finance.isLoading ? null : () => _confirmPayment(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ObsidianTheme.secondaryGold,
                  foregroundColor: ObsidianTheme.backgroundDark,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: finance.isLoading
                    ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, color: ObsidianTheme.backgroundDark))
                    : const Text("PROCEED TO PAYMENT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
              ),
              
              const SizedBox(height: 80), // Padding for BottomNav
            ],
          ),
        ),
      ),
    );
  }
}