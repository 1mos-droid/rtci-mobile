import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DailyInsight {
  final String id;
  final String content;
  final String? reference;
  final String? author;
  final String type; // verse, quote

  DailyInsight({
    required this.id,
    required this.content,
    required this.type,
    this.reference,
    this.author,
  });

  factory DailyInsight.fromMap(Map<String, dynamic> map) {
    return DailyInsight(
      id: map['id']?.toString() ?? '',
      content: map['content'] ?? '',
      type: map['type'] ?? 'verse',
      reference: map['reference'],
      author: map['author'],
    );
  }
}

class DailyInsightsProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  DailyInsight? _currentInsight;
  bool _isLoading = false;

  DailyInsight? get currentInsight => _currentInsight;
  bool get isLoading => _isLoading;

  DailyInsightsProvider() {
    _init();
  }

  void _init() {
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
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
      final response = await _supabase
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
