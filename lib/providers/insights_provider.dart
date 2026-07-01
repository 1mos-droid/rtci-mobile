import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailyInsight {
  final String id;
  final String content;
  final String? reference;
  final String? author;
  final DateTime date;

  DailyInsight({required this.id, required this.content, this.reference, this.author, required this.date});

  factory DailyInsight.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyInsight(
      id: doc.id,
      content: data['content'] ?? '',
      reference: data['reference'],
      author: data['author'],
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class DailyInsightsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  DailyInsight? _currentInsight;
  bool _isLoading = false;

  DailyInsight? get currentInsight => _currentInsight;
  bool get isLoading => _isLoading;

  DailyInsightsProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        fetchLatestInsight();
      } else {
        _currentInsight = null;
        notifyListeners();
      }
    });
  }

  Future<void> fetchLatestInsight() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('insights')
          .from('daily_insights')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        _currentInsight = DailyInsight.fromMap(response);
      }
    } catch (e) {
      debugPrint('Error fetching insights: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
