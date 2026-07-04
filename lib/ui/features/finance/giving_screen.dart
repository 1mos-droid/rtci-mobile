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
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return GlassCard(
          borderRadius: 28,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_outlined, color: AppTheme.accentGold, size: 24),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Authorize Giving",
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ObsidianTheme.textVibrant,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "You are supporting our church with",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: ObsidianTheme.textMuted),
              ),
              const SizedBox(height: 8),
              Text(
                "GHC ${amt.toStringAsFixed(2)}",
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "allocated to $_selectedFund",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.accentGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 28),
              CustomPrimaryButton(
                text: "Confirm & Open Paystack",
                icon: Icons.payment_rounded,
                onPressed: () async {
                  Navigator.pop(ctx);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final user = ref.read(authNotifierProvider).value;
                  
                  final url = Uri.parse('https://paystack.shop/pay/gl0eh2twa-');
                  try {
                    final finance = ref.read(financialProvider);
                    final transactionId = await finance.processGiving(
                      amount: amt, 
                      type: 'contribution', 
                      description: 'Payment via Paystack for $_selectedFund',
                      category: _selectedFund,
                      memberId: user?.email,
                      campus: 'Main',
                      status: 'pending',
                    );

                    if (transactionId == null) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(content: Text("Failed to initialize transaction."))
                      );
                      return;
                    }

                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.inAppWebView,
                        webViewConfiguration: const WebViewConfiguration(
                          enableJavaScript: true,
                          enableDomStorage: true,
                        ),
                      );
                      
                      if (context.mounted) {
                        _showConfirmationDialog(context, transactionId, amt);
                      }
                    } else {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(content: Text("Could not launch Paystack payment link."))
                      );
                    }
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text("Error opening payment: $e"))
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: ObsidianTheme.textMuted,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context, String transactionId, double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogCtx) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF151B2C) : Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            "Confirm Payment Status",
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: ObsidianTheme.textVibrant,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Did you successfully complete your donation of GHC ${amount.toStringAsFixed(0)} on the Paystack checkout page?",
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: ObsidianTheme.textMuted,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actionsPadding: const EdgeInsets.only(bottom: 24, left: 16, right: 16, top: 12),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogCtx);
                final finance = ref.read(financialProvider);
                await finance.updateTransactionStatus(transactionId, 'failed');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Donation marked as failed or cancelled."),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Text(
                "No, Cancel",
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  color: ObsidianTheme.textMuted,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                elevation: 0,
              ),
              onPressed: () async {
                Navigator.pop(dialogCtx);
                final finance = ref.read(financialProvider);
                final success = await finance.updateTransactionStatus(transactionId, 'completed');
                if (success && context.mounted) {
                  _amountController.clear();
                  setState(() => _customAmount = null);
                  _showSuccessOverlay(context, amount);
                }
              },
              child: Text(
                "Yes, Completed",
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessOverlay(BuildContext context, double amount) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          child: GlassCard(
            borderRadius: 24,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_outline_rounded, size: 44, color: Colors.green),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 24),
                Text(
                  "Thank You!",
                  style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.bold, color: ObsidianTheme.textVibrant),
                ),
                const SizedBox(height: 8),
                Text(
                  "Your generous gift of GHC ${amount.toStringAsFixed(0)} has been processed.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: ObsidianTheme.textMuted, height: 1.4),
                ),
                const SizedBox(height: 24),
                CustomPrimaryButton(
                  text: "Done",
                  onPressed: () => Navigator.pop(ctx),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final finance = ref.watch(financialProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Giving Portal",
          style: GoogleFonts.cinzel(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: ObsidianTheme.textVibrant,
          ),
        ),
        centerTitle: true,
      ),
      body: MeshGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Text(
                  "SELECT GIVING CATEGORY",
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    color: ObsidianTheme.textMuted,
                    fontSize: 10,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: _funds.length,
                  itemBuilder: (context, index) {
                    final f = _funds[index];
                    final isSelected = _selectedFund == f;
                    return InkWell(
                      onTap: () => setState(() => _selectedFund = f),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? theme.colorScheme.primary.withOpacity(0.08) 
                              : (isDark ? const Color(0xFF1E293B) : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected 
                                ? theme.colorScheme.primary 
                                : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
                            width: isSelected ? 2.0 : 1.0,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          f.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? theme.colorScheme.primary : ObsidianTheme.textVibrant,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                Text(
                  "CHOOSE AMOUNT",
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    color: ObsidianTheme.textMuted,
                    fontSize: 10,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: _presetAmounts.length,
                  itemBuilder: (context, index) {
                    final val = _presetAmounts[index];
                    final isSelected = _customAmount == val.toDouble();
                    return DonationChip(
                      label: "GHC $val",
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _customAmount = val.toDouble();
                          _amountController.clear();
                        });
                      },
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Modern input box for custom amount
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "GHC",
                        style: GoogleFonts.plusJakartaSans(
                          color: ObsidianTheme.textVibrant,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
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