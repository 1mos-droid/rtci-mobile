import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rtc_mobile/models/giving_transaction.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';

class FinancialProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Ref _ref;
  bool _disposed = false;
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  List<GivingTransaction> _transactions = [];
  bool _isLoading = false;

  // Only expose completed transactions in history and ledger summary
  List<GivingTransaction> get transactions {
    final user = _ref.read(authNotifierProvider).value;
    if (user == null) return [];

    final completed = _transactions
        .where((t) => t.status == 'completed')
        .toList();

    // Admins and developers see all completed transactions
    if (user.isAdmin) {
      return completed;
    }

    // Normal members and dept heads see their own contributions OR shared admin expenses
    return completed.where((t) {
      final isOwn = t.memberId == user.id;
      final isShared = t.isShared;
      return isOwn || isShared;
    }).toList();
  }

  bool get isLoading => _isLoading;

  double get totalRevenue => transactions
      .where((t) => t.type == 'contribution' && t.status == 'completed')
      .fold(0.0, (acc, item) => acc + item.amount);

  double get totalExpense => transactions
      .where((t) => t.type == 'expense' && t.status == 'completed')
      .fold(0.0, (acc, item) => acc + item.amount);

  FinancialProvider(this._ref) {
    _init();
  }

  void _init() {
    // Initial fetch if user already logged in
    final initialUser = _ref.read(authNotifierProvider).value;
    if (initialUser != null) {
      fetchTransactions();
    }

    // Listen for auth notifier changes (e.g. logging in as a different account)
    _ref.listen<AsyncValue>(authNotifierProvider, (previous, next) {
      final user = next.value;
      if (user != null) {
        fetchTransactions();
      } else {
        _transactions = [];
        notifyListeners();
      }
    });
  }

  Future<void> fetchTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _ref.read(authNotifierProvider).value;
      if (user == null) {
        _transactions = [];
        return;
      }
      final collection = _firestore.collection('transactions');
      final List<QuerySnapshot<Map<String, dynamic>>> snapshots;
      if (user.isAdmin) {
        snapshots = [
          await collection.get(const GetOptions(source: Source.server)),
        ];
      } else {
        snapshots = await Future.wait([
          collection
              .where('member_id', isEqualTo: user.id)
              .get(const GetOptions(source: Source.server)),
          collection
              .where('is_shared', isEqualTo: true)
              .get(const GetOptions(source: Source.server)),
        ]);
      }
      if (_disposed || _auth.currentUser?.uid != user.id) return;
      final byId = {
        for (final snapshot in snapshots)
          for (final doc in snapshot.docs)
            doc.id: GivingTransaction.fromFirestore(doc),
      };
      _transactions = byId.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> processGiving({
    required double amount,
    required String type,
    required String category,
    String? description,
    String? memberId,
    String? campus,
    String status = 'completed',
  }) async {
    final user = _ref.read(authNotifierProvider).value;
    if (user?.isAdmin != true ||
        !amount.isFinite ||
        amount < 0.01 ||
        amount > 1000000 ||
        status != 'completed' ||
        !['contribution', 'expense'].contains(type)) {
      return null;
    }
    _isLoading = true;
    notifyListeners();

    try {
      final docRef = await _firestore.collection('transactions').add({
        'amount': (amount * 100).round() / 100,
        'type': type,
        'category': category,
        'description': description ?? '',
        'member_id': memberId ?? _auth.currentUser?.uid,
        'campus': campus ?? 'Main',
        'date': FieldValue.serverTimestamp(),
        'logged_by': _auth.currentUser?.uid,
        'status': status,
        'source': 'manual',
        'amount_subunit': (amount * 100).round(),
        'currency': 'GHS',
      });
      await fetchTransactions();
      return docRef.id;
    } catch (e) {
      debugPrint('Error processing giving: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> recordTransaction(
    double amount,
    String type,
    String contributor, {
    String? description,
    String? campus,
  }) async {
    final docId = await processGiving(
      amount: amount,
      type: type,
      category: contributor,
      description: description,
      campus: campus,
    );
    return docId != null;
  }
}
