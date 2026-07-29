import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rtc_mobile/models/giving_transaction.dart';
import 'package:rtc_mobile/models/prayer_request.dart';
import 'package:rtc_mobile/models/member_application.dart';

void main() {
  group('GivingTransaction TDD Tests', () {
    test('fromMap parses String date correctly', () {
      final map = {
        'id': 'tx_101',
        'amount': 150.50,
        'type': 'contribution',
        'category': 'Tithe',
        'date': '2026-07-25T12:00:00.000Z',
        'description': 'Sunday Tithe',
        'status': 'completed',
      };

      final tx = GivingTransaction.fromMap(map);
      expect(tx.id, equals('tx_101'));
      expect(tx.amount, equals(150.50));
      expect(tx.category, equals('Tithe'));
      expect(tx.date, equals(DateTime.parse('2026-07-25T12:00:00.000Z')));
    });

    test('fromMap handles Timestamp object for date without throwing Exception', () {
      final now = DateTime.now();
      final map = {
        'id': 'tx_102',
        'amount': 50.0,
        'type': 'expense',
        'date': Timestamp.fromDate(now),
        'description': 'Utilities',
      };

      final tx = GivingTransaction.fromMap(map);
      expect(tx.id, equals('tx_102'));
      expect(tx.amount, equals(50.0));
      expect(tx.date.millisecondsSinceEpoch ~/ 1000, equals(now.millisecondsSinceEpoch ~/ 1000));
    });

    test('fromMap handles DateTime object for date without throwing Exception', () {
      final now = DateTime.now();
      final map = {
        'id': 'tx_103',
        'amount': 75.0,
        'type': 'contribution',
        'date': now,
      };

      final tx = GivingTransaction.fromMap(map);
      expect(tx.id, equals('tx_103'));
      expect(tx.date, equals(now));
    });

    test('fromMap handles missing date gracefully', () {
      final map = {
        'id': 'tx_104',
        'amount': 20.0,
      };

      final tx = GivingTransaction.fromMap(map);
      expect(tx.id, equals('tx_104'));
      expect(tx.date, isA<DateTime>());
    });
  });

  group('PrayerRequest TDD Tests', () {
    test('fromMap parses String created_at correctly', () {
      final map = {
        'id': 'pr_1',
        'request': 'Healing for family',
        'status': 'pending',
        'created_at': '2026-07-25T10:00:00.000Z',
      };

      final pr = PrayerRequest.fromMap(map);
      expect(pr.id, equals('pr_1'));
      expect(pr.request, equals('Healing for family'));
      expect(pr.createdAt, equals(DateTime.parse('2026-07-25T10:00:00.000Z')));
    });

    test('fromMap handles Timestamp object for created_at without throwing Exception', () {
      final now = DateTime.now();
      final map = {
        'id': 'pr_2',
        'request': 'Safe travel',
        'created_at': Timestamp.fromDate(now),
      };

      final pr = PrayerRequest.fromMap(map);
      expect(pr.id, equals('pr_2'));
      expect(pr.createdAt.millisecondsSinceEpoch ~/ 1000, equals(now.millisecondsSinceEpoch ~/ 1000));
    });
  });

  group('MemberApplication TDD Tests', () {
    test('fromMap and toMap round-trip preserves all fields', () {
      final app = MemberApplication(
        fullName: 'John Doe',
        email: 'john@example.com',
        phone: '1234567890',
        selectedMinistries: ['Ushering', 'Choir'],
        progress: 0.75,
      );

      final map = app.toMap();
      final recreated = MemberApplication.fromMap(map);

      expect(recreated.fullName, equals('John Doe'));
      expect(recreated.email, equals('john@example.com'));
      expect(recreated.selectedMinistries, containsAll(['Ushering', 'Choir']));
      expect(recreated.progress, equals(0.75));
    });
  });
}
