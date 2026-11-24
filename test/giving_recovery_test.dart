import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:rtc_mobile/domain/auth/user_model.dart';
import 'package:rtc_mobile/providers/riverpod_providers.dart';
import 'package:rtc_mobile/ui/features/finance/giving_screen.dart';

class RecoveryAuth extends AuthNotifier {
  final String uid;
  RecoveryAuth(this.uid);
  @override
  AppUser? build() => AppUser(
    id: uid,
    name: 'Member',
    email: '$uid@example.com',
    role: UserRole.member,
  );
}

class RecoveryFinance extends Mock implements FinancialProvider {}

void main() {
  testWidgets(
    'Pending checkout survives restart and stays scoped to its account',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'rtci_pending_checkout_alice': jsonEncode({
          'key': 'idempotent_request_123',
          'amount': 50,
          'fund': 'Tithe',
          'reference': 'rtci-${'a' * 48}',
        }),
      });
      Future<void> open(String uid) async {
        final finance = RecoveryFinance();
        when(() => finance.isLoading).thenReturn(false);
        await tester.pumpWidget(
          ProviderScope(
            key: ValueKey(uid),
            overrides: [
              authNotifierProvider.overrideWith(() => RecoveryAuth(uid)),
              financialProvider.overrideWith((ref) => finance),
            ],
            child: const MaterialApp(home: GivingScreen()),
          ),
        );
        await tester.pumpAndSettle();
      }

      await open('alice');
      expect(find.text('Check payment status'), findsOneWidget);
      await open('bob');
      expect(find.text('Check payment status'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
