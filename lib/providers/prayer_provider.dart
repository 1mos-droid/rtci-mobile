import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rtc_mobile/models/prayer_request.dart';

class PrayerProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<PrayerRequest> _prayers = [];
  bool _isLoading = false;

  List<PrayerRequest> get prayers => _prayers;
  bool get isLoading => _isLoading;

  PrayerProvider() {
    _init();
  }

  void _init() {
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        fetchPrayers();
      } else {
        _prayers = [];
        notifyListeners();
      }
    });
  }

  Future<void> fetchPrayers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('prayer_requests')
          .select('*, members(name)')
          .order('created_at', ascending: false);

      _prayers = (response as List).map((m) => PrayerRequest.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error fetching prayers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitPrayer(String request, bool isPrivate, String? memberId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabase.from('prayer_requests').insert({
        'request': request,
        'is_private': isPrivate,
        'member_id': memberId,
        'status': 'pending',
      });
      
      await fetchPrayers();
      return true;
    } catch (e) {
      debugPrint('Error submitting prayer: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await _supabase
          .from('prayer_requests')
          .update({'status': status})
          .eq('id', id);
      
      final index = _prayers.indexWhere((p) => p.id == id);
      if (index != -1) {
        _prayers[index] = _prayers[index].copyWith(status: status);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating prayer status: $e');
    }
  }
}
