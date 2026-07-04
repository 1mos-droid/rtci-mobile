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
  
  List<GivingTransaction> _transactions = [];
  bool _isLoading = false;

  // Only expose completed transactions in history and ledger summary
  List<GivingTransaction> get transactions {
    final user = _ref.read(authNotifierProvider).value;
    if (user == null) return [];

    final completed = _transactions.where((t) => t.status == 'completed').toList();

    // Admins and developers see all completed transactions
    if (user.isAdmin) {
      return completed;
    }

    // Normal members and dept heads see their own contributions OR shared admin expenses
    return completed.where((t) {
      final isOwn = t.memberId == user.id || t.memberId == user.email;
      final isShared = t.type == 'expense' || t.isShared;
      return isOwn || isShared;
    }).toList();
  }
  bool get isLoading => _isLoading;
  double get totalRevenue => _transactions.where((t) => t.type == 'contribution').fold(0, (sum, item) => sum + item.amount);
  double get totalExpense => _transactions.where((t) => t.type == 'expense').fold(0, (sum, item) => sum + item.amount);

  FinancialProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((user) {
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
      final snapshot = await _firestore
          .collection('transactions')
          .orderBy('date', descending: true)
          .get();
      _transactions = snapshot.docs.map((doc) => GivingTransaction.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> processGiving({
    required double amount,
    required String type,
    required String category,
    String? description,
    String? memberId,
    String? campus,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('transactions').add({
        'amount': amount,
        'type': type,
        'category': category,
        'description': description ?? '',
        'member_id': memberId ?? _auth.currentUser?.uid,
        'campus': campus ?? 'Main',
        'date': FieldValue.serverTimestamp(),
        'logged_by': _auth.currentUser?.uid,
      });
      await fetchTransactions();
      return true;
    } catch (e) {
      debugPrint('Error processing giving: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> recordTransaction(double amount, String type, String contributor, {String? description, String? campus}) async {
    return processGiving(amount: amount, type: type, category: contributor, description: description, campus: campus);
  }
}