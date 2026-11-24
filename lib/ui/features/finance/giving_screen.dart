import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rtc_mobile/services/giving_service.dart';
import 'package:rtc_mobile/services/backend_client.dart';
import 'package:rtc_mobile/providers/riverpod_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/modern_widgets.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class GivingScreen extends ConsumerStatefulWidget {
  const GivingScreen({super.key});

  @override
  ConsumerState<GivingScreen> createState() => _GivingScreenState();
}

class _GivingScreenState extends ConsumerState<GivingScreen> {
  final _amountController = TextEditingController();
  String _selectedFund = 'Tithe';
  double? _customAmount;
  bool _openingCheckout = false;
  final _giving = const GivingService();
  String? _requestKey;
  String? _pendingReference;
  double? _pendingAmount;
  String? _pendingFund;
  String? _checkoutUid;

  @override
  void initState() {
    super.initState();
    _checkoutUid = ref.read(authNotifierProvider).value?.id;
    _restorePending();
  }

  Future<void> _restorePending() async {
    final uid = _checkoutUid;
    if (uid == null) return;
    try {
      final preferences = await SharedPreferences.getInstance();
      final stored = preferences.getString('rtci_pending_checkout_$uid');
      if (stored == null || !mounted || _openingCheckout) return;
      final data = jsonDecode(stored);
      if (data is! Map ||
          data['amount'] is! num ||
          data['fund'] is! String ||
          data['key'] is! String) {
        return;
      }
      final amount = (data['amount'] as num).toDouble();
      if (!amount.isFinite ||
          amount <= 0 ||
          !_funds.contains(data['fund']) ||
          !RegExp(r'^[a-zA-Z0-9_-]{16,80}$').hasMatch(data['key'])) {
        return;
      }
      final reference = data['reference'];
      if (reference != null &&
          (reference is! String ||
              !RegExp(r'^rtci-[a-f0-9]{48}$').hasMatch(reference))) {
        return;
      }
      setState(() {
        _requestKey = data['key'];
        _pendingAmount = amount;
        _pendingFund = data['fund'];
        _pendingReference = reference;
      });
    } catch (_) {
      /* An unavailable preference store must not prevent giving. */
    }
  }

  Future<void> _savePending({bool clear = false}) async {
    final uid = _checkoutUid;
    if (uid == null) return;
    try {
      final preferences = await SharedPreferences.getInstance();
      if (clear) {
        await preferences.remove('rtci_pending_checkout_$uid');
      } else {
        await preferences.setString(
          'rtci_pending_checkout_$uid',
          jsonEncode({
            'key': _requestKey,
            'amount': _pendingAmount,
            'fund': _pendingFund,
            'reference': _pendingReference,
          }),
        );
      }
    } catch (_) {
      /* The verified server ledger remains the source of truth. */
    }
  }

