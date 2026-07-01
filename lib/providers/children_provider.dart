import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChildCheckIn {
  final String id;
  final String childName;
  final String? parentName;
  final String? parentPhone;
  final String guardianId;
  final DateTime checkInTime;
  final String status;
  final String? tagNumber;

  ChildCheckIn({
    required this.id, 
    required this.childName, 
    required this.guardianId, 
    required this.checkInTime, 
    required this.status,
    this.parentName,
    this.parentPhone,
    this.tagNumber,
  });

  factory ChildCheckIn.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChildCheckIn(
      id: doc.id,
      childName: data['child_name'] ?? '',
      parentName: data['parent_name'],
      parentPhone: data['parent_phone'],
      guardianId: data['guardian_id'] ?? '',
      checkInTime: (data['check_in_time'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'checked_in',
      tagNumber: data['tag_number'] ?? doc.id.substring(0, 4).toUpperCase(),
    );
  }
}

class ChildrenProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<ChildCheckIn> _activeCheckIns = [];
  bool _isLoading = false;

  List<ChildCheckIn> get activeCheckIns => _activeCheckIns;
  List<ChildCheckIn> get checkins => _activeCheckIns; // Support getter name mismatch
  bool get isLoading => _isLoading;

  ChildrenProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        fetchActiveCheckIns();
      } else {
        _activeCheckIns = [];
        notifyListeners();
      }
    });
  }

  Future<void> fetchActiveCheckIns() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('child_checkins')
          .order('checked_in_at', ascending: false);

      _checkins = (response as List).map((m) => ChildCheckin.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error fetching checkins: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkIn({
    required String childName,
    required String parentName,
    required String parentPhone,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final tag = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
      await _supabase.from('child_checkins').insert({
        'child_name': childName,
        'parent_name': parentName,
        'parent_phone': parentPhone,
        'tag_number': tag,
        'status': 'checked_in',
      });
      
      await fetchCheckins();
      return true;
    } catch (e) {
      debugPrint('Error checking in: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> checkOut(String id) async {
    try {
      await _supabase
          .from('child_checkins')
          .update({'status': 'checked_out', 'checked_out_at': DateTime.now().toIso8601String()})
          .eq('id', id);
      
      _checkins.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking out: $e');
    }
  }
}
