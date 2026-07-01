import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CareTicket {
  final String id;
  final String memberName;
  final String memberId;
  final int absenceCount;
  final String status;
  final DateTime lastChecked;

  CareTicket({
    required this.id,
    required this.memberName,
    required this.memberId,
    required this.absenceCount,
    required this.status,
    required this.lastChecked,
  });

  factory CareTicket.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CareTicket(
      id: doc.id,
      memberName: data['member_name'] ?? '',
      memberId: data['member_id'] ?? '',
      absenceCount: data['absence_count'] ?? 0,
      status: data['status'] ?? 'pending',
      lastChecked: (data['last_checked'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