  final List<String> _funds = [
    'Tithe',
    'Offering',
    'Building Fund',
    'Missions',
    'Welfare',
    'Seed',
  ];
  final List<int> _presetAmounts = [50, 100, 200, 500];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _confirmPayment(BuildContext context) {
    if (_openingCheckout) return;
    final amt = _customAmount ?? double.tryParse(_amountController.text) ?? 0;
    if (!amt.isFinite || amt <= 0) {
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

        return SafeArea(
          child: SingleChildScrollView(
            child: GlassCard(
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
                      child: const Icon(
                        Icons.shield_outlined,
                        color: AppTheme.accentGold,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Review your giving",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "You are supporting our church with",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "GHC ${amt.toStringAsFixed(2)}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
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
                  const SizedBox(height: 16),
                  Text(
                    'Your selected amount and fund will be passed securely to Paystack.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  CustomPrimaryButton(
                    text: "Confirm & Open Paystack",
                    icon: Icons.payment_rounded,
                    onPressed: () {
                      Navigator.pop(ctx);
                      _openCheckout(amt, _selectedFund);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openCheckout(double amount, String fund) async {
    if (_openingCheckout) return;
    setState(() => _openingCheckout = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final user = ref.read(authNotifierProvider).value;
      if (user == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Please sign in before giving.')),
        );
        return;
      }
      if (_pendingAmount != amount || _pendingFund != fund) {
        _requestKey = null;
        _pendingReference = null;
      }
      _pendingAmount = amount;
      _pendingFund = fund;
      _requestKey ??= GivingService.newRequestKey();
      await _savePending();
      final checkout = await _giving.initialize(amount, fund, _requestKey!);
      _pendingReference = checkout.reference;
      await _savePending();
      if (!mounted) return;
      final transactionId = checkout.reference;
      final opened = await launchUrl(
        checkout.authorizationUrl,
        mode: LaunchMode.inAppBrowserView,
      );
      if (!mounted) return;
      if (opened) {
        _showConfirmationDialog(context, transactionId, amount);
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'We couldn’t open Paystack. No payment has been confirmed.',
            ),
          ),
        );
      }
    } on BackendException catch (error) {
      // No checkout URL was opened when initialization failed; a fresh attempt is safe.
      if (_pendingReference == null) {
        _requestKey = null;
        await _savePending(clear: true);
      }
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Checkout is unavailable. No payment has been confirmed. Please try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _openingCheckout = false);
    }
  }

  Future<void> _verifyPending() async {
    final reference = _pendingReference;
    if (reference == null || _openingCheckout) return;
    setState(() => _openingCheckout = true);
    try {
      final status = await _giving.verify(reference);
      if (!mounted) return;
      if (status == 'completed') {
        _requestKey = null;
        _pendingReference = null;
        await _savePending(clear: true);
        if (!mounted) return;
        await ref.read(financialProvider).fetchTransactions();
        if (!mounted) return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'completed'
                ? 'Your giving has been confirmed. Thank you.'
                : 'Payment has not been confirmed yet. You can check again shortly.',
          ),
        ),
      );
    } on BackendException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _openingCheckout = false);
    }
  }

  void _showConfirmationDialog(
    BuildContext context,
    String transactionId,
    double amount,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Check your giving status'),
        content: Text(
          'Your GHC ${amount.toStringAsFixed(2)} contribution is awaiting confirmation. '
          'Returning from checkout does not confirm payment. Please contact the church if you need help confirming your contribution. Reference: $transactionId',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _verifyPending();
            },
            child: const Text('Check payment status'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final finance = ref.watch(financialProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Giving')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Generosity makes\na difference.',
                    style: theme.textTheme.displayLarge?.copyWith(height: 1.2),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Support the work of our church and the people we serve.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Where would you like to give?',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _funds
                              .map(
                                (fund) => ChoiceChip(
                                  label: Text(fund),
                                  selected: _selectedFund == fund,
                                  onSelected: (_) =>
                                      setState(() => _selectedFund = fund),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Choose an amount',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _presetAmounts
                              .map(
                                (amount) => ChoiceChip(
                                  label: Text('GHC $amount'),
                                  selected: _customAmount == amount,
                                  onSelected: (_) => setState(() {
                                    _customAmount = amount.toDouble();
                                    _amountController.clear();
                                  }),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (_) =>
                              setState(() => _customAmount = null),
                          decoration: const InputDecoration(
                            labelText: 'Or enter your own amount',
                            prefixText: 'GHC ',
                          ),
                        ),
                        const SizedBox(height: 24),
                        CustomPrimaryButton(
                          text: 'Continue to checkout',
                          icon: Icons.arrow_forward_rounded,
                          isLoading: finance.isLoading || _openingCheckout,
                          onPressed: () => _confirmPayment(context),
                        ),
                        const SizedBox(height: 16),
                        if (_pendingReference != null)
                          TextButton(
                            onPressed: _openingCheckout ? null : _verifyPending,
                            child: const Text('Check payment status'),
                          ),
                        Text(
                          'You’ll continue to Paystack to complete your giving.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Thank you for being part of what God is doing in our community.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
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
