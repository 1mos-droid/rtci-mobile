import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CareRecommendation {
  final String id;
  final String memberId;
  final String memberName;
  final String? department;
  final int absenceCount;
  final String status; // Pending, Contacted, Resolved, Ignored
  final String? pastoralNotes;

  CareRecommendation({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.absenceCount,
    required this.status,
    this.department,
    this.pastoralNotes,
  });

  factory CareRecommendation.fromMap(Map<String, dynamic> map) {
    return CareRecommendation(
      id: map['id']?.toString() ?? '',
      memberId: map['member_id']?.toString() ?? '',
      memberName: map['members'] != null ? map['members']['name'] : 'Unknown Disciple',
      department: map['members'] != null ? map['members']['department'] : null,
      absenceCount: map['absence_count'] ?? 0,
      status: map['status'] ?? 'Pending',
      pastoralNotes: map['pastoral_notes'],
    );
  }
}

class CareProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<CareRecommendation> _careQueue = [];
  bool _isLoading = false;

  List<CareRecommendation> get careQueue => _careQueue;
  bool get isLoading => _isLoading;

  CareProvider() {
    _init();
  }

  void _init() {
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        fetchCareQueue();
      } else {
        _careQueue = [];
        notifyListeners();
      }
    });
  }

  Future<void> fetchCareQueue() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('care_recommendations')
          .select('*, members(name, department)')
          .neq('status', 'Resolved')
          .neq('status', 'Ignored')
          .order('created_at', ascending: false);

      _careQueue = (response as List).map((m) => CareRecommendation.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error fetching care queue: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCareStatus(String id, String status, {String? notes}) async {
    try {
      await _supabase
          .from('care_recommendations')
          .update({
            'status': status,
            if (notes != null) 'pastoral_notes': notes,
          })
          .eq('id', id);
      
      _careQueue.removeWhere((item) => item.id == id && (status == 'Resolved' || status == 'Ignored'));
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating care status: $e');
    }
  }
}
