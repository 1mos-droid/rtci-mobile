import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rtc_mobile/models/giving_transaction.dart';

class FinancialProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<GivingTransaction> _transactions = [];
  bool _isLoading = false;

  List<GivingTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  double get totalRevenue => _transactions
      .where((t) => t.type == 'contribution')
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == 'expense')
      .fold(0.0, (sum, t) => sum + t.amount);

  FinancialProvider() {
    _init();
  }

  void _init() {
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
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
      final response = await _supabase
          .from('transactions')
          .select()
          .order('date', ascending: false);

      _transactions = (response as List).map((m) => GivingTransaction.fromMap(m)).toList();
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
    required String description,
    String? category,
    String? memberId,
    String? campus,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabase.from('transactions').insert({
        'amount': amount,
        'type': type,
        'description': description,
        'category': category,
        'member_id': memberId,
        'campus': campus,
        'date': DateTime.now().toIso8601String(),
      });
      
      await fetchTransactions();
      return true;
    } catch (e) {
      debugPrint('Error processing giving: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _supabase.from('transactions').delete().eq('id', id);
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
    }
  }
}
